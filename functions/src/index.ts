import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { getFirestore } from "firebase-admin/firestore";

// Inicializar Firebase Admin
admin.initializeApp();

// Referencia a Firestore - Usar la base de datos nombrada "biosafe"
const db = getFirestore(admin.app(), "biosafe");

/**
 * Función que se ejecuta cuando se crea o actualiza un medicamento
 * Verifica si está próximo a vencer y envía notificación push
 */
export const onMedicineCreatedOrUpdated = functions
  .region("us-central1")
  .firestore.database("biosafe")
  .document("medicines/{medicineId}")
  .onWrite(async (change, context) => {
    const medicineData = change.after.exists ? change.after.data() : null;
    const previousData = change.before.exists ? change.before.data() : null;

    if (!medicineData) {
      // Medicamento eliminado, no hacer nada
      return null;
    }

    const medicineId = context.params.medicineId;
    const userId = medicineData.user_id;
    const expirationDate = medicineData.expiration_date?.toDate();
    const medicineName = medicineData.name || "Medicamento";

    if (!expirationDate || !userId) {
      return null;
    }

    // Calcular días hasta vencimiento
    const now = new Date();
    const daysUntilExpiration = Math.ceil(
      (expirationDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)
    );

    // Solo enviar notificación si:
    // 1. Es un nuevo medicamento (no existía antes)
    // 2. O la fecha de vencimiento cambió
    // 3. Y está próximo a vencer (dentro de 30 días)
    const shouldNotify =
      (!previousData ||
        previousData.expiration_date?.toDate()?.getTime() !==
          expirationDate.getTime()) &&
      daysUntilExpiration >= 0 &&
      daysUntilExpiration <= 30;

    if (!shouldNotify) {
      return null;
    }

    try {
      // Obtener token FCM del usuario
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        console.log(`Usuario ${userId} no encontrado`);
        return null;
      }

      const userData = userDoc.data();
      const fcmToken = userData?.fcm_token;

      if (!fcmToken) {
        console.log(`Usuario ${userId} no tiene token FCM`);
        return null;
      }

      // Preparar mensaje de notificación
      let title = "";
      let body = "";

      if (daysUntilExpiration === 0) {
        title = "⚠️ Medicamento Vencido";
        body = `${medicineName} ha vencido hoy. Por favor, revisa tu inventario.`;
      } else if (daysUntilExpiration <= 7) {
        title = "🔴 Alerta: Medicamento Próximo a Vencer";
        body = `${medicineName} vence en ${daysUntilExpiration} ${
          daysUntilExpiration === 1 ? "día" : "días"
        }.`;
      } else {
        title = "🟡 Recordatorio: Medicamento Próximo a Vencer";
        body = `${medicineName} vence en ${daysUntilExpiration} días.`;
      }

      // Enviar notificación push
      const message: admin.messaging.Message = {
        notification: {
          title: title,
          body: body,
        },
        data: {
          type: "expiration_alert",
          medicine_id: medicineId,
          medicine_name: medicineName,
          days_until_expiration: daysUntilExpiration.toString(),
        },
        token: fcmToken,
        android: {
          priority: "high",
          notification: {
            channelId: "biosafe_channel",
            sound: "default",
            priority: "high" as const,
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      const response = await admin.messaging().send(message);
      console.log(
        `Notificación de vencimiento enviada a ${userId}: ${response}`
      );

      // Crear registro en la colección de notificaciones
      await db.collection("notifications").add({
        user_id: userId,
        medicine_id: medicineId,
        time: admin.firestore.FieldValue.serverTimestamp(),
        message: body,
        status: "sent",
        type: "expiration_alert",
      });

      return null;
    } catch (error) {
      console.error("Error al enviar notificación de vencimiento:", error);
      return null;
    }
  });

/**
 * Función programada que verifica medicamentos próximos a vencer diariamente
 * Se ejecuta todos los días a las 9:00 AM (hora UTC)
 */
export const checkExpiringMedicines = functions
  .region("us-central1")
  .pubsub.schedule("0 9 * * *") // 9:00 AM UTC todos los días
  .timeZone("America/Mexico_City") // Ajustar según tu zona horaria
  .onRun(async (context) => {
    console.log("Ejecutando verificación diaria de medicamentos próximos a vencer");

    const now = new Date();
    const thirtyDaysFromNow = new Date();
    thirtyDaysFromNow.setDate(now.getDate() + 30);

    try {
      // Obtener todos los medicamentos que vencen en los próximos 30 días
      const medicinesSnapshot = await db
        .collection("medicines")
        .where("expiration_date", ">=", admin.firestore.Timestamp.fromDate(now))
        .where("expiration_date", "<=", admin.firestore.Timestamp.fromDate(thirtyDaysFromNow))
        .get();

      if (medicinesSnapshot.empty) {
        console.log("No hay medicamentos próximos a vencer");
        return null;
      }

      const notifications: Promise<void>[] = [];

      medicinesSnapshot.forEach((doc) => {
        const medicineData = doc.data();
        const userId = medicineData.user_id;
        const expirationDate = medicineData.expiration_date?.toDate();
        const medicineName = medicineData.name || "Medicamento";

        if (!expirationDate || !userId) {
          return;
        }

        const daysUntilExpiration = Math.ceil(
          (expirationDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)
        );

        // Solo notificar si vence en los próximos 7 días o hoy
        if (daysUntilExpiration > 7) {
          return;
        }

        notifications.push(
          sendExpirationNotification(
            userId,
            doc.id,
            medicineName,
            daysUntilExpiration
          )
        );
      });

      await Promise.all(notifications);
      console.log(`Verificación completada. ${notifications.length} notificaciones enviadas.`);

      return null;
    } catch (error) {
      console.error("Error en verificación diaria:", error);
      return null;
    }
  });

/**
 * Función auxiliar para enviar notificación de vencimiento
 */
async function sendExpirationNotification(
  userId: string,
  medicineId: string,
  medicineName: string,
  daysUntilExpiration: number
): Promise<void> {
  try {
    // Obtener token FCM del usuario
    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) {
      return;
    }

    const userData = userDoc.data();
    const fcmToken = userData?.fcm_token;

    if (!fcmToken) {
      return;
    }

    // Preparar mensaje
    let title = "";
    let body = "";

    if (daysUntilExpiration === 0) {
      title = "⚠️ Medicamento Vencido";
      body = `${medicineName} ha vencido hoy. Por favor, revisa tu inventario.`;
    } else if (daysUntilExpiration <= 7) {
      title = "🔴 Alerta: Medicamento Próximo a Vencer";
      body = `${medicineName} vence en ${daysUntilExpiration} ${
        daysUntilExpiration === 1 ? "día" : "días"
      }.`;
    } else {
      return; // No notificar si es más de 7 días
    }

    // Enviar notificación push
    const message: admin.messaging.Message = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        type: "expiration_alert",
        medicine_id: medicineId,
        medicine_name: medicineName,
        days_until_expiration: daysUntilExpiration.toString(),
      },
      token: fcmToken,
      android: {
        priority: "high",
        notification: {
          channelId: "biosafe_channel",
          sound: "default",
          priority: "high" as const,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    await admin.messaging().send(message);

    // Crear registro en la colección de notificaciones
    await db.collection("notifications").add({
      user_id: userId,
      medicine_id: medicineId,
      time: admin.firestore.FieldValue.serverTimestamp(),
      message: body,
      status: "sent",
      type: "expiration_alert",
    });
  } catch (error) {
    console.error(
      `Error al enviar notificación para medicamento ${medicineId}:`,
      error
    );
  }
}

/**
 * Función HTTP para enviar notificación de dosis manualmente
 * Puede ser llamada desde la app o desde otra función
 */
export const sendDosageReminder = functions
  .region("us-central1")
  .https.onCall(async (data, context) => {
    // Verificar autenticación
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "El usuario debe estar autenticado"
      );
    }

    const userId = context.auth.uid;
    const { medicineId, medicineName, dosageAmount } = data;

    if (!medicineId || !medicineName) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "medicineId y medicineName son requeridos"
      );
    }

    try {
      // Obtener token FCM del usuario
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "Usuario no encontrado"
        );
      }

      const userData = userDoc.data();
      const fcmToken = userData?.fcm_token;

      if (!fcmToken) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "El usuario no tiene token FCM registrado"
        );
      }

      // Preparar mensaje
      const title = "💊 Recordatorio: Es hora de tomar tu medicamento";
      const body = `Es hora de tomar: ${dosageAmount || "tu dosis"} de ${medicineName}`;

      // Enviar notificación push
      const message: admin.messaging.Message = {
        notification: {
          title: title,
          body: body,
        },
        data: {
          type: "dosage_reminder",
          medicine_id: medicineId,
          medicine_name: medicineName,
        },
        token: fcmToken,
        android: {
          priority: "high",
          notification: {
            channelId: "biosafe_channel",
            sound: "default",
            priority: "high" as const,
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      const response = await admin.messaging().send(message);

      // Crear registro en la colección de notificaciones
      await db.collection("notifications").add({
        user_id: userId,
        medicine_id: medicineId,
        time: admin.firestore.FieldValue.serverTimestamp(),
        message: body,
        status: "sent",
        type: "dosage_reminder",
      });

      return { success: true, messageId: response };
    } catch (error: any) {
      console.error("Error al enviar recordatorio de dosis:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Error al enviar notificación",
        error.message
      );
    }
  }
);

/**
 * Función que se ejecuta cuando se actualiza el token FCM de un usuario
 * Útil para debugging
 */
export const onFCMTokenUpdated = functions
  .region("us-central1")
  .firestore.database("biosafe")
  .document("users/{userId}")
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();

    const newToken = newData.fcm_token;
    const oldToken = oldData.fcm_token;

    if (newToken !== oldToken && newToken) {
      console.log(
        `Token FCM actualizado para usuario ${context.params.userId}`
      );
    }

    return null;
  });


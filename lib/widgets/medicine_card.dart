// BioSafe - archivo generado con IA asistida - revisión: Pablo

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medicine_model.dart';
import '../utils/theme.dart';

/// Widget de tarjeta para mostrar un medicamento
class MedicineCard extends StatelessWidget {
  final MedicineModel medicine;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MedicineCard({
    super.key,
    required this.medicine,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isExpiringSoon = medicine.isExpiringSoon;
    final isExpired = medicine.isExpired;

    Color cardColor = BioSafeTheme.cardColor;
    Color borderColor = Colors.grey.shade300;
    String statusText = '';
    Color statusColor = BioSafeTheme.textSecondary;

    if (isExpired) {
      cardColor = BioSafeTheme.accentColor.withValues(alpha: 0.1);
      borderColor = BioSafeTheme.accentColor;
      statusText = 'VENCIDO';
      statusColor = BioSafeTheme.accentColor;
    } else if (isExpiringSoon) {
      cardColor = BioSafeTheme.warningColor.withValues(alpha: 0.1);
      borderColor = BioSafeTheme.warningColor;
      statusText = 'Por vencer';
      statusColor = BioSafeTheme.warningColor;
    }

    return Card(
      color: cardColor,
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      medicine.name,
                      style: const TextStyle(
                        fontSize: BioSafeTheme.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                        color: BioSafeTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (statusText.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor, width: 1.5),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: BioSafeTheme.fontSizeSmall,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              if (medicine.description.isNotEmpty) ...[
                Text(
                  medicine.description,
                  style: const TextStyle(
                    fontSize: BioSafeTheme.fontSizeSmall,
                    color: BioSafeTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              if (medicine.dosage.isNotEmpty) ...[
                Text(
                  'Dosis: ${medicine.dosage}',
                  style: const TextStyle(
                    fontSize: BioSafeTheme.fontSizeSmall,
                    color: BioSafeTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              // Información de cantidad y fecha - Responsive
              Wrap(
                spacing: 16,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
              Row(
                    mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inventory_2, size: 20, color: BioSafeTheme.primaryColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Cantidad: ${medicine.remainingQuantity ?? medicine.totalQuantity}${medicine.type == MedicineType.liquido ? ' ml' : ''} / ${medicine.totalQuantity}${medicine.type == MedicineType.liquido ? ' ml' : ''}',
                    style: const TextStyle(
                      fontSize: BioSafeTheme.fontSizeSmall,
                      color: BioSafeTheme.textPrimary,
                    ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  const Icon(Icons.calendar_today, size: 20, color: BioSafeTheme.secondaryColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Vence: ${dateFormat.format(medicine.expirationDate)}',
                    style: const TextStyle(
                      fontSize: BioSafeTheme.fontSizeSmall,
                      color: BioSafeTheme.textPrimary,
                    ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (onDelete != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: BioSafeTheme.accentColor),
                    onPressed: onDelete,
                    tooltip: 'Eliminar medicamento',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

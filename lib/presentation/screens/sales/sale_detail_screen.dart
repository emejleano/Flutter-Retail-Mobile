import 'package:flutter/material.dart';
import '../../../data/models/sale_model.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/app_localizations.dart';

class SaleDetailScreen extends StatelessWidget {
  final Sale sale;

  const SaleDetailScreen({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);

    final productName = sale.product?.productName;
    final customerName = sale.customer?.customerName;
    final regionName = sale.region?.region;
    final orderDate = sale.orderDate?.fullDate;
    final formattedOrderDate = orderDate != null && orderDate.isNotEmpty
        ? DateFormatter.formatIsoString(orderDate)
        : null;

    String headerSubtitle() {
      final parts = <String>[];
      if (formattedOrderDate != null && formattedOrderDate.isNotEmpty) parts.add(formattedOrderDate);
      if (regionName != null && regionName.isNotEmpty) parts.add(regionName);
      return parts.join(' • ');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.saleDetails),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sale.orderId,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (headerSubtitle().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              headerSubtitle(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 10),
                          Text(
                            DateFormatter.formatCurrency(sale.sales),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.transactionDetails,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (productName != null && productName.isNotEmpty)
                      _InfoRow(label: l.productName, value: productName),
                    _InfoRow(label: l.productId, value: sale.productId),
                    if (customerName != null && customerName.isNotEmpty)
                      _InfoRow(label: l.customerName, value: customerName),
                    _InfoRow(label: l.customerId, value: sale.customerId),
                    if (sale.region != null)
                      _InfoRow(
                        label: l.region,
                        value: [
                          sale.region?.city,
                          sale.region?.state,
                          sale.region?.country,
                        ].whereType<String>().where((s) => s.isNotEmpty).join(', '),
                      ),
                    _InfoRow(label: '${l.region} ID', value: sale.regionId),
                    if (formattedOrderDate != null && formattedOrderDate.isNotEmpty)
                      _InfoRow(label: l.orderDate, value: formattedOrderDate),
                    const Divider(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _MetricChip(
                          icon: Icons.shopping_bag_outlined,
                          label: l.quantity,
                          value: sale.quantity.toString(),
                        ),
                        _MetricChip(
                          icon: Icons.discount_outlined,
                          label: l.discount,
                          value: DateFormatter.formatPercentage(sale.discount),
                        ),
                        _MetricChip(
                          icon: Icons.trending_up,
                          label: l.profit,
                          value: DateFormatter.formatCurrency(sale.profit),
                        ),
                      ],
                    ),
                    if (sale.createdAt != null) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        label: l.created,
                        value: DateFormatter.formatDateTime(sale.createdAt!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

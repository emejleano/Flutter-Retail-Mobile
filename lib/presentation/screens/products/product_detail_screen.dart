import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import '../../../data/models/product_model.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../core/utils/date_formatter.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final GlobalKey _shareBoundaryKey = GlobalKey();

  Future<void> _shareProduct() async {
    final l = AppLocalizations.of(context);
    final product = widget.product;

    final priceText = product.avgUnitPrice != null
        ? DateFormatter.formatCurrency(product.avgUnitPrice!)
        : '-';
    final stockText = product.stock.toString();

    final caption = '${product.productName}'
        '\n\n${l.category}: ${product.category}'
        '\n${l.subCategory}: ${product.subCategory}'
        '\n${l.price}: $priceText'
        '\n${l.stock}: $stockText'
        '\nID: ${product.productId}';

    // Web: sharing files/screenshots isn't consistently supported.
    // Use text sharing as a reliable fallback.
    if (kIsWeb) {
      await Share.share(caption, subject: product.productName);
      return;
    }

    try {
      // Give the UI a moment to fully paint before capturing.
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final boundaryContext = _shareBoundaryKey.currentContext;
      if (boundaryContext == null) {
        throw StateError('Share boundary is not ready');
      }

      final renderObject = boundaryContext.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        throw StateError('Share boundary render object not found');
      }

      final image = await renderObject.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Failed to encode screenshot');
      }

      final tempDir = await getTemporaryDirectory();
      final safeId = product.productId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final file = File('${tempDir.path}/product_$safeId.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: caption,
        subject: product.productName,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.operationFailed)),
      );
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Colors.blue;
      case 'furniture':
        return Colors.orange;
      case 'office supplies':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Icons.devices;
      case 'furniture':
        return Icons.chair;
      case 'office supplies':
        return Icons.edit_note;
      default:
        return Icons.inventory_2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final product = widget.product;
    final categoryColor = _getCategoryColor(product.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.productDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareProduct,
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _shareBoundaryKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Hero Card with Product Image/Icon
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    color: categoryColor.withValues(alpha: 0.15),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(product.category),
                        size: 80,
                        color: categoryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: categoryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.category,
                                style: TextStyle(
                                  color: categoryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.subCategory,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.productName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (product.avgUnitPrice != null)
                          Text(
                            DateFormatter.formatCurrency(product.avgUnitPrice!),
                            style: theme.textTheme.headlineMedium?.copyWith(
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
            
            const SizedBox(height: 16),
            
            // Product Barcode Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.qr_code, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          l.productBarcode,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          BarcodeWidget(
                            barcode: Barcode.code128(),
                            data: product.productId,
                            width: 250,
                            height: 80,
                            drawText: false,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.productId,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // QR Code
                          BarcodeWidget(
                            barcode: Barcode.qrCode(),
                            data: product.productId,
                            width: 120,
                            height: 120,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.scanQrCode,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
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
            
            // Product Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          l.productInformation,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.tag,
                      label: l.productId,
                      value: product.productId,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.category,
                      label: l.category,
                      value: product.category,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.label_outline,
                      label: l.subCategory,
                      value: product.subCategory,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.inventory_2_outlined,
                      label: l.stock,
                      value: product.stock.toString(),
                    ),
                    if (product.avgUnitPrice != null) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.attach_money,
                        label: l.avgUnitPrice,
                        value: DateFormatter.formatCurrency(product.avgUnitPrice!),
                      ),
                    ],
                    if (product.createdAt != null) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.calendar_today,
                        label: l.created,
                        value: DateFormatter.formatDateTime(product.createdAt!),
                      ),
                    ],
                    if (product.updatedAt != null) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.update,
                        label: l.lastUpdated,
                        value: DateFormatter.formatDateTime(product.updatedAt!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

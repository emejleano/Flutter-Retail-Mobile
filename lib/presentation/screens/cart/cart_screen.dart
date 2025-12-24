import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/region_provider.dart';
import '../../../providers/notification_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? _selectedRegionId;
  bool _cartLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegionProvider>().loadRegions();
      _loadCart();
    });
  }

  Future<void> _loadCart() async {
    if (!_cartLoaded) {
      await context.read<CartProvider>().loadCart();
      _cartLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        if (cart.orderSuccess) {
          return _buildOrderSuccessView(context, cart);
        }

        if (cart.isLoading && !_cartLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cart.isEmpty) {
          return _buildEmptyCart(context);
        }

        return Stack(
          children: [
            Column(
              children: [
                Expanded(child: _buildCartList(context, cart)),
                _buildCheckoutPanel(context, cart),
              ],
            ),
            if (cart.isSyncing)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            l.emptyCart,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l.addFromCatalog,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(BuildContext context, CartProvider cart) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return _buildCartItemCard(context, item, cart);
      },
    );
  }

  Widget _buildCartItemCard(BuildContext context, BackendCartItem item, CartProvider cart) {
    final theme = Theme.of(context);
    final productName = item.product?.productName ?? 'Product ${item.productId}';
    final category = item.product?.category ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getCategoryColor(category).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(category),
                color: _getCategoryColor(category),
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (category.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  // Show customer price (with 5% markup)
                  Text(
                    DateFormatter.formatCurrency(item.customerPrice),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Quantity Controls
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  iconSize: 20,
                  color: Colors.red,
                  onPressed: () => cart.removeFromCart(item.productId),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      iconSize: 24,
                      onPressed: () => cart.decrementQuantity(item.productId),
                    ),
                    Text(
                      '${item.quantity}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 24,
                      onPressed: () => cart.incrementQuantity(item.productId),
                    ),
                  ],
                ),
                Text(
                  DateFormatter.formatCurrency(item.subtotal),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutPanel(BuildContext context, CartProvider cart) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Region Selector
            Consumer<RegionProvider>(
              builder: (context, regionProvider, _) {
                final regions = regionProvider.regions;
                return DropdownButtonFormField<String>(
                  value: _selectedRegionId,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).selectRegion,
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  hint: Text(AppLocalizations.of(context).shippingAddress),
                  isExpanded: true,
                  items: regions.map((r) {
                    return DropdownMenuItem(
                      value: r.regionId,
                      child: Text(
                        '${r.city}, ${r.state}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedRegionId = value);
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            // Order Summary
            _buildSummaryRow(context, '${AppLocalizations.of(context).subtotal} (${cart.totalQuantity} ${AppLocalizations.of(context).items})', 
                DateFormatter.formatCurrency(cart.totalAmount)),
            if (cart.discountRate > 0) ...[
              const SizedBox(height: 8),
              _buildSummaryRow(
                context,
                '${AppLocalizations.of(context).discount} (${(cart.discountRate * 100).toStringAsFixed(0)}%)',
                '-${DateFormatter.formatCurrency(cart.discountAmount)}',
                isDiscount: true,
              ),
            ],
            const Divider(height: 24),
            _buildSummaryRow(
              context,
              AppLocalizations.of(context).total,
              DateFormatter.formatCurrency(cart.finalTotal),
              isTotal: true,
            ),
            const SizedBox(height: 16),
            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cart.isLoading || _selectedRegionId == null
                    ? null
                    : () => _processCheckout(context, cart),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: cart.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _selectedRegionId == null
                            ? AppLocalizations.of(context).selectRegion
                            : '${AppLocalizations.of(context).checkout} ${DateFormatter.formatCurrency(cart.finalTotal)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
              : theme.textTheme.bodyMedium,
        ),
        Text(
          value,
          style: isTotal
              ? theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  color: isDiscount ? Colors.green : null,
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }

  Future<void> _processCheckout(BuildContext context, CartProvider cart) async {
    final notificationProvider = context.read<NotificationProvider>();
    
    // Save total before clearing cart
    final orderTotal = cart.finalTotal;

    final success = await cart.submitOrder(
      regionId: _selectedRegionId!,
    );

    if (success && mounted) {
      // Add notification for customer
      notificationProvider.addOrderPlacedNotification(
        cart.lastOrderId ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        orderTotal,
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cart.error ?? 'Order failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildOrderSuccessView(BuildContext context, CartProvider cart) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.orderPlaced,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.orderSuccess,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    l.orderId,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cart.lastOrderId ?? '-',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                cart.resetOrderStatus();
              },
              icon: const Icon(Icons.shopping_bag),
              label: Text(l.continueShopping),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Colors.blue;
      case 'furniture':
        return Colors.brown;
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
        return Icons.inventory_2;
      default:
        return Icons.category;
    }
  }
}

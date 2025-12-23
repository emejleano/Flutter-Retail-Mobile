import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom;
import '../scanner/barcode_scanner_screen.dart';

/// Customer-facing product catalog (marketplace style)
class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Data loading is now handled by HomeScreen on tab selection
    // This ensures data is fetched when user navigates to this tab
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(context),
        _buildCategoryChips(context),
        Expanded(child: _buildProductGrid(context)),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l.searchProducts,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ProductProvider>().loadProducts(refresh: true, search: '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              onSubmitted: (value) {
                context.read<ProductProvider>().loadProducts(refresh: true, search: value);
              },
            ),
          ),
          const SizedBox(width: 8),
          // Scanner Button
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.qr_code_scanner,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              onPressed: () => _openScanner(context),
              tooltip: 'Scan Barcode/QR',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openScanner(BuildContext context) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    
    if (result != null && result.isNotEmpty && mounted) {
      _searchController.text = result;
      context.read<ProductProvider>().loadProducts(refresh: true, search: result);
      
      // Check if product exists and show add to cart option
      final provider = context.read<ProductProvider>();
      await Future.delayed(const Duration(milliseconds: 500)); // Wait for search to complete
      
      if (provider.products.isNotEmpty) {
        final product = provider.products.first;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ditemukan: ${product.productName}'),
              action: SnackBarAction(
                label: 'Tambah',
                onPressed: () async {
                  final success = await context.read<CartProvider>().addToCart(product);
                  if (!success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.read<CartProvider>().error ?? 'Gagal menambahkan'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Widget _buildCategoryChips(BuildContext context) {
    final categories = ['All', 'Technology', 'Furniture', 'Office Supplies'];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = (_selectedCategory == null && cat == 'All') ||
              _selectedCategory == cat;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedCategory = cat == 'All' ? null : cat;
                });
                context.read<ProductProvider>().loadProducts(
                      refresh: true,
                      category: _selectedCategory,
                    );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.products.isEmpty) {
          return const LoadingWidget(message: 'Memuat produk...');
        }

        if (provider.error != null && provider.products.isEmpty) {
          return custom.ErrorWidget(
            message: provider.error!,
            onRetry: () => provider.loadProducts(refresh: true),
          );
        }

        if (provider.products.isEmpty) {
          return const custom.ErrorWidget(
            message: 'Tidak ada produk ditemukan',
            icon: Icons.inventory_2_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadProducts(refresh: true),
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.products.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= provider.products.length) {
                return const Center(child: CircularProgressIndicator());
              }
              return _ProductCard(product: provider.products[index]);
            },
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showProductDetail(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Placeholder
            Container(
              height: 100,
              width: double.infinity,
              color: _getCategoryColor(product.category).withValues(alpha: 0.15),
              child: Center(
                child: Icon(
                  _getCategoryIcon(product.category),
                  size: 48,
                  color: _getCategoryColor(product.category),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(product.category).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 10,
                          color: _getCategoryColor(product.category),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Product Name
                    Text(
                      product.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // Price (with 5% markup for customer)
                    Text(
                      DateFormatter.formatCurrency((product.avgUnitPrice ?? 0) * 1.05),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Add to Cart Button
                    Consumer<CartProvider>(
                      builder: (context, cart, _) {
                        final inCart = cart.isInCart(product.productId);
                        final qty = cart.getQuantity(product.productId);
                        
                        if (inCart) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () => cart.decrementQuantity(product.productId),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.remove, size: 16, color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  '$qty',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              InkWell(
                                onTap: () => cart.incrementQuantity(product.productId),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.add, size: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        }
                        
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final success = await cart.addToCart(product);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success 
                                        ? '${product.productName} ditambahkan ke keranjang'
                                        : cart.error ?? 'Gagal menambahkan'),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: success ? null : Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.add_shopping_cart, size: 16),
                            label: const Text('Tambah'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetail(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Product Image
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _getCategoryColor(product.category).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(product.category),
                    size: 80,
                    color: _getCategoryColor(product.category),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Category
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(product.category).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${product.category} • ${product.subCategory}',
                  style: TextStyle(
                    color: _getCategoryColor(product.category),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Name
              Text(
                product.productName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // ID
              Text(
                'ID: ${product.productId}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 20),
              // Price (with 5% markup for customer)
              Row(
                children: [
                  Text(
                    'Harga:',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormatter.formatCurrency((product.avgUnitPrice ?? 0) * 1.05),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.category, 'Kategori', product.category),
                      const Divider(),
                      _buildInfoRow(Icons.label, 'Sub-Kategori', product.subCategory),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Add to Cart Button
              Consumer<CartProvider>(
                builder: (ctx2, cart, _) {
                  final inCart = cart.isInCart(product.productId);
                  final qty = cart.getQuantity(product.productId);
                  
                  return Column(
                    children: [
                      if (inCart)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () => cart.decrementQuantity(product.productId),
                              icon: const Icon(Icons.remove_circle),
                              color: theme.colorScheme.primary,
                              iconSize: 32,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$qty',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => cart.incrementQuantity(product.productId),
                              icon: const Icon(Icons.add_circle),
                              color: theme.colorScheme.primary,
                              iconSize: 32,
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (!inCart) {
                              await cart.addToCart(product);
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(inCart 
                                      ? 'Keranjang diperbarui' 
                                      : '${product.productName} ditambahkan ke keranjang'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          icon: Icon(inCart ? Icons.check : Icons.add_shopping_cart),
                          label: Text(inCart ? 'Selesai' : 'Tambah ke Keranjang'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
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
        return Icons.edit;
      default:
        return Icons.inventory_2;
    }
  }
}

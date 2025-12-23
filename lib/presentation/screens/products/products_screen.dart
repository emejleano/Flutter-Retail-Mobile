import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom;
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/dialogs.dart';
import '../scanner/barcode_scanner_screen.dart';
import 'product_form_screen.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isGridView = true;
  String? _selectedSubCategory;
  String _sortBy = 'name';
  bool _sortAscending = true;

  // Sub categories for each main category
  static const Map<String, List<String>> _subCategories = {
    'Furniture': ['Bookcases', 'Chairs', 'Furnishings', 'Tables'],
    'Office Supplies': ['Appliances', 'Art', 'Binders', 'Envelopes', 'Fasteners', 'Labels', 'Paper', 'Storage', 'Supplies'],
    'Technology': ['Accessories', 'Copiers', 'Machines', 'Phones'],
  };

  @override
  void initState() {
    super.initState();
    // Data loading is now handled by HomeScreen on tab selection
    // This ensures data is fetched when user navigates to this tab
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductProvider>().loadMore();
    }
  }

  Future<void> _scanBarcode() async {
    final l = AppLocalizations.of(context);
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );

    if (barcode != null && mounted) {
      final product = await context.read<ProductProvider>().searchByBarcode(barcode);
      if (product != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      } else if (mounted) {
        showSnackBar(context, message: l.productNotFound, isError: true);
      }
    }
  }

  void _showFilterBottomSheet() {
    final provider = context.read<ProductProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return DraggableScrollableSheet(
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
                  Text(
                    AppLocalizations.of(context).filterAndSort,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Category Section
                  Text(
                    AppLocalizations.of(context).category,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: Text(AppLocalizations.of(context).all),
                        selected: provider.selectedCategory == null,
                        onSelected: (_) {
                          setModalState(() {
                            _selectedSubCategory = null;
                          });
                          provider.loadProducts(refresh: true, category: '');
                        },
                      ),
                      ...AppConstants.productCategories.map((cat) => FilterChip(
                        label: Text(cat),
                        selected: provider.selectedCategory == cat,
                        onSelected: (_) {
                          setModalState(() {
                            _selectedSubCategory = null;
                          });
                          provider.loadProducts(refresh: true, category: cat);
                        },
                      )),
                    ],
                  ),
                  
                  // Sub Category Section (if category selected)
                  if (provider.selectedCategory != null && 
                      _subCategories.containsKey(provider.selectedCategory)) ...[
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context).subCategory,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: Text(AppLocalizations.of(context).all),
                          selected: _selectedSubCategory == null,
                          onSelected: (_) {
                            setModalState(() {
                              _selectedSubCategory = null;
                            });
                          },
                        ),
                        ..._subCategories[provider.selectedCategory]!.map((sub) => 
                          FilterChip(
                            label: Text(sub),
                            selected: _selectedSubCategory == sub,
                            onSelected: (_) {
                              setModalState(() {
                                _selectedSubCategory = sub;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Sort Section
                  Text(
                    AppLocalizations.of(context).sort,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(AppLocalizations.of(context).name),
                        selected: _sortBy == 'name',
                        onSelected: (_) {
                          setModalState(() => _sortBy = 'name');
                        },
                      ),
                      ChoiceChip(
                        label: Text(AppLocalizations.of(context).price),
                        selected: _sortBy == 'price',
                        onSelected: (_) {
                          setModalState(() => _sortBy = 'price');
                        },
                      ),
                      ChoiceChip(
                        label: Text(AppLocalizations.of(context).category),
                        selected: _sortBy == 'category',
                        onSelected: (_) {
                          setModalState(() => _sortBy = 'category');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('${AppLocalizations.of(context).order}: '),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                            const SizedBox(width: 4),
                            Text(_sortAscending ? AppLocalizations.of(context).ascending : AppLocalizations.of(context).descending),
                          ],
                        ),
                        selected: true,
                        onSelected: (_) {
                          setModalState(() => _sortAscending = !_sortAscending);
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(ctx);
                      },
                      child: Text(AppLocalizations.of(context).applyFilters),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedSubCategory = null;
                          _sortBy = 'name';
                          _sortAscending = true;
                        });
                        provider.loadProducts(refresh: true, category: '');
                      },
                      child: Text(AppLocalizations.of(context).resetAll),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Product> _getSortedProducts(List<Product> products) {
    var filtered = products.toList();
    
    // Filter by sub category
    if (_selectedSubCategory != null) {
      filtered = filtered.where((p) => 
        p.subCategory.toLowerCase() == _selectedSubCategory!.toLowerCase()
      ).toList();
    }
    
    // Sort
    filtered.sort((a, b) {
      int result;
      switch (_sortBy) {
        case 'price':
          result = (a.avgUnitPrice ?? 0).compareTo(b.avgUnitPrice ?? 0);
          break;
        case 'category':
          result = a.category.compareTo(b.category);
          break;
        case 'name':
        default:
          result = a.productName.compareTo(b.productName);
      }
      return _sortAscending ? result : -result;
    });
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Column(
      children: [
        // Search Bar & Actions
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).searchProducts,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<ProductProvider>().loadProducts(
                                    refresh: true,
                                    search: '',
                                  );
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      onSubmitted: (value) {
                        context.read<ProductProvider>().loadProducts(
                          refresh: true,
                          search: value,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Scan Button
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.qr_code_scanner,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      onPressed: _scanBarcode,
                      tooltip: AppLocalizations.of(context).scanBarcodeTooltip,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Action Row
              Row(
                children: [
                  // Filter Button
                  OutlinedButton.icon(
                    onPressed: _showFilterBottomSheet,
                    icon: const Icon(Icons.filter_list, size: 18),
                    label: Text(AppLocalizations.of(context).filter),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // View Toggle
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => setState(() => _isGridView = true),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _isGridView ? theme.colorScheme.primaryContainer : null,
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
                            ),
                            child: Icon(
                              Icons.grid_view,
                              size: 20,
                              color: _isGridView 
                                ? theme.colorScheme.onPrimaryContainer 
                                : theme.colorScheme.outline,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _isGridView = false),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: !_isGridView ? theme.colorScheme.primaryContainer : null,
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(7)),
                            ),
                            child: Icon(
                              Icons.view_list,
                              size: 20,
                              color: !_isGridView 
                                ? theme.colorScheme.onPrimaryContainer 
                                : theme.colorScheme.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Add Product Button (Admin only)
                  if (authProvider.isAdmin)
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProductFormScreen()),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(AppLocalizations.of(context).add),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // Category Quick Filter
        Consumer<ProductProvider>(
          builder: (context, provider, _) {
            return SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(AppLocalizations.of(context).all),
                      selected: provider.selectedCategory == null,
                      onSelected: (_) {
                        setState(() => _selectedSubCategory = null);
                        provider.loadProducts(refresh: true, category: '');
                      },
                    ),
                  ),
                  ...AppConstants.productCategories.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: provider.selectedCategory == cat,
                      onSelected: (_) {
                        setState(() => _selectedSubCategory = null);
                        provider.loadProducts(refresh: true, category: cat);
                      },
                    ),
                  )),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // Products Grid/List
        Expanded(
          child: Consumer<ProductProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.products.isEmpty) {
                return const LoadingWidget();
              }

              if (provider.error != null && provider.products.isEmpty) {
                return custom.ErrorWidget(
                  message: provider.error!,
                  onRetry: () => provider.loadProducts(refresh: true),
                );
              }

              if (provider.products.isEmpty) {
                return custom.ErrorWidget(
                  message: AppLocalizations.of(context).noProducts,
                  icon: Icons.inventory_2_outlined,
                );
              }

              final sortedProducts = _getSortedProducts(provider.products);

              if (sortedProducts.isEmpty) {
                return custom.ErrorWidget(
                  message: AppLocalizations.of(context).noProductsMatchFilter,
                  icon: Icons.filter_alt_off_outlined,
                  onRetry: () {
                    setState(() => _selectedSubCategory = null);
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: () => provider.loadProducts(refresh: true),
                child: _isGridView
                    ? _buildGridView(sortedProducts, provider.hasMore, authProvider.isAdmin)
                    : _buildListView(sortedProducts, provider.hasMore, authProvider.isAdmin),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGridView(List<Product> products, bool hasMore, bool isAdmin) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= products.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return _ProductGridCard(
          product: products[index],
          isAdmin: isAdmin,
          onEdit: () => _editProduct(products[index]),
          onDelete: () => _deleteProduct(products[index]),
        );
      },
    );
  }

  Widget _buildListView(List<Product> products, bool hasMore, bool isAdmin) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: products.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= products.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _ProductListCard(
          product: products[index],
          isAdmin: isAdmin,
          onEdit: () => _editProduct(products[index]),
          onDelete: () => _deleteProduct(products[index]),
        );
      },
    );
  }

  void _editProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(product: product),
      ),
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final l = AppLocalizations.of(context);
    final confirm = await showConfirmDialog(
      context,
      title: l.deleteProduct,
      message: '${l.deleteProductConfirm} "${product.productName}"?',
      isDanger: true,
      confirmText: l.delete,
    );
    if (confirm == true && mounted) {
      final success = await context
          .read<ProductProvider>()
          .deleteProduct(product.productId);
      if (mounted) {
        showSnackBar(
          context,
          message: success ? l.productDeleted : l.failedToDeleteProduct,
          isSuccess: success,
          isError: !success,
        );
      }
    }
  }
}

// Grid Card Widget
class _ProductGridCard extends StatelessWidget {
  final Product product;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductGridCard({
    required this.product,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

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
    final categoryColor = _getCategoryColor(product.category);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Placeholder with Icon
            Container(
              height: 90,
              width: double.infinity,
              color: categoryColor.withValues(alpha: 0.15),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _getCategoryIcon(product.category),
                      size: 40,
                      color: categoryColor,
                    ),
                  ),
                  if (isAdmin)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: PopupMenuButton<String>(
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.more_vert, size: 16),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') onEdit();
                          if (value == 'delete') onDelete();
                        },
                        itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(AppLocalizations.of(context).edit),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(AppLocalizations.of(context).delete),
                            ),
                        ],
                      ),
                    ),
                ],
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
                        color: categoryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 10,
                          color: categoryColor,
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
                    const SizedBox(height: 2),
                    // Sub Category
                    Text(
                      product.subCategory,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const Spacer(),
                    // Price
                    Text(
                      DateFormatter.formatCurrency(product.avgUnitPrice ?? 0),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppLocalizations.of(context).stock}: ${product.stock}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
}

// List Card Widget  
class _ProductListCard extends StatelessWidget {
  final Product product;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductListCard({
    required this.product,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

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
    final categoryColor = _getCategoryColor(product.category);

    return CustomCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(product.category),
              color: categoryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 10,
                          color: categoryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      product.subCategory,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.productName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatCurrency(product.avgUnitPrice ?? 0),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${AppLocalizations.of(context).stock}: ${product.stock}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isAdmin)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Text(AppLocalizations.of(context).edit),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(AppLocalizations.of(context).delete),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/sale_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/sale_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom;
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/dialogs.dart';
import 'sale_form_screen.dart';
import 'sale_detail_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  
  // Filter states
  DateTimeRange? _selectedDateRange;
  String _sortBy = 'date';
  bool _sortDescending = true;

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
      context.read<SaleProvider>().loadMore();
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      if (mounted) {
        context.read<SaleProvider>().loadSales(
          refresh: true,
          // API supports YYYYMMDD or YYYY-MM-DD
          startDate: DateFormatter.formatDateApi(picked.start),
          endDate: DateFormatter.formatDateApi(picked.end),
        );
      }
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                
                // Date Range
                Text(
                  AppLocalizations.of(context).dateRange,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _selectDateRange();
                  },
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _selectedDateRange != null
                        ? '${DateFormatter.formatDate(_selectedDateRange!.start)} - ${DateFormatter.formatDate(_selectedDateRange!.end)}'
                        : AppLocalizations.of(context).selectDateRange,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Sort By
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
                      label: Text(AppLocalizations.of(context).date),
                      selected: _sortBy == 'date',
                      onSelected: (_) => setModalState(() => _sortBy = 'date'),
                    ),
                    ChoiceChip(
                      label: Text(AppLocalizations.of(context).sales),
                      selected: _sortBy == 'sales',
                      onSelected: (_) => setModalState(() => _sortBy = 'sales'),
                    ),
                    ChoiceChip(
                      label: Text(AppLocalizations.of(context).profit),
                      selected: _sortBy == 'profit',
                      onSelected: (_) => setModalState(() => _sortBy = 'profit'),
                    ),
                    ChoiceChip(
                      label: Text(AppLocalizations.of(context).quantity),
                      selected: _sortBy == 'quantity',
                      onSelected: (_) => setModalState(() => _sortBy = 'quantity'),
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
                          Icon(_sortDescending ? Icons.arrow_downward : Icons.arrow_upward, size: 16),
                          const SizedBox(width: 4),
                          Text(_sortDescending ? AppLocalizations.of(context).descending : AppLocalizations.of(context).ascending),
                        ],
                      ),
                      selected: true,
                      onSelected: (_) {
                        setModalState(() => _sortDescending = !_sortDescending);
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      setState(() {});

                      final provider = context.read<SaleProvider>();
                      final range = _selectedDateRange;
                      
                      // Apply server-side sorting and date filter
                      provider.loadSales(
                        refresh: true,
                        startDate: range != null ? DateFormatter.formatDateApi(range.start) : null,
                        endDate: range != null ? DateFormatter.formatDateApi(range.end) : null,
                        sortBy: _mapSortByToApi(_sortBy),
                        sortDir: _sortDescending ? 'desc' : 'asc',
                      );
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
                        _selectedDateRange = null;
                        _sortBy = 'date';
                        _sortDescending = true;
                      });
                      setState(() {});
                      context.read<SaleProvider>().clearFilters();
                      Navigator.pop(ctx);
                    },
                    child: Text(AppLocalizations.of(context).resetAll),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Sale> _getSortedSales(List<Sale> sales) {
    // Server-side sorting is now used, just return as-is
    return sales;
  }

  // Map UI sort values to API sort_by values
  String _mapSortByToApi(String uiSortBy) {
    switch (uiSortBy) {
      case 'date':
        return 'date_id';
      case 'sales':
        return 'sales';
      case 'profit':
        return 'profit';
      case 'quantity':
        return 'quantity';
      default:
        return 'date_id';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);

    return Column(
      children: [
        // Header with search and actions
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.salesTransactions,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (authProvider.isAdmin)
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SaleFormScreen()),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l.newSale),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _showFilterBottomSheet,
                    icon: const Icon(Icons.filter_list, size: 18),
                    label: Text(l.filter),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  if (_selectedDateRange != null) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        '${DateFormatter.formatDate(_selectedDateRange!.start)} - ${DateFormatter.formatDate(_selectedDateRange!.end)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() => _selectedDateRange = null);
                        context.read<SaleProvider>().clearFilters();
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        
        // Summary Stats
        Consumer<SaleProvider>(
          builder: (context, provider, _) {
            if (provider.sales.isEmpty) return const SizedBox.shrink();
            
            final totalSales = provider.sales.fold<double>(0, (sum, s) => sum + s.sales);
            final totalProfit = provider.sales.fold<double>(0, (sum, s) => sum + s.profit);
            final totalQty = provider.sales.fold<int>(0, (sum, s) => sum + s.quantity);
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      icon: Icons.attach_money,
                      label: 'Sales',
                      value: DateFormatter.formatCurrency(totalSales),
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.trending_up,
                      label: 'Profit',
                      value: DateFormatter.formatCurrency(totalProfit),
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.inventory_2,
                      label: 'Items',
                      value: DateFormatter.formatNumber(totalQty.toDouble()),
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        
        const SizedBox(height: 12),
        
        // Sales List
        Expanded(child: _buildSalesList(context, authProvider)),
      ],
    );
  }

  Widget _buildSalesList(BuildContext context, AuthProvider authProvider) {
    final l = AppLocalizations.of(context);
    return Consumer<SaleProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.sales.isEmpty) {
          return LoadingWidget(message: l.loadingSales);
        }

        if (provider.error != null && provider.sales.isEmpty) {
          return custom.ErrorWidget(
            message: provider.error!,
            onRetry: () => provider.loadSales(refresh: true),
          );
        }

        if (provider.sales.isEmpty) {
          return custom.ErrorWidget(
            message: l.noSales,
            icon: Icons.point_of_sale_outlined,
          );
        }

        final sortedSales = _getSortedSales(provider.sales);

        return RefreshIndicator(
          onRefresh: () => provider.loadSales(refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: sortedSales.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= sortedSales.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final sale = sortedSales[index];
              return SaleCard(sale: sale, isAdmin: authProvider.isAdmin);
            },
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class SaleCard extends StatelessWidget {
  final Sale sale;
  final bool isAdmin;

  const SaleCard({super.key, required this.sale, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isProfitable = sale.profit >= 0;

    return CustomCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SaleDetailScreen(sale: sale)),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isProfitable 
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_long,
              color: isProfitable ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sale.orderId,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Qty: ${sale.quantity}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (sale.discount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${(sale.discount * 100).toStringAsFixed(0)}% off',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormatter.formatCurrency(sale.sales),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isProfitable ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: isProfitable ? Colors.green : Colors.red,
                  ),
                  Text(
                    DateFormatter.formatCurrency(sale.profit.abs()),
                    style: TextStyle(
                      fontSize: 12,
                      color: isProfitable ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isAdmin) _buildPopupMenu(context),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      onSelected: (value) => _handleMenuAction(context, value),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'edit', child: Text(l.edit)),
        PopupMenuItem(value: 'delete', child: Text(l.delete)),
      ],
    );
  }

  Future<void> _handleMenuAction(BuildContext context, String value) async {
    final l = AppLocalizations.of(context);
    if (value == 'edit') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => SaleFormScreen(sale: sale)));
    } else if (value == 'delete' && sale.factId != null) {
      final confirm = await showConfirmDialog(
        context,
        title: l.deleteSale,
        message: l.deleteSaleConfirm,
        isDanger: true,
        confirmText: l.delete,
      );
      if (confirm == true && context.mounted) {
        final success = await context.read<SaleProvider>().deleteSale(sale.factId!);
        if (context.mounted) {
          showSnackBar(
            context,
            message: success ? l.saleDeleted : l.failedToDeleteSale,
            isSuccess: success,
            isError: !success,
          );
        }
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom;
import '../../widgets/common/custom_card.dart';
import '../../widgets/charts/sales_line_chart.dart';
import '../../widgets/charts/category_pie_chart.dart';
import '../../widgets/charts/region_bar_chart.dart';
import '../../widgets/charts/profit_margin_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTimeRange? _dateRange;
  String? _category;
  String? _region;
  int? _trendDays;

  @override
  void initState() {
    super.initState();
    // Data loading is now handled by HomeScreen on tab selection
    // This ensures data is fetched when user navigates to this tab
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;
    
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final l = AppLocalizations.of(context);

        // Keep local filter UI state in sync with provider (e.g., after tab refetch)
        // without overriding user edits mid-session.
        _dateRange ??= _tryInitRangeFromProvider(provider.from, provider.to);
        _category ??= provider.category;
        _region ??= provider.region;
        _trendDays ??= provider.trendDays;
        
        if (provider.isLoading && !provider.hasData) {
          return LoadingWidget(message: l.loading);
        }

        if (provider.error != null && !provider.hasData) {
          return custom.ErrorWidget(
            message: provider.error == DashboardProvider.genericErrorKey
                ? l.errorLoading
                : provider.error!,
            onRetry: () => provider.loadDashboard(),
          );
        }

        final data = provider.dashboardData;
        if (data == null) {
          return custom.ErrorWidget(message: l.noData);
        }

        // Use daily trend only if it has at least 2 data points, else use monthly
        final useDailyTrend = data.dailySalesTrend.length >= 2;
        final trendSpots = useDailyTrend
            ? data.dailySalesTrend.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.sales);
              }).toList()
            : data.monthlySalesTrend.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.sales);
              }).toList();

        final trendLabels = useDailyTrend
            ? data.dailySalesTrend.map((e) => _formatDailyLabel(e.period)).toList()
            : data.monthlySalesTrend.map((e) => _formatMonthlyLabel(e.period)).toList();

        final trendTitle = useDailyTrend ? l.salesTrend : l.monthlySalesTrend;
        final trendSubtitle = useDailyTrend
            ? l.lastNDaysPerformance(_trendDays ?? provider.trendDays)
            : l.last12MonthsPerformance;

        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Message
                _buildWelcomeHeader(context, authProvider),

                const SizedBox(height: 16),

                _buildFilterCard(context, provider),
                
                const SizedBox(height: 16),
                
                // Summary Cards
                _buildSummaryCards(context, data),
                
                const SizedBox(height: 24),
                
                // Sales Trend Chart
                _buildChartCard(
                  context,
                  title: trendTitle,
                  subtitle: trendSubtitle,
                  child: SalesLineChart(
                    spots: trendSpots,
                    labels: trendLabels,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Sales by Category
                _buildChartCard(
                  context,
                  title: l.salesByCategory,
                  subtitle: l.distributionByCategory,
                  child: CategoryPieChart(data: data.salesByCategory),
                ),
                
                const SizedBox(height: 16),
                
                // Sales by Region (Admin only sees full details)
                _buildChartCard(
                  context,
                  title: l.salesByRegion,
                  subtitle: l.geographicDistribution,
                  child: RegionBarChart(data: data.salesByRegion),
                ),
                
                // Profit Margin - Admin only
                if (isAdmin) ...[
                  const SizedBox(height: 16),
                  _buildChartCard(
                    context,
                    title: l.profitMargin,
                    subtitle: l.profitabilityAnalysis,
                    child: ProfitMarginChart(data: data.profitMarginByCategory),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Top Products
                _buildTopProductsCard(context, data),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  DateTime? _tryParseYmd(String? ymd) {
    if (ymd == null) return null;
    final trimmed = ymd.trim();
    if (trimmed.isEmpty) return null;
    try {
      final parts = trimmed.split('-');
      if (parts.length != 3) return null;
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (year == null || month == null || day == null) return null;
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  DateTimeRange? _tryInitRangeFromProvider(String? from, String? to) {
    final start = _tryParseYmd(from);
    final end = _tryParseYmd(to);
    if (start == null && end == null) return null;
    return DateTimeRange(
      start: start ?? end!,
      end: end ?? start!,
    );
  }

  String _formatYmd(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatDailyLabel(String period) {
    // Expected: YYYY-MM-DD
    final parts = period.split('-');
    if (parts.length == 3) {
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (month != null && day != null && month >= 1 && month <= 12) {
        const months = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '$day ${months[month - 1]}';
      }
    }
    return period;
  }

  String _formatMonthlyLabel(String period) {
    // Expected: YYYY-MM
    final parts = period.split('-');
    if (parts.length >= 2) {
      final month = int.tryParse(parts[1]);
      if (month != null && month >= 1 && month <= 12) {
        const months = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return months[month - 1];
      }
    }
    return period;
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final initial = _dateRange ?? DateTimeRange(start: now, end: now);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: initial,
    );

    if (!mounted) return;
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  Widget _buildFilterCard(BuildContext context, DashboardProvider provider) {
    final l = AppLocalizations.of(context);

    final categoryOptions = <MapEntry<String, String?>>[
      MapEntry(l.all, null),
      MapEntry(l.technology, 'Technology'),
      MapEntry(l.furniture, 'Furniture'),
      MapEntry(l.officeSupplies, 'Office Supplies'),
    ];

    final regionOptions = <String?>[null, 'West', 'East', 'Central', 'South'];
    final trendDaysOptions = <int>[7, 14, 30, 90, 365];

    final rangeLabel = _dateRange == null
        ? l.selectDateRange
        : '${DateFormatter.formatDate(_dateRange!.start)} - ${DateFormatter.formatDate(_dateRange!.end)}';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with title and action buttons
            Row(
              children: [
                Icon(
                  Icons.filter_alt_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l.filterAndSort,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      TextButton(
                        onPressed: provider.isLoading
                            ? null
                            : () {
                                setState(() {
                                  _dateRange = null;
                                  _category = null;
                                  _region = null;
                                });
                                provider.resetFilters();
                                provider.loadDashboard(
                                  from: null,
                                  to: null,
                                  category: null,
                                  region: null,
                                );
                              },
                        child: Text(l.resetAll),
                      ),
                      FilledButton(
                        onPressed: provider.isLoading
                            ? null
                            : () {
                                provider.loadDashboard(
                                  from: _dateRange == null
                                      ? null
                                      : _formatYmd(_dateRange!.start),
                                  to: _dateRange == null
                                      ? null
                                      : _formatYmd(_dateRange!.end),
                                  category: _category,
                                  region: _region,
                                  trendDays: _trendDays,
                                );
                              },
                        child: Text(l.applyFilters),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: provider.isLoading ? null : () => _pickDateRange(context),
                  icon: const Icon(Icons.date_range_outlined, size: 18),
                  label: Text(
                    rangeLabel,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _CompactDropdown<int?>(
                  label: l.trendDays,
                  value: _trendDays,
                  items: trendDaysOptions
                      .map(
                        (d) => DropdownMenuItem<int?>(
                          value: d,
                          child: Text('$d'),
                        ),
                      )
                      .toList(),
                  onChanged: provider.isLoading
                      ? null
                      : (value) => setState(() => _trendDays = value ?? 7),
                ),
                _CompactDropdown<String?>(
                  label: l.category,
                  value: _category,
                  items: categoryOptions
                      .map(
                        (e) => DropdownMenuItem<String?>(
                          value: e.value,
                          child: Text(e.key),
                        ),
                      )
                      .toList(),
                  onChanged: provider.isLoading
                      ? null
                      : (value) => setState(() => _category = value),
                ),
                _CompactDropdown<String?>(
                  label: l.region,
                  value: _region,
                  items: regionOptions
                      .map(
                        (value) => DropdownMenuItem<String?>(
                          value: value,
                          child: Text(value ?? l.all),
                        ),
                      )
                      .toList(),
                  onChanged: provider.isLoading
                      ? null
                      : (value) => setState(() => _region = value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, AuthProvider authProvider) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final userName = authProvider.user?.name ?? 'User';
    final isAdmin = authProvider.isAdmin;
    
    return Card(
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
                isAdmin ? Icons.admin_panel_settings : Icons.person,
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
                    l.welcomeBackMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  Text(
                    userName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isAdmin 
                        ? Colors.orange.withValues(alpha: 0.15)
                        : Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isAdmin ? l.admin : l.customer,
                      style: TextStyle(
                        fontSize: 11,
                        color: isAdmin ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.waving_hand,
              color: Colors.amber,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, dynamic data) {
    final l = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        final isPhoneNarrow = constraints.maxWidth < 380;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: crossAxisCount == 2 && isPhoneNarrow ? 1.1 : 1.3,
          children: [
            StatCard(
              title: l.totalSales,
              value: DateFormatter.formatCurrency(data.totalSales),
              icon: Icons.attach_money,
              iconColor: Colors.green,
            ),
            StatCard(
              title: l.totalTransactions,
              value: DateFormatter.formatNumber(data.summaryInfo.totalTransactions.toDouble()),
              icon: Icons.receipt_long,
              iconColor: Colors.blue,
            ),
            StatCard(
              title: l.profit,
              value: DateFormatter.formatCurrency(data.totalProfit),
              icon: Icons.trending_up,
              iconColor: Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsCard(BuildContext context, dynamic data) {
    final l = AppLocalizations.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.topProducts,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.topProducts.length > 5 ? 5 : data.topProducts.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final product = data.topProducts[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    product.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: product.category.isNotEmpty 
                      ? Text(product.category) 
                      : null,
                  trailing: Text(
                    DateFormatter.formatCurrency(product.totalSales),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const _CompactDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 240),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

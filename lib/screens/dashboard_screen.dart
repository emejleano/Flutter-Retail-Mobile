import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../core/api_service.dart';
import '../models/dashboard_model.dart';
import 'product_list_screen.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardModel> _futureDashboard;

  @override
  void initState() {
    super.initState();
    _futureDashboard = ApiService.fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Products',
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductListScreen()));
            },
          ),
          IconButton(
            tooltip: 'Add Sale',
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: () async {
              final res = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
              if (res == true) {
                setState(() {
                  _futureDashboard = ApiService.fetchDashboard();
                });
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<DashboardModel>(
        future: _futureDashboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final dashboard = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _futureDashboard = ApiService.fetchDashboard();
              });
              await _futureDashboard;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top summary row
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 22,
                                  child: Icon(Icons.attach_money, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Total Sales', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    Text(currency.format(dashboard.totalSales), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 22,
                                  child: Icon(Icons.shopping_bag, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Transactions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    // Backend does not provide totalTransactions in the current model.
                                    // Use number of top products as a lightweight placeholder.
                                    Text('${dashboard.topProducts.length}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Sales by Category section
                  Text('Sales by Category', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          SizedBox(height: 220, child: _buildCategoryPieChart(dashboard.salesByCategory)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: dashboard.salesByCategory.map((e) => Chip(label: Text('${e.category} — ${NumberFormat.compact(locale: 'id').format(e.total)}'))).toList(),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Top products
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Top Products', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      TextButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductListScreen())), icon: const Icon(Icons.list), label: const Text('See all'))
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dashboard.topProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final p = dashboard.topProducts[index];
                        return SizedBox(
                          width: 220,
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.productName, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 8),
                                  Text('Sold: ${p.sold}', style: Theme.of(context).textTheme.bodySmall),
                                  const Spacer(),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      // `TopProduct` doesn't expose averagePrice in current model.
                                      // Show compact sold count instead.
                                      NumberFormat.compact(locale: 'id').format(p.sold),
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

  Widget _buildCategoryPieChart(List<CategorySales> data) {
    if (data.isEmpty) return const SizedBox(height: 160, child: Center(child: Text('No category data')));

    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.purple, Colors.brown];

    final sections = <PieChartSectionData>[];
    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      sections.add(PieChartSectionData(
        value: item.total,
        color: colors[i % colors.length],
        title: item.category,
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
      ));
    }

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 2,
          centerSpaceRadius: 24,
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

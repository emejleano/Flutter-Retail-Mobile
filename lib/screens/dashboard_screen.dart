import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../main.dart';
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
    final currency =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 2);

    return Scaffold(
    appBar: AppBar(
  title: const Text('Dashboard'),
  actions: [

    // 🌙 DARK MODE TOGGLE (TARUH DI SINI)
    IconButton(
      icon: const Icon(Icons.dark_mode),
      tooltip: 'Toggle Dark Mode',
      onPressed: () {
        MyApp.of(context).toggleTheme();
      },
    ),

    // 📦 PRODUCT LIST
    IconButton(
      icon: const Icon(Icons.list_alt),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProductListScreen()),
        );
      },
    ),

    // ➕ ADD TRANSACTION
    IconButton(
      icon: const Icon(Icons.add_shopping_cart),
      onPressed: () async {
        final res = await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        );
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= SUMMARY =================
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          icon: Icons.attach_money,
                          title: 'Total Sales',
                          value: currency.format(dashboard.totalSales),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          icon: Icons.shopping_cart,
                          title: 'Transactions',
                          value: dashboard.topProducts.length.toString(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ================= PIE CHART =================
                  Text(
                    'Sales by Category',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        height: 220,
                        child: _buildCategoryPieChart(
                            dashboard.salesByCategory),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= LINE CHART =================
                  Text(
                    'Sales Trend',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        height: 220,
                        child: _buildSalesTrendChart(
                            dashboard.salesByCategory),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= BAR CHART =================
                  Text(
                    'Top Products Chart',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        height: 220,
                        child: _buildTopProductBarChart(
                            dashboard.topProducts),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= TOP PRODUCT LIST =================
                  Text(
                    'Top Products',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dashboard.topProducts.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final p = dashboard.topProducts[index];
                        return SizedBox(
                          width: 220,
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.productName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Sold: ${p.sold}'),
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

  // ================= COMPONENTS =================

  Widget _summaryCard(
      {required IconData icon,
      required String title,
      required String value}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(List<CategorySales> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple
    ];

    return PieChart(
      PieChartData(
        sections: List.generate(
          data.length,
          (i) => PieChartSectionData(
            value: data[i].total,
            title: data[i].category,
            color: colors[i % colors.length],
            radius: 60,
            titleStyle:
                const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
        centerSpaceRadius: 30,
      ),
    );
  }

  Widget _buildSalesTrendChart(List<CategorySales> data) {
  if (data.isEmpty) {
    return const Center(child: Text('No trend data'));
  }

  final spots = List.generate(
    data.length,
    (i) => FlSpot(i.toDouble(), data[i].total),
  );

  double maxY =
      data.map((e) => e.total).reduce((a, b) => a > b ? a : b);

  return LineChart(
    LineChartData(
      minY: 0,
      maxY: maxY * 1.2,

      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: false),

      // 🔥 FIX ANGKA SAMPING
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY / 4, // ⬅️ kunci interval
            reservedSize: 42,
            getTitlesWidget: (value, meta) {
              return Text(
                '${(value / 1000).toStringAsFixed(0)}K',
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),

      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 3,
          dotData: FlDotData(show: true),
        ),
      ],
    ),
  );
}

Widget _buildTopProductBarChart(List<TopProduct> products) {
  if (products.isEmpty) {
    return const Center(child: Text('No product data'));
  }

  final top5 = products.take(5).toList();

  final maxY =
      top5.map((e) => e.sold).reduce((a, b) => a > b ? a : b) + 5;

  return BarChart(
    BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: false),

      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.black87,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${top5[groupIndex].productName}\nSold: ${rod.toY.toInt()}',
              const TextStyle(color: Colors.white, fontSize: 12),
            );
          },
        ),
      ),

      barGroups: List.generate(
        top5.length,
        (i) => BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: top5[i].sold,
              width: 18,
              borderRadius: BorderRadius.circular(6),
              color: Colors.blue,
            ),
          ],
        ),
      ),

      titlesData: FlTitlesData(
       leftTitles: AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    interval: maxY / 4,
    reservedSize: 42,
    getTitlesWidget: (value, meta) {
      return Text(
        '${(value / 1000).toStringAsFixed(0)}K',
        style: const TextStyle(fontSize: 10),
      );
    },
  ),
),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= top5.length) {
                return const SizedBox.shrink();
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8,
                child: Transform.rotate(
                  angle: -0.6, // miring biar ga numpuk
                  child: SizedBox(
                    width: 60,
                    child: Text(
                      top5[index].productName,
                      style: const TextStyle(fontSize: 9),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        topTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
    ),
  );
}
}
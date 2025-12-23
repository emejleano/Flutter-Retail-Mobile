class DashboardData {
  final SummaryInfo summaryInfo;
  final double totalSales;
  final double totalProfit;
  final double averageDiscount;
  final Map<String, double> salesByCategory;
  final Map<String, double> salesByRegion;
  final List<TopProduct> topProducts;
  final List<MonthlySalesTrend> monthlySalesTrend;
  final List<DailySalesTrend> dailySalesTrend;
  final RecentSummary? recentSummary;
  final Map<String, double> profitMarginByCategory;

  DashboardData({
    required this.summaryInfo,
    required this.totalSales,
    required this.totalProfit,
    required this.averageDiscount,
    required this.salesByCategory,
    required this.salesByRegion,
    required this.topProducts,
    required this.monthlySalesTrend,
    required this.dailySalesTrend,
    required this.recentSummary,
    required this.profitMarginByCategory,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      summaryInfo: SummaryInfo.fromJson(json),
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      totalProfit: (json['total_profit'] ?? 0).toDouble(),
      averageDiscount: (json['average_discount'] ?? 0).toDouble(),
      salesByCategory: _parseStringDoubleMap(json['sales_by_category']),
      salesByRegion: _parseStringDoubleMap(json['sales_by_region']),
      topProducts: (json['top_products'] as List<dynamic>?)
          ?.map((e) => TopProduct.fromJson(e))
          .toList() ?? [],
      monthlySalesTrend: (json['monthly_sales_trend'] as List<dynamic>?)
          ?.map((e) => MonthlySalesTrend.fromJson(e))
          .toList() ?? [],
      dailySalesTrend: (json['daily_sales_trend'] as List<dynamic>?)
          ?.map((e) => DailySalesTrend.fromJson(e))
          .toList() ?? [],
      recentSummary: json['recent_summary'] is Map<String, dynamic>
          ? RecentSummary.fromJson(json['recent_summary'] as Map<String, dynamic>)
          : null,
      profitMarginByCategory: _parseStringDoubleMap(json['profit_margin_by_category']),
    );
  }

  double get profitMargin => totalSales > 0 ? totalProfit / totalSales : 0;
}

Map<String, double> _parseStringDoubleMap(dynamic input) {
  if (input is Map) {
    return input.map<String, double>((key, value) {
      final k = key?.toString() ?? '';
      final v = (value ?? 0);
      if (v is num) return MapEntry(k, v.toDouble());
      return MapEntry(k, double.tryParse(v.toString()) ?? 0);
    });
  }

  // Tolerate alternative list format:
  // [{"region":"West","sales":123}, ...] or [{"name":"West","value":123}, ...]
  if (input is List) {
    final out = <String, double>{};
    for (final item in input) {
      if (item is! Map) continue;
      final key = (item['region'] ?? item['category'] ?? item['name'] ?? '').toString();
      final raw = item['sales'] ?? item['profit_margin'] ?? item['value'] ?? 0;
      final val = raw is num ? raw.toDouble() : (double.tryParse(raw.toString()) ?? 0);
      if (key.isNotEmpty) out[key] = val;
    }
    return out;
  }

  return const <String, double>{};
}

class SummaryInfo {
  final String generatedAt;
  final int totalTransactions;
  final int totalLineItems;

  SummaryInfo({
    required this.generatedAt,
    required this.totalTransactions,
    required this.totalLineItems,
  });

  factory SummaryInfo.fromJson(Map<String, dynamic> json) {
    // Support both formats: nested summary_info or direct total_transactions
    if (json.containsKey('summary_info')) {
      final summaryInfo = json['summary_info'] as Map<String, dynamic>? ?? {};
      return SummaryInfo(
        generatedAt: summaryInfo['generated_at'] ?? '',
        totalTransactions: summaryInfo['total_transactions'] ?? 0,
        totalLineItems: summaryInfo['total_line_items'] ?? 0,
      );
    }
    return SummaryInfo(
      generatedAt: json['generated_at'] ?? '',
      totalTransactions: json['total_transactions'] ?? 0,
      totalLineItems: json['total_line_items'] ?? 0,
    );
  }
}

class TopProduct {
  final String productId;
  final String productName;
  final String category;
  final double totalSales;

  TopProduct({
    required this.productId,
    required this.productName,
    required this.category,
    required this.totalSales,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: json['product_id'] ?? '',
      // Support both "product_name" and "Product Name" keys
      productName: json['product_name'] ?? json['Product Name'] ?? '',
      category: json['category'] ?? '',
      // Support both "total_sales" and "Sales" keys
      totalSales: (json['total_sales'] ?? json['Sales'] ?? 0).toDouble(),
    );
  }
}

class MonthlySalesTrend {
  final String period;
  final double sales;
  final double profit;
  final int transactions;

  MonthlySalesTrend({
    required this.period,
    required this.sales,
    required this.profit,
    required this.transactions,
  });

  factory MonthlySalesTrend.fromJson(Map<String, dynamic> json) {
    return MonthlySalesTrend(
      // Support both "period" and "month" keys
      period: json['period'] ?? json['month'] ?? '',
      // Support both "sales" and "Sales" keys
      sales: (json['sales'] ?? json['Sales'] ?? 0).toDouble(),
      profit: (json['profit'] ?? 0).toDouble(),
      transactions: json['transactions'] ?? 0,
    );
  }
}

class DailySalesTrend {
  final String period;
  final double sales;
  final double profit;
  final int transactions;

  DailySalesTrend({
    required this.period,
    required this.sales,
    required this.profit,
    required this.transactions,
  });

  factory DailySalesTrend.fromJson(Map<String, dynamic> json) {
    return DailySalesTrend(
      period: json['period'] ?? json['date'] ?? '',
      sales: (json['sales'] ?? 0).toDouble(),
      profit: (json['profit'] ?? 0).toDouble(),
      transactions: json['transactions'] ?? 0,
    );
  }
}

class RecentSummary {
  final int days;
  final String from;
  final String to;
  final int totalTransactions;
  final int totalLineItems;
  final double totalSales;
  final double totalProfit;

  RecentSummary({
    required this.days,
    required this.from,
    required this.to,
    required this.totalTransactions,
    required this.totalLineItems,
    required this.totalSales,
    required this.totalProfit,
  });

  factory RecentSummary.fromJson(Map<String, dynamic> json) {
    return RecentSummary(
      days: (json['days'] ?? 0) is num
          ? (json['days'] as num).toInt()
          : (int.tryParse(json['days']?.toString() ?? '') ?? 0),
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      totalTransactions: (json['total_transactions'] ?? 0) is num
          ? (json['total_transactions'] as num).toInt()
          : (int.tryParse(json['total_transactions']?.toString() ?? '') ?? 0),
      totalLineItems: (json['total_line_items'] ?? 0) is num
          ? (json['total_line_items'] as num).toInt()
          : (int.tryParse(json['total_line_items']?.toString() ?? '') ?? 0),
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      totalProfit: (json['total_profit'] ?? 0).toDouble(),
    );
  }
}

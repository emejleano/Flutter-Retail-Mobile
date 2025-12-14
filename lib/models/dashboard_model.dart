class CategorySales {
  final String category;
  final double total;

  CategorySales({required this.category, required this.total});

  factory CategorySales.fromJson(Map<String, dynamic> json) {
    double parseTotal(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '')) ?? 0.0;
      return 0.0;
    }

    return CategorySales(
      category: json['category'] ?? '',
      total: parseTotal(json['total']),
    );
  }
}

class TopProduct {
  final String productName;
  final double sold;

  TopProduct({required this.productName, required this.sold});

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    double parseSold(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '')) ?? 0.0;
      return 0.0;
    }

    // Accept both "product_name" + "sold" and backend "name" + "sales"
    final name = json['product_name'] ?? json['name'] ?? '';
    final soldVal = json['sold'] ?? json['sales'];
    return TopProduct(
      productName: name,
      sold: parseSold(soldVal),
    );
  }
}

class MonthlySales {
  final String month;
  final double sales;

  MonthlySales({required this.month, required this.sales});

  factory MonthlySales.fromJson(Map<String, dynamic> json) {
    double parseSales(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '')) ?? 0.0;
      return 0.0;
    }

    // Accept both 'month' and backend 'period'
    final monthLabel = json['month'] ?? json['period'] ?? '';
    return MonthlySales(
      month: monthLabel,
      sales: parseSales(json['sales']),
    );
  }
}

class DashboardModel {
  final double totalSales;
  final List<CategorySales> salesByCategory;
  final List<TopProduct> topProducts;
  final List<MonthlySales> monthlySalesTrend;

  DashboardModel({
    required this.totalSales,
    required this.salesByCategory,
    required this.topProducts,
    required this.monthlySalesTrend,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    double parseTotalSales(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '')) ?? 0.0;
      return 0.0;
    }

    final salesByCategoryRaw = json['sales_by_category'];
    final topProductsJson = json['top_products'] as List<dynamic>?;
    final monthlyJson = json['monthly_sales_trend'] as List<dynamic>?;

    // sales_by_category may be a list of objects or a map of key->value
    List<CategorySales> salesByCategory = [];
    if (salesByCategoryRaw is List) {
      salesByCategory = salesByCategoryRaw
        .map((e) => CategorySales.fromJson(e as Map<String, dynamic>))
        .toList();
    } else if (salesByCategoryRaw is Map) {
      salesByCategory = (salesByCategoryRaw as Map<String, dynamic>)
        .entries
        .map((e) => CategorySales(category: e.key, total: (e.value is num) ? (e.value as num).toDouble() : double.tryParse(e.value.toString().replaceAll(',', '')) ?? 0.0))
        .toList();
    }

    return DashboardModel(
      totalSales: parseTotalSales(json['total_sales']),
      salesByCategory: salesByCategory,
      topProducts: topProductsJson != null
        ? topProductsJson.map((e) => TopProduct.fromJson(e as Map<String, dynamic>)).toList()
        : [],
      monthlySalesTrend: monthlyJson != null
        ? monthlyJson.map((e) => MonthlySales.fromJson(e as Map<String, dynamic>)).toList()
        : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'total_sales': totalSales,
        'sales_by_category': salesByCategory.map((e) => {'category': e.category, 'total': e.total}).toList(),
        'top_products': topProducts.map((e) => {'product_name': e.productName, 'sold': e.sold}).toList(),
        'monthly_sales_trend': monthlySalesTrend.map((e) => {'month': e.month, 'sales': e.sales}).toList(),
      };
}

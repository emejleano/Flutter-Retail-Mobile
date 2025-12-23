import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/customer_provider.dart';
import '../../../providers/sale_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../products/products_screen.dart';
import '../products/product_catalog_screen.dart';
import '../customers/customers_screen.dart';
import '../sales/sales_screen.dart';
import '../orders/order_history_screen.dart';
import '../cart/cart_screen.dart';
import '../settings/settings_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index, bool isAdmin) {
    if (_currentIndex == index) return; // Don't reload if same tab
    setState(() => _currentIndex = index);
    
    // Always reload data when switching tabs to ensure fresh data
    if (isAdmin) {
      switch (index) {
        case 0: // Dashboard
          context.read<DashboardProvider>().loadDashboard();
          break;
        case 1: // Products
          context.read<ProductProvider>().loadProducts(refresh: true);
          break;
        case 2: // Customers
          context.read<CustomerProvider>().loadCustomers(refresh: true);
          break;
        case 3: // Sales
          context.read<SaleProvider>().loadSales(refresh: true);
          break;
      }
    } else {
      switch (index) {
        case 0: // Product Catalog
          context.read<ProductProvider>().loadProducts(refresh: true);
          break;
        case 1: // Cart
          context.read<CartProvider>().loadCart();
          break;
        case 2: // Orders
          context.read<SaleProvider>().loadSales(refresh: true);
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Load initial tab data after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isAdmin = context.read<AuthProvider>().isAdmin;
      
      // Set user role for notification filtering
      context.read<NotificationProvider>().setUserRole(isAdmin: isAdmin);
      
      if (isAdmin) {
        context.read<DashboardProvider>().loadDashboard();
      } else {
        context.read<ProductProvider>().loadProducts(refresh: true);
        // Load cart for customers
        context.read<CartProvider>().loadCart();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final authProvider = context.watch<AuthProvider>();
    final l = AppLocalizations.of(context);
    final bool isAdminUser = authProvider.isAdmin;
    
    // Admin/Owner: Dashboard, Products (CRUD), Customers, Sales, Settings
    // Customer: Katalog (browse), Cart, Orders (history), Settings (NO DASHBOARD)
    final screens = isAdminUser
        ? const [
            DashboardScreen(),
            ProductsScreen(),
            CustomersScreen(),
            SalesScreen(),
            SettingsScreen(),
          ]
        : const [
            ProductCatalogScreen(), // No Dashboard for customer
            CartScreen(),
            OrderHistoryScreen(),
            SettingsScreen(),
          ];

    final navItems = isAdminUser
        ? [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: l.dashboard,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.inventory_2_outlined),
              activeIcon: const Icon(Icons.inventory_2),
              label: l.products,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people_outlined),
              activeIcon: const Icon(Icons.people),
              label: l.customers,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.point_of_sale_outlined),
              activeIcon: const Icon(Icons.point_of_sale),
              label: l.sales,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: l.settings,
            ),
          ]
        : [
            // Customer: No Dashboard, starts with Catalog
            BottomNavigationBarItem(
              icon: const Icon(Icons.storefront_outlined),
              activeIcon: const Icon(Icons.storefront),
              label: l.catalog,
            ),
            BottomNavigationBarItem(
              icon: Consumer<CartProvider>(
                builder: (_, cart, child) => Badge(
                  isLabelVisible: cart.itemCount > 0,
                  label: Text('${cart.itemCount}'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
              ),
              activeIcon: Consumer<CartProvider>(
                builder: (_, cart, child) => Badge(
                  isLabelVisible: cart.itemCount > 0,
                  label: Text('${cart.itemCount}'),
                  child: const Icon(Icons.shopping_cart),
                ),
              ),
              label: l.cart,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_outlined),
              activeIcon: const Icon(Icons.receipt_long),
              label: l.orders,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: l.settings,
            ),
          ];

    if (_currentIndex >= screens.length) {
      _currentIndex = screens.length - 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(context, isAdminUser)),
        actions: [
          // Notification Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              if (notificationProvider.hasFilteredUnread)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notificationProvider.filteredUnreadCount > 9 
                          ? '9+' 
                          : notificationProvider.filteredUnreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => _onTabSelected(index, isAdminUser),
        items: navItems,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 10,
      ),
    );
  }

  String _getTitle(BuildContext context, bool isAdmin) {
    final l = AppLocalizations.of(context);
    
    if (isAdmin) {
      // Admin layout: Dashboard, Products, Customers, Sales, Settings (5 tabs)
      switch (_currentIndex) {
        case 0:
          return l.dashboard;
        case 1:
          return l.products;
        case 2:
          return l.customers;
        case 3:
          return l.sales;
        case 4:
          return l.settings;
        default:
          return l.appName;
      }
    } else {
      // Customer layout: Katalog, Cart, Orders, Settings (4 tabs - NO Dashboard)
      switch (_currentIndex) {
        case 0:
          return l.catalog;
        case 1:
          return l.cart;
        case 2:
          return l.orderHistory;
        case 3:
          return l.settings;
        default:
          return l.appName;
      }
    }
  }
}

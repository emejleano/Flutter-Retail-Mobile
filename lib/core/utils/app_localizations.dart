import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? 
           AppLocalizations(const Locale('id', 'ID'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  bool get isIndonesian => locale.languageCode == 'id';
  bool get isEnglish => locale.languageCode == 'en';

  // ============ COMMON ============
  String get appName => _t('Super Store Sales', 'Super Store Sales');
  String get loading => _t('Memuat...', 'Loading...');
  String get error => _t('Terjadi kesalahan', 'An error occurred');
  String get retry => _t('Coba Lagi', 'Retry');
  String get cancel => _t('Batal', 'Cancel');
  String get save => _t('Simpan', 'Save');
  String get delete => _t('Hapus', 'Delete');
  String get edit => _t('Edit', 'Edit');
  String get add => _t('Tambah', 'Add');
  String get search => _t('Cari...', 'Search...');
  String get noData => _t('Tidak ada data', 'No data available');
  String get success => _t('Berhasil', 'Success');
  String get confirm => _t('Konfirmasi', 'Confirm');
  String get yes => _t('Ya', 'Yes');
  String get no => _t('Tidak', 'No');
  String get close => _t('Tutup', 'Close');
  String get ok => _t('OK', 'OK');
  String get back => _t('Kembali', 'Back');
  String get next => _t('Lanjut', 'Next');
  String get all => _t('Semua', 'All');
  String get filter => _t('Filter', 'Filter');
  String get sort => _t('Urutkan', 'Sort');
  String get apply => _t('Terapkan', 'Apply');
  String get reset => _t('Reset', 'Reset');

  // ============ NAVIGATION ============
  String get dashboard => _t('Dashboard', 'Dashboard');
  String get products => _t('Produk', 'Products');
  String get catalog => _t('Katalog', 'Catalog');
  String get customers => _t('Pelanggan', 'Customers');
  String get sales => _t('Penjualan', 'Sales');
  String get cart => _t('Keranjang', 'Cart');
  String get orders => _t('Pesanan', 'Orders');
  String get orderHistory => _t('Riwayat Pesanan', 'Order History');
  String get settings => _t('Pengaturan', 'Settings');
  String get notifications => _t('Notifikasi', 'Notifications');

  // ============ AUTH ============
  String get login => _t('Masuk', 'Login');
  String get logout => _t('Keluar', 'Logout');
  String get logoutConfirm => _t('Apakah Anda yakin ingin keluar?', 'Are you sure you want to logout?');
  String get email => _t('Email', 'Email');
  String get register => _t('Daftar', 'Register');
  String get createAccount => _t('Buat Akun Anda', 'Create Your Account');
  String get registerDescription => _t(
    'Masukkan nama dan email Anda. Password default akan diberikan.',
    'Enter your name and email. A default password will be provided.',
  );
  String get registerSuccessTitle => _t('Pendaftaran Berhasil!', 'Registration Successful!');
  String get registerSuccessMessage => _t(
    'Akun Anda telah dibuat. Silakan login menggunakan password default di bawah ini, lalu segera ubah password Anda.',
    'Your account has been created. Please login using the default password below, then change your password immediately.',
  );
  String get defaultPasswordLabel => _t('Password Default Anda:', 'Your Default Password:');
  String get changePasswordReminder => _t(
    '⚠️ Anda WAJIB mengubah password setelah login pertama.',
    '⚠️ You MUST change your password after first login.',
  );
  String get goToLogin => _t('Lanjut ke Login', 'Go to Login');
  String get backToLogin => _t('Kembali ke Login', 'Back to Login');
  String get changePassword => _t('Ubah Password', 'Change Password');
  String get currentPassword => _t('Password Saat Ini', 'Current Password');
  String get newPassword => _t('Password Baru', 'New Password');
  String get confirmNewPassword => _t('Konfirmasi Password Baru', 'Confirm New Password');
  String get passwordChangedSuccess => _t('Password berhasil diubah', 'Password changed successfully');
  String get passwordMismatch => _t('Password tidak cocok', 'Passwords do not match');
  String get changePasswordRequired => _t(
    'Anda harus mengubah password default sebelum melanjutkan.',
    'You must change your default password before continuing.',
  );
  String get password => _t('Kata Sandi', 'Password');
  String get loginButton => _t('Masuk', 'Sign In');
  String get welcomeBack => _t('Selamat Datang Kembali!', 'Welcome Back!');
  String get signInToContinue => _t('Masuk untuk melanjutkan', 'Sign in to continue');
  String get forgotPassword => _t('Lupa kata sandi?', 'Forgot password?');
  String get admin => _t('Admin', 'Admin');
  String get customer => _t('Pelanggan', 'Customer');
  String get owner => _t('Pemilik', 'Owner');

  // ============ DASHBOARD ============
  String get totalSales => _t('Total Penjualan', 'Total Sales');
  String get totalTransactions => _t('Total Transaksi', 'Total Transactions');
  String get topProducts => _t('Produk Terlaris', 'Top Products');
  String get salesByCategory => _t('Penjualan per Kategori', 'Sales by Category');
  String get monthlySalesTrend => _t('Tren Penjualan Bulanan', 'Monthly Sales Trend');
  String get profitMargin => _t('Margin Keuntungan', 'Profit Margin');
  String get welcomeUser => _t('Selamat Datang', 'Welcome');
  String get overviewToday => _t('Ringkasan Hari Ini', 'Today\'s Overview');
  String get viewAll => _t('Lihat Semua', 'View All');

  // ============ PRODUCTS ============
  String get productName => _t('Nama Produk', 'Product Name');
  String get productId => _t('ID Produk', 'Product ID');
  String get category => _t('Kategori', 'Category');
  String get subCategory => _t('Sub Kategori', 'Sub Category');
  String get price => _t('Harga', 'Price');
  String get unitPrice => _t('Harga Satuan', 'Unit Price');
  String get quantity => _t('Jumlah', 'Quantity');
  String get stock => _t('Stok', 'Stock');
  String get avgUnitPrice => _t('Rata-rata Harga Satuan', 'Avg Unit Price');
  String get productNotFound => _t('Produk tidak ditemukan', 'Product not found');
  String get addProduct => _t('Tambah Produk', 'Add Product');
  String get editProduct => _t('Edit Produk', 'Edit Product');
  String get createProduct => _t('Buat Produk', 'Create Product');
  String get updateProduct => _t('Perbarui Produk', 'Update Product');
  String get productCreated => _t('Produk berhasil dibuat', 'Product created');
  String get productUpdated => _t('Produk berhasil diperbarui', 'Product updated');
  String get deleteProduct => _t('Hapus Produk', 'Delete Product');
  String get productDetails => _t('Detail Produk', 'Product Details');
  String get noProducts => _t('Tidak ada produk', 'No products found');
  String get searchProducts => _t('Cari produk...', 'Search products...');
  String get productBarcode => _t('Barcode Produk', 'Product Barcode');
  String get productInformation => _t('Informasi Produk', 'Product Information');
  String get scanQrCode => _t('Pindai Kode QR', 'Scan QR Code');
  String get shareComingSoon => _t('Fitur berbagi segera hadir', 'Share feature coming soon');
  String get barcode => _t('Barcode', 'Barcode');
  String get qrCode => _t('Kode QR', 'QR Code');
  String get scanBarcode => _t('Pindai Barcode', 'Scan Barcode');
  String get gridView => _t('Tampilan Grid', 'Grid View');
  String get listView => _t('Tampilan List', 'List View');
  String get sortByName => _t('Urutkan Nama', 'Sort by Name');
  String get sortByPrice => _t('Urutkan Harga', 'Sort by Price');
  String get sortByCategory => _t('Urutkan Kategori', 'Sort by Category');
  String get filterByCategory => _t('Filter Kategori', 'Filter by Category');
  String get ascending => _t('Naik', 'Ascending');
  String get descending => _t('Turun', 'Descending');
  
  // Categories
  String get furniture => _t('Furnitur', 'Furniture');
  String get officeSupplies => _t('Perlengkapan Kantor', 'Office Supplies');
  String get technology => _t('Teknologi', 'Technology');

  // ============ CART ============
  String get emptyCart => _t('Keranjang Kosong', 'Cart is Empty');
  String get addFromCatalog => _t('Tambahkan produk dari katalog', 'Add products from catalog');
  String get addToCart => _t('Tambah ke Keranjang', 'Add to Cart');
  String get removeFromCart => _t('Hapus dari Keranjang', 'Remove from Cart');
  String get updateCart => _t('Perbarui Keranjang', 'Update Cart');
  String get clearCart => _t('Kosongkan Keranjang', 'Clear Cart');
  String get cartTotal => _t('Total Keranjang', 'Cart Total');
  String get subtotal => _t('Subtotal', 'Subtotal');
  String get discount => _t('Diskon', 'Discount');
  String get total => _t('Total', 'Total');
  String get checkout => _t('Checkout', 'Checkout');
  String get proceedToCheckout => _t('Lanjut ke Checkout', 'Proceed to Checkout');
  String get itemsInCart => _t('item di keranjang', 'items in cart');
  String get continueShopping => _t('Lanjut Belanja', 'Continue Shopping');

  // ============ CHECKOUT ============
  String get selectRegion => _t('Pilih Wilayah', 'Select Region');
  String get shippingAddress => _t('Alamat Pengiriman', 'Shipping Address');
  String get paymentMethod => _t('Metode Pembayaran', 'Payment Method');
  String get orderSummary => _t('Ringkasan Pesanan', 'Order Summary');
  String get placeOrder => _t('Buat Pesanan', 'Place Order');
  String get orderPlaced => _t('Pesanan Berhasil!', 'Order Placed!');
  String get orderSuccess => _t('Pesanan Anda telah berhasil dibuat', 'Your order has been placed successfully');
  String get orderId => _t('ID Pesanan', 'Order ID');
  String get orderDate => _t('Tanggal Pesanan', 'Order Date');
  String get shipDate => _t('Tanggal Pengiriman', 'Ship Date');
  String get backToShopping => _t('Kembali Belanja', 'Back to Shopping');
  String get viewOrders => _t('Lihat Pesanan', 'View Orders');
  String get processing => _t('Memproses...', 'Processing...');

  // ============ CUSTOMERS ============
  String get customerName => _t('Nama Pelanggan', 'Customer Name');
  String get customerId => _t('ID Pelanggan', 'Customer ID');
  String get segment => _t('Segmen', 'Segment');
  String get addCustomer => _t('Tambah Pelanggan', 'Add Customer');
  String get editCustomer => _t('Edit Pelanggan', 'Edit Customer');
  String get deleteCustomer => _t('Hapus Pelanggan', 'Delete Customer');
  String get customerDetails => _t('Detail Pelanggan', 'Customer Details');
  String get customerInformation => _t('Informasi Pelanggan', 'Customer Information');
  String get customerDeleted => _t('Pelanggan dihapus', 'Customer deleted');
  String get failedToDeleteCustomer => _t('Gagal menghapus pelanggan', 'Failed to delete customer');
  String get noCustomers => _t('Tidak ada pelanggan', 'No customers found');
  String get searchCustomers => _t('Cari pelanggan...', 'Search customers...');

  String confirmDeleteCustomerMessage(String name) =>
      isIndonesian
          ? 'Apakah Anda yakin ingin menghapus "$name"?'
          : 'Are you sure you want to delete "$name"?';

  // ============ SALES ============
  String get salesAmount => _t('Jumlah Penjualan', 'Sales Amount');
  String get profit => _t('Keuntungan', 'Profit');
  String get loss => _t('Kerugian', 'Loss');
  String get items => _t('Item', 'Items');
  String get transactions => _t('Transaksi', 'Transactions');
  String get noSales => _t('Tidak ada penjualan', 'No sales found');
  String get searchSales => _t('Cari penjualan...', 'Search sales...');
  String get saleDetails => _t('Detail Penjualan', 'Sale Details');
  String get transactionDetails => _t('Detail Transaksi', 'Transaction Details');
  String get dateRange => _t('Rentang Tanggal', 'Date Range');
  String get startDate => _t('Tanggal Mulai', 'Start Date');
  String get endDate => _t('Tanggal Akhir', 'End Date');
  String get sortByDate => _t('Urutkan Tanggal', 'Sort by Date');
  String get sortBySales => _t('Urutkan Penjualan', 'Sort by Sales');
  String get sortByProfit => _t('Urutkan Keuntungan', 'Sort by Profit');
  String get region => _t('Wilayah', 'Region');
  String get country => _t('Negara', 'Country');
  String get state => _t('Provinsi', 'State');
  String get city => _t('Kota', 'City');

  // ============ SETTINGS ============
  String get appearance => _t('Tampilan', 'Appearance');
  String get darkMode => _t('Mode Gelap', 'Dark Mode');
  String get lightMode => _t('Mode Terang', 'Light Mode');
  String get toggleTheme => _t('Ubah tema gelap/terang', 'Toggle dark/light theme');
  String get language => _t('Bahasa', 'Language');
  String get selectLanguage => _t('Pilih Bahasa', 'Select Language');
  String get indonesian => _t('Bahasa Indonesia', 'Indonesian');
  String get english => _t('English', 'English');
  String get account => _t('Akun', 'Account');
  String get about => _t('Tentang', 'About');
  String get appVersion => _t('Versi Aplikasi', 'App Version');
  String get aboutApp => _t('Tentang Aplikasi', 'About App');
  String get signOutAccount => _t('Keluar dari akun Anda', 'Sign out from your account');

  // ============ NOTIFICATIONS ============
  String get noNotifications => _t('Tidak ada notifikasi', 'No notifications');
  String get allNotifications => _t('Semua Notifikasi', 'All Notifications');
  String get stockAlerts => _t('Peringatan Stok', 'Stock Alerts');
  String get orderUpdates => _t('Update Pesanan', 'Order Updates');
  String get noOrderUpdates => _t('Tidak ada update pesanan', 'No order updates');
  String get noStockAlerts => _t('Tidak ada peringatan stok', 'No stock alerts');
  String get markAllRead => _t('Tandai Semua Dibaca', 'Mark All as Read');
  String get clearAll => _t('Hapus Semua', 'Clear All');
  String get newNotification => _t('Notifikasi Baru', 'New Notification');
  String get unread => _t('Belum Dibaca', 'Unread');
  
  // Notification types
  String get lowStockAlert => _t('Peringatan Stok Menipis', 'Low Stock Alert');
  String get stockOpnameReminder => _t('Pengingat Stock Opname', 'Stock Opname Reminder');
  String get orderPlacedNotif => _t('Pesanan Dibuat', 'Order Placed');
  String get orderShippedNotif => _t('Pesanan Dikirim', 'Order Shipped');
  String get orderDeliveredNotif => _t('Pesanan Terkirim', 'Order Delivered');
  String get promotionNotif => _t('Promo', 'Promotion');

  // ============ ORDERS ============
  String get orderStatus => _t('Status Pesanan', 'Order Status');
  String get pending => _t('Menunggu', 'Pending');
  String get confirmed => _t('Dikonfirmasi', 'Confirmed');
  String get shipped => _t('Dikirim', 'Shipped');
  String get delivered => _t('Terkirim', 'Delivered');
  String get cancelled => _t('Dibatalkan', 'Cancelled');
  String get noOrders => _t('Tidak ada pesanan', 'No orders found');
  String get viewOrderDetails => _t('Lihat Detail Pesanan', 'View Order Details');

  // ============ ERRORS ============
  String get errorLoading => _t('Gagal memuat data', 'Failed to load data');
  String get errorSaving => _t('Gagal menyimpan', 'Failed to save');
  String get errorNetwork => _t('Kesalahan jaringan', 'Network error');
  String get errorUnauthorized => _t('Sesi telah berakhir', 'Session expired');
  String get tryAgain => _t('Silakan coba lagi', 'Please try again');
  String get somethingWentWrong => _t('Terjadi kesalahan', 'Something went wrong');
  String get operationFailed => _t('Operasi gagal', 'Operation failed');
  String get pullToRefresh => _t('Tarik untuk menyegarkan', 'Pull to refresh');

  // ============ VALIDATION ============
  String get required => _t('Wajib diisi', 'Required');
  String get invalidEmail => _t('Email tidak valid', 'Invalid email');
  String get invalidPassword => _t('Kata sandi tidak valid', 'Invalid password');
  String get passwordTooShort => _t('Kata sandi terlalu pendek', 'Password too short');
  String get fieldRequired => _t('Field ini wajib diisi', 'This field is required');
  String get invalidNumber => _t('Angka tidak valid', 'Invalid number');

  // ============ FILTER & SORT ============
  String get filterAndSort => _t('Filter & Urutkan', 'Filter & Sort');
  String get applyFilters => _t('Terapkan Filter', 'Apply Filters');
  String get resetAll => _t('Reset Semua', 'Reset All');
  String get order => _t('Urutan', 'Order');
  String get name => _t('Nama', 'Name');
  String get date => _t('Tanggal', 'Date');
  String get selectDateRange => _t('Pilih rentang tanggal', 'Select date range');

  // ============ COMMON LABELS ==========
  String get created => _t('Dibuat', 'Created');
  String get updated => _t('Diperbarui', 'Updated');
  String get lastUpdated => _t('Terakhir Diperbarui', 'Last Updated');
  String get selectFromListOptional => _t('Pilih dari daftar (opsional)', 'Select from list (optional)');
  
  // ============ DASHBOARD EXTRA ============
  String get welcomeBackMessage => _t('Selamat datang,', 'Welcome back,');
  String get last12MonthsPerformance => _t('Performa 12 bulan terakhir', 'Last 12 months performance');
  String get salesTrend => _t('Tren Penjualan', 'Sales Trend');
  String get trendDays => _t('Hari Tren', 'Trend Days');
  String lastNDaysPerformance(int days) =>
      isIndonesian ? 'Performa $days hari terakhir' : 'Last $days days performance';
  String get distributionByCategory => _t('Distribusi berdasarkan kategori produk', 'Distribution across product categories');
  String get salesByRegion => _t('Penjualan per Wilayah', 'Sales by Region');
  String get geographicDistribution => _t('Distribusi penjualan geografis', 'Geographic sales distribution');
  String get profitabilityAnalysis => _t('Analisis profitabilitas', 'Profitability analysis');
  String get avgDiscount => _t('Rata-rata Diskon', 'Avg Discount');
  
  // ============ PRODUCTS EXTRA ============
  String get noProductsMatchFilter => _t('Tidak ada produk yang cocok dengan filter', 'No products match the filter');
  String get deleteProductConfirm => _t('Apakah Anda yakin ingin menghapus', 'Are you sure you want to delete');
  String get productDeleted => _t('Produk berhasil dihapus', 'Product deleted');
  String get failedToDeleteProduct => _t('Gagal menghapus produk', 'Failed to delete product');
  String get scanBarcodeTooltip => _t('Pindai Barcode', 'Scan Barcode');
  
  // ============ SALES EXTRA ============
  String get salesTransactions => _t('Transaksi Penjualan', 'Sales Transactions');
  String get newSale => _t('Penjualan Baru', 'New Sale');
  String get loadingSales => _t('Memuat penjualan...', 'Loading sales...');
  String get deleteSale => _t('Hapus Penjualan', 'Delete Sale');
  String get deleteSaleConfirm => _t('Apakah Anda yakin ingin menghapus penjualan ini?', 'Are you sure you want to delete this sale?');
  String get saleDeleted => _t('Penjualan berhasil dihapus', 'Sale deleted');
  String get failedToDeleteSale => _t('Gagal menghapus penjualan', 'Failed to delete sale');
  String get off => _t('diskon', 'off');

  // Helper function to return text based on locale
  String _t(String id, String en) {
    return isIndonesian ? id : en;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['id', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

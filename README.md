# Business Intelligence Dashboard

A comprehensive Flutter application for Business Intelligence Dashboard with modular architecture.

## Features

### Core Features
- ✅ **Bottom Navigation Bar** - 5 tabs: Dashboard, Products, Customers, Sales, Settings
- ✅ **Dark/Light Mode** - Toggle between themes with persistence
- ✅ **Role-Based Access** - Admin (full CRUD) and User (view only) roles
- ✅ **Barcode/QR Scanner** - Scan products using camera
- ✅ **Interactive Charts** - Line, Pie, Bar charts using fl_chart
- ✅ **Notifications** - Stock alerts and system notifications

### API Integration
- Dashboard statistics and trends
- Products CRUD with categories
- Customers CRUD with segments
- Regions CRUD
- Sales transactions CRUD

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── api_constants.dart    # API endpoints
│   │   └── app_constants.dart    # App configuration
│   ├── theme/
│   │   └── app_theme.dart        # Light/Dark themes
│   └── utils/
│       ├── date_formatter.dart   # Formatting utilities
│       └── validators.dart       # Form validation
├── data/
│   ├── models/
│   │   ├── customer_model.dart
│   │   ├── dashboard_model.dart
│   │   ├── notification_model.dart
│   │   ├── paginated_response.dart
│   │   ├── product_model.dart
│   │   ├── region_model.dart
│   │   └── sale_model.dart
│   └── services/
│       ├── api_service.dart      # Base HTTP client
│       ├── customer_service.dart
│       ├── dashboard_service.dart
│       ├── product_service.dart
│       ├── region_service.dart
│       └── sale_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── customer_provider.dart
│   ├── dashboard_provider.dart
│   ├── notification_provider.dart
│   ├── product_provider.dart
│   ├── region_provider.dart
│   ├── sale_provider.dart
│   └── theme_provider.dart
└── presentation/
    ├── screens/
    │   ├── auth/
    │   │   └── login_screen.dart
    │   ├── customers/
    │   │   ├── customers_screen.dart
    │   │   ├── customer_detail_screen.dart
    │   │   └── customer_form_screen.dart
    │   ├── dashboard/
    │   │   └── dashboard_screen.dart
    │   ├── home/
    │   │   └── home_screen.dart
    │   ├── notifications/
    │   │   └── notifications_screen.dart
    │   ├── products/
    │   │   ├── products_screen.dart
    │   │   ├── product_detail_screen.dart
    │   │   └── product_form_screen.dart
    │   ├── sales/
    │   │   ├── sales_screen.dart
    │   │   ├── sale_detail_screen.dart
    │   │   └── sale_form_screen.dart
    │   ├── scanner/
    │   │   └── barcode_scanner_screen.dart
    │   └── settings/
    │       └── settings_screen.dart
    └── widgets/
        ├── charts/
        │   ├── category_pie_chart.dart
        │   ├── profit_margin_chart.dart
        │   ├── region_bar_chart.dart
        │   └── sales_line_chart.dart
        └── common/
            ├── custom_button.dart
            ├── custom_card.dart
            ├── custom_text_field.dart
            ├── dialogs.dart
            ├── error_widget.dart
            ├── filter_chips.dart
            └── loading_widget.dart
```

## Dependencies

```yaml
dependencies:
  provider: ^6.1.2          # State management
  http: ^1.2.2              # HTTP client
  dio: ^5.7.0               # Advanced HTTP client
  shared_preferences: ^2.3.3 # Local storage
  fl_chart: ^0.69.2         # Interactive charts
  mobile_scanner: ^6.0.2    # Barcode/QR scanner
  flutter_local_notifications: ^18.0.1 # Notifications
  intl: ^0.19.0             # Internationalization
  shimmer: ^3.0.0           # Loading shimmer effect
  fluttertoast: ^8.2.8      # Toast messages
```

## Getting Started

1. Clone the repository
2. Run `flutter pub get`
3. Update the API base URL in `lib/core/constants/api_constants.dart`
4. Run the app with `flutter run`

## Login Credentials

**Admin Access:**
- Username: `admin`
- Password: `admin`

**User Access:**
- Username: any
- Password: any

## API Configuration

Update the base URL in `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'http://your-api-url/api';
```

## Screenshots

The app features:
- Modern Material 3 design
- Responsive layouts
- Interactive data visualizations
- Pull-to-refresh functionality
- Infinite scroll pagination

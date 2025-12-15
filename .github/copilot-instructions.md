# Project Context: Retail Analytics Mobile App (Flutter + Laravel)

## 1. Project Overview
Aplikasi mobile untuk Retail Analytics yang terintegrasi dengan backend Laravel. Aplikasi ini menampilkan Dashboard BI (Business Intelligence) mini dan memungkinkan user melakukan transaksi sederhana.

**Tech Stack:**
- **Frontend:** Flutter (Dart)
- **Backend:** Laravel 11 (REST API, MySQL)
- **Key Libraries:** `http` (API requests), `fl_chart` (Charts), `intl` (Currency formatting), `provider` (optional, for state management).

---

## 2. Backend API Specification (Laravel)
Base URL: `http://10.0.2.2:8000/api` (Android Emulator) or `http://localhost:8000/api` (iOS/Web).

### Endpoints
The following endpoints are available. Always implement error handling (try-catch) for these requests.

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/dashboard` | Mengambil summary data untuk chart (Total sales, Top products, Sales by Category). |
| `GET` | `/products` | Mengambil daftar produk (mendukung pagination atau search). |
| `GET` | `/products/{id}` | Mengambil detail produk spesifik. |
| `POST` | `/sales` | Membuat transaksi baru. |
| `GET` | `/customers` | Mengambil daftar customer (untuk dropdown saat transaksi). |
| `GET` | `/regions` | Mengambil data wilayah (opsional). |

---

## 3. Data Models & JSON Structure
When generating Dart models (`lib/models/`), use `factory .fromJson` pattern.

### A. Dashboard Model (`/api/dashboard`)
Expected JSON response structure:
```json
{
  "total_sales": 15000000.00,
  "sales_by_category": [
    { "category": "Furniture", "total": 5000000 },
    { "category": "Technology", "total": 8000000 }
  ],
  "top_products": [
    { "product_name": "Chair A", "sold": 120 },
    { "product_name": "Phone B", "sold": 90 }
  ],
  "monthly_sales_trend": [
    { "month": "Jan", "sales": 100000 },
    { "month": "Feb", "sales": 120000 }
  ]
}
```

### B. Product Model (`/api/products`)
Fields based on `dim_product.csv`:
- `id` (int/string)
- `product_name` (string)
- `category` (string)
- `sub_category` (string)
- `price` (double) - Important: Format as IDR (Rp) in UI.

### C. Sale Model (`POST /api/sales`)
Body payload for creating a transaction:
```json
{
  "customer_id": "CG-12520",
  "product_id": "FUR-BO-10001798",
  "quantity": 2,
  "date": "2025-12-14"
}
```

## 4. Folder Structure Standards
Generate code following this structure:
- `lib/models/` -> Data classes with `fromJson` and `toJson`.
- `lib/services/` -> `ApiService` class containing static methods for HTTP calls.
- `lib/screens/` -> UI Widgets (Pages).
- `lib/widgets/` -> Reusable widgets (e.g., `SummaryCard`, `ChartWidget`).

## 5. Coding Guidelines & Rules
1. Http Requests:
  - Use the `http` package.
  - Always check `response.statusCode == 200` (or 201 for POST).
  - Handle JSON decoding errors.
2. UI/UX:
  - Use `FutureBuilder` for loading states (fetching API).
  - Show a `CircularProgressIndicator` while waiting for data.
  - Show an error message/Snackbar if the API call fails.
3. Formatting:
  - Use `Intl` package to format currency to Indonesian Rupiah (e.g., `NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)`).
  - Dates should be formatted as dd MMM yyyy.
4. Charts:
  - Use `fl_chart` for visualizing `sales_by_category` (PieChart) and `monthly_sales_trend` (LineChart).

## 6. Specific Instructions for Dashboard
When generating the Dashboard UI:
1. Top section: Cards showing `Total Sales` and `Total Transactions`.
2. Middle section: Pie Chart for Categories.
3. Bottom section: Horizontal list of Top Products.

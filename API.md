# 📚 API Documentation - Business Intelligence (BI) System
## Star Schema Data Warehouse Backend

**Base URL:** `http://localhost:8000/api`

**Architecture:** Data Warehouse Star Schema Design  
**Database:** MySQL with dimensional modeling for analytics

---

## 🔐 Authentication & Roles

This API uses **Laravel Sanctum Personal Access Tokens**.

### Roles
- `admin`: can create/update/delete (write access)
- `customer`: read-only access

### How to call protected endpoints
All endpoints except `POST /api/login` require:

- Header: `Authorization: Bearer <access_token>`

> If you call a protected endpoint without a token, you will get `401 Unauthenticated`.
> If you call an **admin-only** endpoint with a non-admin user, you will get `403 Forbidden`.

## 📋 Available Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/login` | Login and get access token (public) |
| GET | `/api/me` | Get current user profile (auth) |
| POST | `/api/refresh` | Refresh access token (rotate token) (auth) |
| POST | `/api/logout` | Logout (revoke current token) (auth) |
| GET | `/api/dashboard` | Get BI dashboard analytics data |
| GET | `/api/products` | Get all products (dimension) |
| POST | `/api/products` | Create new product (**admin**) |
| PUT/PATCH | `/api/products/{id}` | Update product (**admin**) |
| DELETE | `/api/products/{id}` | Delete product (**admin**) |
| GET | `/api/customers` | Get all customers (dimension) |
| POST | `/api/customers` | Create new customer (**admin**) |
| GET | `/api/customers/{id}` | Get customer by ID |
| PUT/PATCH | `/api/customers/{id}` | Update customer (**admin**) |
| DELETE | `/api/customers/{id}` | Delete customer (**admin**) |
| GET | `/api/regions` | Get all regions (dimension) |
| POST | `/api/regions` | Create new region (**admin**) |
| GET | `/api/regions/{id}` | Get region by ID |
| PUT/PATCH | `/api/regions/{id}` | Update region (**admin**) |
| DELETE | `/api/regions/{id}` | Delete region (**admin**) |
| GET | `/api/sales` | Get all sales transactions (fact) |
| POST | `/api/sales` | Create new sale transaction (**admin**) |
| GET | `/api/sales/{id}` | Get sale by ID |
| PUT/PATCH | `/api/sales/{id}` | Update sale transaction (**admin**) |
| DELETE | `/api/sales/{id}` | Delete sale transaction (**admin**) |

---

## 🔑 Auth API

### 1. Login (Get Token)
```http
POST /api/login
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "admin@example.com",
  "password": "password",
  "device_name": "flutter"
}
```

**Response (200):**
```json
{
  "token_type": "Bearer",
  "access_token": "<token>",
  "user": {
    "id": 1,
    "name": "Admin",
    "email": "admin@example.com",
    "role": "admin"
  }
}
```

### 2. Profile (Me)
```http
GET /api/me
Authorization: Bearer <access_token>
```

### 3. Logout
```http
POST /api/logout
Authorization: Bearer <access_token>
```

### 4. Refresh Token (Rotate Token)
```http
POST /api/refresh
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body (optional):**
```json
{
  "device_name": "flutter"
}
```

**Response (200):**
```json
{
  "token_type": "Bearer",
  "access_token": "<new_token>"
}
```

**Notes:**
- Laravel Sanctum does not provide JWT-style refresh tokens by default.
- This endpoint performs **token rotation**: it creates a new token and revokes the current one.

---

## 📊 Dashboard API

### Get Dashboard Analytics
```http
GET /api/dashboard
```

**Description:** Returns comprehensive BI analytics including sales summaries, trends, and key metrics.

**Response (200):**
```json
{
  "summary_info": {
    "generated_at": "2025-12-19 04:30:15.123456",
    "total_transactions": 9994
  },
  "total_sales": 2297200.86,
  "total_profit": 286397.02,
  "average_discount": 0.156,
  "sales_by_category": {
    "Technology": 836154.03,
    "Furniture": 741999.80,
    "Office Supplies": 719047.03
  },
  "sales_by_region": {
    "West": 725457.82,
    "East": 678781.24,
    "Central": 501239.89,
    "South": 391721.91
  },
  "top_products": [
    {
      "product_id": "TEC-PH-10002275",
      "product_name": "Canon imageCLASS 2200 Advanced Copier",
      "category": "Technology",
      "total_sales": 61599.82
    }
  ],
  "monthly_sales_trend": [
    {
      "period": "2024-01",
      "sales": 125430.50,
      "profit": 18234.21,
      "transactions": 312
    }
  ],
  "profit_margin_by_category": {
    "Technology": 0.145,
    "Furniture": 0.102,
    "Office Supplies": 0.168
  }
}
```

---

## 🛍️ Products API (DIM_PRODUCT)

**Table:** `dim_product` (Dimension Table)

### 1. Get All Products
```http
GET /api/products
```

**Auth:** Required

**Headers:**
`Authorization: Bearer <access_token>`

**Query Parameters:**
- `search` (optional) - Search by product name
- `category` (optional) - Filter by category (Furniture, Office Supplies, Technology)
- `sub_category` (optional) - Filter by sub category
- `page` (optional) - Page number (default: 1)

> Page size is fixed to 20 items per page.

**Response (200):**
```json
{
  "current_page": 1,
  "data": [
    {
      "product_id": "FUR-BO-10001798",
      "category": "Furniture",
      "sub_category": "Bookcases",
      "product_name": "Bush Somerset Collection Bookcase",
      "avg_unit_price": 111.68,
      "created_at": "2024-12-11T00:00:00.000000Z",
      "updated_at": "2024-12-11T00:00:00.000000Z"
    },
    {
      "product_id": "TEC-PH-10002275",
      "category": "Technology",
      "sub_category": "Phones",
      "product_name": "Mitel 5320 IP Phone VoIP phone",
      "avg_unit_price": 87.75,
      "created_at": "2024-12-11T00:00:00.000000Z",
      "updated_at": "2024-12-11T00:00:00.000000Z"
    }
  ],
  "per_page": 20,
  "total": 1862,
  "last_page": 94
}
```

### 2. Create Product
```http
POST /api/products
Content-Type: application/json
```

**Request Body:**
```json
{
  "product_id": "TEC-ACC-10003001",
  "category": "Technology",
  "sub_category": "Accessories",
  "product_name": "Logitech MX Master 3S Wireless Mouse",
  "avg_unit_price": 99.99
}
```

**Validation Rules:**
- `product_id`: required, unique, string
- `category`: required, string
- `sub_category`: required, string
- `product_name`: required, string
- `avg_unit_price`: optional, numeric, min:0

**Response (201):**
```json
{
  "message": "Product created successfully",
  "data": {
    "product_id": "TEC-ACC-10003001",
    "category": "Technology",
    "sub_category": "Accessories",
    "product_name": "Logitech MX Master 3S Wireless Mouse",
    "avg_unit_price": 99.99,
    "created_at": "2025-12-19T04:30:15.000000Z",
    "updated_at": "2025-12-19T04:30:15.000000Z"
  }
}
```

### 3. Update Product
```http
PUT /api/products/{product_id}
PATCH /api/products/{product_id}
Content-Type: application/json
```

**Request Body:**
```json
{
  "product_name": "Logitech MX Master 3S - Special Edition",
  "avg_unit_price": 109.99
}
```

**Response (200):**
```json
{
  "message": "Product updated successfully",
  "data": {
    "product_id": "TEC-ACC-10003001",
    "category": "Technology",
    "sub_category": "Accessories",
    "product_name": "Logitech MX Master 3S - Special Edition",
    "avg_unit_price": 109.99,
    "created_at": "2025-12-19T04:30:15.000000Z",
    "updated_at": "2025-12-19T04:35:22.000000Z"
  }
}
```

### 4. Delete Product
```http
DELETE /api/products/{product_id}
```

**Response (200):**
```json
{
  "message": "Product deleted successfully"
}
```

**Note:** ⚠️ Deleting a product will cascade delete all related sales transactions.

---

## 👥 Customers API (DIM_CUSTOMER)

**Table:** `dim_customer` (Dimension Table)

### 1. Get All Customers
```http
GET /api/customers
```

**Auth:** Required

**Headers:**
`Authorization: Bearer <access_token>`

**Query Parameters:**
- `search` (optional) - Search by customer name
- `segment` (optional) - Filter by segment
- `page` (optional) - Page number

**Response (200):**
```json
{
  "current_page": 1,
  "data": [
    {
      "customer_id": "CG-12520",
      "customer_name": "Claire Gute",
      "segment": "Consumer",
      "created_at": "2024-12-11T00:00:00.000000Z",
      "updated_at": "2024-12-11T00:00:00.000000Z"
    }
  ],
  "per_page": 20,
  "total": 793
}
```

### 2. Get Customer by ID
```http
GET /api/customers/{customer_id}
```

**Response (200):**
```json
{
  "customer_id": "CG-12520",
  "customer_name": "Claire Gute",
  "segment": "Consumer",
  "created_at": "2024-12-11T00:00:00.000000Z",
  "updated_at": "2024-12-11T00:00:00.000000Z"
}
```

### 3. Create Customer
```http
POST /api/customers
Content-Type: application/json
```

**Request Body:**
```json
{
  "customer_id": "JD-15820",
  "customer_name": "John Doe",
  "segment": "Corporate"
}
```

**Validation Rules:**
- `customer_id`: required, unique, string
- `customer_name`: required, string
- `segment`: required, string

**Response (201):**
```json
{
  "message": "Customer created successfully",
  "data": {
    "customer_id": "JD-15820",
    "customer_name": "John Doe",
    "segment": "Corporate",
    "created_at": "2025-12-19T04:30:15.000000Z",
    "updated_at": "2025-12-19T04:30:15.000000Z"
  }
}
```

### 4. Update Customer
```http
PUT /api/customers/{customer_id}
PATCH /api/customers/{customer_id}
Content-Type: application/json
```

**Request Body:**
```json
{
  "customer_name": "John Doe Jr.",
  "segment": "Home Office"
}
```

**Response (200):**
```json
{
  "message": "Customer updated successfully",
  "data": {
    "customer_id": "JD-15820",
    "customer_name": "John Doe Jr.",
    "segment": "Home Office",
    "created_at": "2025-12-19T04:30:15.000000Z",
    "updated_at": "2025-12-19T04:35:22.000000Z"
  }
}
```

### 5. Delete Customer
```http
DELETE /api/customers/{customer_id}
```

**Response (200):**
```json
{
  "message": "Customer deleted successfully"
}
```

---

## 🌍 Regions API (DIM_REGION)

**Table:** `dim_region` (Dimension Table)

### 1. Get All Regions
```http
GET /api/regions
```

**Auth:** Required

**Headers:**
`Authorization: Bearer <access_token>`

> This endpoint returns **all regions** (no pagination).

**Response (200):**
```json
[
  {
    "region_id": "US-CA-SF-94102",
    "country": "United States",
    "state": "California",
    "city": "San Francisco",
    "postal_code": "94102",
    "region": "West",
    "created_at": "2024-12-11T00:00:00.000000Z",
    "updated_at": "2024-12-11T00:00:00.000000Z"
  },
  {
    "region_id": "US-NY-NYC-10001",
    "country": "United States",
    "state": "New York",
    "city": "New York City",
    "postal_code": "10001",
    "region": "East",
    "created_at": "2024-12-11T00:00:00.000000Z",
    "updated_at": "2024-12-11T00:00:00.000000Z"
  }
]
```

### 2. Get Region by ID
```http
GET /api/regions/{region_id}
```

**Response (200):**
```json
{
  "region_id": "US-CA-SF-94102",
  "country": "United States",
  "state": "California",
  "city": "San Francisco",
  "postal_code": "94102",
  "region": "West",
  "created_at": "2024-12-11T00:00:00.000000Z",
  "updated_at": "2024-12-11T00:00:00.000000Z"
}
```

### 3. Create Region
```http
POST /api/regions
Content-Type: application/json
```

**Request Body:**
```json
{
  "region_id": "US-TX-DAL-75201",
  "country": "United States",
  "state": "Texas",
  "city": "Dallas",
  "postal_code": "75201",
  "region": "Central"
}
```

**Validation Rules:**
- `region_id`: required, unique, string
- `country`: required, string
- `state`: required, string
- `city`: required, string
- `postal_code`: optional, string
- `region`: required, string

**Response (201):**
```json
{
  "message": "Region created successfully",
  "data": {
    "region_id": "US-TX-DAL-75201",
    "country": "United States",
    "state": "Texas",
    "city": "Dallas",
    "postal_code": "75201",
    "region": "Central",
    "created_at": "2025-12-19T04:30:15.000000Z",
    "updated_at": "2025-12-19T04:30:15.000000Z"
  }
}
```

### 4. Update Region
```http
PUT /api/regions/{region_id}
PATCH /api/regions/{region_id}
Content-Type: application/json
```

**Request Body:**
```json
{
  "city": "Dallas Metro",
  "postal_code": "75202"
}
```

**Response (200):**
```json
{
  "message": "Region updated successfully",
  "data": {
    "region_id": "US-TX-DAL-75201",
    "country": "United States",
    "state": "Texas",
    "city": "Dallas Metro",
    "postal_code": "75202",
    "region": "Central",
    "created_at": "2025-12-19T04:30:15.000000Z",
    "updated_at": "2025-12-19T04:35:22.000000Z"
  }
}
```

### 5. Delete Region
```http
DELETE /api/regions/{region_id}
```

**Response (200):**
```json
{
  "message": "Region deleted successfully"
}
```

---

## 💰 Sales API (FACT_SALES)

**Table:** `fact_sales` (Fact Table)

### 1. Get All Sales
```http
GET /api/sales
```

**Auth:** Required

**Headers:**
`Authorization: Bearer <access_token>`

**Query Parameters:**
- `product_id` (optional) - Filter by product
- `customer_id` (optional) - Filter by customer
- `region_id` (optional) - Filter by region
- `start_date` (optional) - Date range start (supports `YYYYMMDD` or `YYYY-MM-DD`)
- `end_date` (optional) - Date range end (supports `YYYYMMDD` or `YYYY-MM-DD`)
- `page` (optional) - Page number

**Response (200):**
```json
{
  "current_page": 1,
  "data": [
    {
      "fact_id": 1,
      "order_id": "CA-2016-152156",
      "date_id": 20161108,
      "customer_id": "CG-12520",
      "product_id": "FUR-BO-10001798",
      "region_id": "US-KY-HEN-42420",
      "sales": 261.96,
      "quantity": 2,
      "discount": 0.00,
      "profit": 41.91,
      "created_at": "2024-12-11T00:00:00.000000Z",
      "updated_at": "2024-12-11T00:00:00.000000Z",
      "product": {
        "product_id": "FUR-BO-10001798",
        "category": "Furniture",
        "sub_category": "Bookcases",
        "product_name": "Bush Somerset Collection Bookcase",
        "avg_unit_price": 111.68
      },
      "customer": {
        "customer_id": "CG-12520",
        "customer_name": "Claire Gute",
        "segment": "Consumer"
      },
      "region": {
        "region_id": "US-KY-HEN-42420",
        "country": "United States",
        "state": "Kentucky",
        "city": "Henderson",
        "postal_code": "42420",
        "region": "South"
      },
      "order_date": {
        "date_id": 20161108,
        "full_date": "2016-11-08",
        "year": 2016,
        "month": 11,
        "month_name": "November"
      }
    }
  ],
  "per_page": 20,
  "total": 9994,
  "last_page": 500
}
```

### 2. Get Sale by ID
```http
GET /api/sales/{fact_id}
```

**Response (200):**
```json
{
  "fact_id": 1,
  "order_id": "CA-2016-152156",
  "date_id": 20161108,
  "customer_id": "CG-12520",
  "product_id": "FUR-BO-10001798",
  "region_id": "US-KY-HEN-42420",
  "sales": 261.96,
  "quantity": 2,
  "discount": 0.00,
  "profit": 41.91,
  "created_at": "2024-12-11T00:00:00.000000Z",
  "updated_at": "2024-12-11T00:00:00.000000Z"
}
```

### 3. Create Sale
```http
POST /api/sales
Content-Type: application/json
```

**Request Body:**
```json
{
  "order_id": "CA-2025-100001",
  "date_id": 20251219,
  "ship_date_id": 20251220,
  "customer_id": "CG-12520",
  "product_id": "FUR-BO-10001798",
  "region_id": "US-CA-SF-94102",
  "sales": 299.99,
  "quantity": 3,
  "discount": 0.10,
  "profit": 45.50
}
```

**Validation Rules:**
- `order_id`: required, string
- `date_id`: required, integer, exists in dim_date
- `ship_date_id`: required, integer, exists in dim_date
- `customer_id`: required, exists in dim_customer
- `product_id`: required, exists in dim_product
- `region_id`: required, exists in dim_region
- `sales`: required, numeric, min:0
- `quantity`: required, integer, min:1
- `discount`: optional, numeric, min:0, max:1
- `profit`: required, numeric

**Response (201):**
```json
{
  "message": "Sale created successfully",
  "data": {
    "fact_id": 9995,
    "order_id": "CA-2025-100001",
    "date_id": 20251219,
    "customer_id": "CG-12520",
    "product_id": "FUR-BO-10001798",
    "region_id": "US-CA-SF-94102",
    "sales": 299.99,
    "quantity": 3,
    "discount": 0.10,
    "profit": 45.50,
    "created_at": "2025-12-19T04:30:15.000000Z",
    "updated_at": "2025-12-19T04:30:15.000000Z"
  }
}
```

### 4. Update Sale
```http
PUT /api/sales/{fact_id}
PATCH /api/sales/{fact_id}
Content-Type: application/json
```

**Request Body:**
```json
{
  "sales": 350.00,
  "quantity": 4,
  "discount": 0.15,
  "profit": 52.50
}
```

**Response (200):**
```json
{
  "message": "Sale updated successfully",
  "data": {
    "fact_id": 9995,
    "order_id": "CA-2025-100001",
    "date_id": 20251219,
    "customer_id": "CG-12520",
    "product_id": "FUR-BO-10001798",
    "region_id": "US-CA-SF-94102",
    "sales": 350.00,
    "quantity": 4,
    "discount": 0.15,
    "profit": 52.50,
    "created_at": "2025-12-19T04:30:15.000000Z",
    "updated_at": "2025-12-19T04:35:22.000000Z"
  }
}
```

### 5. Delete Sale
```http
DELETE /api/sales/{fact_id}
```

**Response (200):**
```json
{
  "message": "Sale deleted successfully"
}
```

---

## ❌ Error Responses

### Unauthenticated (401)
```json
{
  "message": "Unauthenticated."
}
```

### Forbidden (403) - Admin only
```json
{
  "message": "Forbidden. Admin only."
}
```

### Validation Error (422)
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "product_id": [
      "The product id field is required."
    ],
    "sales": [
      "The sales must be at least 0."
    ],
    "quantity": [
      "The quantity must be at least 1."
    ]
  }
}
```

### Not Found (404)
```json
{
  "message": "Product not found"
}
```

### Foreign Key Constraint Error (422)
```json
{
  "message": "The selected customer id does not exist."
}
```

### Server Error (500)
```json
{
  "message": "Internal server error",
  "error": "Database connection failed"
}
```

---

## 🔑 Key Features & Notes

### Star Schema Design
- **Fact Table (`fact_sales`)**: Stores measurable business metrics (sales, quantity, discount, profit)
- **Dimension Tables**: Store descriptive attributes (products, customers, regions, dates)
- **Many-to-One Relationships**: Each sale references one product, customer, region, and date

### Data Integrity
1. **Foreign Key Constraints**: All dimension references are validated
2. **Cascade Delete**: Deleting dimensions will remove related fact records
3. **No Transactional Data in Dimensions**: Product dimension stores `avg_unit_price`, not transactional `sales`

### Date Format
- `date_id`: Integer format `YYYYMMDD` (e.g., `20251219`)
- `full_date`: Date format `YYYY-MM-DD` (e.g., `2025-12-19`)

### Pagination
- Default: 20 items per page
- Use `?page=2` for next page

> Page size is fixed to 20.

### Performance
- All foreign key columns are indexed
- `order_id` in fact table is indexed for faster lookups
- Use query parameters to filter large datasets

### Analytics Capabilities
- Dashboard endpoint provides pre-aggregated metrics
- Sales can be analyzed by: category, region, time period, customer segment
- Supports OLAP-style queries for business intelligence

---

## 🗂️ Database Schema

### Fact Table Structure
```sql
fact_sales (
  fact_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  order_id VARCHAR INDEX,
  date_id INT FK → dim_date,
  customer_id VARCHAR FK → dim_customer,
  product_id VARCHAR FK → dim_product,
  region_id VARCHAR FK → dim_region,
  sales DECIMAL(15,2),
  quantity INT,
  discount DECIMAL(5,4),
  profit DECIMAL(15,2)
)
```

### Dimension Tables Structure
```sql
dim_product (product_id PK, category, sub_category, product_name, avg_unit_price)
dim_customer (customer_id PK, customer_name, segment)
dim_region (region_id PK, country, state, city, postal_code, region)
dim_date (date_id PK, full_date, year, month, month_name)
```

---

## 📝 Change Log

**v2.0.0 - 2025-12-19**
- ✅ Refactored to Star Schema architecture
- ✅ Added fact_id as primary key for fact_sales
- ✅ Added quantity, discount, profit metrics
- ✅ Expanded dim_region with geographic hierarchy
- ✅ Removed transactional fields from dimension tables
- ✅ Updated all API endpoints documentation
- ✅ Enhanced dashboard analytics

**v2.0.0 - 2025-12-19**
- ✅ Refactored to Star Schema architecture
- ✅ Added fact_id as primary key for fact_sales
- ✅ Added quantity, discount, profit metrics
- ✅ Expanded dim_region with geographic hierarchy
- ✅ Removed transactional fields from dimension tables
- ✅ Updated all API endpoints documentation
- ✅ Enhanced dashboard analytics

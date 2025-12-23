Instruksi Tugas Akhir (BI + Mobile Programming)
Tugas Akhir MK Mobile Programming
1. Ketentuan Umum
•	Buat kelompok beranggotakan 3–4 orang.
•	Buat aplikasi mobile Android berbasis Flutter dengan topik: Retail Analytics App berbasis dataset Superstore 
•	Tidak wajib terhubung ke payment gateway.
•	Backend bebas (Laravel, Node, Flask, Supabase, dsb.)
•	Wajib menyediakan:
o	File .apk
o	Laporan akhir (cantumkan kelas di masing-masing MK) 
o	Link repository (GitHub/GitLab)
•	Deadline: 26 Desember 2025 pukul 23.59 WIB
•	Link pengumpulan: https://bit.ly/48Pqvlj (buat folder format nim_nama) 
2. Fitur Utama Aplikasi
Aplikasi minimal harus memiliki:
A. Fitur Data Produk
•	List produk
•	Detail produk
•	Pencarian produk
•	Tambah transaksi sederhana
(misal: “jual produk ini”, “reservasi item ini”, atau “tambah order”)
B. Mini Dashboard (WAJIB – Modifikasi terbaru)
Dashboard harus mengambil data dari backend atau file lokal yang:
•	Menampilkan ringkasan penjualan, misal:
o	total sales
o	sales per category
o	best-selling product
o	tren sales sederhana (misal chart garis 7 hari terakhir)
Dashboard tidak harus selengkap BI, tapi cukup merepresentasikan insight dasar.
C. Integrasi API
Aplikasi harus memanggil API backend untuk:
•	mengambil daftar produk
•	membuat transaksi baru
•	mengambil summary data dashboard 
D. Bonus (poin tambahan)
•	Barcode/QR scanner untuk mencari produk
•	Grafik interaktif (line, bar) dengan package seperti fl_chart
•	Mode dark/light
•	Notifikasi local (mis: pengingat stok menipis → dummy rule)

 
Tugas Akhir MK Business Intelligence
1. Dataset yang digunakan
Superstore Sales Dataset – Kaggle
https://www.kaggle.com/datasets/rohitsahoo/sales-forecasting/data
Dataset yang diberikan berbentuk flat table, sehingga mahasiswa wajib melakukan:
2. Tugas BI yang harus dikerjakan
A. Analisis Dataset
•	Identifikasi atribut
•	Temukan masalah data (redundansi, missing values, format tanggal, dll.)
•	Dokumentasi deskriptif awal
B. Desain Data Warehouse
Normalisasi database, kemudian desain data warehouse seperti: 
•	Mendesain Star Schema
o	fact_sales
o	dim_product
o	dim_date
o	dim_customer
o	dim_region
•	Menjelaskan alasan pemilihan grain fact
•	Desain ERD DWH
C. ETL Pipeline
Melakukan proses:
•	Extract → dari CSV Superstore
•	Transform → normalisasi, cleaning, mapping ke dimensi
•	Load → isi fact & dim
•	Boleh pakai: SQL, Python, PowerQuery, Pandas, Airbyte, dsb.
D. Dashboard BI (Bagian Paling Dimodifikasi—konsisten dengan Flutter)
Karena dashboard akhir akan ditampilkan di Flutter, maka:
•	Mahasiswa harus mendesain skema data summary yang akan dipakai oleh aplikasi mobile, misalnya:
o	total_sales
o	sales_by_category
o	top_products
o	monthly_sales_trend
•	BI menghasilkan API-ready dataset (misal JSON format) yang dapat dikonsumsi backend.
Contoh output:
{
  "total_sales": 83402.20,
  "top_products": [
    {"name": "Staple Envelope", "sales": 3200},
    {"name": "Office Chair", "sales": 2800}
  ],
  "sales_by_category": {
    "Furniture": 24000,
    "Office Supplies": 36000,
    "Technology": 23000
  }
}
Back-end bebas ingin menyimpannya di:
1.	database
2.	endpoint API
3.	atau JSON static file (asalkan konsisten)

 
Alur Integrasi BI ↔ Mobile (Modifikasi Penting)
1.	MK BI menghasilkan data olahan & insight summary
(format tabel/JSON yang siap dikonsumsi aplikasi mobile)
2.	Backend dari MK Mobile mengambil data tersebut, lalu:
•	simpan ke endpoint API
•	atau generate ulang berdasarkan data transaksi
3.	Aplikasi Flutter menampilkan dashboard mini berdasarkan data tersebut.
Dengan alur ini:
•	MK BI fokus pada pengolahan data & insight,
•	MK Mobile fokus pada UI + API + fungsionalitas,
•	Keduanya tetap “terhubung” dalam satu skenario retail analytics.

Rubrik Penilaian (Versi Revisi—Selaras dengan Integrasi)
MK BI
Komponen	Bobot
Pemahaman dataset	20%
Desain DWH	25%
ETL & data quality	25%
Dashboard Insight	20%
Laporan & presentasi	10%
MK Mobile Programming 
Komponen	Bobot
UI/UX	20%
Fitur dasar	30%
Integrasi API	20%
Code quality	20%
Bonus	10%


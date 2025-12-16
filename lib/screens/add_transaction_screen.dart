import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/api_service.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  // 👉 CUSTOMER INPUT MANUAL
  final TextEditingController _customerController = TextEditingController();

  List<Product> _products = [];

  Product? _selectedProduct;
  int _quantity = 1;
  DateTime _selectedDate = DateTime.now();

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final products = await ApiService.fetchProducts();
      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product wajib dipilih')),
      );
      return;
    }

    final sale = Sale(
      customerId: _customerController.text.trim(),
      productId: _selectedProduct!.id.toString(),
      quantity: _quantity,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
    );

    try {
      final ok = await ApiService.createSale(sale);
      if (!mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuat transaksi')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ================= CUSTOMER INPUT =================
                            TextFormField(
                              controller: _customerController,
                              decoration: const InputDecoration(
                                labelText: 'Customer ID / Name',
                                hintText: 'Contoh: CG-12520 atau Budi',
                                filled: true,
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Customer wajib diisi'
                                  : null,
                            ),

                            const SizedBox(height: 12),

                            // ================= PRODUCT =================
                            DropdownButtonFormField<Product>(
                              decoration: const InputDecoration(
                                labelText: 'Product',
                                filled: true,
                              ),
                              value: _selectedProduct,
                              items: _products
                                  .map(
                                    (p) => DropdownMenuItem<Product>(
                                      value: p,
                                      child: Text(p.productName),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedProduct = v),
                              validator: (v) =>
                                  v == null ? 'Pilih product' : null,
                            ),

                            const SizedBox(height: 12),

                            // ================= QUANTITY =================
                            TextFormField(
                              initialValue: '1',
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                filled: true,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                if (n == null || n <= 0) {
                                  return 'Quantity tidak valid';
                                }
                                return null;
                              },
                              onChanged: (v) =>
                                  _quantity = int.tryParse(v) ?? 1,
                            ),

                            const SizedBox(height: 12),

                            // ================= DATE =================
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                                  ),
                                ),
                                FilledButton.tonal(
                                  onPressed: _pickDate,
                                  child: const Text('Pick Date'),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ================= SUBMIT =================
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _submit,
                                child: const Text('Submit'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
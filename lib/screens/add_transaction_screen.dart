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
  List<Map<String, dynamic>> _customers = [];
  List<Product> _products = [];

  String? _selectedCustomerId;
  Product? _selectedProduct;
  int? _quantity;
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
      final customers = await ApiService.fetchCustomers();
      final products = await ApiService.fetchProducts();
      setState(() {
        _customers = customers;
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

  String _extractCustomerId(Map<String, dynamic> m) {
    return (m['id'] ?? m['customer_id'] ?? m['customerId'] ?? m['code'] ?? m['uid'] ?? m['key'] ?? '').toString();
  }

  String _extractCustomerLabel(Map<String, dynamic> m) {
    return (m['name'] ?? m['customer_name'] ?? m['full_name'] ?? m['label'] ?? m['title'] ?? _extractCustomerId(m)).toString();
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
    if (_selectedCustomerId == null || _selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select customer and product')));
      return;
    }

    _formKey.currentState!.save();

    final sale = Sale(
      customerId: _selectedCustomerId!,
      productId: _selectedProduct!.id.toString(),
      quantity: _quantity ?? 1,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
    );

    try {
      final ok = await ApiService.createSale(sale);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale created')));
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create sale')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
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
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(labelText: 'Customer', filled: true),
                              items: _customers.map((c) {
                                final id = _extractCustomerId(c);
                                final label = _extractCustomerLabel(c);
                                return DropdownMenuItem(value: id, child: Text(label));
                              }).toList(),
                              initialValue: _selectedCustomerId,
                              onChanged: (v) => setState(() => _selectedCustomerId = v),
                              validator: (v) => v == null || v.isEmpty ? 'Select customer' : null,
                            ),

                            const SizedBox(height: 12),

                            DropdownButtonFormField<Product>(
                              decoration: InputDecoration(labelText: 'Product', filled: true),
                              items: _products.map((p) => DropdownMenuItem(value: p, child: Text(p.productName))).toList(),
                              initialValue: _selectedProduct,
                              onChanged: (v) => setState(() => _selectedProduct = v),
                              validator: (v) => v == null ? 'Select product' : null,
                            ),

                            const SizedBox(height: 12),

                            TextFormField(
                              initialValue: '1',
                              decoration: const InputDecoration(labelText: 'Quantity', hintText: '1', filled: true),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Enter quantity';
                                final n = int.tryParse(v);
                                if (n == null || n <= 0) return 'Enter a valid quantity';
                                return null;
                              },
                              onSaved: (v) => _quantity = int.tryParse(v ?? '1') ?? 1,
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(child: Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}')),
                                FilledButton.tonal(onPressed: _pickDate, child: const Text('Pick Date')),
                              ],
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(onPressed: _submit, child: const Text('Submit')),
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

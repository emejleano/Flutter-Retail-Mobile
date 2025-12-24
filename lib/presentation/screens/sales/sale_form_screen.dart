import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/region_model.dart';
import '../../../data/services/product_service.dart';
import '../../../data/services/customer_service.dart';
import '../../../data/services/region_service.dart';
import '../../../providers/sale_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../widgets/common/dialogs.dart';
import '../scanner/barcode_scanner_screen.dart';

class SaleFormScreen extends StatefulWidget {
  final Sale? sale;

  const SaleFormScreen({super.key, this.sale});

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _orderIdController;
  late TextEditingController _productIdController;
  late TextEditingController _customerIdController;
  late TextEditingController _regionIdController;
  late TextEditingController _salesController;
  late TextEditingController _quantityController;
  late TextEditingController _profitController;
  
  DateTime _selectedOrderDate = DateTime.now();
  DateTime _selectedShipDate = DateTime.now();
  bool _isLoading = false;
  
  final ProductService _productService = ProductService();
  final CustomerService _customerService = CustomerService();
  final RegionService _regionService = RegionService();
  
  Product? _selectedProduct;
  Customer? _selectedCustomer;
  Region? _selectedRegion;
  
  // Region state (load all once)
  List<Region> _regions = [];
  bool _isLoadingRegions = false;

  bool get isEditing => widget.sale != null;

  @override
  void initState() {
    super.initState();
    _orderIdController = TextEditingController(text: widget.sale?.orderId ?? '');
    _productIdController = TextEditingController(text: widget.sale?.productId ?? '');
    _customerIdController = TextEditingController(text: widget.sale?.customerId ?? '');
    _regionIdController = TextEditingController(text: widget.sale?.regionId ?? '');
    _salesController = TextEditingController(text: widget.sale?.sales.toString() ?? '');
    _quantityController = TextEditingController(text: widget.sale?.quantity.toString() ?? '');
    _profitController = TextEditingController(text: widget.sale?.profit.toString() ?? '');
    
    if (widget.sale != null) {
      _selectedOrderDate = DateFormatter.dateIdToDate(widget.sale!.dateId);
      // Ship date - try to parse from sale if available, otherwise use order date + 1 day
      if (widget.sale!.shipDateId != null && widget.sale!.shipDateId! > 0) {
        _selectedShipDate = DateFormatter.dateIdToDate(widget.sale!.shipDateId!);
      } else {
        _selectedShipDate = _selectedOrderDate.add(const Duration(days: 1));
      }
      _loadExistingData();
    } else {
      // Default ship date is tomorrow
      _selectedShipDate = _selectedOrderDate.add(const Duration(days: 1));
    }
    _loadRegions();
  }
  
  Future<void> _loadExistingData() async {
    if (widget.sale == null) return;
    
    // Load product if available
    if (widget.sale!.product != null) {
      setState(() {
        _selectedProduct = widget.sale!.product;
      });
    } else if (widget.sale!.productId.isNotEmpty) {
      try {
        final resp = await _productService.getProducts(search: widget.sale!.productId, page: 1);
        if (resp.data.isNotEmpty && mounted) {
          setState(() {
            _selectedProduct = resp.data.first;
          });
        }
      } catch (_) {}
    }
    
    // Load customer if available
    if (widget.sale!.customer != null) {
      setState(() {
        _selectedCustomer = widget.sale!.customer;
      });
    } else if (widget.sale!.customerId.isNotEmpty) {
      try {
        final resp = await _customerService.getCustomers(search: widget.sale!.customerId, page: 1);
        if (resp.data.isNotEmpty && mounted) {
          setState(() {
            _selectedCustomer = resp.data.first;
          });
        }
      } catch (_) {}
    }
    
    // Region will be matched when regions load
  }
  
  Future<void> _loadRegions() async {
    setState(() => _isLoadingRegions = true);
    try {
      final resp = await _regionService.getRegions();
      if (mounted) {
        setState(() {
          _regions = resp;
          _isLoadingRegions = false;
          
          // Match existing region if editing
          if (widget.sale != null && widget.sale!.regionId.isNotEmpty) {
            _selectedRegion = _regions.firstWhere(
              (r) => r.regionId == widget.sale!.regionId,
              orElse: () => _regions.isNotEmpty ? _regions.first : Region(
                regionId: widget.sale!.regionId,
                region: '',
                country: '',
                state: '',
                city: '',
                postalCode: '',
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRegions = false);
      }
    }
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    _productIdController.dispose();
    _customerIdController.dispose();
    _regionIdController.dispose();
    _salesController.dispose();
    _quantityController.dispose();
    _profitController.dispose();
    super.dispose();
  }

  Future<void> _selectOrderDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedOrderDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedOrderDate = date;
        // Ensure ship date is not before order date
        if (_selectedShipDate.isBefore(date)) {
          _selectedShipDate = date.add(const Duration(days: 1));
        }
      });
    }
  }
  
  Future<void> _selectShipDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedShipDate,
      firstDate: _selectedOrderDate, // Ship date must be >= order date
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedShipDate = date);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<SaleProvider>();
      bool success;

      final data = {
        'order_id': _orderIdController.text.trim(),
        'date_id': DateFormatter.dateToDateId(_selectedOrderDate),
        'ship_date_id': DateFormatter.dateToDateId(_selectedShipDate),
        'product_id': _productIdController.text.trim(),
        'customer_id': _customerIdController.text.trim(),
        'region_id': _selectedRegion?.regionId ?? _regionIdController.text.trim(),
        'sales': double.parse(_salesController.text),
        'quantity': int.parse(_quantityController.text),
        'discount': 0.0, // No discount for customer checkout
        'profit': double.parse(_profitController.text),
      };

      if (isEditing && widget.sale?.factId != null) {
        success = await provider.updateSale(widget.sale!.factId!, data);
      } else {
        final sale = Sale(
          orderId: data['order_id'] as String,
          dateId: data['date_id'] as int,
          shipDateId: data['ship_date_id'] as int,
          productId: data['product_id'] as String,
          customerId: data['customer_id'] as String,
          regionId: data['region_id'] as String,
          sales: data['sales'] as double,
          quantity: data['quantity'] as int,
          discount: data['discount'] as double,
          profit: data['profit'] as double,
        );
        success = await provider.createSale(sale);
      }

      if (mounted) {
        if (success) {
          showSnackBar(
            context,
            message: isEditing ? 'Sale updated' : 'Sale created',
            isSuccess: true,
          );
          Navigator.pop(context);
        } else {
          showSnackBar(
            context,
            message: provider.error ?? 'Operation failed',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, message: 'Error: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _recalculateSales() {
    final unitPrice = _selectedProduct?.avgUnitPrice;
    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;

    if (unitPrice == null || qty <= 0) return;

    // Sales = unit price × quantity (no discount for customer)
    final sales = unitPrice * qty;
    _salesController.text = sales.toStringAsFixed(2);
    
    // Auto-calculate profit as 5% of sales
    final profit = sales * 0.05;
    _profitController.text = profit.toStringAsFixed(2);
  }

  void _onProductSelected(Product product) {
    setState(() {
      _selectedProduct = product;
      _productIdController.text = product.productId;
    });
    _recalculateSales();
  }
  
  void _onCustomerSelected(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      _customerIdController.text = customer.customerId;
    });
  }
  
  void _onRegionSelected(Region region) {
    setState(() {
      _selectedRegion = region;
      _regionIdController.text = region.regionId;
    });
  }
  
  // Show product search dialog
  Future<void> _showProductSearchDialog() async {
    final result = await showDialog<Product>(
      context: context,
      builder: (context) => _SearchDialog<Product>(
        title: 'Search Product',
        hintText: 'Enter product ID or name...',
        searchFn: (query) async {
          final resp = await _productService.getProducts(search: query, page: 1);
          return resp.data;
        },
        itemBuilder: (product) => ListTile(
          leading: const Icon(Icons.inventory_2_outlined),
          title: Text(product.productName, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${product.productId} • ${product.category} • ${DateFormatter.formatCurrency(product.avgUnitPrice ?? 0)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        displayString: (p) => p.productId,
      ),
    );
    
    if (result != null) {
      _onProductSelected(result);
    }
  }
  
  // Show customer search dialog
  Future<void> _showCustomerSearchDialog() async {
    final result = await showDialog<Customer>(
      context: context,
      builder: (context) => _SearchDialog<Customer>(
        title: 'Search Customer',
        hintText: 'Enter customer ID or name...',
        searchFn: (query) async {
          final resp = await _customerService.getCustomers(search: query, page: 1);
          return resp.data;
        },
        itemBuilder: (customer) => ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(customer.customerName, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${customer.customerId} • ${customer.segment}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        displayString: (c) => c.customerId,
      ),
    );
    
    if (result != null) {
      _onCustomerSelected(result);
    }
  }
  
  // Lookup product by ID/barcode
  Future<void> _lookupProduct(String value) async {
    if (value.trim().isEmpty) return;
    
    try {
      final resp = await _productService.getProducts(search: value.trim(), page: 1);
      if (resp.data.isNotEmpty && mounted) {
        _onProductSelected(resp.data.first);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Sale' : 'New Sale'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info banner
            if (!isEditing)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 77),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 77),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'POS Mode: Select product, set quantity, profit is auto-calculated (5%).',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Order ID
            TextFormField(
              controller: _orderIdController,
              decoration: const InputDecoration(
                labelText: 'Order ID *',
                prefixIcon: Icon(Icons.receipt),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Order ID is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Order Date & Ship Date Row
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectOrderDate,
                    borderRadius: BorderRadius.circular(8),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Order Date *',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(DateFormatter.formatDate(_selectedOrderDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectShipDate,
                    borderRadius: BorderRadius.circular(8),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Ship Date *',
                        prefixIcon: Icon(Icons.local_shipping),
                      ),
                      child: Text(DateFormatter.formatDate(_selectedShipDate)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Product Selection
            TextFormField(
              controller: _productIdController,
              readOnly: true,
              onTap: _showProductSearchDialog,
              decoration: InputDecoration(
                labelText: 'Product *',
                prefixIcon: const Icon(Icons.inventory_2),
                hintText: 'Tap to search product...',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Search',
                      onPressed: _showProductSearchDialog,
                      icon: const Icon(Icons.search),
                    ),
                    IconButton(
                      tooltip: 'Scan',
                      onPressed: _isLoading ? null : () async {
                        final scanned = await Navigator.push<String?>(
                          context,
                          MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
                        );
                        if (scanned != null && scanned.trim().isNotEmpty) {
                          await _lookupProduct(scanned.trim());
                        }
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                    ),
                  ],
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Product is required';
                }
                if (_selectedProduct == null) {
                  return 'Please select a product';
                }
                return null;
              },
            ),
            
            // Selected Product Info
            if (_selectedProduct != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 77),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedProduct!.productName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${_selectedProduct!.category} • ${DateFormatter.formatCurrency(_selectedProduct!.avgUnitPrice ?? 0)}/unit',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() {
                          _selectedProduct = null;
                          _productIdController.clear();
                          _salesController.clear();
                          _profitController.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            
            // Customer Selection
            TextFormField(
              controller: _customerIdController,
              readOnly: true,
              onTap: _showCustomerSearchDialog,
              decoration: InputDecoration(
                labelText: 'Customer *',
                prefixIcon: const Icon(Icons.person),
                hintText: 'Tap to search customer...',
                suffixIcon: IconButton(
                  tooltip: 'Search',
                  onPressed: _showCustomerSearchDialog,
                  icon: const Icon(Icons.search),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Customer is required';
                }
                return null;
              },
            ),
            
            // Selected Customer Info
            if (_selectedCustomer != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${_selectedCustomer!.customerName} • ${_selectedCustomer!.segment}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            // Region Dropdown
            DropdownButtonFormField<Region>(
              value: _selectedRegion,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Region *',
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon: _isLoadingRegions
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              items: _regions.map((region) {
                return DropdownMenuItem<Region>(
                  value: region,
                  child: Text(
                    '${region.city}, ${region.state} (${region.region})',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (region) {
                if (region != null) {
                  _onRegionSelected(region);
                }
              },
              validator: (value) {
                if (value == null && _regionIdController.text.isEmpty) {
                  return 'Region is required';
                }
                return null;
              },
            ),
            
            // Manual region input fallback
            if (_regions.isEmpty && !_isLoadingRegions)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextFormField(
                  controller: _regionIdController,
                  decoration: const InputDecoration(
                    labelText: 'Region ID (manual)',
                    prefixIcon: Icon(Icons.edit_location),
                    hintText: 'Enter region ID manually',
                  ),
                  validator: (value) {
                    if (_selectedRegion == null && (value == null || value.isEmpty)) {
                      return 'Region ID is required';
                    }
                    return null;
                  },
                ),
              ),
            const SizedBox(height: 16),
            
            // Sales & Quantity Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _salesController,
                    decoration: const InputDecoration(
                      labelText: 'Sales *',
                      prefixIcon: Icon(Icons.attach_money),
                      helperText: 'Auto-calculated',
                    ),
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity *',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _recalculateSales(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Profit field - auto calculated
            TextFormField(
              controller: _profitController,
              decoration: const InputDecoration(
                labelText: 'Profit (5%)',
                prefixIcon: Icon(Icons.trending_up),
                helperText: 'Auto-calculated (no discount for customers)',
              ),
              keyboardType: TextInputType.number,
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                if (double.tryParse(value) == null) {
                  return 'Invalid';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            
            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? 'Update Sale' : 'Create Sale'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Generic search dialog for products and customers
class _SearchDialog<T> extends StatefulWidget {
  final String title;
  final String hintText;
  final Future<List<T>> Function(String query) searchFn;
  final Widget Function(T item) itemBuilder;
  final String Function(T item) displayString;

  const _SearchDialog({
    required this.title,
    required this.hintText,
    required this.searchFn,
    required this.itemBuilder,
    required this.displayString,
  });

  @override
  State<_SearchDialog<T>> createState() => _SearchDialogState<T>();
}

class _SearchDialogState<T> extends State<_SearchDialog<T>> {
  final _searchController = TextEditingController();
  List<T> _results = [];
  bool _isLoading = false;
  String _lastQuery = '';
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _search(String query) async {
    if (query.length < 2 || query == _lastQuery) return;
    _lastQuery = query;
    
    setState(() => _isLoading = true);
    try {
      final results = await widget.searchFn(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              onChanged: _search,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.length < 2
                            ? 'Type at least 2 characters to search'
                            : 'No results found',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        return InkWell(
                          onTap: () => Navigator.pop(context, item),
                          child: widget.itemBuilder(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/common/dialogs.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  late TextEditingController _productIdController;
  late TextEditingController _productNameController;
  late TextEditingController _subCategoryController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  String _selectedCategory = AppConstants.productCategories.first;
  bool _isLoading = false;
  List<String> _subCategoryOptions = [];
  bool _loadingSubCategories = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _productIdController = TextEditingController(text: widget.product?.productId ?? '');
    _productNameController = TextEditingController(text: widget.product?.productName ?? '');
    _subCategoryController = TextEditingController(text: widget.product?.subCategory ?? '');
    _priceController = TextEditingController(
      text: widget.product?.avgUnitPrice?.toString() ?? '',
    );
    _stockController = TextEditingController(text: (widget.product?.stock ?? 0).toString());
    if (widget.product != null) {
      _selectedCategory = widget.product!.category;
    }
    _loadSubCategories();
  }

  Future<void> _loadSubCategories() async {
    setState(() => _loadingSubCategories = true);
    try {
      final subCategories = await _productService.getSubCategories(category: _selectedCategory);
      if (mounted) {
        setState(() {
          _subCategoryOptions = subCategories;
          _loadingSubCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingSubCategories = false);
      }
    }
  }

  void _onCategoryChanged(String? value) {
    if (value != null && value != _selectedCategory) {
      setState(() {
        _selectedCategory = value;
        _subCategoryController.clear();
      });
      _loadSubCategories();
    }
  }

  @override
  void dispose() {
    _productIdController.dispose();
    _productNameController.dispose();
    _subCategoryController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<ProductProvider>();
      bool success;

      final stock = int.tryParse(_stockController.text.trim()) ?? 0;

      if (isEditing) {
        success = await provider.updateProduct(
          widget.product!.productId,
          {
            'product_name': _productNameController.text.trim(),
            'category': _selectedCategory,
            'sub_category': _subCategoryController.text.trim(),
            if (_priceController.text.isNotEmpty)
              'avg_unit_price': double.parse(_priceController.text),
            'stock': stock,
          },
        );
      } else {
        final product = Product(
          productId: _productIdController.text.trim(),
          productName: _productNameController.text.trim(),
          category: _selectedCategory,
          subCategory: _subCategoryController.text.trim(),
          avgUnitPrice: _priceController.text.isNotEmpty
              ? double.parse(_priceController.text)
              : null,
          stock: stock,
        );
        success = await provider.createProduct(product);
      }

      if (mounted) {
        final l = AppLocalizations.of(context);
        if (success) {
          showSnackBar(
            context,
            message: isEditing ? l.productUpdated : l.productCreated,
            isSuccess: true,
          );
          Navigator.pop(context);
        } else {
          showSnackBar(
            context,
            message: provider.error ?? l.operationFailed,
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, message: '${AppLocalizations.of(context).somethingWentWrong}: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l.editProduct : l.addProduct),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _productIdController,
              decoration: InputDecoration(
                labelText: '${l.productId} *',
                prefixIcon: const Icon(Icons.tag),
              ),
              enabled: !isEditing,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l.fieldRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _productNameController,
              decoration: InputDecoration(
                labelText: '${l.productName} *',
                prefixIcon: const Icon(Icons.inventory_2),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l.fieldRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: '${l.category} *',
                prefixIcon: const Icon(Icons.category),
              ),
              items: AppConstants.productCategories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: _onCategoryChanged,
            ),
            const SizedBox(height: 16),
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _subCategoryController.text),
              optionsBuilder: (textEditingValue) {
                final query = textEditingValue.text.trim().toLowerCase();
                if (query.isEmpty) {
                  return _subCategoryOptions;
                }
                return _subCategoryOptions.where(
                  (option) => option.toLowerCase().contains(query),
                );
              },
              onSelected: (selection) {
                _subCategoryController.text = selection;
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                if (textEditingController.text != _subCategoryController.text) {
                  textEditingController.value = textEditingController.value.copyWith(
                    text: _subCategoryController.text,
                    selection: TextSelection.collapsed(offset: _subCategoryController.text.length),
                  );
                }

                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: '${l.subCategory} *',
                    prefixIcon: const Icon(Icons.subdirectory_arrow_right),
                    helperText: _subCategoryOptions.isEmpty 
                        ? (_loadingSubCategories ? l.loading : null) 
                        : l.selectFromListOptional,
                  ),
                  onChanged: (value) {
                    _subCategoryController.text = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l.fieldRequired;
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: l.avgUnitPrice,
                prefixIcon: const Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (double.tryParse(value) == null) {
                    return l.invalidNumber;
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stockController,
              decoration: InputDecoration(
                labelText: '${l.stock} *',
                prefixIcon: const Icon(Icons.inventory),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l.fieldRequired;
                }
                final parsed = int.tryParse(value.trim());
                if (parsed == null || parsed < 0) {
                  return l.invalidNumber;
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
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
                    : Text(isEditing ? l.updateProduct : l.createProduct),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

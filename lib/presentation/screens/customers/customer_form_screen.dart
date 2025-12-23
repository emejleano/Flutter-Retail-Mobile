import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/customer_model.dart';
import '../../../providers/customer_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../data/models/notification_model.dart';
import '../../widgets/common/dialogs.dart';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;

  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _customerIdController;
  late TextEditingController _customerNameController;
  String _selectedSegment = AppConstants.customerSegments.first;
  bool _isLoading = false;

  bool get isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    _customerIdController = TextEditingController(text: widget.customer?.customerId ?? '');
    _customerNameController = TextEditingController(text: widget.customer?.customerName ?? '');
    if (widget.customer != null) {
      _selectedSegment = widget.customer!.segment;
    }
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<CustomerProvider>();
      bool success;

      if (isEditing) {
        success = await provider.updateCustomer(
          widget.customer!.customerId,
          {
            'customer_name': _customerNameController.text.trim(),
            'segment': _selectedSegment,
          },
        );
      } else {
        final customer = Customer(
          customerId: _customerIdController.text.trim(),
          customerName: _customerNameController.text.trim(),
          segment: _selectedSegment,
        );
        success = await provider.createCustomer(customer);
      }

      if (mounted) {
        if (success) {
          final notificationProvider = context.read<NotificationProvider>();
          if (isEditing) {
            notificationProvider.addNotification(
              AppNotification(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Customer updated',
                message: 'Updated customer "${_customerNameController.text.trim()}"',
                type: NotificationType.dataModified,
                createdAt: DateTime.now(),
              ),
            );
          } else {
            notificationProvider.addNotification(
              AppNotification(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Customer created',
                message: 'Created customer "${_customerNameController.text.trim()}"',
                type: NotificationType.dataModified,
                createdAt: DateTime.now(),
              ),
            );
          }

          showSnackBar(
            context,
            message: isEditing ? 'Customer updated' : 'Customer created',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'New Customer'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _customerIdController,
              decoration: const InputDecoration(
                labelText: 'Customer ID *',
                prefixIcon: Icon(Icons.tag),
              ),
              enabled: !isEditing,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Customer ID is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name *',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Customer name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSegment,
              decoration: const InputDecoration(
                labelText: 'Segment *',
                prefixIcon: Icon(Icons.business),
              ),
              items: AppConstants.customerSegments.map((segment) {
                return DropdownMenuItem(value: segment, child: Text(segment));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSegment = value);
                }
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
                    : Text(isEditing ? 'Update Customer' : 'Create Customer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

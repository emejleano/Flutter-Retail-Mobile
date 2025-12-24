import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../data/models/customer_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/customer_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../data/models/notification_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom;
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/dialogs.dart';
import '../../widgets/common/filter_chips.dart';
import 'customer_form_screen.dart';
import 'customer_detail_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Data loading is now handled by HomeScreen on tab selection
    // This ensures data is fetched when user navigates to this tab
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CustomerProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Column(
      children: [
        _buildSearchField(context, isAdmin: authProvider.isAdmin),
        _buildFilterChips(),
        const SizedBox(height: 8),
        Expanded(child: _buildCustomerList(context, authProvider)),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context, {required bool isAdmin}) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l.searchCustomers,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context
                              .read<CustomerProvider>()
                              .loadCustomers(refresh: true, search: '');
                        },
                      )
                    : null,
              ),
              onSubmitted: (value) {
                context
                    .read<CustomerProvider>()
                    .loadCustomers(refresh: true, search: value);
              },
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(width: 12),
            IconButton.filledTonal(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
                );
                if (context.mounted) {
                  context.read<CustomerProvider>().loadCustomers(refresh: true);
                }
              },
              icon: const Icon(Icons.person_add_alt_1),
              tooltip: l.addCustomer,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        return FilterChipGroup(
          options: AppConstants.customerSegments,
          selectedOption: provider.selectedSegment,
          onSelected: (segment) {
            provider.loadCustomers(refresh: true, segment: segment ?? '');
          },
        );
      },
    );
  }

  Widget _buildCustomerList(BuildContext context, AuthProvider authProvider) {
    final l = AppLocalizations.of(context);
    return Consumer<CustomerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.customers.isEmpty) {
          return LoadingWidget(message: l.loading);
        }

        if (provider.error != null && provider.customers.isEmpty) {
          return custom.ErrorWidget(
            message: provider.error!,
            onRetry: () => provider.loadCustomers(refresh: true),
          );
        }

        if (provider.customers.isEmpty) {
          return custom.ErrorWidget(
            message: l.noCustomers,
            icon: Icons.people_outline,
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadCustomers(refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: provider.customers.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= provider.customers.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final customer = provider.customers[index];
              return CustomerCard(
                customer: customer,
                isAdmin: authProvider.isAdmin,
              );
            },
          ),
        );
      },
    );
  }
}

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final bool isAdmin;

  const CustomerCard({super.key, required this.customer, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CustomerDetailScreen(customer: customer)),
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              customer.customerName.isNotEmpty ? customer.customerName[0].toUpperCase() : '?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.customerName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getSegmentColor(customer.segment).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    customer.segment,
                    style: TextStyle(color: _getSegmentColor(customer.segment), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          if (isAdmin) _buildPopupMenu(context),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      onSelected: (value) => _handleMenuAction(context, value),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'edit', child: Text(l.edit)),
        PopupMenuItem(value: 'delete', child: Text(l.delete)),
      ],
    );
  }

  Future<void> _handleMenuAction(BuildContext context, String value) async {
    final l = AppLocalizations.of(context);
    if (value == 'edit') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CustomerFormScreen(customer: customer)),
      );
      if (context.mounted) {
        context.read<CustomerProvider>().loadCustomers(refresh: true);
      }
    } else if (value == 'delete') {
      final confirm = await showConfirmDialog(
        context,
        title: l.deleteCustomer,
        message: l.confirmDeleteCustomerMessage(customer.customerName),
        isDanger: true,
        confirmText: l.delete,
      );
      if (confirm == true && context.mounted) {
        final success = await context.read<CustomerProvider>().deleteCustomer(customer.customerId);
        if (context.mounted) {
          if (success) {
            context.read<NotificationProvider>().addNotification(
                  AppNotification(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: l.customerDeleted,
                    message: '${l.deleteCustomer}: "${customer.customerName}"',
                    type: NotificationType.dataModified,
                    createdAt: DateTime.now(),
                  ),
                );
          }
          showSnackBar(
            context,
            message: success ? l.customerDeleted : l.failedToDeleteCustomer,
            isSuccess: success,
            isError: !success,
          );
        }
      }
    }
  }

  Color _getSegmentColor(String segment) {
    switch (segment.toLowerCase()) {
      case 'consumer':
        return Colors.blue;
      case 'corporate':
        return Colors.purple;
      case 'home office':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

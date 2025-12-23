import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/notification_model.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/app_localizations.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final notificationProvider = context.read<NotificationProvider>();
      // Set role for filtering
      notificationProvider.setUserRole(isAdmin: authProvider.isAdmin);
      notificationProvider.loadNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final l = AppLocalizations.of(context);
    final isAdmin = authProvider.isAdmin;
    
    // Different tabs for admin vs customer
    final tabs = isAdmin
        ? [
            Tab(text: l.allNotifications),
            Tab(text: l.stockAlerts),
          ]
        : [
            Tab(text: l.allNotifications),
            Tab(text: l.orderUpdates),
          ];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l.notifications),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.filteredUnreadCount > 0) {
                return TextButton(
                  onPressed: () => provider.markAllAsRead(),
                  child: Text(l.markAllRead),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: isAdmin
            ? [
                _buildNotificationsList(showAll: true),
                _buildStockAlertsList(),
              ]
            : [
                _buildNotificationsList(showAll: true),
                _buildOrderNotificationsList(),
              ],
      ),
    );
  }

  Widget _buildNotificationsList({bool showAll = false}) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const LoadingWidget();
        }

        if (provider.error != null) {
          return custom.ErrorWidget(
            message: provider.error!,
            onRetry: () => provider.loadNotifications(),
          );
        }

        final notifications = provider.filteredNotifications;
        
        if (notifications.isEmpty) {
          return custom.ErrorWidget(
            message: AppLocalizations.of(context).noNotifications,
            icon: Icons.notifications_none,
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadNotifications(),
          child: ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationCard(notification: notification);
            },
          ),
        );
      },
    );
  }
  
  Widget _buildOrderNotificationsList() {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const LoadingWidget();
        }

        if (provider.error != null) {
          return custom.ErrorWidget(
            message: provider.error!,
            onRetry: () => provider.loadNotifications(),
          );
        }

        // Filter only order-related notifications
        final orderNotifications = provider.customerNotifications
            .where((n) => 
                n.type == NotificationType.orderPlaced ||
                n.type == NotificationType.orderShipped ||
                n.type == NotificationType.orderDelivered)
            .toList();
        
        if (orderNotifications.isEmpty) {
          return custom.ErrorWidget(
            message: AppLocalizations.of(context).noOrderUpdates,
            icon: Icons.receipt_long_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadNotifications(),
          child: ListView.builder(
            itemCount: orderNotifications.length,
            itemBuilder: (context, index) {
              final notification = orderNotifications[index];
              return NotificationCard(notification: notification);
            },
          ),
        );
      },
    );
  }

  Widget _buildStockAlertsList() {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const LoadingWidget();
        }

        if (provider.error != null) {
          return custom.ErrorWidget(
            message: provider.error!,
            onRetry: () => provider.loadNotifications(),
          );
        }

        if (provider.stockAlerts.isEmpty) {
          return const custom.ErrorWidget(
            message: 'No stock alerts',
            icon: Icons.inventory_2_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadNotifications(),
          child: ListView.builder(
            itemCount: provider.stockAlerts.length,
            itemBuilder: (context, index) {
              final alert = provider.stockAlerts[index];
              return StockAlertCard(alert: alert);
            },
          ),
        );
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final AppNotification notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<NotificationProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: notification.isRead ? null : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(notification.type),
          child: Icon(_getTypeIcon(notification.type), color: Colors.white, size: 20),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatDateTime(notification.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => provider.markAsRead(notification.id),
              ),
        onTap: () {
          if (!notification.isRead) {
            provider.markAsRead(notification.id);
          }
        },
      ),
    );
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      // Admin notifications
      case NotificationType.stockAlert:
        return Colors.orange;
      case NotificationType.stockOpname:
        return Colors.deepOrange;
      case NotificationType.salesUpdate:
        return Colors.green;
      case NotificationType.dataModified:
        return Colors.indigo;
      // Customer notifications
      case NotificationType.orderPlaced:
        return Colors.blue;
      case NotificationType.orderShipped:
        return Colors.teal;
      case NotificationType.orderDelivered:
        return Colors.green;
      case NotificationType.promotion:
        return Colors.pink;
      // System notifications
      case NotificationType.systemMessage:
        return Colors.blueGrey;
      case NotificationType.reminder:
        return Colors.purple;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      // Admin notifications
      case NotificationType.stockAlert:
        return Icons.warning;
      case NotificationType.stockOpname:
        return Icons.inventory_2;
      case NotificationType.salesUpdate:
        return Icons.trending_up;
      case NotificationType.dataModified:
        return Icons.edit_note;
      // Customer notifications
      case NotificationType.orderPlaced:
        return Icons.shopping_bag;
      case NotificationType.orderShipped:
        return Icons.local_shipping;
      case NotificationType.orderDelivered:
        return Icons.check_circle;
      case NotificationType.promotion:
        return Icons.local_offer;
      // System notifications
      case NotificationType.systemMessage:
        return Icons.info;
      case NotificationType.reminder:
        return Icons.alarm;
    }
  }
}

class StockAlertCard extends StatelessWidget {
  final StockAlert alert;

  const StockAlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLow = alert.currentStock <= alert.minimumStock;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLow ? Colors.red : Colors.orange,
          child: Icon(
            isLow ? Icons.warning : Icons.inventory,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          alert.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(alert.productId),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Stock: ${alert.currentStock}',
              style: TextStyle(
                color: isLow ? Colors.red : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Min: ${alert.minimumStock}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

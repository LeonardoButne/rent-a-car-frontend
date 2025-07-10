import 'package:flutter/material.dart';
import 'package:rent_a_car_app/features/notifications/models/notification_item.dart';
import 'package:rent_a_car_app/features/notifications/services/notification_service.dart';
import 'package:rent_a_car_app/features/notifications/widgets/notification_state.dart';
import 'package:rent_a_car_app/features/notifications/widgets/notification_widgets.dart';
import 'package:rent_a_car_app/features/notifications/helpers/notification_helpers.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late Future<List<NotificationItem>> _futureNotifications;
  List<NotificationItem> _selectedNotifications = [];
  bool _isSelectionMode = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _loadNotifications() {
    setState(() {
      _futureNotifications = NotificationService.fetchNotifications();
    });
  }

  void _toggleSelection(NotificationItem notification) {
    setState(() {
      if (_selectedNotifications.contains(notification)) {
        _selectedNotifications.remove(notification);
      } else {
        _selectedNotifications.add(notification);
      }

      if (_selectedNotifications.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _onNotificationTap(NotificationItem notification) async {
    if (_isSelectionMode) {
      _toggleSelection(notification);
      return;
    }

    // Marca como lida se não estiver lida
    if (!notification.isRead) {
      try {
        await NotificationService.markAsRead(notification.id);
        _loadNotifications(); // Recarrega para atualizar o status
      } catch (e) {
        NotificationFeedback.showError(context, 'Erro ao marcar como lida');
      }
    }

    // Navega para a tela apropriada
    NotificationNavigator.navigateToTarget(context, notification);
  }

  void _onNotificationLongPress(NotificationItem notification) {
    setState(() {
      _isSelectionMode = true;
      if (!_selectedNotifications.contains(notification)) {
        _selectedNotifications.add(notification);
      }
    });
  }

  void _onBackPressed() {
    if (_isSelectionMode) {
      setState(() {
        _isSelectionMode = false;
        _selectedNotifications.clear();
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _onSelectAll(List<NotificationItem> notifications) {
    setState(() {
      _selectedNotifications = List.from(notifications);
    });
  }

  void _onDeselectAll() {
    setState(() {
      _selectedNotifications.clear();
    });
  }

  Future<void> _onDeleteSelected() async {
    if (_selectedNotifications.isEmpty) return;

    final confirmed = await NotificationDialogs.showDeleteConfirmation(
      context,
      _selectedNotifications.length,
    );

    if (!confirmed) return;

    try {
      final notificationIds = _selectedNotifications.map((n) => n.id).toList();
      await NotificationService.deleteMultipleNotifications(notificationIds);

      setState(() {
        _selectedNotifications.clear();
        _isSelectionMode = false;
      });

      _loadNotifications();
      NotificationFeedback.showSuccess(
        context,
        'Notificações deletadas com sucesso',
      );
    } catch (e) {
      NotificationFeedback.showError(context, 'Erro ao deletar notificações');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<List<NotificationItem>>(
      future: _futureNotifications,
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];
        final unreadCount = notifications.where((n) => !n.isRead).length;

        return NotificationHeader(
          unreadCount: unreadCount,
          isSelectionMode: _isSelectionMode,
          selectedCount: _selectedNotifications.length,
          onBackPressed: _onBackPressed,
          onDeleteSelected: _selectedNotifications.isNotEmpty
              ? _onDeleteSelected
              : null,
          onSelectAll: _isSelectionMode
              ? () => _onSelectAll(notifications)
              : null,
          onDeselectAll: _isSelectionMode && _selectedNotifications.isNotEmpty
              ? _onDeselectAll
              : null,
        );
      },
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<NotificationItem>>(
      future: _futureNotifications,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const NotificationLoadingState();
        }

        if (snapshot.hasError) {
          return NotificationErrorState(onRetry: _loadNotifications);
        }

        final notifications = snapshot.data ?? [];
        if (notifications.isEmpty) {
          return const NotificationEmptyState();
        }

        return _buildNotificationsList(notifications);
      },
    );
  }

  Widget _buildNotificationsList(List<NotificationItem> notifications) {
    final groupedNotifications = NotificationGrouper.groupByPeriod(
      notifications,
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final entry in groupedNotifications.entries) ...[
          SectionHeader(title: entry.key),
          ...entry.value
              .map(
                (notification) => NotificationCard(
                  notification: notification,
                  isSelected: _selectedNotifications.contains(notification),
                  isSelectionMode: _isSelectionMode,
                  onTap: () => _onNotificationTap(notification),
                  onLongPress: () => _onNotificationLongPress(notification),
                ),
              )
              .toList(),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

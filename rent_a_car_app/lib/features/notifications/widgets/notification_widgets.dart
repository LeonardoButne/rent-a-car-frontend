import 'package:flutter/material.dart';
import 'package:rent_a_car_app/features/notifications/models/notification_item.dart';

/// Header da tela de notificações
class NotificationHeader extends StatelessWidget {
  final int unreadCount;
  final bool isSelectionMode;
  final int selectedCount;
  final VoidCallback onBackPressed;
  final VoidCallback? onDeleteSelected;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;

  const NotificationHeader({
    super.key,
    required this.unreadCount,
    required this.isSelectionMode,
    required this.selectedCount,
    required this.onBackPressed,
    this.onDeleteSelected,
    this.onSelectAll,
    this.onDeselectAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildBackButton(),
              const SizedBox(width: 16),
              Expanded(child: _buildHeaderTitle()),
              if (isSelectionMode) _buildDeleteButton() else _buildMenuButton(),
            ],
          ),
          if (isSelectionMode) ...[
            const SizedBox(height: 16),
            _buildSelectionActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: onBackPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isSelectionMode
              ? Icons.close_rounded
              : Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSelectionMode ? '$selectedCount Selecionadas' : 'Notificações',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        if (!isSelectionMode && unreadCount > 0)
          Text(
            '$unreadCount novas notificações',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: onDeleteSelected,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          size: 20,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.more_horiz_rounded,
        size: 20,
        color: Color(0xFF64748B),
      ),
    );
  }

  Widget _buildSelectionActions() {
    return Row(
      children: [
        _buildActionButton(
          'Selecionar todas',
          Icons.select_all_rounded,
          onSelectAll,
        ),
        const Spacer(),
        _buildActionButton(
          'Desmarcar todas',
          Icons.deselect_rounded,
          onDeselectAll,
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF475569)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card individual de notificação
class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NotificationIcon(type: notification.type),
                const SizedBox(width: 16),
                Expanded(
                  child: NotificationContent(notification: notification),
                ),
                const SizedBox(width: 12),
                NotificationTrailing(
                  notification: notification,
                  isSelected: isSelected,
                  isSelectionMode: isSelectionMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ícone da notificação
class NotificationIcon extends StatelessWidget {
  final String type;

  const NotificationIcon({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getNotificationColor(type).withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        _getNotificationIcon(type),
        color: _getNotificationColor(type),
        size: 24,
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'reservation_request':
        return Icons.car_rental_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'pickup':
        return Icons.schedule_rounded;
      case 'return':
        return Icons.warning_rounded;
      case 'cancellation':
        return Icons.cancel_rounded;
      case 'discount':
        return Icons.local_offer_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'reservation_request':
        return Colors.black;
      case 'payment':
        return Colors.black;
      case 'pickup':
        return Colors.black;
      case 'return':
        return Colors.black;
      case 'cancellation':
        return Colors.black;
      case 'discount':
        return Colors.black;
      default:
        return Colors.black;
    }
  }
}

/// Conteúdo da notificação
class NotificationContent extends StatelessWidget {
  final NotificationItem notification;

  const NotificationContent({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: notification.isRead
                      ? FontWeight.w500
                      : FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            Text(
              _formatTime(notification.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          notification.message,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Agora';
    }
  }
}

/// Trailing da notificação (checkbox ou indicador)
class NotificationTrailing extends StatelessWidget {
  final NotificationItem notification;
  final bool isSelected;
  final bool isSelectionMode;

  const NotificationTrailing({
    super.key,
    required this.notification,
    required this.isSelected,
    required this.isSelectionMode,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelectionMode) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2196F3)
                : const Color(0xFFCBD5E1),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 14)
            : null,
      );
    } else if (!notification.isRead) {
      return Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Color(0xFF2196F3),
          shape: BoxShape.circle,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

/// Cabeçalho de seção (Hoje, Ontem, etc.)
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
        ),
      ),
    );
  }
}

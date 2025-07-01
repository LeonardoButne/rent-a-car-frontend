class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    required this.type,
  });
}

enum NotificationType {
  booking, // Reservas
  payment, // Pagamentos
  reminder, // Lembretes
  promotion, // Promoções
  system, // Sistema
}

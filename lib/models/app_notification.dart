/// A notification shown to a customer or to a repair business.
class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final bool forCustomer; // true = customer, false = repair business
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.forCustomer,
    this.isRead = false,
  });
}

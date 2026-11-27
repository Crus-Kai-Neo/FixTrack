import 'package:flutter/foundation.dart';
import '../models/app_notification.dart';
import '../models/repair_request.dart';
import '../models/shop.dart';

enum UserRole { customer, business }

DateTime _ago({int days = 0, int hours = 0, int minutes = 0}) {
  return DateTime.now()
      .subtract(Duration(days: days, hours: hours, minutes: minutes));
}

/// Temporary in-memory "backend" so every screen works with sample data.
/// LATER: replace the methods in this file with real API calls
/// (ASP.NET Core Web API) and keep the screens almost unchanged.
class MockService extends ChangeNotifier {
  MockService._();
  static final MockService instance = MockService._();

  /// The demo repair business (TechCare Repairs).
  static const String businessShopId = 's1';

  UserRole role = UserRole.customer;
  String userName = 'Aayush Sharma';
  String userEmail = 'aayush@example.com';

  int _nextRequestNumber = 5;
  int _nextNotificationNumber = 5;

  final List<Shop> shops = const [
    Shop(
      id: 's1',
      name: 'TechCare Repairs',
      location: 'Kathmandu',
      phone: '9800000001',
      deviceTypes: ['Phones', 'Laptops', 'Tablets'],
      isOpen: true,
    ),
    Shop(
      id: 's2',
      name: 'FixPoint Electronics',
      location: 'Lalitpur',
      phone: '9800000002',
      deviceTypes: ['Laptops', 'Desktops'],
      isOpen: true,
    ),
    Shop(
      id: 's3',
      name: 'Mobile Doctor',
      location: 'Kathmandu',
      phone: '9800000003',
      deviceTypes: ['Phones', 'Tablets'],
      isOpen: false,
    ),
    Shop(
      id: 's4',
      name: 'Bhaktapur PC Care',
      location: 'Bhaktapur',
      phone: '9800000004',
      deviceTypes: ['Phones', 'Laptops', 'Desktops'],
      isOpen: true,
    ),
  ];

  final List<RepairRequest> requests = [
    RepairRequest(
      id: 'FT-001',
      customerName: 'Aayush Sharma',
      deviceType: 'Laptop',
      deviceModel: 'Dell Inspiron 15',
      problem: 'Laptop is not charging when plugged in. Please check the charging port.',
      shopId: 's1',
      shopName: 'TechCare Repairs',
      submittedAt: _ago(days: 2),
      updatedAt: _ago(hours: 2),
      stage: RequestStage.booked,
      estimatedCost: 5000,
      estimatedTime: '2 days',
      shopNotes: 'Charging port needs inspection and possible replacement.',
      status: RepairStatus.repairing,
    ),
    RepairRequest(
      id: 'FT-002',
      customerName: 'Aayush Sharma',
      deviceType: 'Smartphone',
      deviceModel: 'iPhone 13',
      problem: 'Battery drains very fast.',
      shopId: 's3',
      shopName: 'Mobile Doctor',
      submittedAt: _ago(days: 12),
      updatedAt: _ago(days: 9),
      stage: RequestStage.booked,
      estimatedCost: 3000,
      estimatedTime: '1 day',
      shopNotes: 'Battery replacement.',
      status: RepairStatus.collected,
    ),
    RepairRequest(
      id: 'FT-003',
      customerName: 'Priya Thapa',
      deviceType: 'Smartphone',
      deviceModel: 'Samsung Galaxy A54',
      problem: 'Cracked screen after a fall.',
      shopId: 's1',
      shopName: 'TechCare Repairs',
      submittedAt: _ago(hours: 3),
      updatedAt: _ago(hours: 3),
    ),
    RepairRequest(
      id: 'FT-004',
      customerName: 'Rohan Shrestha',
      deviceType: 'Laptop',
      deviceModel: 'HP Pavilion 14',
      problem: 'Laptop is very slow and the fan is noisy.',
      shopId: 's1',
      shopName: 'TechCare Repairs',
      submittedAt: _ago(days: 1),
      updatedAt: _ago(days: 1),
    ),
  ];

  final List<AppNotification> notifications = [
    AppNotification(
      id: 'n1',
      title: 'Repair update',
      message: 'Your Dell Inspiron 15 (FT-001) is now Repairing.',
      time: _ago(hours: 2),
      forCustomer: true,
    ),
    AppNotification(
      id: 'n2',
      title: 'Repair collected',
      message: 'Your iPhone 13 (FT-002) was collected. Thank you for using FixTrack.',
      time: _ago(days: 9),
      forCustomer: true,
      isRead: true,
    ),
    AppNotification(
      id: 'n3',
      title: 'New repair request',
      message: 'Priya Thapa sent a request for Samsung Galaxy A54 (FT-003).',
      time: _ago(hours: 3),
      forCustomer: false,
    ),
    AppNotification(
      id: 'n4',
      title: 'New repair request',
      message: 'Rohan Shrestha sent a request for HP Pavilion 14 (FT-004).',
      time: _ago(days: 1),
      forCustomer: false,
    ),
  ];

  // ---------------------------------------------------------------- session

  void login(UserRole newRole, String email, {String? name}) {
    role = newRole;
    userEmail = email;
    if (name != null && name.isNotEmpty) {
      userName = name;
    } else {
      userName =
          newRole == UserRole.customer ? 'Aayush Sharma' : 'TechCare Repairs';
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------- queries

  Shop shopById(String id) => shops.firstWhere((s) => s.id == id);

  List<RepairRequest> get customerRequests {
    final list = requests.where((r) => r.customerName == userName).toList();
    list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return list;
  }

  List<RepairRequest> get shopRequests {
    final list = requests.where((r) => r.shopId == businessShopId).toList();
    list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return list;
  }

  List<AppNotification> get myNotifications {
    final isCustomer = role == UserRole.customer;
    final list = notifications.where((n) => n.forCustomer == isCustomer).toList();
    list.sort((a, b) => b.time.compareTo(a.time));
    return list;
  }

  int get unreadCount => myNotifications.where((n) => !n.isRead).length;

  // ------------------------------------------------------- customer actions

  /// Steps 3: customer submits a repair request (gets a reference number).
  RepairRequest submitRequest({
    required String deviceType,
    required String deviceModel,
    required String problem,
    required Shop shop,
  }) {
    final number = _nextRequestNumber++;
    final id = 'FT-' + number.toString().padLeft(3, '0');
    final now = DateTime.now();
    final request = RepairRequest(
      id: id,
      customerName: userName,
      deviceType: deviceType,
      deviceModel: deviceModel,
      problem: problem,
      shopId: shop.id,
      shopName: shop.name,
      submittedAt: now,
      updatedAt: now,
    );
    requests.add(request);
    _addNotification(false, 'New repair request',
        '$userName sent a request for $deviceModel ($id).');
    notifyListeners();
    return request;
  }

  /// Step 7: customer accepts the estimate -> confirmed booking.
  void acceptEstimate(RepairRequest r) {
    r.stage = RequestStage.booked;
    r.updatedAt = DateTime.now();
    _addNotification(false, 'Estimate accepted',
        '${r.customerName} accepted the estimate for ${r.id}. Booking confirmed. Please receive the device.');
    notifyListeners();
  }

  void rejectEstimate(RepairRequest r) {
    r.stage = RequestStage.estimateRejected;
    r.updatedAt = DateTime.now();
    _addNotification(false, 'Estimate rejected',
        '${r.customerName} rejected the estimate for ${r.id}.');
    notifyListeners();
  }

  // --------------------------------------------------------- business actions

  void acceptRequest(RepairRequest r) {
    r.stage = RequestStage.accepted;
    r.updatedAt = DateTime.now();
    _addNotification(true, 'Request accepted',
        '${r.shopName} accepted your request ${r.id}. An estimate will follow.');
    notifyListeners();
  }

  void rejectRequest(RepairRequest r) {
    r.stage = RequestStage.rejected;
    r.updatedAt = DateTime.now();
    _addNotification(true, 'Request rejected',
        '${r.shopName} could not accept your request ${r.id}.');
    notifyListeners();
  }

  void sendEstimate(RepairRequest r, int cost, String time, String notes) {
    r.stage = RequestStage.estimateSent;
    r.estimatedCost = cost;
    r.estimatedTime = time;
    r.shopNotes = notes.isEmpty ? null : notes;
    r.updatedAt = DateTime.now();
    _addNotification(true, 'Estimate received',
        '${r.shopName} sent an estimate for ${r.id}. Please review it.');
    notifyListeners();
  }

  /// Step 9: business updates the repair progress.
  void updateStatus(RepairRequest r, RepairStatus newStatus) {
    r.status = newStatus;
    r.updatedAt = DateTime.now();
    _addNotification(true, 'Repair update',
        'Your ${r.deviceModel} (${r.id}) is now ${newStatus.label}.');
    notifyListeners();
  }

  // ---------------------------------------------------------- notifications

  void markRead(AppNotification n) {
    n.isRead = true;
    notifyListeners();
  }

  void markAllRead() {
    for (final n in myNotifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void _addNotification(bool forCustomer, String title, String message) {
    final number = _nextNotificationNumber++;
    notifications.add(AppNotification(
      id: 'n$number',
      title: title,
      message: message,
      time: DateTime.now(),
      forCustomer: forCustomer,
    ));
  }
}

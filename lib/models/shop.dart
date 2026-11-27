/// A repair business that customers can discover.
/// NOTE: field names will be matched to the Shops table once the SQL is shared.
class Shop {
  final String id;
  final String name;
  final String location;
  final String phone;
  final List<String> deviceTypes; // e.g. Phones, Laptops, Tablets, Desktops
  final bool isOpen;

  const Shop({
    required this.id,
    required this.name,
    required this.location,
    required this.phone,
    required this.deviceTypes,
    required this.isOpen,
  });
}

class Property {
  final String image;
  final String price;
  final String address;
  final String details;
  final bool bookmarked;

  Property({
    required this.image,
    required this.price,
    required this.address,
    required this.details,
    this.bookmarked = false,
  });
}

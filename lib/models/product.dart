/// Product data model.
class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final double rating;
  final int reviews;
  final String image; 
  final String? badge;
  final String description;
  final List<String> tags;
  final String time;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.image,
    this.badge,
    required this.description,
    required this.tags,
    required this.time,
  });
}

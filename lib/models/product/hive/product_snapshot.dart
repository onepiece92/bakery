import 'package:hive/hive.dart';

part 'product_snapshot.g.dart';

@HiveType(typeId: 2)
class HiveProductSnapshot extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String name;
  @HiveField(2) final String image;
  @HiveField(3) final double price;
  @HiveField(4) final String categories;

  HiveProductSnapshot({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.categories,
  });
}
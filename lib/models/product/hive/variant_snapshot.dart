import 'package:hive/hive.dart';

part 'variant_snapshot.g.dart';

@HiveType(typeId: 1)
class HiveVariantSnapshot extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final List<String> optionValues;
  @HiveField(2) final double price;

  HiveVariantSnapshot({
    required this.id,
    required this.optionValues,
    required this.price,
  });
}
import 'package:hive/hive.dart';

part 'addon_snapshot.g.dart';

@HiveType(typeId: 0)
class HiveAddonSnapshot extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String name;
  @HiveField(2) final double price;

  HiveAddonSnapshot({
    required this.id,
    required this.name,
    required this.price,
  });
}
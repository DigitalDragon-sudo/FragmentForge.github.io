import 'package:hive/hive.dart';

part 'fragment.g.dart';

@HiveType(typeId: 0)
class Fragment extends HiveObject {
  @HiveField(0)
  String? imagePath;

  @HiveField(1)
  String? audioPath;

  @HiveField(2)
  String text;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  String moodTag;

  Fragment({
    this.imagePath,
    this.audioPath,
    this.text = '',
    required this.timestamp,
    this.moodTag = 'Unknown',
  });
}

import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 2)
class Note {
  @HiveField(1)
  String title;
  @HiveField(2)
  String subtitle;
  Note(this.title, this.subtitle);
}
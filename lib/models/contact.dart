import 'package:isar/isar.dart';

part 'contact.g.dart';

@collection
class Contact {
  Id id = Isar.autoIncrement;

  late String originalId;

  late String name;

  bool isConnected = false;
}

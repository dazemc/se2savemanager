import 'dart:io';
import 'dart:convert';

class SaveMeta {
  final int slot;
  final Directory parent;
  static Future<SaveMeta> fromDirectory(Directory dir) async {
    final metaFile =
        (dir.list().firstWhere((e) => e.path.contains('.autobackup'))
                as File)
            .readAsString();
    return SaveMeta.fromJson(jsonDecode(await metaFile));
  }

  const SaveMeta({required this.slot, required this.parent});

  factory SaveMeta.fromJson(json) {
    return SaveMeta(slot: json['slot'], parent: Directory(json['parent']));
  }

  // factory SaveMeta.fromDirectory(Directory dir) {
  //   final metaFile =
  //       (dir.listSync().firstWhere((e) => e.path.contains('.autobackup'))
  //               as File)
  //           .readAsStringSync();
  //   return SaveMeta.fromJson(jsonDecode(metaFile));
  // }

  Map<String, dynamic> toJson() {
    return {"slot": slot, "parent": parent.path};
  }
}

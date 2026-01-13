import 'dart:io';
import 'container_info.dart';
import 'save_meta.dart';

class Save {
  final SaveMeta? saveMeta;
  final ContainerInfo container;
  final Directory dir;
  static Future<Save> fromDirectory(Directory dir) async => Save(
    saveMeta: null, //TODO
    container: await ContainerInfo.fromDirectory(dir),
    dir: dir,
  );
  const Save({this.saveMeta, required this.container, required this.dir});
}

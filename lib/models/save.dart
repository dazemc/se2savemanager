import 'dart:io';
import 'container_info.dart';
import 'save_meta.dart';
import 'dart:typed_data';

class Save {
  final SaveMeta? saveMeta;
  final ContainerInfo container;
  final Directory dir;
  final Uint8List? screenshot;
  static Future<Save> fromDirectory(Directory dir) async => Save(
    saveMeta: null, //TODO
    container: await ContainerInfo.fromDirectory(dir),
    dir: dir,
    screenshot: await File('${dir.path}/thumb.jpg').readAsBytes(),
  );
  static Future<Save> fromPath(String path) async =>
      await Save.fromDirectory(Directory(path));
  const Save({
    this.saveMeta,
    this.screenshot,
    required this.container,
    required this.dir,
  });
}

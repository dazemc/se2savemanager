import 'dart:io';
import 'container_info.dart';
import 'save_meta.dart';

class Save {
  final SaveMeta saveMeta;
  final ContainerInfo container;
  final Directory location;
  // final Iterable<FileSystemEntity> data; //TODO: SaveData;
  const Save({
    required this.saveMeta,
    required this.container,
    required this.location,
    // required this.data,
  });
}

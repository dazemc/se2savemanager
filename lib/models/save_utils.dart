import 'dart:io';

Future<File> getContainerInfo(Directory dir) async {
  final cFile = dir.list().firstWhere(
    (e) => e.path.contains('.container-info'),
  );
  return cFile as Future<File>;
}

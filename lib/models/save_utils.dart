import 'dart:io';

File getContainerInfo(Directory dir) {
  final cFile = dir.listSync().firstWhere(
    (e) => e.path.contains('.container-info'),
  );
  return cFile as File;
}

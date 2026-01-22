class ManagedSave {
  final String name;
  final String path;
  final Map<String, String> children;
  const ManagedSave({
    required this.name,
    required this.path,
    required this.children,
  });

  //TODO: fromMap, toMap for hive
}

class ManagedSave {
  bool isParent;
  final String name;
  final String path;
  final Map<String, String> children;
  ManagedSave({
    required this.name,
    required this.path,
    required this.children,
    required this.isParent,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'path': path,
    'isParent': isParent,
    'children': children,
  };

  factory ManagedSave.fromMap(Map<String, dynamic> map) => ManagedSave(
    name: map['name'],
    isParent: map['isParent'],
    path: map['path'],
    children: map['children'],
  );
}

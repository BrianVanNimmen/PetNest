class SimpleItem {
  const SimpleItem({required this.id, required this.name});

  final int id;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is SimpleItem && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}

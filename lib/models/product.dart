class Product {
  const Product({
    required this.id,
    required this.name,
    required this.colorway,
    required this.category,
    required this.price,
    required this.imageAsset,
    required this.description,
    required this.materials,
    required this.fitNote,
    required this.sizes,
    required this.releaseLabel,
  });

  final String id;
  final String name;
  final String colorway;
  final String category;
  final double price;
  final String imageAsset;
  final String description;
  final String materials;
  final String fitNote;
  final List<int> sizes;
  final String releaseLabel;
}

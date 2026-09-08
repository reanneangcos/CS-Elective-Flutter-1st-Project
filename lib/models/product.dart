/// Immutable data model for one catalog product.
///
/// This is plain application data, not a widget. `final` fields prevent a
/// product from changing unexpectedly after the catalog is created.
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

  final String id; // Visible SKU-style key, e.g. SS-P001, used by routes/cart.
  final String name;
  final String colorway;
  final String category;
  final double price; // Numeric storage allows subtotal/total calculations.
  final String imageAsset; // Path declared under assets/ in pubspec.yaml.
  final String description;
  final String materials;
  final String fitNote;
  final List<int> sizes;
  final String releaseLabel;
}

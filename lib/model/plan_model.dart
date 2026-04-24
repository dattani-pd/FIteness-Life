class PlanModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String duration;

  PlanModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.duration,
  });

  // Factory to convert JSON from API to Dart Object
  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      // Handle price safely (API might send String "40" or Int 40)
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      // API often sends relative paths (e.g. "/images/pic.jpg"), so we might need to add the domain
      imageUrl: json['image_url'] ?? '',
      duration: json['duration'] ?? 'Unknown',
    );
  }
}
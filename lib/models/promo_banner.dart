class PromoBanner {
  const PromoBanner({
    required this.id,
    required this.imageUrl,
    required this.title,
  });

  final int id;
  final String imageUrl;
  final String title;

  factory PromoBanner.fromJson(Map<String, dynamic> json) {
    return PromoBanner(
      id: (json['id'] as num).toInt(),
      imageUrl: (json['imageUrl'] ?? '') as String,
      title: (json['title'] ?? '') as String,
    );
  }
}

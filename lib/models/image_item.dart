class ImageItem {
  int? id;
  String title;
  String imagePath;

  ImageItem({
    this.id,
    required this.title,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'imagePath': imagePath,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory ImageItem.fromMap(Map<String, dynamic> map) {
    return ImageItem(
      id: map['id'],
      title: map['title'],
      imagePath: map['imagePath'],
    );
  }
}

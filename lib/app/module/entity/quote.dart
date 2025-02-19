class QuoteModel {
  final String text;
  final String author;

  QuoteModel({required this.text, required this.author});

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      text: json['text'] ?? json['q'] ?? json['content'] ?? '',
      author: json['author'] ?? json['a'] ?? '',
    );
  }
}

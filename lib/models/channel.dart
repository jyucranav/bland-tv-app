class Channel {
  Channel({
    required this.title,
    required this.groupTitle,
    required this.number,
    required this.link,
  });

  final String title;
  final String groupTitle;
  final String number;
  final String link;

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      title: json['title'] as String,
      groupTitle: json['group_title'] as String,
      number: json['tvg_id'] as String,
      link: json['link'] as String,
    );
  }
}

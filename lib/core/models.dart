class JagxModel {
  const JagxModel({
    required this.id,
    required this.name,
    required this.subtitle,
    this.badge,
    this.comingSoon = false,
  });

  final String id;
  final String name;
  final String subtitle;
  final String? badge;
  final bool comingSoon;
}

/// Ask/Build uses Fast only for now. Multi-agent lives in JagX Bot.
class Models {
  static const fast = JagxModel(
    id: 'jagx-0.3',
    name: 'Fast',
    subtitle: 'Everyday answers',
    badge: 'Fast',
  );

  static const list = [fast];

  static JagxModel byId(String id) => fast;
}

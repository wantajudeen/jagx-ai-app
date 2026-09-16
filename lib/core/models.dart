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

class Models {
  static const list = [
    JagxModel(
      id: 'jagx-0.3',
      name: 'JagX 0.3',
      subtitle: 'Fast · everyday',
      badge: 'Fast',
    ),
    JagxModel(
      id: 'jagx-0.4',
      name: 'JagX 0.4',
      subtitle: 'Expert · deep reasoning',
      badge: 'Expert',
    ),
    JagxModel(
      id: 'forge',
      name: 'Forge',
      subtitle: 'Most powerful regular model',
      badge: 'Power',
    ),
    JagxModel(
      id: 'bot',
      name: 'JagX Bot',
      subtitle: 'AI teammate that does real work',
      badge: 'New',
    ),
    JagxModel(
      id: 'oracle',
      name: 'Oracle',
      subtitle: 'Full agent',
      badge: 'Soon',
      comingSoon: true,
    ),
  ];

  static JagxModel get fast => list.first;

  static JagxModel byId(String id) =>
      list.firstWhere((m) => m.id == id, orElse: () => fast);
}

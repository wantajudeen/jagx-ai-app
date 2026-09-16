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

/// Models users can pick in Ask / Build — Bot is a separate screen, not listed here.
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
      subtitle: 'Expert · deep reasoning & code',
      badge: 'Expert',
    ),
    JagxModel(
      id: 'forge',
      name: 'Forge',
      subtitle: 'Most powerful regular model',
      badge: 'Power',
    ),
    JagxModel(
      id: 'oracle',
      name: 'Oracle',
      subtitle: 'Full agent — coming soon',
      badge: 'Soon',
      comingSoon: true,
    ),
  ];

  static JagxModel get fast => list.first;

  static JagxModel byId(String id) =>
      list.firstWhere((m) => m.id == id, orElse: () => fast);
}

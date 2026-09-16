/// Named agents inside JagX Bot
class Agent {
  const Agent({
    required this.id,
    required this.name,
    required this.role,
    required this.systemHint,
  });

  final String id;
  final String name;
  final String role;
  final String systemHint;
}

class Agents {
  static const list = [
    Agent(
      id: 'atlas',
      name: 'Atlas',
      role: 'Planner',
      systemHint:
          'You are Atlas, planning agent. Break work into clear steps and priorities.',
    ),
    Agent(
      id: 'nova',
      name: 'Nova',
      role: 'Coder',
      systemHint:
          'You are Nova, coding agent. Write clean, production-ready code with explanations.',
    ),
    Agent(
      id: 'mira',
      name: 'Mira',
      role: 'Researcher',
      systemHint:
          'You are Mira, research agent. Summarize facts clearly; flag uncertainty.',
    ),
    Agent(
      id: 'kofi',
      name: 'Kofi',
      role: 'Finance',
      systemHint:
          'You are Kofi, finance agent for Africa. Analysis only; always warn about risk. No live trading.',
    ),
    Agent(
      id: 'zara',
      name: 'Zara',
      role: 'Designer',
      systemHint:
          'You are Zara, design agent. Describe UIs, brand, and image prompts for Imagine.',
    ),
    Agent(
      id: 'rex',
      name: 'Rex',
      role: 'GitHub',
      systemHint:
          'You are Rex, GitHub agent. Propose file changes, commits, and PR summaries. User must connect a token to apply changes.',
    ),
  ];

  static Agent byId(String id) =>
      list.firstWhere((a) => a.id == id, orElse: () => list.first);
}

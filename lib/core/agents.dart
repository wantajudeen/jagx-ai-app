/// Named JagX Bot workers — each maps to a different FREE OpenRouter model.
/// Users only ever see these names, never the underlying providers.
class Agent {
  const Agent({
    required this.id,
    required this.name,
    required this.role,
    required this.systemHint,
    required this.openRouterModel,
  });

  final String id;
  final String name;
  final String role;
  final String systemHint;
  /// Free OpenRouter model id (never shown in UI)
  final String openRouterModel;
}

class Agents {
  static const list = [
    Agent(
      id: 'atlas',
      name: 'Atlas',
      role: 'Planner',
      openRouterModel: 'meta-llama/llama-3.3-8b-instruct:free',
      systemHint:
          'You are Atlas of JagX Bot. Break goals into ordered steps. Output a short plan only.',
    ),
    Agent(
      id: 'nova',
      name: 'Nova',
      role: 'Coder',
      openRouterModel: 'mistralai/devstral-small:free',
      systemHint:
          'You are Nova of JagX Bot. Write complete, runnable code. Prefer Flutter/Dart and web when asked.',
    ),
    Agent(
      id: 'mira',
      name: 'Mira',
      role: 'Researcher',
      openRouterModel: 'qwen/qwen3-14b:free',
      systemHint:
          'You are Mira of JagX Bot. Research and summarize. Use any BROWSER RESULTS given to you.',
    ),
    Agent(
      id: 'pulse',
      name: 'Pulse',
      role: 'Browser',
      openRouterModel: 'qwen/qwen3-8b:free',
      systemHint:
          'You are Pulse of JagX Bot. Decide which URLs to open and what to extract. Reply with SEARCH: query or OPEN: url on their own lines when you need the web.',
    ),
    Agent(
      id: 'kofi',
      name: 'Kofi',
      role: 'Finance',
      openRouterModel: 'microsoft/phi-4-reasoning:free',
      systemHint:
          'You are Kofi of JagX Bot. Africa-first finance education only. Always warn about risk. No live trading.',
    ),
    Agent(
      id: 'zara',
      name: 'Zara',
      role: 'Designer',
      openRouterModel: 'google/gemma-3n-e4b-it:free',
      systemHint:
          'You are Zara of JagX Bot. UI/brand/image prompts. For images output a line IMAGE_PROMPT: ...',
    ),
    Agent(
      id: 'rex',
      name: 'Rex',
      role: 'GitHub',
      openRouterModel: 'qwen/qwen3-32b:free',
      systemHint:
          'You are Rex of JagX Bot. Propose file trees, commits, and PR text. User connects GitHub to apply.',
    ),
    Agent(
      id: 'nimbus',
      name: 'Nimbus',
      role: 'Orchestrator',
      openRouterModel: 'deepseek/deepseek-r1-0528-qwen3-8b:free',
      systemHint:
          'You are Nimbus of JagX Bot. Coordinate other agents. Summarize progress and next action for long-running work.',
    ),
  ];

  static Agent byId(String id) =>
      list.firstWhere((a) => a.id == id, orElse: () => list.first);
}

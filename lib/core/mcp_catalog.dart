/// Curated MCP / connector catalog for JagX AI.
/// Prefer official remote HTTP MCP URLs. Entries without a public remote
/// URL are still listable; users can paste a custom URL or use JagX tools.
class McpItem {
  const McpItem({
    required this.id,
    required this.name,
    required this.category,
    required this.blurb,
    this.url,
    this.auth = 'none',
    this.remote = false,
    this.priority = false,
  });

  final String id;
  final String name;
  final String category;
  final String blurb;
  /// Official remote MCP URL if one exists.
  final String? url;
  /// none | oauth | api_key | pat
  final String auth;
  final bool remote;
  final bool priority;
}

class McpCatalog {
  static const categories = [
    'Core',
    'Search',
    'Dev',
    'Cloud',
    'Data',
    'Comms',
    'Payments',
    'Social',
    'Research',
    'Creative',
    'Automation',
  ];

  /// ~100 curated entries. Priority ones have verified remote URLs.
  static const List<McpItem> all = [
    // —— Core (verified remote) ——
    McpItem(
      id: 'supabase',
      name: 'Supabase',
      category: 'Core',
      blurb: 'Database, Auth, Storage, Edge Functions',
      url: 'https://mcp.supabase.com/mcp',
      auth: 'oauth',
      remote: true,
      priority: true,
    ),
    McpItem(
      id: 'github',
      name: 'GitHub',
      category: 'Core',
      blurb: 'Repos, issues, PRs, Actions',
      url: 'https://api.githubcopilot.com/mcp/',
      auth: 'pat',
      remote: true,
      priority: true,
    ),
    McpItem(
      id: 'vercel',
      name: 'Vercel',
      category: 'Core',
      blurb: 'Projects, deployments, logs',
      url: 'https://mcp.vercel.com',
      auth: 'oauth',
      remote: true,
      priority: true,
    ),
    McpItem(
      id: 'cloudflare',
      name: 'Cloudflare',
      category: 'Core',
      blurb: 'Workers, DNS, R2, infrastructure',
      url: 'https://mcp.cloudflare.com/mcp',
      auth: 'oauth',
      remote: true,
      priority: true,
    ),
    McpItem(
      id: 'context7',
      name: 'Context7',
      category: 'Core',
      blurb: 'Up-to-date library docs for coding',
      url: 'https://mcp.context7.com/mcp',
      auth: 'api_key',
      remote: true,
      priority: true,
    ),
    McpItem(
      id: 'linear',
      name: 'Linear',
      category: 'Dev',
      blurb: 'Issues, projects, cycles',
      url: 'https://mcp.linear.app/mcp',
      auth: 'oauth',
      remote: true,
      priority: true,
    ),
    McpItem(
      id: 'notion',
      name: 'Notion',
      category: 'Core',
      blurb: 'Pages and databases',
      url: 'https://mcp.notion.com/mcp',
      auth: 'oauth',
      remote: true,
      priority: true,
    ),
    McpItem(
      id: 'slack',
      name: 'Slack',
      category: 'Comms',
      blurb: 'Channels, messages, search',
      url: 'https://mcp.slack.com/mcp',
      auth: 'oauth',
      remote: true,
      priority: true,
    ),
    McpItem(
      id: 'neon',
      name: 'Neon',
      category: 'Data',
      blurb: 'Serverless Postgres',
      url: 'https://mcp.neon.tech/mcp',
      auth: 'oauth',
      remote: true,
      priority: true,
    ),
    McpItem(
      id: 'x_api',
      name: 'X (Twitter) API',
      category: 'Social',
      blurb: 'Posts, search, timelines',
      url: 'https://api.x.com/mcp',
      auth: 'oauth',
      remote: true,
      priority: true,
    ),
    McpItem(
      id: 'x_docs',
      name: 'X API Docs',
      category: 'Social',
      blurb: 'X API documentation (no auth)',
      url: 'https://docs.x.com/mcp',
      auth: 'none',
      remote: true,
      priority: true,
    ),
    McpItem(
      id: 'aws',
      name: 'AWS',
      category: 'Cloud',
      blurb: 'AWS APIs, docs, sandboxed scripts',
      url: 'https://aws-mcp.us-east-1.api.aws/mcp',
      auth: 'oauth',
      remote: true,
      priority: true,
    ),

    // —— Search / research (remote or JagX-backed) ——
    McpItem(
      id: 'exa',
      name: 'Exa',
      category: 'Search',
      blurb: 'AI web search and research',
      auth: 'api_key',
      priority: true,
    ),
    McpItem(
      id: 'brave',
      name: 'Brave Search',
      category: 'Search',
      blurb: 'Web and news search',
      auth: 'api_key',
    ),
    McpItem(
      id: 'tavily',
      name: 'Tavily',
      category: 'Search',
      blurb: 'AI research search',
      auth: 'api_key',
    ),
    McpItem(
      id: 'firecrawl',
      name: 'Firecrawl',
      category: 'Search',
      blurb: 'Crawl sites to clean text',
      auth: 'api_key',
      priority: true,
    ),
    McpItem(
      id: 'fetch',
      name: 'Fetch',
      category: 'Search',
      blurb: 'Fetch webpage content',
      remote: false,
    ),
    McpItem(
      id: 'wikipedia',
      name: 'Wikipedia',
      category: 'Research',
      blurb: 'Encyclopedia lookup',
      remote: false,
      priority: true,
    ),
    McpItem(
      id: 'semantic_scholar',
      name: 'Semantic Scholar',
      category: 'Research',
      blurb: 'Academic papers',
    ),
    McpItem(
      id: 'pubmed',
      name: 'PubMed',
      category: 'Research',
      blurb: 'Medical literature',
    ),
    McpItem(
      id: 'openalex',
      name: 'OpenAlex',
      category: 'Research',
      blurb: 'Research graph',
    ),

    // —— Browser / automation ——
    McpItem(
      id: 'playwright',
      name: 'Playwright',
      category: 'Automation',
      blurb: 'Browser automation and testing',
      priority: true,
    ),
    McpItem(
      id: 'browserbase',
      name: 'Browserbase',
      category: 'Automation',
      blurb: 'Remote browser sessions',
      auth: 'api_key',
      priority: true,
    ),
    McpItem(
      id: 'apify',
      name: 'Apify',
      category: 'Automation',
      blurb: 'Scraping and actors',
      auth: 'api_key',
    ),
    McpItem(
      id: 'zapier',
      name: 'Zapier',
      category: 'Automation',
      blurb: 'Thousands of app actions',
      auth: 'oauth',
      priority: true,
    ),

    // —— Dev ——
    McpItem(
      id: 'gitlab',
      name: 'GitLab',
      category: 'Dev',
      blurb: 'Repos and CI/CD',
      auth: 'pat',
    ),
    McpItem(
      id: 'bitbucket',
      name: 'Bitbucket',
      category: 'Dev',
      blurb: 'Repos',
      auth: 'oauth',
    ),
    McpItem(
      id: 'sentry',
      name: 'Sentry',
      category: 'Dev',
      blurb: 'Errors and traces',
      auth: 'oauth',
    ),
    McpItem(
      id: 'jira',
      name: 'Jira',
      category: 'Dev',
      blurb: 'Tickets and projects',
      auth: 'oauth',
    ),
    McpItem(
      id: 'docker',
      name: 'Docker',
      category: 'Dev',
      blurb: 'Containers and images',
    ),
    McpItem(
      id: 'npm',
      name: 'NPM',
      category: 'Dev',
      blurb: 'Package registry info',
    ),
    McpItem(
      id: 'filesystem',
      name: 'Filesystem',
      category: 'Dev',
      blurb: 'Local project files (desktop)',
    ),

    // —— Cloud ——
    McpItem(
      id: 'gcp',
      name: 'Google Cloud',
      category: 'Cloud',
      blurb: 'GCP resources',
      auth: 'oauth',
    ),
    McpItem(
      id: 'azure',
      name: 'Azure',
      category: 'Cloud',
      blurb: 'Microsoft cloud',
      auth: 'oauth',
    ),
    McpItem(
      id: 'render',
      name: 'Render',
      category: 'Cloud',
      blurb: 'Web service deploys',
      auth: 'api_key',
    ),
    McpItem(
      id: 'railway',
      name: 'Railway',
      category: 'Cloud',
      blurb: 'Deploy backends',
      auth: 'api_key',
    ),
    McpItem(
      id: 'netlify',
      name: 'Netlify',
      category: 'Cloud',
      blurb: 'Static and edge deploys',
      auth: 'oauth',
    ),
    McpItem(
      id: 'fly',
      name: 'Fly.io',
      category: 'Cloud',
      blurb: 'Global app hosting',
      auth: 'api_key',
    ),
    McpItem(
      id: 'firebase',
      name: 'Firebase',
      category: 'Cloud',
      blurb: 'Auth, Firestore, hosting',
      auth: 'oauth',
    ),

    // —— Data ——
    McpItem(
      id: 'mongodb',
      name: 'MongoDB',
      category: 'Data',
      blurb: 'Document database',
      auth: 'api_key',
    ),
    McpItem(
      id: 'redis',
      name: 'Redis',
      category: 'Data',
      blurb: 'Cache and keys',
      auth: 'api_key',
    ),
    McpItem(
      id: 'planetscale',
      name: 'PlanetScale',
      category: 'Data',
      blurb: 'MySQL serverless',
      auth: 'api_key',
    ),
    McpItem(
      id: 'upstash',
      name: 'Upstash',
      category: 'Data',
      blurb: 'Serverless Redis/Kafka',
      auth: 'api_key',
    ),
    McpItem(
      id: 'gdrive',
      name: 'Google Drive',
      category: 'Data',
      blurb: 'Files and folders',
      url: 'https://drivemcp.googleapis.com/mcp/v1',
      auth: 'oauth',
      remote: true,
      priority: true,
    ),

    // —— Comms ——
    McpItem(
      id: 'gmail',
      name: 'Gmail',
      category: 'Comms',
      blurb: 'Read and draft email',
      auth: 'oauth',
      priority: true,
    ),
    McpItem(
      id: 'resend',
      name: 'Resend',
      category: 'Comms',
      blurb: 'Transactional email',
      auth: 'api_key',
    ),
    McpItem(
      id: 'twilio',
      name: 'Twilio',
      category: 'Comms',
      blurb: 'SMS and voice',
      auth: 'api_key',
    ),
    McpItem(
      id: 'telegram',
      name: 'Telegram',
      category: 'Comms',
      blurb: 'Bots and messages',
      auth: 'api_key',
    ),
    McpItem(
      id: 'discord',
      name: 'Discord',
      category: 'Comms',
      blurb: 'Servers and channels',
      auth: 'oauth',
    ),
    McpItem(
      id: 'onesignal',
      name: 'OneSignal',
      category: 'Comms',
      blurb: 'Push, SMS, email campaigns',
      auth: 'api_key',
      priority: true,
    ),
    McpItem(
      id: 'intercom',
      name: 'Intercom',
      category: 'Comms',
      blurb: 'Customer messaging',
      auth: 'oauth',
    ),

    // —— Payments ——
    McpItem(
      id: 'stripe',
      name: 'Stripe',
      category: 'Payments',
      blurb: 'Payments and customers',
      auth: 'api_key',
      priority: true,
    ),
    McpItem(
      id: 'paystack',
      name: 'Paystack',
      category: 'Payments',
      blurb: 'Nigeria / Africa payments',
      auth: 'api_key',
      priority: true,
    ),
    McpItem(
      id: 'flutterwave',
      name: 'Flutterwave',
      category: 'Payments',
      blurb: 'African payments',
      auth: 'api_key',
      priority: true,
    ),
    McpItem(
      id: 'paypal',
      name: 'PayPal',
      category: 'Payments',
      blurb: 'Payments',
      auth: 'oauth',
    ),

    // —— Social ——
    McpItem(
      id: 'linkedin',
      name: 'LinkedIn',
      category: 'Social',
      blurb: 'Professional network',
      auth: 'oauth',
    ),
    McpItem(
      id: 'youtube',
      name: 'YouTube',
      category: 'Social',
      blurb: 'Videos and channels',
      auth: 'oauth',
    ),
    McpItem(
      id: 'reddit',
      name: 'Reddit',
      category: 'Social',
      blurb: 'Search and communities',
      auth: 'oauth',
    ),
    McpItem(
      id: 'meta',
      name: 'Meta / Facebook',
      category: 'Social',
      blurb: 'Pages and ads context',
      auth: 'oauth',
    ),

    // —— Creative ——
    McpItem(
      id: 'figma',
      name: 'Figma',
      category: 'Creative',
      blurb: 'Design files and UI',
      auth: 'oauth',
    ),
    McpItem(
      id: 'canva',
      name: 'Canva',
      category: 'Creative',
      blurb: 'Design workflows',
      auth: 'oauth',
    ),
    McpItem(
      id: 'elevenlabs',
      name: 'ElevenLabs',
      category: 'Creative',
      blurb: 'AI voice',
      auth: 'api_key',
    ),
    McpItem(
      id: 'rostro',
      name: 'Rostro',
      category: 'Creative',
      blurb: 'Image, video, 3D, voice, music',
      url: 'https://proto.rostro.dev/mcp',
      auth: 'api_key',
      remote: true,
      priority: true,
    ),

    // —— Memory / thinking ——
    McpItem(
      id: 'memory',
      name: 'Memory',
      category: 'Core',
      blurb: 'Persistent agent memory',
    ),
    McpItem(
      id: 'sequential',
      name: 'Sequential Thinking',
      category: 'Core',
      blurb: 'Structured problem solving',
    ),
    McpItem(
      id: 'smithery',
      name: 'Smithery',
      category: 'Automation',
      blurb: 'Discover hosted MCP servers',
      priority: true,
    ),

    // —— Africa / local focus ——
    McpItem(
      id: 'jagx_web',
      name: 'JagX Web Search',
      category: 'Search',
      blurb: 'Built-in free web search via JagX backend',
      remote: false,
      priority: true,
    ),
    McpItem(
      id: 'jagx_code',
      name: 'JagX Code Sandbox',
      category: 'Dev',
      blurb: 'Run code via JagX (Piston)',
      remote: false,
      priority: true,
    ),
    McpItem(
      id: 'jagx_news',
      name: 'JagX Live News',
      category: 'Research',
      blurb: 'Free RSS news via JagX backend',
      remote: false,
      priority: true,
    ),
    McpItem(
      id: 'jagx_maps',
      name: 'JagX Maps & Weather',
      category: 'Research',
      blurb: 'OpenStreetMap + Open-Meteo',
      remote: false,
      priority: true,
    ),
  ];

  static List<McpItem> byCategory(String c) =>
      all.where((e) => e.category == c).toList();

  static List<McpItem> search(String q) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return all;
    return all
        .where((e) =>
            e.name.toLowerCase().contains(s) ||
            e.blurb.toLowerCase().contains(s) ||
            e.category.toLowerCase().contains(s))
        .toList();
  }
}

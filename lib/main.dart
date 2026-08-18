import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

void main() {
  usePathUrlStrategy();
  runApp(const FruitApp());
}

class Fruit {
  const Fruit({
    required this.name,
    required this.emoji,
    required this.description,
    required this.color,
  });

  final String name;
  final String emoji;
  final String description;
  final Color color;

  String get slug => name.toLowerCase();
}

const fruits = <Fruit>[
  Fruit(
    name: 'Apple',
    emoji: '🍎',
    description: 'Crisp, sweet, and perfect for an afternoon snack.',
    color: Color(0xFFE94B4B),
  ),
  Fruit(
    name: 'Banana',
    emoji: '🍌',
    description: 'Soft, sunny, and naturally packed with energy.',
    color: Color(0xFFF4C542),
  ),
  Fruit(
    name: 'Orange',
    emoji: '🍊',
    description: 'Bright, juicy, and bursting with citrus flavor.',
    color: Color(0xFFFF8A35),
  ),
  Fruit(
    name: 'Grapes',
    emoji: '🍇',
    description: 'A sweet cluster of bite-sized treats.',
    color: Color(0xFF8D64C5),
  ),
  Fruit(
    name: 'Watermelon',
    emoji: '🍉',
    description: 'Cool, refreshing, and made for warm days.',
    color: Color(0xFF31A66A),
  ),
];

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const FruitListPage(),
      routes: [
        GoRoute(
          path: 'fruit/:name',
          redirect: (context, state) {
            final name = state.pathParameters['name'];
            return fruits.any((fruit) => fruit.slug == name) ? null : '/';
          },
          builder: (context, state) {
            final name = state.pathParameters['name']!;
            final fruit = fruits.firstWhere((fruit) => fruit.slug == name);
            return FruitDetailsPage(fruit: fruit);
          },
        ),
      ],
    ),
  ],
);

class FruitApp extends StatelessWidget {
  const FruitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fruit Basket',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3A7D44)),
        scaffoldBackgroundColor: const Color(0xFFFFFBF1),
        useMaterial3: true,
      ),
    );
  }
}

class FruitListPage extends StatelessWidget {
  const FruitListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fruit Basket'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: fruits.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final fruit = fruits[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              leading: Text(fruit.emoji, style: const TextStyle(fontSize: 38)),
              title: Text(
                fruit.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text('Open /fruit/${fruit.slug}'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onTap: () => context.go('/fruit/${fruit.slug}'),
            ),
          );
        },
      ),
    );
  }
}

class FruitDetailsPage extends StatelessWidget {
  const FruitDetailsPage({super.key, required this.fruit});

  final Fruit fruit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fruit.name)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 240,
                height: 240,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fruit.color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Text(fruit.emoji, style: const TextStyle(fontSize: 130)),
              ),
              const SizedBox(height: 32),
              Text(
                fruit.name,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: fruit.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                fruit.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 36),
              FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back to all fruits'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

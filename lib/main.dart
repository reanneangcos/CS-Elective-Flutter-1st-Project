import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/shop_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/shop_screen.dart';
import 'services/jersey_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!SupabaseConfig.isConfigured) {
    runApp(const CourtsideKitsApp(home: _SetupScreen()));
    return;
  }

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(Supabase.instance.client.auth),
      child: const CourtsideKitsApp(home: AuthGate()),
    ),
  );
}

/// Shows the sign-in screen until a user is signed in (by email or GitHub),
/// then the shop. Signing out returns to the sign-in screen automatically.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.select<AuthProvider, String?>((a) => a.user?.id);
    if (userId == null) return const AuthScreen();

    return ChangeNotifierProvider(
      key: ValueKey(userId),
      create: (_) => ShopProvider(JerseyService(Supabase.instance.client))..init(),
      child: const ShopScreen(),
    );
  }
}

class CourtsideKitsApp extends StatelessWidget {
  const CourtsideKitsApp({super.key, required this.home});
  final Widget home;

  @override
  Widget build(BuildContext context) {
    ThemeData theme(Brightness brightness) => ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFEA580C), // basketball orange
            brightness: brightness,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        );

    return MaterialApp(
      title: 'Courtside Kits',
      debugShowCheckedModeBanner: false,
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      home: home,
    );
  }
}

class _SetupScreen extends StatelessWidget {
  const _SetupScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.sports_basketball, size: 48, color: Color(0xFFEA580C)),
                const SizedBox(height: 16),
                Text('Connect Courtside Kits to Supabase',
                    style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                const Text(
                  '1. Run supabase/schema.sql in your Supabase SQL Editor.\n'
                  '2. Copy your Project URL and anon key from Project Settings → API.\n'
                  '3. Paste them into lib/config/supabase_config.dart, or run:\n',
                ),
                SelectableText(
                  'flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co '
                  '--dart-define=SUPABASE_ANON_KEY=your-anon-key',
                  style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

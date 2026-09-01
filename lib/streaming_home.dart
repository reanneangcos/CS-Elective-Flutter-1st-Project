import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum ScreenClass { mobile, tablet, desktop }

const sectionTitles = [
  'Good evening, Reanne',
  'Discover',
  'New & noteworthy',
  'Your library',
];
const sectionSubtitles = [
  'Settle in. Your next story is ready.',
  'Find something outside your usual orbit.',
  'Fresh stories, added every Friday.',
  'Saved titles, watch history, and preferences.',
];

class _DashboardScope extends InheritedWidget {
  const _DashboardScope({
    required this.selectedCategory,
    required this.isSaved,
    required this.onSelectCategory,
    required this.onToggleSaved,
    required super.child,
  });

  final int selectedCategory;
  final bool isSaved;
  final ValueChanged<int> onSelectCategory;
  final VoidCallback onToggleSaved;

  static _DashboardScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_DashboardScope>()!;
  }

  @override
  bool updateShouldNotify(_DashboardScope oldWidget) {
    return selectedCategory != oldWidget.selectedCategory ||
        isSaved != oldWidget.isSaved;
  }
}

class LumenHomeScreen extends StatefulWidget {
  const LumenHomeScreen({super.key});

  static const background = Color(0xFF090A18);
  static const surface = Color(0xFF15172A);
  static const accent = Color(0xFFA6F4C5);
  static const violet = Color(0xFF8B7CF6);

  @override
  State<LumenHomeScreen> createState() => _LumenHomeScreenState();
}

class _LumenHomeScreenState extends State<LumenHomeScreen> {
  int selectedIndex = 0;
  int selectedCategory = 0;
  bool isSaved = false;

  bool get isCupertino =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final screenClass =
            constraints.maxWidth < 700 ||
                (constraints.maxHeight < 600 && constraints.maxWidth < 1150)
            ? ScreenClass.mobile
            : constraints.maxWidth < 1150
            ? ScreenClass.tablet
            : ScreenClass.desktop;

        return switch (screenClass) {
          ScreenClass.mobile => _MobileLayout(
            key: const ValueKey('mobile-layout'),
            isCupertino: isCupertino,
            selectedIndex: selectedIndex,
            onSelect: selectDestination,
          ),
          ScreenClass.tablet => _TabletLayout(
            key: const ValueKey('tablet-layout'),
            selectedIndex: selectedIndex,
            onSelect: selectDestination,
          ),
          ScreenClass.desktop => _DesktopLayout(
            key: const ValueKey('desktop-layout'),
            selectedIndex: selectedIndex,
            onSelect: selectDestination,
          ),
        };
      },
    );

    final backdrop = _DashboardScope(
      selectedCategory: selectedCategory,
      isSaved: isSaved,
      onSelectCategory: (index) {
        setState(() => selectedCategory = index);
      },
      onToggleSaved: () {
        setState(() => isSaved = !isSaved);
      },
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.72, -0.78),
            radius: 1.25,
            colors: [Color(0xFF28234D), LumenHomeScreen.background],
          ),
        ),
        child: content,
      ),
    );

    if (isCupertino) {
      return CupertinoPageScaffold(
        backgroundColor: LumenHomeScreen.background,
        child: SafeArea(bottom: false, child: backdrop),
      );
    }
    return Scaffold(
      backgroundColor: LumenHomeScreen.background,
      body: SafeArea(bottom: false, child: backdrop),
    );
  }

  void selectDestination(int index) => setState(() => selectedIndex = index);
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    super.key,
    required this.isCupertino,
    required this.selectedIndex,
    required this.onSelect,
  });

  final bool isCupertino;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shortScreen = constraints.maxHeight < 700;
        final horizontalPadding = constraints.maxWidth < 360 ? 10.0 : 14.0;
        final panelWidth = constraints.maxWidth - (horizontalPadding * 2);
        final heightFromViewport =
            constraints.maxHeight * (shortScreen ? 0.70 : 0.61);
        final heroHeight = math
            .min(panelWidth * (shortScreen ? 0.92 : 1.28), heightFromViewport)
            .clamp(280.0, 520.0);
        final navigationInset = shortScreen ? 8.0 : 14.0;

        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _TopBar(
                    horizontalPadding: constraints.maxWidth < 360 ? 12 : 18,
                    title: sectionTitles[selectedIndex],
                    subtitle: sectionSubtitles[selectedIndex],
                  ),
                ),
                const SliverToBoxAdapter(child: _CategoryBar()),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    12,
                    horizontalPadding,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _FeaturedPanel(height: heroHeight, compact: true),
                  ),
                ),
                const SliverToBoxAdapter(child: _MyListSection(cardWidth: 210)),
                const SliverToBoxAdapter(child: SizedBox(height: 112)),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: isCupertino
                  ? _CupertinoBottomNavigation(
                      selectedIndex: selectedIndex,
                      onSelect: onSelect,
                      bottomInset: navigationInset,
                    )
                  : _MaterialBottomNavigation(
                      selectedIndex: selectedIndex,
                      onSelect: onSelect,
                      bottomInset: navigationInset,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _TabletLayout extends StatelessWidget {
  const _TabletLayout({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SideNavigation(
          selectedIndex: selectedIndex,
          onSelect: onSelect,
          extended: false,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 720
                  ? 18.0
                  : 26.0;
              final heroHeight = math
                  .min(
                    constraints.maxHeight * 0.56,
                    (constraints.maxWidth - horizontalPadding * 2) * 0.72,
                  )
                  .clamp(330.0, 530.0);
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _TopBar(
                      horizontalPadding: horizontalPadding,
                      title: sectionTitles[selectedIndex],
                      subtitle: sectionSubtitles[selectedIndex],
                    ),
                  ),
                  const SliverToBoxAdapter(child: _CategoryBar()),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      12,
                      horizontalPadding,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _FeaturedPanel(
                        height: heroHeight,
                        compact: constraints.maxWidth < 650,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: _MyListSection(cardWidth: 220),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SideNavigation(
          selectedIndex: selectedIndex,
          onSelect: onSelect,
          extended: MediaQuery.sizeOf(context).width >= 1500,
        ),
        Expanded(
          child: Column(
            children: [
              _TopBar(
                horizontalPadding: 30,
                showCategories: true,
                title: sectionTitles[selectedIndex],
                subtitle: sectionSubtitles[selectedIndex],
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final heroHeight = (constraints.maxHeight - 36).clamp(
                      420.0,
                      630.0,
                    );
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(30, 8, 30, 34),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1500),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 7,
                                child: _FeaturedPanel(height: heroHeight),
                              ),
                              const SizedBox(width: 22),
                              SizedBox(
                                width: constraints.maxWidth < 1280 ? 310 : 360,
                                child: _DesktopList(height: heroHeight),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.horizontalPadding,
    required this.title,
    required this.subtitle,
    this.showCategories = false,
  });

  final double horizontalPadding;
  final String title;
  final String subtitle;
  final bool showCategories;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        18,
        horizontalPadding,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          if (showCategories) ...[
            const SizedBox(width: 28),
            const Expanded(flex: 2, child: _CategoryBar(centered: true)),
          ],
          _AdaptiveIconButton(
            materialIcon: Icons.cast_rounded,
            cupertinoIcon: CupertinoIcons.tv,
            tooltip: 'Cast',
            onPressed: () => showCastDialog(context),
          ),
          const SizedBox(width: 8),
          _AdaptiveIconButton(
            materialIcon: Icons.search_rounded,
            cupertinoIcon: CupertinoIcons.search,
            tooltip: 'Search',
            onPressed: () => showSearchPanel(context),
          ),
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({this.centered = false});

  final bool centered;

  @override
  Widget build(BuildContext context) {
    final scope = _DashboardScope.of(context);
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CategoryChip(
          label: 'Featured',
          selected: scope.selectedCategory == 0,
          onTap: () => scope.onSelectCategory(0),
        ),
        const SizedBox(width: 8),
        _CategoryChip(
          label: 'Series',
          selected: scope.selectedCategory == 1,
          onTap: () => scope.onSelectCategory(1),
        ),
        const SizedBox(width: 8),
        _CategoryChip(
          label: 'Films',
          showArrow: true,
          selected: scope.selectedCategory == 2,
          onTap: () => scope.onSelectCategory(2),
        ),
      ],
    );
    if (centered) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: row,
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: row,
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.onTap,
    this.showArrow = false,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool showArrow;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: selected
                  ? LumenHomeScreen.accent
                  : Colors.white.withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? LumenHomeScreen.accent : Colors.white10,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.black : Colors.white70,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (showArrow) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: selected ? Colors.black : Colors.white70,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedPanel extends StatelessWidget {
  const _FeaturedPanel({required this.height, this.compact = false});

  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(compact ? 22 : 28);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: Colors.white10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 36,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/afterlight_hero.png',
                fit: BoxFit.cover,
                alignment: compact
                    ? const Alignment(0.18, 0)
                    : const Alignment(0.08, 0),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00000000),
                      Color(0x26000000),
                      Color(0xF2090A18),
                    ],
                    stops: [0.2, 0.53, 1],
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xD9090A18), Color(0x00090A18)],
                    stops: [0, 0.76],
                  ),
                ),
              ),
              Positioned(
                top: compact ? 18 : 24,
                right: compact ? 18 : 24,
                child: const _MatchBadge(),
              ),
              Positioned(
                left: compact ? 22 : 36,
                right: compact ? 22 : 36,
                bottom: compact ? 24 : 36,
                child: _HeroDetails(compact: compact),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  const _MatchBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF191B32).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: const Text(
        'NEW PREMIERE',
        style: TextStyle(
          color: LumenHomeScreen.accent,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _HeroDetails extends StatelessWidget {
  const _HeroDetails({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LumenMark(),
        const SizedBox(height: 10),
        const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'AFTERLIGHT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sci-fi drama  •  2026  •  1h 52m',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        if (!compact) ...[
          const SizedBox(height: 11),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 490),
            child: const Text(
              'A signal from beyond the horizon draws one traveler back to '
              'the city she promised never to see again.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AdaptivePlayButton(),
              SizedBox(width: 10),
              _AdaptiveAddButton(),
            ],
          ),
        ),
      ],
    );
  }
}

class _LumenMark extends StatelessWidget {
  const _LumenMark();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: LumenHomeScreen.accent,
            shape: BoxShape.circle,
          ),
          child: SizedBox(width: 9, height: 9),
        ),
        SizedBox(width: 8),
        Text(
          'A LUMEN ORIGINAL',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }
}

class _AdaptivePlayButton extends StatelessWidget {
  const _AdaptivePlayButton();

  @override
  Widget build(BuildContext context) {
    final cupertino = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    if (cupertino) {
      return CupertinoButton.filled(
        key: const ValueKey('cupertino-play-button'),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        onPressed: () => showPlayerDialog(context),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.play_fill, size: 19),
            SizedBox(width: 7),
            Text('Play'),
          ],
        ),
      );
    }
    return FilledButton.icon(
      key: const ValueKey('material-play-button'),
      style: FilledButton.styleFrom(
        backgroundColor: LumenHomeScreen.accent,
        foregroundColor: const Color(0xFF101221),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
      ),
      onPressed: () => showPlayerDialog(context),
      icon: const Icon(Icons.play_arrow_rounded),
      label: const Text('Play'),
    );
  }
}

class _AdaptiveAddButton extends StatelessWidget {
  const _AdaptiveAddButton();

  @override
  Widget build(BuildContext context) {
    final cupertino = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final scope = _DashboardScope.of(context);
    if (cupertino) {
      return CupertinoButton(
        key: const ValueKey('cupertino-add-button'),
        color: const Color(0xB32D2A50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        onPressed: scope.onToggleSaved,
        child: Icon(
          scope.isSaved ? CupertinoIcons.check_mark : CupertinoIcons.add,
          color: Colors.white,
          size: 21,
        ),
      );
    }
    return OutlinedButton.icon(
      key: const ValueKey('material-add-button'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white54),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      ),
      onPressed: scope.onToggleSaved,
      icon: Icon(scope.isSaved ? Icons.check_rounded : Icons.add_rounded),
      label: Text(scope.isSaved ? 'Saved' : 'Save'),
    );
  }
}

class _AdaptiveIconButton extends StatelessWidget {
  const _AdaptiveIconButton({
    required this.materialIcon,
    required this.cupertinoIcon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData materialIcon;
  final IconData cupertinoIcon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cupertino = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    if (cupertino) {
      return CupertinoButton(
        key: ValueKey('cupertino-${tooltip.toLowerCase()}'),
        minimumSize: const Size.square(42),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Icon(cupertinoIcon, color: Colors.white, size: 24),
      );
    }
    return IconButton(
      key: ValueKey('material-${tooltip.toLowerCase()}'),
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.055),
        side: const BorderSide(color: Colors.white10),
      ),
      icon: Icon(materialIcon, color: Colors.white),
    );
  }
}

class _MyListSection extends StatelessWidget {
  const _MyListSection({this.cardWidth = 145});

  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Keep watching',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => showLibraryPanel(context),
                  child: const Row(
                    children: [
                      Text(
                        'See all',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, color: Colors.white54),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: movies.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _MovieCard(
                movie: movies[index],
                width: cardWidth,
                progress: (index + 2) / 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopList extends StatelessWidget {
  const _DesktopList({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
      decoration: BoxDecoration(
        color: LumenHomeScreen.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'On your radar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Curated for tonight',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'View all',
                onPressed: () => showLibraryPanel(context),
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Column(
              children: [
                for (var index = 0; index < movies.length; index++) ...[
                  Expanded(
                    child: _CompactMovieTile(
                      movie: movies[index],
                      rank: index + 1,
                    ),
                  ),
                  if (index != movies.length - 1)
                    const Divider(height: 1, color: Colors.white10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactMovieTile extends StatelessWidget {
  const _CompactMovieTile({required this.movie, required this.rank});

  final _MovieData movie;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showMovieDetails(context, movie),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 12),
              AspectRatio(
                aspectRatio: 1.18,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: movie.colors),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(movie.icon, color: Colors.white70, size: 28),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      movie.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.play_circle_outline_rounded,
                color: Colors.white38,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MovieData {
  const _MovieData(this.title, this.subtitle, this.colors, this.icon);

  final String title;
  final String subtitle;
  final List<Color> colors;
  final IconData icon;
}

const movies = [
  _MovieData('Glass Harbor', 'Continue episode 4', [
    Color(0xFF183A56),
    Color(0xFF4EA7A1),
  ], Icons.waves_rounded),
  _MovieData('Paper Moons', 'New this week', [
    Color(0xFF49336F),
    Color(0xFFB886D9),
  ], Icons.nightlight_round),
  _MovieData('Slow Orbit', 'Episode 2 of 8', [
    Color(0xFF17233E),
    Color(0xFF6678D8),
  ], Icons.public_rounded),
  _MovieData('Wildflower', 'Critics’ choice', [
    Color(0xFF234B3A),
    Color(0xFF78B989),
  ], Icons.local_florist_rounded),
  _MovieData('Northern Lines', 'Because you watched Afterlight', [
    Color(0xFF26324A),
    Color(0xFF7895B9),
  ], Icons.train_rounded),
  _MovieData('The Last Signal', 'Lumen exclusive', [
    Color(0xFF3A2850),
    Color(0xFF8B7CF6),
  ], Icons.graphic_eq_rounded),
];

bool get usesCupertinoControls =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

Future<void> showPlayerDialog(BuildContext context) async {
  if (usesCupertinoControls) {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => const _PlayerPanel(cupertino: true),
    );
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PlayerPanel(cupertino: false),
  );
}

Future<void> showSearchPanel(BuildContext context) async {
  if (usesCupertinoControls) {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => _SearchPanel(hostContext: context, cupertino: true),
    );
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SearchPanel(hostContext: context, cupertino: false),
  );
}

Future<void> showLibraryPanel(BuildContext context) async {
  if (usesCupertinoControls) {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => _LibraryPanel(hostContext: context),
    );
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LibraryPanel(hostContext: context),
  );
}

Future<void> showCastDialog(BuildContext context) async {
  const devices = ['Living Room TV', 'Bedroom Chromecast', 'Web Player'];
  if (usesCupertinoControls) {
    final selected = await showCupertinoDialog<String>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Cast to a device'),
        content: const Text('Choose a nearby screen to start watching.'),
        actions: [
          for (final device in devices)
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialogContext, device),
              child: Text(device),
            ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (selected != null && context.mounted) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (messageContext) => CupertinoAlertDialog(
          title: const Text('Connected'),
          content: Text('Now casting to $selected.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(messageContext),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
    return;
  }

  final selected = await showDialog<String>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      backgroundColor: LumenHomeScreen.surface,
      title: const Text('Cast to a device'),
      children: [
        for (final device in devices)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, device),
            child: Row(
              children: [
                const Icon(Icons.tv_rounded),
                const SizedBox(width: 12),
                Text(device),
              ],
            ),
          ),
      ],
    ),
  );
  if (selected != null && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Now casting to $selected')));
  }
}

Future<void> _showMovieDetails(BuildContext context, _MovieData movie) async {
  if (usesCupertinoControls) {
    final play = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(movie.title),
        content: Text(
          '${movie.subtitle}\n\nAn unforgettable story, selected for your evening.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Close'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Play'),
          ),
        ],
      ),
    );
    if (play == true && context.mounted) await showPlayerDialog(context);
    return;
  }

  final play = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: LumenHomeScreen.surface,
      icon: Icon(movie.icon, color: Colors.white70, size: 42),
      title: Text(movie.title),
      content: Text(
        '${movie.subtitle}\n\nAn unforgettable story, selected for your evening.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(dialogContext, true),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Play'),
        ),
      ],
    ),
  );
  if (play == true && context.mounted) await showPlayerDialog(context);
}

class _PlayerPanel extends StatefulWidget {
  const _PlayerPanel({required this.cupertino});

  final bool cupertino;

  @override
  State<_PlayerPanel> createState() => _PlayerPanelState();
}

class _PlayerPanelState extends State<_PlayerPanel> {
  bool isPlaying = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: math
            .min(420, math.max(280, MediaQuery.sizeOf(context).height - 24))
            .toDouble(),
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: LumenHomeScreen.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Now playing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
            const Spacer(),
            const Text(
              'AFTERLIGHT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPlaying ? 'Playing preview' : 'Preview paused',
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => setState(() => isPlaying = !isPlaying),
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.black,
                  size: 38,
                ),
              ),
            ),
            const Spacer(),
            const LinearProgressIndicator(
              value: 0.28,
              minHeight: 4,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(LumenHomeScreen.accent),
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Text('00:42', style: TextStyle(color: Colors.white54)),
                Spacer(),
                Text('02:30', style: TextStyle(color: Colors.white54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPanel extends StatefulWidget {
  const _SearchPanel({required this.hostContext, required this.cupertino});

  final BuildContext hostContext;
  final bool cupertino;

  @override
  State<_SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<_SearchPanel> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final results = movies
        .where(
          (movie) => movie.title.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    return _ModalSurface(
      title: 'Search',
      onClose: () => Navigator.pop(context),
      child: Column(
        children: [
          if (widget.cupertino)
            CupertinoSearchTextField(onChanged: updateQuery)
          else
            TextField(
              autofocus: true,
              onChanged: updateQuery,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search titles',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Text(
                      'No titles found',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, _) =>
                        const Divider(color: Colors.white10),
                    itemBuilder: (context, index) {
                      final movie = results[index];
                      return _ModalMovieRow(
                        movie: movie,
                        onTap: () {
                          Navigator.pop(context);
                          Future.microtask(() {
                            if (widget.hostContext.mounted) {
                              _showMovieDetails(widget.hostContext, movie);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void updateQuery(String value) => setState(() => query = value);
}

class _LibraryPanel extends StatelessWidget {
  const _LibraryPanel({required this.hostContext});

  final BuildContext hostContext;

  @override
  Widget build(BuildContext context) {
    return _ModalSurface(
      title: 'Keep watching',
      onClose: () => Navigator.pop(context),
      child: ListView.separated(
        itemCount: movies.length,
        separatorBuilder: (_, _) => const Divider(color: Colors.white10),
        itemBuilder: (context, index) {
          final movie = movies[index];
          return _ModalMovieRow(
            movie: movie,
            onTap: () {
              Navigator.pop(context);
              Future.microtask(() {
                if (hostContext.mounted) {
                  _showMovieDetails(hostContext, movie);
                }
              });
            },
          );
        },
      ),
    );
  }
}

class _ModalSurface extends StatelessWidget {
  const _ModalSurface({
    required this.title,
    required this.onClose,
    required this.child,
  });

  final String title;
  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.72,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        decoration: const BoxDecoration(
          color: LumenHomeScreen.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _ModalMovieRow extends StatelessWidget {
  const _ModalMovieRow({required this.movie, required this.onTap});

  final _MovieData movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: movie.colors),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(movie.icon, color: Colors.white70),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({
    required this.movie,
    required this.width,
    required this.progress,
  });

  final _MovieData movie;
  final double width;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: () => _showMovieDetails(context, movie),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: movie.colors,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: const Alignment(0.72, -0.35),
                child: Icon(
                  movie.icon,
                  color: Colors.white.withValues(alpha: 0.22),
                  size: 76,
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC000000)],
                    stops: [0.35, 1],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(
                          LumenHomeScreen.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideNavigation extends StatelessWidget {
  const _SideNavigation({
    required this.selectedIndex,
    required this.onSelect,
    required this.extended,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: extended,
      minExtendedWidth: 210,
      minWidth: 82,
      backgroundColor: const Color(0xE6111222),
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelect,
      indicatorColor: LumenHomeScreen.violet,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      selectedIconTheme: const IconThemeData(color: Colors.white),
      selectedLabelTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      unselectedIconTheme: const IconThemeData(color: Colors.white60),
      unselectedLabelTextStyle: const TextStyle(color: Colors.white60),
      leading: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        child: Text(
          key: const ValueKey('brand-logo'),
          extended ? 'LUMEN' : 'L',
          style: const TextStyle(
            color: LumenHomeScreen.accent,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore_rounded),
          label: Text('Discover'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.video_library_outlined),
          selectedIcon: Icon(Icons.video_library_rounded),
          label: Text('Premieres'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: Text('Library'),
        ),
      ],
    );
  }
}

class _MaterialBottomNavigation extends StatelessWidget {
  const _MaterialBottomNavigation({
    required this.selectedIndex,
    required this.onSelect,
    required this.bottomInset,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottomInset),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: NavigationBar(
          key: const ValueKey('material-bottom-navigation'),
          height: bottomInset < 14 ? 64 : 72,
          backgroundColor: const Color(0xF21A1C31),
          indicatorColor: LumenHomeScreen.violet,
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelect,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded),
              label: 'Discover',
            ),
            NavigationDestination(
              icon: Icon(Icons.video_library_outlined),
              selectedIcon: Icon(Icons.video_library_rounded),
              label: 'Premieres',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Library',
            ),
          ],
        ),
      ),
    );
  }
}

class _CupertinoBottomNavigation extends StatelessWidget {
  const _CupertinoBottomNavigation({
    required this.selectedIndex,
    required this.onSelect,
    required this.bottomInset,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottomInset),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: CupertinoTabBar(
          key: const ValueKey('cupertino-bottom-navigation'),
          backgroundColor: const Color(0xF21A1C31),
          activeColor: LumenHomeScreen.accent,
          inactiveColor: CupertinoColors.systemGrey,
          currentIndex: selectedIndex,
          onTap: onSelect,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.house),
              activeIcon: Icon(CupertinoIcons.house_fill),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.compass),
              activeIcon: Icon(CupertinoIcons.compass_fill),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.play_rectangle),
              activeIcon: Icon(CupertinoIcons.play_rectangle_fill),
              label: 'Premieres',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              activeIcon: Icon(CupertinoIcons.person_fill),
              label: 'Library',
            ),
          ],
        ),
      ),
    );
  }
}

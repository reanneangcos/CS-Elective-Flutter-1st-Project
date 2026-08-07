import 'dart:math' as math;

import 'package:flutter/material.dart';

class StreamingHomeScreen extends StatelessWidget {
  const StreamingHomeScreen({super.key});

  static const background = Color(0xFF0B0A0E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 112),
                  child: Column(
                    children: [
                      _HeroBanner(
                        height: math.max(
                          590,
                          MediaQuery.sizeOf(context).height * 0.72,
                        ),
                      ),
                      const _MyListSection(),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: _BottomNavigation(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/spacebound_hero.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.18),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xB8000000),
                  Color(0x18000000),
                  Color(0x08000000),
                  Color(0xD90B0A0E),
                  StreamingHomeScreen.background,
                ],
                stops: [0, 0.2, 0.5, 0.84, 1],
              ),
            ),
          ),
          const Positioned(top: 20, left: 20, right: 20, child: _Header()),
          const Positioned(
            top: 72,
            left: 16,
            right: 16,
            child: _CategoryChips(),
          ),
          const Positioned(
            left: 18,
            right: 18,
            bottom: 20,
            child: _HeroDetails(),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'For Reanne',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
        ),
        Icon(Icons.cast_rounded, size: 26),
        SizedBox(width: 22),
        Icon(Icons.search_rounded, size: 29),
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Row(
        children: [
          _CategoryChip(label: 'TV Shows'),
          SizedBox(width: 8),
          _CategoryChip(label: 'Movies'),
          SizedBox(width: 8),
          _CategoryChip(label: 'Categories', showArrow: true),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, this.showArrow = false});

  final String label;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF81543D).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          if (showArrow) ...[
            const SizedBox(width: 5),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 17),
          ],
        ],
      ),
    );
  }
}

class _HeroDetails extends StatelessWidget {
  const _HeroDetails();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SPACEBOUND',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w300,
            letterSpacing: 3.5,
            height: 1,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Science fiction  •  Adventure  •  Drama',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.66),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            _StreamBoxMark(),
            Spacer(),
            _AddButton(),
            SizedBox(width: 10),
            _PlayButton(),
          ],
        ),
      ],
    );
  }
}

class _StreamBoxMark extends StatelessWidget {
  const _StreamBoxMark();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'S',
          style: TextStyle(
            color: Color(0xFFFF3D32),
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(width: 5),
        Text(
          'STREAMBOX',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: const Icon(Icons.add_rounded, size: 25),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow_rounded, color: Colors.black, size: 25),
          SizedBox(width: 3),
          Text(
            'Play',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _MyListSection extends StatelessWidget {
  const _MyListSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'My List',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Text('See all', style: TextStyle(fontSize: 13)),
              SizedBox(width: 2),
              Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 13),
        SizedBox(
          height: 190,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            children: const [
              _MovieCard(
                title: 'Silent Orbit',
                subtitle: 'New Episode',
                colors: [Color(0xFF44566F), Color(0xFFE1C9B1)],
                icon: Icons.public_rounded,
              ),
              SizedBox(width: 10),
              _MovieCard(
                title: 'Red Horizon',
                subtitle: 'Top 10',
                colors: [Color(0xFF651D16), Color(0xFFFF8A1D)],
                icon: Icons.local_fire_department_rounded,
              ),
              SizedBox(width: 10),
              _MovieCard(
                title: 'Deep Signal',
                subtitle: 'Recently Added',
                colors: [Color(0xFF112A33), Color(0xFF2E8B8D)],
                icon: Icons.graphic_eq_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final List<Color> colors;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 137,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              icon,
              size: 48,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const Spacer(),
          Text(
            subtitle.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xF21B191F),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SelectedHome(),
          _NavIcon(icon: Icons.explore_outlined),
          _NavIcon(icon: Icons.video_collection_rounded),
          _NavIcon(icon: Icons.sentiment_satisfied_alt_rounded, accent: true),
        ],
      ),
    );
  }
}

class _SelectedHome extends StatelessWidget {
  const _SelectedHome();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 43,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          Icon(Icons.home_rounded, color: Colors.black, size: 23),
          SizedBox(width: 7),
          Text(
            'Home',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, this.accent = false});

  final IconData icon;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: accent ? const Color(0xFFFFC94A) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: accent ? Colors.black : Colors.white, size: 24),
    );
  }
}

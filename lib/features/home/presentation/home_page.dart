import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/auth_repository.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_header.dart';

// Responsive geometry is derived from the available mobile/web viewport.

const _bg = Color(0xFF03150F);
const _surface = Color(0xFF09231A);
const _goldLight = Color(0xFFF1D37A);
const _text = Color(0xFFF8F5EC);
const _muted = Color(0xFFB7C2BC);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _navigationInProgress = false;
  int _selectedIndex = -1;

  static const _items = <_MenuItemData>[
    _MenuItemData(
      label: 'PELANGGARAN',
      description: 'RINGKASAN DAN TREN PELANGGARAN HUKUM.',
      icon: Icons.policy_rounded,
      lightColor: Color(0xFFF09A4A),
      route: '/statistik/pelanggaran',
    ),
    _MenuItemData(
      label: 'LAKA-LALIN',
      description: 'RINGKASAN DAN TREN KECELAKAAN LALU LINTAS.',
      icon: Icons.car_crash_rounded,
      lightColor: Color(0xFFE15B5B),
      route: '/statistik/laka-lalin',
    ),
    _MenuItemData(
      label: 'SIM TNI',
      description: 'RINGKASAN PENERBITAN DAN DATA SIM TNI.',
      icon: Icons.badge_rounded,
      lightColor: Color(0xFF5D8FE0),
      route: '/statistik/sim-tni',
    ),
    _MenuItemData(
      label: 'K9',
      description: 'RINGKASAN DATA K-9 DAN SEBARAN SATUAN.',
      icon: Icons.pets_rounded,
      lightColor: Color(0xFFE3BE4F),
      route: '/statistik/k9',
    ),
    _MenuItemData(
      label: 'PROVOS TNI-AD',
      description: 'RINGKASAN DATA DAN KINERJA PROVOS TNI-AD.',
      icon: Icons.shield_rounded,
      lightColor: Color(0xFF49A86B),
      route: '/statistik/provos',
    ),
  ];

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _surface,
          title: const Text(
            'KELUAR DARI SISTEM?',
            style: TextStyle(color: _text, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'SESI ANDA AKAN DIAKHIRI DAN ANDA AKAN KEMBALI KE HALAMAN SIGN IN.',
            style: TextStyle(color: _muted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('BATAL'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: _goldLight,
                foregroundColor: const Color(0xFF10140F),
              ),
              child: const Text('KELUAR'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ref.read(authRepositoryProvider).signOut();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('TIDAK DAPAT MENGAKHIRI SESI. COBA LAGI.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _selectMenu(int index) async {
    if (_navigationInProgress) {
      return;
    }

    setState(() {
      _selectedIndex = index;
      _navigationInProgress = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 180));

    if (!mounted) {
      return;
    }

    await context.push(_items[index].route);

    if (!mounted) {
      return;
    }

    setState(() {
      _navigationInProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppHeader(title: 'SDIRBINGAKKUM', onSignOut: _confirmSignOut),
      body: AppBackground(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 560,
                      maxHeight: 560,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                      child: _PieMenu(
                        items: _items,
                        selectedIndex: _selectedIndex,
                        onSelected: _selectMenu,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PieMenu extends StatelessWidget {
  const _PieMenu({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_MenuItemData> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : double.infinity;
        final maxHeight =
            constraints.hasBoundedHeight ? constraints.maxHeight : maxWidth;
        final diameter = math.min(maxWidth, maxHeight);

        if (!diameter.isFinite || diameter <= 0) {
          return const SizedBox.shrink();
        }

        return SizedBox.square(
          dimension: diameter,
          child: GestureDetector(
            key: const ValueKey('main-pie-menu'),
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              final index = _PieMenuPainter.indexAt(
                localPosition,
                box.size,
                itemCount: items.length,
              );

              if (index != null) {
                onSelected(index);
              }
            },
            child: CustomPaint(
              painter: _PieMenuPainter(
                itemCount: items.length,
                selectedIndex: selectedIndex,
              ),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  for (var i = 0; i < items.length; i++)
                    _PieMenuLabel(
                      index: i,
                      item: items[i],
                      itemCount: items.length,
                      selected: i == selectedIndex,
                      diameter: diameter,
                    ),
                  _PieMenuCenter(
                    item: selectedIndex >= 0 ? items[selectedIndex] : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Center hub styled after the central core medallion of the POMAD PRIMA badge.
/// Features a heavy double-coin gold bezel, deep obsidian minted plate,
/// and high-contrast chiseled gold icon relief.
class _PieMenuCenter extends StatelessWidget {
  const _PieMenuCenter({this.item});

  final _MenuItemData? item;

  @override
  Widget build(BuildContext context) {
    final icon = item?.icon ?? Icons.apps_rounded;
    final iconColor = item?.lightColor ?? _goldLight;
    final centerKey = item?.label ?? 'MENU UTAMA';

    return FractionallySizedBox(
      widthFactor: 0.35,
      heightFactor: 0.35,
      child: ClipOval(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // POMAD PRIMA central medallion: deep obsidian metal base
            // with rich gold rim
            gradient: const RadialGradient(
              center: Alignment(-0.35, -0.40),
              radius: 0.95,
              colors: [
                Color(0xFF1E2822), // subtle metallic highlight
                Color(0xFF0F1713), // dark coin plate
                Color(0xFF060A08), // deep edge vignette
              ],
              stops: [0.0, 0.55, 1.0],
            ),
            border: Border.all(
              color: const Color(0xFFF3D882), // outer polished gold rim
              width: 2.2,
            ),
            boxShadow: [
              // Deep cast shadow like a raised military medal
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.68),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
              // Warm golden ambient illumination
              BoxShadow(
                color: const Color(0xFFD4A535).withValues(alpha: 0.22),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Inner chamfered gold step (stepped coin bezel like POMAD PRIMA)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(3.5),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF8B6419).withValues(alpha: 0.85),
                        width: 1.0,
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0x38FFFFFF),
                          Colors.transparent,
                          Color(0x55000000),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Upper-left curved specular reflection
              // (curved glass/metal dome sheen)
              Positioned(
                left: 6,
                top: 4,
                right: 6,
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(80),
                      bottom: Radius.circular(50),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.24),
                        Colors.white.withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),

              // Center content: chiseled 3D gold relief icon and typography
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Column(
                    key: ValueKey(centerKey),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Chiseled Gold Relief Icon (like Gajah Mada gold mask)
                      Icon(
                        icon,
                        color: iconColor,
                        size: diameterForCenter(context),
                        shadows: [
                          // Deep 3D extrusion shadow (bottom-right)
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.85),
                            offset: const Offset(1.8, 2.5),
                            blurRadius: 1,
                          ),
                          // Secondary bevel shadow
                          Shadow(
                            color:
                                const Color(0xFF382405).withValues(alpha: 0.90),
                            offset: const Offset(0.9, 1.3),
                            blurRadius: 0,
                          ),
                          // Crisp white specular edge on top-left
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.65),
                            offset: const Offset(-0.8, -0.9),
                            blurRadius: 0,
                          ),
                          // Soft gold radiance aura
                          Shadow(
                            color: iconColor.withValues(alpha: 0.45),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          centerKey,
                          textAlign: TextAlign.center,
                          maxLines: centerKey == 'MENU UTAMA' ? 2 : 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: item == null ? _goldLight : iconColor,
                            fontSize: centerTextSize(context, centerKey),
                            fontWeight: FontWeight.w800,
                            letterSpacing: centerKey.length > 18 ? 0.2 : 0.7,
                            height: 1.05,
                            shadows: [
                              // Embossed chiseled letter depth
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.85),
                                offset: const Offset(1.2, 1.8),
                                blurRadius: 0,
                              ),
                              Shadow(
                                color: Colors.white.withValues(alpha: 0.35),
                                offset: const Offset(-0.6, -0.6),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double diameterForCenter(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    return shortest < 300 ? 22 : 28;
  }

  double centerTextSize(BuildContext context, String text) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;

    if (text == 'MENU UTAMA') {
      return shortest < 300 ? 8.2 : 9.5;
    }

    if (text.length >= 22) {
      return shortest < 300 ? 6.8 : 7.8;
    }

    if (text.length >= 18) {
      return shortest < 300 ? 7.2 : 8.2;
    }

    return shortest < 300 ? 7.8 : 8.8;
  }
}

/// Pie slice labels and icons styled with extruded chiseled 3D metal effect,
/// matching the embossed silver/chrome "POMAD" and gold "PRIMA" lettering.
class _PieMenuLabel extends StatelessWidget {
  const _PieMenuLabel({
    required this.index,
    required this.item,
    required this.itemCount,
    required this.selected,
    required this.diameter,
  });

  final int index;
  final _MenuItemData item;
  final int itemCount;
  final bool selected;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final outerRadius = diameter * 0.43;
    final labelRadius = outerRadius * 0.69;
    final angle = -math.pi / 2 + (2 * math.pi / itemCount) * (index + 0.5);
    final compact = diameter < 310;
    final labelWidth = (diameter * 0.30).clamp(72.0, 108.0).toDouble();
    final iconSize = compact ? 28.0 : 34.0;
    final labelFontSize = compact ? 8.0 : 8.8;
    final isLong = item.label.length > 20;

    return Transform.translate(
      offset: Offset(
        math.cos(angle) * labelRadius,
        math.sin(angle) * labelRadius,
      ),
      child: SizedBox(
        width: labelWidth,
        child: AnimatedScale(
          scale: selected ? 1.04 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Extruded Chiseled 3D Metal Icon
              // (like POMAD/PRIMA metal reliefs)
              AnimatedScale(
                scale: selected ? 1.10 : 1,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: Icon(
                  item.icon,
                  // Polished silver/platinum finish with crisp metallic edge
                  color: selected
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFFF4F0E4),
                  size: compact ? iconSize * 0.80 : iconSize * 0.84,
                  shadows: [
                    // Deep 3D drop extrusion shadow
                    Shadow(
                      color: Colors.black
                          .withValues(alpha: selected ? 0.90 : 0.75),
                      offset: const Offset(2.2, 3.2),
                      blurRadius: 1,
                    ),
                    // Intermediate bronze/dark metallic bevel
                    Shadow(
                      color: const Color(0xFF2B1A05).withValues(alpha: 0.85),
                      offset: const Offset(1.1, 1.6),
                      blurRadius: 0,
                    ),
                    // Crisp specular crest highlight
                    // (light shining from top-left)
                    Shadow(
                      color: Colors.white
                          .withValues(alpha: selected ? 0.75 : 0.45),
                      offset: const Offset(-0.8, -0.9),
                      blurRadius: 0,
                    ),
                    // Ambient module illumination aura
                    Shadow(
                      color: item.lightColor
                          .withValues(alpha: selected ? 0.55 : 0.15),
                      blurRadius: selected ? 18 : 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Chiseled 3D Lettering (matching "POMAD PRIMA" stamped text)
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? item.lightColor : _text,
                  fontSize: isLong
                      ? math.max(labelFontSize - 0.5, 7.6).toDouble()
                      : labelFontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.45,
                  height: 1.05,
                  shadows: [
                    // 3D cast extrusion
                    Shadow(
                      color: Colors.black
                          .withValues(alpha: selected ? 0.90 : 0.75),
                      offset: const Offset(1.6, 2.4),
                      blurRadius: 1,
                    ),
                    // Mid-bevel groove
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.55),
                      offset: const Offset(0.8, 1.2),
                      blurRadius: 0,
                    ),
                    // Crisp upper highlight
                    Shadow(
                      color: Colors.white
                          .withValues(alpha: selected ? 0.65 : 0.35),
                      offset: const Offset(-0.6, -0.7),
                      blurRadius: 0,
                    ),
                    // Vibrant module glow on selection
                    if (selected)
                      Shadow(
                        color: item.lightColor.withValues(alpha: 0.45),
                        blurRadius: 12,
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

/// Custom painter executing the POMAD PRIMA coin-medal aesthetic:
/// 1. Stepped chamfered gold outer rim with directional specular highlights.
/// 2. Vitreous enamel module slices with lacquer dome reflections and edge
///    vignettes.
/// 3. Machined coin separator ridges with highlight and groove shadows.
/// 4. Stepped inner gold bezel separating segments from center hub.
class _PieMenuPainter extends CustomPainter {
  const _PieMenuPainter({required this.itemCount, required this.selectedIndex});

  final int itemCount;
  final int selectedIndex;

  // Module identity colors:
  static const _lightPalette = <Color>[
    Color(0xFFF09A4A), // PELANGGARAN - warm amber/orange
    Color(0xFFE15B5B), // LAKA-LALIN - ruby crimson
    Color(0xFF5D8FE0), // SIM TNI - sapphire royal blue
    Color(0xFFE3BE4F), // K9 - imperial gold
    Color(0xFF49A86B), // PROVOS TNI-AD - emerald military green
  ];

  // Rich POMAD PRIMA coin gold palette
  static const _goldBright = Color(0xFFFFF0A8); // specular crest highlight
  static const _goldFace = Color(0xFFE5B842); // primary minted gold
  static const _goldMid = Color(0xFFB8861E); // warm amber gold
  static const _goldDeep = Color(0xFF7A540E); // bronze core shadow
  static const _goldDark = Color(0xFF382304); // deep recess groove shadow

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = size.shortestSide * 0.43;
    final innerRadius = size.shortestSide * 0.17;
    final sweep = 2 * math.pi / itemCount;

    // -- STEP 1: PHYSICAL COIN THICKNESS / EXTRUSION RIM -------------
    // Multiple offset layers drawing down to produce the physical depth
    // of a heavy minted coin medal resting against the dark backdrop.
    const int rimSteps = 7;
    for (var layer = rimSteps; layer >= 1; layer--) {
      final yOffset = layer * 1.0;
      final layerAlpha = 0.14 + (layer / rimSteps) * 0.20;
      final rimOffset = Offset(0, yOffset);

      final rimPaint = Paint()..color = _goldDark.withValues(alpha: layerAlpha);

      for (var i = 0; i < itemCount; i++) {
        final start = -math.pi / 2 + i * sweep;
        final light = _lightPalette[i];

        final path = Path()
          ..moveTo(center.dx, center.dy + yOffset)
          ..lineTo(
            center.dx + math.cos(start) * (outerRadius + 3.0),
            center.dy + math.sin(start) * (outerRadius + 3.0) + yOffset,
          )
          ..arcTo(
            Rect.fromCircle(
                center: center + rimOffset, radius: outerRadius + 3.0),
            start,
            sweep,
            false,
          )
          ..close();

        // Darkened bronze/module tint for the extruded coin side
        final rimSideColor = Color.lerp(light, _goldDark, 0.78)!;
        rimPaint.color = rimSideColor.withValues(alpha: layerAlpha);
        canvas.drawPath(path, rimPaint);
      }
    }

    // -- STEP 2: AMBIENT COIN DROP SHADOW ---------------------------
    final baseShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center.translate(0, 5.0), outerRadius + 4.0, baseShadow);

    // -- STEP 3: VITREOUS ENAMEL SLICES (Module Bodies) --------------
    // Each slice is rendered with the depth of a polished military enamel badge
    for (var i = 0; i < itemCount; i++) {
      final start = -math.pi / 2 + i * sweep;
      final selected = i == selectedIndex;
      final light = _lightPalette[i];

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + math.cos(start) * outerRadius,
          center.dy + math.sin(start) * outerRadius,
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: outerRadius),
          start,
          sweep,
          false,
        )
        ..close();

      // Elevated shadow for selected segment (lifts higher from coin bed)
      if (selected) {
        canvas.drawShadow(
          path,
          Colors.black.withValues(alpha: 0.65),
          12.0,
          true,
        );
      }

      // Base Enamel Gradient: rich saturation, crisp directional falloff
      final enamelBase = Paint()
        ..shader = LinearGradient(
          begin: const Alignment(-0.85, -0.90),
          end: const Alignment(0.85, 0.90),
          colors: [
            Color.lerp(light, Colors.white, selected ? 0.48 : 0.38)!,
            Color.lerp(light, Colors.white, selected ? 0.24 : 0.16)!,
            light,
            Color.lerp(light, Colors.black, selected ? 0.08 : 0.14)!,
            Color.lerp(light, Colors.black, selected ? 0.28 : 0.36)!,
            Color.lerp(light, Colors.black, selected ? 0.52 : 0.62)!,
            Color.lerp(light, Colors.black, selected ? 0.74 : 0.82)!,
          ],
          stops: const [0.0, 0.06, 0.18, 0.36, 0.56, 0.76, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, enamelBase);

      // Curved Lacquer Dome Reflection (Glossy glass/enamel badge sheen)
      final domeGloss = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.55, -0.60),
          radius: 0.85,
          colors: [
            Colors.white.withValues(alpha: selected ? 0.38 : 0.26),
            Colors.white.withValues(alpha: selected ? 0.16 : 0.09),
            Colors.white.withValues(alpha: selected ? 0.03 : 0.015),
            Colors.transparent,
          ],
          stops: const [0.0, 0.18, 0.40, 0.75],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, domeGloss);

      // Intense Specular Hotspot (Mirror-like polished chrome shine)
      final mirrorHotspot = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.46, -0.52),
          radius: 0.32,
          colors: [
            Colors.white.withValues(alpha: selected ? 0.34 : 0.20),
            Colors.white.withValues(alpha: selected ? 0.08 : 0.04),
            Colors.transparent,
          ],
          stops: const [0.0, 0.32, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, mirrorHotspot);

      // Deep Edge Vignette
      // (simulates enamel sitting inside a recessed coin bed)
      final rimRecess = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.12),
            Colors.black.withValues(alpha: 0.48),
          ],
          stops: const [0.65, 0.86, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, rimRecess);

      // Lower-right ambient occlusion bevel
      final lowerBevel = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.80, 0.82),
          radius: 0.95,
          colors: [
            Colors.black.withValues(alpha: selected ? 0.42 : 0.50),
            Colors.black.withValues(alpha: 0.18),
            Colors.transparent,
          ],
          stops: const [0.0, 0.40, 0.85],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, lowerBevel);
    }

    // -- STEP 4: MACHINED COIN SEPARATOR RIBS -----------------------
    // Embossed gold dividers between slices, like minted coin partitions
    for (var i = 0; i < itemCount; i++) {
      final angle = -math.pi / 2 + i * sweep;
      final unit = Offset(math.cos(angle), math.sin(angle));
      final normal = Offset(-unit.dy, unit.dx);
      final startPoint = center;
      final endPoint = Offset(
        center.dx + unit.dx * outerRadius,
        center.dy + unit.dy * outerRadius,
      );

      // Deep coin groove channel
      final groovePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.butt
        ..color = _goldDark.withValues(alpha: 0.85);
      canvas.drawLine(
        startPoint + normal * 0.6,
        endPoint + normal * 0.6,
        groovePaint,
      );

      // Raised gold bevel crest (highlighted top-left facing edge)
      final ribHighlight = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.butt
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _goldBright.withValues(alpha: 0.95),
            _goldFace.withValues(alpha: 0.70),
            _goldMid.withValues(alpha: 0.40),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawLine(
        startPoint - normal * 0.7,
        endPoint - normal * 0.7,
        ribHighlight,
      );

      // Hairline specular glint on the ridge
      final ridgeSpecular = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.4
        ..color = Colors.white.withValues(alpha: 0.45);
      canvas.drawLine(
        startPoint - normal * 0.9,
        endPoint - normal * 0.9,
        ridgeSpecular,
      );
    }

    // -- STEP 5: OUTER MULTI-STEPPED GOLD COIN BEZEL ----------------
    // Exactly like the heavy chamfered gold rim on POMAD PRIMA!

    // Layer 5A: Outermost bronze edge bevel
    final outerBevelBase = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..shader = LinearGradient(
        begin: const Alignment(-0.85, -0.90),
        end: const Alignment(0.85, 0.90),
        colors: [
          _goldMid.withValues(alpha: 0.85),
          _goldDeep.withValues(alpha: 0.95),
          _goldDark,
        ],
        stops: const [0.0, 0.48, 1.0],
      ).createShader(
          Rect.fromCircle(center: center, radius: outerRadius + 2.0));
    canvas.drawCircle(center, outerRadius + 2.2, outerBevelBase);

    // Layer 5B: Heavy Chamfered Primary Gold Rim
    final primaryGoldRim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..shader = LinearGradient(
        begin: const Alignment(-0.90, -0.92),
        end: const Alignment(0.80, 0.82),
        colors: [
          _goldBright, // bright specular reflection
          _goldFace, // warm minted gold
          _goldMid.withValues(alpha: 0.85),
          _goldDeep.withValues(alpha: 0.55), // shadow bronze
          _goldMid.withValues(alpha: 0.70),
        ],
        stops: const [0.0, 0.22, 0.55, 0.82, 1.0],
      ).createShader(
          Rect.fromCircle(center: center, radius: outerRadius + 1.2));
    canvas.drawCircle(center, outerRadius + 1.2, primaryGoldRim);

    // Layer 5C: Fine Specular Crest Hairline
    final outerSpecularHairline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.85),
          _goldBright.withValues(alpha: 0.65),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.70],
      ).createShader(
          Rect.fromCircle(center: center, radius: outerRadius + 2.8));
    canvas.drawCircle(center, outerRadius + 2.8, outerSpecularHairline);

    // Layer 5D: Inset Coin Groove (The recessed step inside the outer rim)
    final insetGroove = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85
      ..color = _goldDark.withValues(alpha: 0.90);
    canvas.drawCircle(center, outerRadius - 0.2, insetGroove);

    // -- STEP 6: INNER STEPPED GOLD COIN BEZEL ----------------------
    // The inner gold ring enclosing the center hub,
    // matching POMAD PRIMA inner coin circle

    // Layer 6A: Inner Groove / Recess
    final innerGroove = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = _goldDark.withValues(alpha: 0.95);
    canvas.drawCircle(center, innerRadius + 1.2, innerGroove);

    // Layer 6B: Raised Inner Gold Bezel Ring
    final innerGoldBezel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..shader = LinearGradient(
        begin: const Alignment(-0.85, -0.90),
        end: const Alignment(0.85, 0.90),
        colors: [
          _goldBright,
          _goldFace,
          _goldMid.withValues(alpha: 0.75),
          _goldDeep.withValues(alpha: 0.45),
          _goldMid.withValues(alpha: 0.60),
        ],
        stops: const [0.0, 0.25, 0.60, 0.85, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: innerRadius));
    canvas.drawCircle(center, innerRadius, innerGoldBezel);

    // Layer 6C: Inner Specular Edge Hairline
    final innerSpecularHairline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.80),
          _goldBright.withValues(alpha: 0.40),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.75],
      ).createShader(
          Rect.fromCircle(center: center, radius: innerRadius - 1.2));
    canvas.drawCircle(center, innerRadius - 1.2, innerSpecularHairline);
  }

  static int? indexAt(Offset position, Size size, {required int itemCount}) {
    final center = size.center(Offset.zero);
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final outerRadius = size.shortestSide * 0.46;
    final innerRadius = size.shortestSide * 0.17;

    if (distance > outerRadius || distance < innerRadius) {
      return null;
    }

    var angle = math.atan2(dy, dx) + math.pi / 2;
    if (angle < 0) {
      angle += 2 * math.pi;
    }

    final sweep = 2 * math.pi / itemCount;
    final index = math.min((angle / sweep).floor(), itemCount - 1);

    return index;
  }

  @override
  bool shouldRepaint(covariant _PieMenuPainter oldDelegate) {
    return oldDelegate.itemCount != itemCount ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}

class _MenuItemData {
  const _MenuItemData({
    required this.label,
    required this.description,
    required this.icon,
    required this.lightColor,
    required this.route,
  });

  final String label;
  final String description;
  final IconData icon;
  final Color lightColor;
  final String route;
}

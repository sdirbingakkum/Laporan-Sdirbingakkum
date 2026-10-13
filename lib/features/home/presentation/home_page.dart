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

/// Sleek modern floating center hub with sophisticated depth.
/// Borderless and minimal, yet distinctly 3D with layered reflections.
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
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.40),
                radius: 1.0,
                colors: [
                  Colors.white.withValues(alpha: 0.18),
                  const Color(0xFF0F261C).withValues(alpha: 0.50),
                  const Color(0xFF040F0A).withValues(alpha: 0.88),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.60),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Top-left curved specular sheen
                Positioned(
                  left: -12,
                  top: -14,
                  child: Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.70],
                      ),
                    ),
                  ),
                ),

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
                        // Chiseled 3D metallic icon in center hub
                        Icon(
                          icon,
                          color: iconColor,
                          size: diameterForCenter(context),
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.80),
                              offset: const Offset(1.6, 2.4),
                              blurRadius: 1,
                            ),
                            Shadow(
                              color: Colors.white.withValues(alpha: 0.45),
                              offset: const Offset(-0.7, -0.8),
                              blurRadius: 0,
                            ),
                            Shadow(
                              color: iconColor.withValues(alpha: 0.35),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            centerKey,
                            textAlign: TextAlign.center,
                            maxLines: centerKey == 'MENU UTAMA' ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: item == null ? _text : iconColor,
                              fontSize: centerTextSize(context, centerKey),
                              fontWeight: FontWeight.w800,
                              letterSpacing: centerKey.length > 18 ? 0.2 : 0.6,
                              height: 1.05,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  offset: const Offset(1.0, 1.6),
                                  blurRadius: 0,
                                ),
                                Shadow(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  offset: const Offset(-0.5, -0.5),
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

/// 3D Sculpted / Chiseled relief labels and icons:
/// - Distinct physical extrusion depth (multi-step shadow).
/// - Top-left directional specular rim (catching directional light).
/// - Anchored directly to the face of the pie slice with realistic drop shadow.
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
          scale: selected ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // =======================================================
              // TRUE 3D CHISELED METAL ICON
              // Sculpted, raised from the slice face with directional
              // highlights and deep physical extrusion shadows.
              // =======================================================
              AnimatedScale(
                scale: selected ? 1.10 : 1.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: Icon(
                  item.icon,
                  color: selected
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFFFAF7F0),
                  size: compact ? iconSize * 0.82 : iconSize * 0.86,
                  shadows: [
                    // Deep physical extrusion shadow (bottom-right wall)
                    Shadow(
                      color: Colors.black
                          .withValues(alpha: selected ? 0.95 : 0.85),
                      offset: const Offset(2.4, 3.4),
                      blurRadius: 1,
                    ),
                    // Intermediate shadow layer (gives thickness to the icon)
                    Shadow(
                      color: Colors.black
                          .withValues(alpha: selected ? 0.70 : 0.55),
                      offset: const Offset(1.2, 1.8),
                      blurRadius: 0,
                    ),
                    // Directional highlight on top-left edge
                    Shadow(
                      color: Colors.white
                          .withValues(alpha: selected ? 0.85 : 0.60),
                      offset: const Offset(-0.9, -1.0),
                      blurRadius: 0,
                    ),
                    // Soft light bounce from the colored slice below
                    Shadow(
                      color: item.lightColor
                          .withValues(alpha: selected ? 0.45 : 0.20),
                      offset: const Offset(0.0, -0.4),
                      blurRadius: 0,
                    ),
                    // Ambient glow aura when selected
                    if (selected)
                      Shadow(
                        color: item.lightColor.withValues(alpha: 0.60),
                        blurRadius: 18,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // =======================================================
              // TRUE 3D CHISELED TEXT
              // Raised lettering with physical depth and specular bevel.
              // =======================================================
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
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.45,
                  height: 1.05,
                  shadows: [
                    // Deep 3D extrusion wall
                    Shadow(
                      color: Colors.black
                          .withValues(alpha: selected ? 0.95 : 0.85),
                      offset: const Offset(1.8, 2.6),
                      blurRadius: 1,
                    ),
                    // Mid-extrusion bevel
                    Shadow(
                      color: Colors.black
                          .withValues(alpha: selected ? 0.60 : 0.45),
                      offset: const Offset(0.9, 1.3),
                      blurRadius: 0,
                    ),
                    // Sharp top-left specular catch light
                    Shadow(
                      color: Colors.white
                          .withValues(alpha: selected ? 0.75 : 0.50),
                      offset: const Offset(-0.7, -0.8),
                      blurRadius: 0,
                    ),
                    // Vibrant aura on selection
                    if (selected)
                      Shadow(
                        color: item.lightColor.withValues(alpha: 0.50),
                        blurRadius: 14,
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

/// Custom painter crafting sleek, sophisticated 3D volumetric pie slices:
/// - NO outer gold rim or border.
/// - NO heavy gold separator ribs.
/// - Pure 3D volume on each slice: curved pillowed surface lighting,
///   faceted specular shoulder, and micro-groove precision seams.
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

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = size.shortestSide * 0.43;
    final sweep = 2 * math.pi / itemCount;

    // -----------------------------------------------------------------
    // 1. SOFT AMBIENT BASE SHADOW
    // Floats the entire sleek 3D wheel cleanly above the dark canvas.
    // -----------------------------------------------------------------
    final baseShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.40)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(center.translate(0, 4.0), outerRadius + 1.0, baseShadow);

    // -----------------------------------------------------------------
    // 2. 3D VOLUMETRIC PIE SLICES
    // Each slice is sculpted with rich 3D curvature and lighting.
    // -----------------------------------------------------------------
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

      // Selected segment lifts up in 3D space with a deep cast shadow
      if (selected) {
        canvas.drawShadow(
          path,
          Colors.black.withValues(alpha: 0.65),
          14.0,
          true,
        );
      }

      // --- Volumetric Face Gradient ---
      // Sculpted 3D curvature: crisp top-left highlight, rich saturated core,
      // and deep shadowed falloff toward bottom-right.
      final faceGradient = Paint()
        ..shader = LinearGradient(
          begin: const Alignment(-0.85, -0.90),
          end: const Alignment(0.85, 0.90),
          colors: [
            Color.lerp(light, Colors.white, selected ? 0.52 : 0.40)!,
            Color.lerp(light, Colors.white, selected ? 0.28 : 0.18)!,
            Color.lerp(light, Colors.white, selected ? 0.10 : 0.05)!,
            light,
            Color.lerp(light, Colors.black, selected ? 0.10 : 0.18)!,
            Color.lerp(light, Colors.black, selected ? 0.32 : 0.44)!,
            Color.lerp(light, Colors.black, selected ? 0.58 : 0.70)!,
            Color.lerp(light, Colors.black, selected ? 0.78 : 0.88)!,
          ],
          stops: const [0.0, 0.05, 0.12, 0.28, 0.48, 0.68, 0.85, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, faceGradient);

      // --- Convex Dome Light Sheen ---
      // Simulates a smooth pillowed 3D surface reflecting ambient light.
      final domeLight = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.55, -0.60),
          radius: 0.88,
          colors: [
            Colors.white.withValues(alpha: selected ? 0.36 : 0.24),
            Colors.white.withValues(alpha: selected ? 0.14 : 0.08),
            Colors.white.withValues(alpha: selected ? 0.03 : 0.015),
            Colors.transparent,
          ],
          stops: const [0.0, 0.20, 0.45, 0.80],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, domeLight);

      // --- Sharp Specular Hotspot ---
      // A bright point of focused reflection, creating high-gloss depth.
      final specularSpot = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.46, -0.50),
          radius: 0.35,
          colors: [
            Colors.white.withValues(alpha: selected ? 0.32 : 0.18),
            Colors.white.withValues(alpha: selected ? 0.08 : 0.04),
            Colors.transparent,
          ],
          stops: const [0.0, 0.30, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, specularSpot);

      // --- Edge Chiaroscuro Vignette ---
      // Darkens the perimeter of each slice, making the center bulge forward.
      final edgeVignette = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.10),
            Colors.black.withValues(alpha: selected ? 0.35 : 0.48),
          ],
          stops: const [0.65, 0.88, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, edgeVignette);

      // --- Lower Depth Falloff ---
      final lowerDepth = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.80, 0.82),
          radius: 0.95,
          colors: [
            Colors.black.withValues(alpha: selected ? 0.36 : 0.45),
            Colors.black.withValues(alpha: 0.15),
            Colors.transparent,
          ],
          stops: const [0.0, 0.40, 0.85],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, lowerDepth);
    }

    // -----------------------------------------------------------------
    // 3. PRECISION MICRO-GROOVE SEAMS (NO HEAVY BARS)
    // Clean, hairline joint between slices: dark groove + hairline light.
    // Creates seamless 3D facet boundaries without any clunky borders.
    // -----------------------------------------------------------------
    for (var i = 0; i < itemCount; i++) {
      final angle = -math.pi / 2 + i * sweep;
      final unit = Offset(math.cos(angle), math.sin(angle));
      final normal = Offset(-unit.dy, unit.dx);
      final startPoint = center;
      final endPoint = Offset(
        center.dx + unit.dx * outerRadius,
        center.dy + unit.dy * outerRadius,
      );

      // Recessed micro-groove (dark shadow line)
      final darkGroove = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.butt
        ..color = Colors.black.withValues(alpha: 0.45);
      canvas.drawLine(
        startPoint + normal * 0.5,
        endPoint + normal * 0.5,
        darkGroove,
      );

      // Highlighted micro-crest (hairline light reflection on opposite edge)
      final lightCrest = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..strokeCap = StrokeCap.butt
        ..color = Colors.white.withValues(alpha: 0.28);
      canvas.drawLine(
        startPoint - normal * 0.6,
        endPoint - normal * 0.6,
        lightCrest,
      );
    }

    // -----------------------------------------------------------------
    // 4. NATURAL BEVEL HAIRLINE ON OUTER EDGE (NO GOLD RIM)
    // A subtle, clean directional catch-light on the top-left outer curve,
    // creating a polished beveled edge without any colored border.
    // -----------------------------------------------------------------
    final outerBevelLight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.10),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.25),
        ],
        stops: const [0.0, 0.25, 0.60, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
    canvas.drawCircle(center, outerRadius - 0.4, outerBevelLight);
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

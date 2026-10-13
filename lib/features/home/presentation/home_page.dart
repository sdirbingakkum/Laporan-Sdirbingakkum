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
        final maxHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : maxWidth;
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

class _PieMenuCenter extends StatelessWidget {
  const _PieMenuCenter({this.item});

  final _MenuItemData? item;

  @override
  Widget build(BuildContext context) {
    final icon = item?.icon ?? Icons.apps_rounded;
    final iconColor = item?.lightColor ?? _goldLight;
    final centerKey = item?.label ?? 'MENU UTAMA';

    return FractionallySizedBox(
      widthFactor: 0.34,
      heightFactor: 0.34,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.20),
                  const Color(0xFF173428).withValues(alpha: 0.42),
                  const Color(0xFF06120D).withValues(alpha: 0.72),
                ],
                stops: const [0.0, 0.42, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.28),
                width: 1.2,
              ),
              boxShadow: [
                // Deeper, more dramatic outer shadow for 3D depth
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.50),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                // Subtle gold glow behind center hub
                BoxShadow(
                  color: _goldLight.withValues(alpha: 0.10),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Upper-left specular highlight orb
                Positioned(
                  left: -14,
                  top: -16,
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.20),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.72],
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
                        Icon(
                          icon,
                          color: iconColor.withValues(alpha: 0.94),
                          size: diameterForCenter(context),
                          shadows: [
                            // Glow aura behind center icon
                            Shadow(
                              color: iconColor.withValues(alpha: 0.30),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            centerKey,
                            textAlign: TextAlign.center,
                            maxLines: centerKey == 'MENU UTAMA' ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: item == null ? _text : iconColor,
                              fontSize: centerTextSize(context, centerKey),
                              fontWeight: FontWeight.w700,
                              letterSpacing: centerKey.length > 18
                                  ? 0.05
                                  : 0.55,
                              height: 1.02,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.48),
                                  offset: const Offset(0.8, 1.2),
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
    return shortest < 300 ? 21 : 26;
  }

  double centerTextSize(BuildContext context, String text) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;

    if (text == 'MENU UTAMA') {
      return shortest < 300 ? 8.0 : 9.2;
    }

    if (text.length >= 22) {
      return shortest < 300 ? 6.5 : 7.5;
    }

    if (text.length >= 18) {
      return shortest < 300 ? 7.0 : 8.0;
    }

    return shortest < 300 ? 7.6 : 8.6;
  }
}

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
          scale: selected ? 1.02 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Background-free 3D icon: a compact dark extrusion plus a
              // tiny upper highlight make it feel raised from the colored face.
              // Enhanced: glow aura when selected for luxurious depth.
              AnimatedScale(
                scale: selected ? 1.08 : 1,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: Icon(
                  item.icon,
                  color: selected
                      ? const Color(0xFFF8F5EC)
                      : const Color(0xFFEFECE3),
                  size: compact ? iconSize * 0.78 : iconSize * 0.80,
                  shadows: [
                    // Primary extrusion shadow — deeper for 3D
                    Shadow(
                      color: Colors.black.withValues(
                        alpha: selected ? 0.80 : 0.62,
                      ),
                      offset: const Offset(1.8, 2.8),
                      blurRadius: 0,
                    ),
                    // Secondary colored extrusion layer
                    Shadow(
                      color: item.lightColor.withValues(
                        alpha: selected ? 0.28 : 0.14,
                      ),
                      offset: const Offset(0.7, 1.0),
                      blurRadius: 0,
                    ),
                    // Upper highlight for raised feel
                    Shadow(
                      color: Colors.white.withValues(
                        alpha: selected ? 0.18 : 0.08,
                      ),
                      offset: const Offset(-0.55, -0.65),
                      blurRadius: 0,
                    ),
                    // Glow aura behind icon when selected
                    Shadow(
                      color: item.lightColor.withValues(
                        alpha: selected ? 0.40 : 0.0,
                      ),
                      blurRadius: selected ? 16 : 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
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
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.35,
                  height: 1.05,
                  shadows: [
                    // Small stacked offsets create letter extrusion without
                    // introducing any background behind the label.
                    // Deeper primary shadow for 3D raised text
                    Shadow(
                      color: Colors.black.withValues(
                        alpha: selected ? 0.80 : 0.62,
                      ),
                      offset: const Offset(1.4, 2.2),
                      blurRadius: 0,
                    ),
                    // Mid-depth layer
                    Shadow(
                      color: Colors.black.withValues(
                        alpha: selected ? 0.34 : 0.24,
                      ),
                      offset: const Offset(0.7, 1.1),
                      blurRadius: 0,
                    ),
                    // Upper highlight
                    Shadow(
                      color: Colors.white.withValues(
                        alpha: selected ? 0.16 : 0.08,
                      ),
                      offset: const Offset(-0.45, -0.5),
                      blurRadius: 0,
                    ),
                    // Glow aura behind text when selected
                    Shadow(
                      color: item.lightColor.withValues(
                        alpha: selected ? 0.28 : 0.0,
                      ),
                      blurRadius: selected ? 10 : 0,
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

class _PieMenuPainter extends CustomPainter {
  const _PieMenuPainter({required this.itemCount, required this.selectedIndex});

  final int itemCount;
  final int selectedIndex;

  // Locked module colors, matching the five menu identities.
  static const _lightPalette = <Color>[
    Color(0xFFF09A4A), // PELANGGARAN — orange
    Color(0xFFE15B5B), // LAKA-LALIN — red
    Color(0xFF5D8FE0), // SIM TNI — blue
    Color(0xFFE3BE4F), // K9 — gold
    Color(0xFF49A86B), // PROVOS TNI-AD — green
  ];

  // Gold tones for metallic rings
  static const _goldBright = Color(0xFFF1D37A);
  static const _goldDark = Color(0xFF8B6914);
  static const _goldMid = Color(0xFFD4A535);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = size.shortestSide * 0.43;
    final innerRadius = size.shortestSide * 0.17;
    final sweep = 2 * math.pi / itemCount;

    // ── UPGRADE 1: 3D Extruded Rim ──────────────────────────────────
    // Draw offset copies of the pie from back to front to create the
    // illusion of a thick coin/medal rim beneath the face.
    const int rimDepth = 6;
    for (var layer = rimDepth; layer >= 1; layer--) {
      final layerOffset = Offset(0, layer * 0.8);
      final layerAlpha = 0.12 + (layer / rimDepth) * 0.14;
      final rimPaint = Paint()
        ..color = Colors.black.withValues(alpha: layerAlpha);

      for (var i = 0; i < itemCount; i++) {
        final start = -math.pi / 2 + i * sweep;
        final light = _lightPalette[i];

        final path = Path()
          ..moveTo(center.dx + layerOffset.dx, center.dy + layerOffset.dy)
          ..lineTo(
            center.dx + math.cos(start) * outerRadius + layerOffset.dx,
            center.dy + math.sin(start) * outerRadius + layerOffset.dy,
          )
          ..arcTo(
            Rect.fromCircle(
              center: center + layerOffset,
              radius: outerRadius,
            ),
            start,
            sweep,
            false,
          )
          ..close();

        // Use a very dark version of the module color for the rim
        final rimColor = Color.lerp(light, Colors.black, 0.82)!;
        rimPaint.color = rimColor.withValues(alpha: layerAlpha);
        canvas.drawPath(path, rimPaint);
      }
    }

    // ── UPGRADE 2: Ambient Glow per Segment ─────────────────────────
    // A soft radial glow behind each segment using its module color.
    for (var i = 0; i < itemCount; i++) {
      final start = -math.pi / 2 + i * sweep;
      final midAngle = start + sweep / 2;
      final selected = i == selectedIndex;
      final light = _lightPalette[i];

      final glowCenter = Offset(
        center.dx + math.cos(midAngle) * outerRadius * 0.55,
        center.dy + math.sin(midAngle) * outerRadius * 0.55,
      );

      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            light.withValues(alpha: selected ? 0.18 : 0.04),
            light.withValues(alpha: selected ? 0.06 : 0.01),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(
          Rect.fromCircle(center: glowCenter, radius: outerRadius * 0.55),
        )
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, selected ? 18 : 10);

      canvas.drawCircle(glowCenter, outerRadius * 0.50, glowPaint);
    }

    // ── Base shadow beneath the main face ────────────────────────────
    final faceShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(center.translate(0, 3.5), outerRadius + 2, faceShadow);

    // ── Main pie segments (face) ─────────────────────────────────────
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

      // Elevated shadow for selected segment
      if (selected) {
        canvas.drawShadow(
          path,
          Colors.black.withValues(alpha: 0.52),
          10.0,
          true,
        );
      }

      // ── UPGRADE 3: Polished metallic face with dramatic specular ──
      // Enhanced gradient with brighter highlights and deeper shadows.
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(light, Colors.white, selected ? 0.42 : 0.34)!,
            Color.lerp(light, Colors.white, selected ? 0.22 : 0.16)!,
            Color.lerp(light, Colors.white, selected ? 0.08 : 0.04)!,
            light,
            Color.lerp(light, Colors.black, selected ? 0.06 : 0.10)!,
            Color.lerp(light, Colors.black, selected ? 0.24 : 0.30)!,
            Color.lerp(light, Colors.black, selected ? 0.44 : 0.52)!,
            Color.lerp(light, Colors.black, selected ? 0.62 : 0.70)!,
            Color.lerp(light, Colors.black, selected ? 0.80 : 0.88)!,
          ],
          stops: const [0.0, 0.04, 0.09, 0.16, 0.30, 0.48, 0.66, 0.82, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, paint);

      // ── Upper specular highlight — brighter, more focused ─────────
      final upperSpecular = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.62, -0.66),
          radius: 0.80,
          colors: [
            Colors.white.withValues(alpha: selected ? 0.34 : 0.24),
            Colors.white.withValues(alpha: selected ? 0.14 : 0.08),
            Colors.white.withValues(alpha: selected ? 0.04 : 0.02),
            Colors.transparent,
          ],
          stops: const [0.0, 0.14, 0.32, 0.62],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, upperSpecular);

      // ── Tight specular hotspot — chrome-like bright spot ──────────
      final hotspot = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.50, -0.54),
          radius: 0.38,
          colors: [
            Colors.white.withValues(alpha: selected ? 0.22 : 0.12),
            Colors.white.withValues(alpha: selected ? 0.06 : 0.03),
            Colors.transparent,
          ],
          stops: const [0.0, 0.30, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, hotspot);

      // ── Lower depth shadow — deeper for volume ────────────────────
      final lowerDepth = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.72, 0.74),
          radius: 0.98,
          colors: [
            Colors.black.withValues(alpha: selected ? 0.40 : 0.46),
            Colors.black.withValues(alpha: selected ? 0.20 : 0.26),
            Colors.transparent,
          ],
          stops: const [0.0, 0.34, 0.82],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, lowerDepth);

      // ── Narrow sweep highlight for machined-metal feel ────────────
      final sweepHighlight = Paint()
        ..shader = LinearGradient(
          begin: Alignment(-0.92, -0.88),
          end: Alignment(0.72, 0.70),
          colors: [
            Colors.white.withValues(alpha: selected ? 0.20 : 0.12),
            Colors.white.withValues(alpha: selected ? 0.06 : 0.035),
            Colors.transparent,
          ],
          stops: const [0.0, 0.14, 0.42],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, sweepHighlight);

      // ── Lower-right bevel shadow for embossed insignia feel ───────
      final bevelShadow = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.82, 0.80),
          radius: 1.0,
          colors: [
            Colors.black.withValues(alpha: selected ? 0.36 : 0.28),
            Colors.black.withValues(alpha: selected ? 0.10 : 0.07),
            Colors.transparent,
          ],
          stops: const [0.0, 0.30, 0.72],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, bevelShadow);
    }

    // ── Radial module separators — embossed joint lines ──────────────
    for (var i = 0; i < itemCount; i++) {
      final angle = -math.pi / 2 + i * sweep;
      final unit = Offset(math.cos(angle), math.sin(angle));
      final normal = Offset(-unit.dy, unit.dx);
      final startPoint = center;
      final endPoint = Offset(
        center.dx + unit.dx * outerRadius,
        center.dy + unit.dy * outerRadius,
      );

      final groove = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.butt
        ..color = Colors.black.withValues(alpha: 0.30);
      canvas.drawLine(
        startPoint + normal * 0.7,
        endPoint + normal * 0.7,
        groove,
      );

      final bevelLight = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.55
        ..strokeCap = StrokeCap.butt
        ..color = Colors.white.withValues(alpha: 0.24);
      canvas.drawLine(
        startPoint - normal * 0.8,
        endPoint - normal * 0.8,
        bevelLight,
      );
    }

    // ── UPGRADE 5: Outer Metallic Gold Ring ─────────────────────────
    // A polished gold ring at the outside edge, directional-lit.
    final outerRingWidth = 2.2;

    // Dark base of the ring (shadow side)
    final outerRingBase = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerRingWidth + 0.6
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _goldMid.withValues(alpha: 0.50),
          _goldDark.withValues(alpha: 0.60),
          Colors.black.withValues(alpha: 0.40),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
    canvas.drawCircle(center, outerRadius + 1.5, outerRingBase);

    // Bright highlight on the ring
    final outerRingHighlight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerRingWidth
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _goldBright.withValues(alpha: 0.82),
          _goldMid.withValues(alpha: 0.50),
          _goldDark.withValues(alpha: 0.30),
          _goldMid.withValues(alpha: 0.22),
        ],
        stops: const [0.0, 0.28, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
    canvas.drawCircle(center, outerRadius + 1.5, outerRingHighlight);

    // Thin specular edge on the outer ring
    final outerRingSpec = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = Colors.white.withValues(alpha: 0.28);
    canvas.drawCircle(center, outerRadius + 2.6, outerRingSpec);

    // ── UPGRADE 4: Inner Metallic Gold Ring (bezel) ─────────────────
    // A refined gold bezel separating the segments from the center hub.
    final innerRingWidth = 1.8;

    // Dark base of inner ring
    final innerRingBase = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = innerRingWidth + 0.4
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _goldBright.withValues(alpha: 0.40),
          _goldDark.withValues(alpha: 0.50),
          Colors.black.withValues(alpha: 0.30),
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: innerRadius));
    canvas.drawCircle(center, innerRadius, innerRingBase);

    // Bright highlight on inner ring
    final innerRingHighlight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = innerRingWidth
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _goldBright.withValues(alpha: 0.74),
          _goldMid.withValues(alpha: 0.44),
          _goldDark.withValues(alpha: 0.24),
          _goldMid.withValues(alpha: 0.18),
        ],
        stops: const [0.0, 0.30, 0.68, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: innerRadius));
    canvas.drawCircle(center, innerRadius, innerRingHighlight);

    // Thin specular edge on inner ring
    final innerRingSpec = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4
      ..color = Colors.white.withValues(alpha: 0.22);
    canvas.drawCircle(center, innerRadius - 1.0, innerRingSpec);

    // ── UPGRADE 6: Center hub double-bezel rings ────────────────────
    // Two concentric thin gold rings around the center hub area.
    final centerRadius = size.shortestSide * 0.17 * 0.92;

    // Outer bezel ring of center hub
    final centerOuterBezel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _goldBright.withValues(alpha: 0.60),
          _goldDark.withValues(alpha: 0.30),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: centerRadius));
    canvas.drawCircle(center, centerRadius, centerOuterBezel);

    // Inner bezel ring of center hub (slightly smaller)
    final centerInnerBezel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _goldBright.withValues(alpha: 0.42),
          _goldDark.withValues(alpha: 0.20),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: centerRadius - 3.5),
      );
    canvas.drawCircle(center, centerRadius - 3.5, centerInnerBezel);

    // Radial gold glow behind center hub
    final centerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          _goldBright.withValues(alpha: 0.08),
          _goldBright.withValues(alpha: 0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: centerRadius + 8),
      );
    canvas.drawCircle(center, centerRadius + 8, centerGlow);
  }

  static int? indexAt(Offset position, Size size, {required int itemCount}) {
    final center = size.center(Offset.zero);
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final outerRadius = size.shortestSide * 0.46;
    final innerRadius = size.shortestSide * 0.19;

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

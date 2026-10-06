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
      description: 'HALAMAN K9 DISIAPKAN UNTUK PENGISIAN DATA BERIKUTNYA.',
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
                  Colors.white.withValues(alpha: 0.16),
                  const Color(0xFF173428).withValues(alpha: 0.36),
                  const Color(0xFF06120D).withValues(alpha: 0.62),
                ],
                stops: const [0.0, 0.42, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.24),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.34),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Stack(
              children: [
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
                          Colors.white.withValues(alpha: 0.14),
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
                    Shadow(
                      color: Colors.black.withValues(
                        alpha: selected ? 0.72 : 0.58,
                      ),
                      offset: const Offset(1.5, 2.2),
                      blurRadius: 0,
                    ),
                    Shadow(
                      color: item.lightColor.withValues(
                        alpha: selected ? 0.22 : 0.14,
                      ),
                      offset: const Offset(0.7, 1.0),
                      blurRadius: 0,
                    ),
                    Shadow(
                      color: Colors.white.withValues(
                        alpha: selected ? 0.14 : 0.08,
                      ),
                      offset: const Offset(-0.55, -0.65),
                      blurRadius: 0,
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
                    Shadow(
                      color: Colors.black.withValues(
                        alpha: selected ? 0.72 : 0.58,
                      ),
                      offset: const Offset(1.2, 1.8),
                      blurRadius: 0,
                    ),
                    Shadow(
                      color: Colors.black.withValues(
                        alpha: selected ? 0.28 : 0.20,
                      ),
                      offset: const Offset(0.55, 0.9),
                      blurRadius: 0,
                    ),
                    Shadow(
                      color: Colors.white.withValues(
                        alpha: selected ? 0.14 : 0.08,
                      ),
                      offset: const Offset(-0.45, -0.5),
                      blurRadius: 0,
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

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = size.shortestSide * 0.43;
    final sweep = 2 * math.pi / itemCount;

    // No physical layer is drawn beneath the wheel. Metallic depth is
    // carried by the face lighting and restrained edge treatment.
    final faceShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.20)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center.translate(0, 2.5), outerRadius + 1, faceShadow);

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

      // Polished metallic face: a crisp specular highlight, stable module
      // color through the midtone, then a long controlled falloff into shadow.
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(light, Colors.white, selected ? 0.36 : 0.30)!,
            Color.lerp(light, Colors.white, selected ? 0.14 : 0.10)!,
            light,
            Color.lerp(light, Colors.black, selected ? 0.07 : 0.10)!,
            Color.lerp(light, Colors.black, selected ? 0.26 : 0.32)!,
            Color.lerp(light, Colors.black, selected ? 0.48 : 0.56)!,
            Color.lerp(light, Colors.black, selected ? 0.68 : 0.74)!,
            Color.lerp(light, Colors.black, selected ? 0.86 : 0.92)!,
          ],
          stops: const [0.0, 0.05, 0.13, 0.27, 0.45, 0.65, 0.83, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, paint);

      // Metallic volume is produced with soft light fields rather than
      // circular stroke lines. This keeps the outer edge clean.
      final upperSpecular = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.58, -0.62),
          radius: 0.92,
          colors: [
            Colors.white.withValues(alpha: selected ? 0.24 : 0.18),
            Colors.white.withValues(alpha: selected ? 0.08 : 0.055),
            Colors.transparent,
          ],
          stops: const [0.0, 0.20, 0.62],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, upperSpecular);

      final lowerDepth = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.72, 0.74),
          radius: 0.98,
          colors: [
            Colors.black.withValues(alpha: selected ? 0.34 : 0.40),
            Colors.black.withValues(alpha: selected ? 0.16 : 0.20),
            Colors.transparent,
          ],
          stops: const [0.0, 0.34, 0.82],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawPath(path, lowerDepth);
    }

    // Keep only the radial module separators; the circular outer contour
    // stays completely free of decorative lines.
    final seamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.butt
      ..color = const Color(0xFF09231A).withValues(alpha: 0.80);

    for (var i = 0; i < itemCount; i++) {
      final angle = -math.pi / 2 + i * sweep;
      canvas.drawLine(
        center,
        Offset(
          center.dx + math.cos(angle) * outerRadius,
          center.dy + math.sin(angle) * outerRadius,
        ),
        seamPaint,
      );
    }

    // No separate circular outer-lip lines. The metallic volume is carried
    // by the face gradient and the subtle per-slice bevel/specular treatment.
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

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/auth_repository.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_header.dart';

// Responsive geometry is derived from the available mobile/web viewport.

const _bg = Color(0xFF03150F);
const _surface = Color(0xFF09231A);
const _surfaceSoft = Color(0xFF0D2C20);
const _gold = Color(0xFFD7A93C);
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
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(colors: [_surfaceSoft, _surface]),
          border: Border.all(
            color: iconColor.withValues(alpha: 0.72),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.12),
              blurRadius: 28,
              spreadRadius: 3,
            ),
            const BoxShadow(
              color: Colors.black54,
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Center(
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
                Icon(icon, color: iconColor, size: diameterForCenter(context)),
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
                      fontWeight: FontWeight.w900,
                      letterSpacing: centerKey.length > 18 ? 0.1 : 0.8,
                      height: 1.02,
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
    return shortest < 300 ? 23 : 29;
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
    final iconSize = compact ? 31.0 : 37.0;
    final labelFontSize = compact ? 8.2 : 9.3;
    final isLong = item.label.length > 20;

    return Transform.translate(
      offset: Offset(
        math.cos(angle) * labelRadius,
        math.sin(angle) * labelRadius,
      ),
      child: SizedBox(
        width: labelWidth,
        child: AnimatedScale(
          scale: selected ? 1.05 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? iconSize + 3 : iconSize,
                height: selected ? iconSize + 3 : iconSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: selected
                        ? [
                            item.lightColor.withValues(alpha: 0.26),
                            _surface.withValues(alpha: 0.82),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.07),
                            _surface.withValues(alpha: 0.74),
                            const Color(0xFF05130E),
                          ],
                  ),
                  border: Border.all(
                    color: selected
                        ? item.lightColor.withValues(alpha: 0.92)
                        : Colors.white.withValues(alpha: 0.22),
                    width: selected ? 1.4 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: selected
                          ? item.lightColor.withValues(alpha: 0.20)
                          : Colors.black26,
                      blurRadius: selected ? 16 : 8,
                    ),
                  ],
                ),
                child: Icon(
                  item.icon,
                  color: selected ? item.lightColor : _text,
                  size: compact ? 16 : 19,
                ),
              ),
              const SizedBox(height: 5),
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
                  letterSpacing: 0.25,
                  height: 1.05,
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

  static const _lightPalette = <Color>[
    Color(0xFFE1A361),
    Color(0xFFD06F69),
    Color(0xFF7198D2),
    Color(0xFFD4B85F),
    Color(0xFF6CAF88),
  ];

  static const _darkPalette = <Color>[
    Color(0xFF744A26),
    Color(0xFF642F35),
    Color(0xFF2A456B),
    Color(0xFF6C5823),
    Color(0xFF28523D),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = size.shortestSide * 0.43;
    final sweep = 2 * math.pi / itemCount;

    for (var i = 0; i < itemCount; i++) {
      final start = -math.pi / 2 + i * sweep;
      final segmentCenter = start + sweep / 2;
      final selected = i == selectedIndex;

      // The base menu is a mathematically complete circle. Only the
      // selected sector is translated outward to create the "lift".
      final lift = selected ? size.shortestSide * 0.026 : 0.0;
      final segmentCenterOffset = Offset(
        math.cos(segmentCenter) * lift,
        math.sin(segmentCenter) * lift,
      );
      final segmentCenterPoint = center + segmentCenterOffset;
      final light = _lightPalette[i];
      final dark = _darkPalette[i];

      final path = Path()
        ..moveTo(segmentCenterPoint.dx, segmentCenterPoint.dy)
        ..lineTo(
          segmentCenterPoint.dx + math.cos(start) * outerRadius,
          segmentCenterPoint.dy + math.sin(start) * outerRadius,
        )
        ..arcTo(
          Rect.fromCircle(center: segmentCenterPoint, radius: outerRadius),
          start,
          sweep,
          false,
        )
        ..close();

      final depthPaint = Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                dark.withValues(alpha: 0.92),
                const Color(0xFF020806).withValues(alpha: 0.88),
              ],
            ).createShader(
              Rect.fromCircle(
                center: segmentCenterPoint + const Offset(0, 6),
                radius: outerRadius,
              ),
            );
      canvas.drawPath(path.shift(const Offset(0, 6)), depthPaint);

      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: selected ? 0.34 : 0.20)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, selected ? 12 : 8);
      canvas.drawPath(path.shift(Offset(0, selected ? 8 : 5)), shadowPaint);

      final paint = Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                light.withValues(alpha: selected ? 0.96 : 0.88),
                light.withValues(alpha: selected ? 0.72 : 0.62),
                dark.withValues(alpha: 0.96),
              ],
              stops: const [0.0, 0.42, 1.0],
            ).createShader(
              Rect.fromCircle(center: segmentCenterPoint, radius: outerRadius),
            );
      canvas.drawPath(path, paint);

      final bevelPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 1.1 : 0.8
        ..color = Colors.white.withValues(alpha: selected ? 0.15 : 0.075);
      canvas.drawPath(path, bevelPaint);
    }

    // Subtle separators, not black gaps: every sector still touches its
    // neighbors and the outer silhouette remains a true circle.
    final seamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.butt
      ..color = _surfaceSoft.withValues(alpha: 0.62);

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

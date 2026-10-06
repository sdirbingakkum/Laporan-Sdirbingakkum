import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/auth_repository.dart';

const _bg = Color(0xFF03150F);
const _surface = Color(0xFF09231A);
const _surfaceSoft = Color(0xFF0D2C20);
const _gold = Color(0xFFD7A93C);
const _goldLight = Color(0xFFF1D37A);
const _goldDark = Color(0xFF8D651E);
const _text = Color(0xFFF8F5EC);
const _muted = Color(0xFFB7C2BC);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  bool _navigationInProgress = false;

  static const _items = <_MenuItemData>[
    _MenuItemData(
      label: 'Statistik Pelanggaran',
      description: 'Ringkasan dan tren pelanggaran hukum.',
      icon: Icons.gavel_rounded,
      lightColor: Color(0xFFF09A4A),
      darkColor: Color(0xFF5A2B0D),
      route: '/statistik/pelanggaran',
    ),
    _MenuItemData(
      label: 'Statistik Laka-lalin',
      description: 'Ringkasan dan tren kecelakaan lalu lintas.',
      icon: Icons.directions_car_filled_outlined,
      lightColor: Color(0xFFE15B5B),
      darkColor: Color(0xFF461518),
      route: '/statistik/laka-lalin',
    ),
    _MenuItemData(
      label: 'Statistik SIM TNI',
      description: 'Ringkasan penerbitan dan data SIM TNI.',
      icon: Icons.badge_outlined,
      lightColor: Color(0xFF5D8FE0),
      darkColor: Color(0xFF192A55),
      route: '/statistik/sim-tni',
    ),
    _MenuItemData(
      label: 'Statistik K9',
      description: 'Informasi dan statistik satuan K9.',
      icon: Icons.pets_rounded,
      lightColor: Color(0xFFE3BE4F),
      darkColor: Color(0xFF59410D),
      route: '/statistik/k9',
    ),
    _MenuItemData(
      label: 'Statistik Provos TNI-AD',
      description: 'Ringkasan data dan kinerja Provos TNI-AD.',
      icon: Icons.military_tech_rounded,
      lightColor: Color(0xFF49A86B),
      darkColor: Color(0xFF123827),
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
            'Keluar dari sistem?',
            style: TextStyle(color: _text, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Sesi Anda akan diakhiri dan Anda akan kembali ke halaman Sign In.',
            style: TextStyle(color: _muted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: _goldLight,
                foregroundColor: const Color(0xFF10140F),
              ),
              child: const Text('Keluar'),
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
          content: Text('Tidak dapat mengakhiri sesi. Coba lagi.'),
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

    if (mounted) {
      setState(() {
        _navigationInProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          const Positioned.fill(child: _MenuBackdrop()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                          child: _MenuHeader(onSignOut: _confirmSignOut),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'SEMUA STATISTIK',
                          style: TextStyle(
                            color: _goldLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4.2,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: _PieMenu(
                                items: _items,
                                selectedIndex: _selectedIndex,
                                onSelected: _selectMenu,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 92,
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          decoration: BoxDecoration(
            color: _surface.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _gold.withValues(alpha: 0.50),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: ClipRect(
            child: Transform.scale(
              scale: 1.48,
              child: Image.asset(
                'assets/images/pomad_puspomad.webp',
                fit: BoxFit.contain,
                semanticLabel: 'Logo PUSPOMAD',
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SDIRBINGAKKUM',
                style: TextStyle(
                  color: _goldLight,
                  fontFamily: 'serif',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'P U S P O M A D',
                style: TextStyle(
                  color: _text,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.8,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Sistem Laporan Bidang Gakkum',
                style: TextStyle(
                  color: _muted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: _surface.withValues(alpha: 0.84),
            shape: BoxShape.circle,
            border: Border.all(color: _gold.withValues(alpha: 0.24)),
          ),
          child: PopupMenuButton<String>(
            tooltip: 'Menu akun',
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: _goldLight,
              size: 22,
            ),
            color: _surface,
            onSelected: (value) {
              if (value == 'signout') {
                onSignOut();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'signout',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout_rounded, color: _goldLight),
                    SizedBox(width: 10),
                    Text(
                      'Keluar / Sign Out',
                      style: TextStyle(color: _text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
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
              Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [_surfaceSoft, _surface],
                  ),
                  border: Border.all(
                    color: _gold.withValues(alpha: 0.56),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.12),
                      blurRadius: 34,
                      spreadRadius: 3,
                    ),
                    const BoxShadow(
                      color: Colors.black54,
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        items[selectedIndex].icon,
                        key: ValueKey(items[selectedIndex].label),
                        color: items[selectedIndex].lightColor,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'MENU',
                      style: TextStyle(
                        color: _text,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.8,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'UTAMA',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.4,
                      ),
                    ),
                  ],
                ),
              ),
              for (var i = 0; i < items.length; i++)
                _PieMenuLabel(
                  index: i,
                  item: items[i],
                  itemCount: items.length,
                  selected: i == selectedIndex,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PieMenuLabel extends StatelessWidget {
  const _PieMenuLabel({
    required this.index,
    required this.item,
    required this.itemCount,
    required this.selected,
  });

  final int index;
  final _MenuItemData item;
  final int itemCount;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    const radius = 132.0;
    final angle = -math.pi / 2 + (2 * math.pi / itemCount) * (index + 0.5);

    return Transform.translate(
      offset: Offset(math.cos(angle) * radius, math.sin(angle) * radius),
      child: AnimatedScale(
        scale: selected ? 1.06 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: 102,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 48 : 44,
                height: selected ? 48 : 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? item.lightColor.withValues(alpha: 0.18)
                      : _surface.withValues(alpha: 0.78),
                  border: Border.all(
                    color: selected
                        ? item.lightColor.withValues(alpha: 0.84)
                        : _gold.withValues(alpha: 0.26),
                    width: selected ? 1.4 : 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: item.lightColor.withValues(alpha: 0.16),
                            blurRadius: 18,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  item.icon,
                  color: selected ? item.lightColor : _muted,
                  size: selected ? 21 : 19,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? item.lightColor : _text,
                  fontSize: item.label == 'LAKA LALIN' ? 9.5 : 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
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
  const _PieMenuPainter({
    required this.itemCount,
    required this.selectedIndex,
  });

  final int itemCount;
  final int selectedIndex;

  static const _segmentGap = 0.045;

  static const _lightPalette = <Color>[
    Color(0xFFF09A4A), // orange — Statistik Pelanggaran
    Color(0xFF5D8FE0), // blue — Statistik SIM TNI
    Color(0xFF49A86B), // green — Statistik Provos TNI-AD
    Color(0xFFE15B5B), // red — Statistik Laka-lalin
    Color(0xFFE3BE4F), // yellow — K9
  ];

  static const _darkPalette = <Color>[
    Color(0xFF5A2B0D), // orange
    Color(0xFF192A55), // blue
    Color(0xFF123827), // green
    Color(0xFF461518), // red
    Color(0xFF59410D), // yellow
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = size.shortestSide * 0.43;
    final segmentSweep =
        (2 * math.pi - (_segmentGap * itemCount)) / itemCount;
    final startOffset = -math.pi / 2;

    for (var i = 0; i < itemCount; i++) {
      final start =
          startOffset + i * (segmentSweep + _segmentGap) + _segmentGap / 2;
      final selected = i == selectedIndex;
      final radius = outerRadius + (selected ? 9 : 0);
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + math.cos(start) * radius,
          center.dy + math.sin(start) * radius,
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          start,
          segmentSweep,
          false,
        )
        ..close();

      final colors = <Color>[
        // Merah: merah marun gelap dengan highlight elegan.
        _lightPalette[i].withValues(alpha: selected ? 1 : 0.90),
        _darkPalette[i],
      ];

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.first,
            colors.first.withValues(alpha: selected ? 0.88 : 0.72),
            colors.last,
          ],
          stops: const [0.0, 0.42, 1.0],
        ).createShader(
          Rect.fromCircle(center: center, radius: radius),
        );

      canvas.drawPath(path, paint);

      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 1.7 : 1
        ..color = selected
            ? colors.first.withValues(alpha: 0.96)
            : colors.first.withValues(alpha: 0.34);

      canvas.drawPath(path, borderPaint);
    }

    final innerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          _gold.withValues(alpha: 0.10),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: outerRadius * 0.58),
      );

    canvas.drawCircle(center, outerRadius * 0.58, innerGlow);
  }

  static int? indexAt(
    Offset position,
    Size size, {
    required int itemCount,
  }) {
    final center = size.center(Offset.zero);
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final outerRadius = size.shortestSide * 0.46;

    if (distance > outerRadius || distance < 72) {
      return null;
    }

    var angle = math.atan2(dy, dx) + math.pi / 2;
    if (angle < 0) {
      angle += 2 * math.pi;
    }

    final segmentSweep =
        (2 * math.pi - (_segmentGap * itemCount)) / itemCount;
    final slot = angle / (segmentSweep + _segmentGap);
    final index = slot.floor();

    if (index < 0 || index >= itemCount) {
      return null;
    }

    final within = angle - index * (segmentSweep + _segmentGap);
    if (within < _segmentGap / 2 ||
        within > _segmentGap / 2 + segmentSweep) {
      return null;
    }

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
    required this.darkColor,
    required this.route,
  });

  final String label;
  final String description;
  final IconData icon;
  final Color lightColor;
  final Color darkColor;
  final String route;
}

class _MenuBackdrop extends StatelessWidget {
  const _MenuBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MenuBackdropPainter());
  }
}

class _MenuBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    paint.color = _gold.withValues(alpha: 0.10);
    final large = Rect.fromCircle(
      center: Offset(size.width * 0.10, size.height * 0.88),
      radius: size.width * 0.70,
    );
    canvas.drawArc(large, -0.8, 1.5, false, paint);

    final second = Rect.fromCircle(
      center: Offset(size.width * 0.94, size.height * 0.18),
      radius: size.width * 0.58,
    );
    canvas.drawArc(second, 1.9, 1.0, false, paint);

    paint
      ..strokeWidth = 0.7
      ..color = Colors.white.withValues(alpha: 0.035);

    for (var i = 0; i < 7; i++) {
      final y = size.height * 0.74 + i * 15;
      canvas.drawLine(Offset(-20, y), Offset(size.width * 0.32, y - 50), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
        final diameter = math.min(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        if (diameter <= 0) {
          return const SizedBox.shrink();
        }

        return SizedBox.square(
          dimension: diameter,
          child: GestureDetector(
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
                  _PieMenuCenter(
                    item: items[selectedIndex],
                  ),
                  for (var i = 0; i < items.length; i++)
                    _PieMenuLabel(
                      index: i,
                      item: items[i],
                      itemCount: items.length,
                      selected: i == selectedIndex,
                      diameter: diameter,
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
  const _PieMenuCenter({required this.item});

  final _MenuItemData item;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.34,
      heightFactor: 0.34,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [_surfaceSoft, _surface],
          ),
          border: Border.all(
            color: item.lightColor.withValues(alpha: 0.72),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: item.lightColor.withValues(alpha: 0.12),
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
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Column(
              key: ValueKey(item.label),
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  color: item.lightColor,
                  size: 29,
                ),
                const SizedBox(height: 4),
                const Text(
                  'MENU',
                  style: TextStyle(
                    color: _text,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'UTAMA',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
    final angle =
        -math.pi / 2 + (2 * math.pi / itemCount) * (index + 0.5);
    final compact = diameter < 310;
    final labelWidth = (diameter * 0.29).clamp(72.0, 104.0);
    final iconSize = compact ? 32.0 : 38.0;
    final fontSize = compact ? 8.2 : 9.3;

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
                  color: selected
                      ? item.lightColor.withValues(alpha: 0.22)
                      : _surface.withValues(alpha: 0.72),
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
                  color: selected ? item.lightColor : _text.withValues(alpha: 0.90),
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
                  fontSize: item.label == 'Statistik Provos TNI-AD'
                      ? math.max(fontSize - 0.5, 7.6)
                      : fontSize,
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
  const _PieMenuPainter({
    required this.itemCount,
    required this.selectedIndex,
  });

  final int itemCount;
  final int selectedIndex;

  static const _segmentGap = 0.055;
  static const _lightPalette = <Color>[
    Color(0xFFF09A4A),
    Color(0xFFE15B5B),
    Color(0xFF5D8FE0),
    Color(0xFFE3BE4F),
    Color(0xFF49A86B),
  ];
  static const _darkPalette = <Color>[
    Color(0xFF5A2B0D),
    Color(0xFF461518),
    Color(0xFF192A55),
    Color(0xFF59410D),
    Color(0xFF123827),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = size.shortestSide * 0.43;
    final hubRadius = size.shortestSide * 0.17;
    final sweep =
        (2 * math.pi - _segmentGap * itemCount) / itemCount;

    for (var i = 0; i < itemCount; i++) {
      final start =
          -math.pi / 2 +
          i * (sweep + _segmentGap) +
          _segmentGap / 2;
      final isSelected = i == selectedIndex;
      final radius = outerRadius + (isSelected ? 4.0 : 0.0);

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + math.cos(start) * radius,
          center.dy + math.sin(start) * radius,
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          start,
          sweep,
          false,
        )
        ..close();

      final light = _lightPalette[i];
      final dark = _darkPalette[i];
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            light.withValues(alpha: isSelected ? 1.0 : 0.88),
            light.withValues(alpha: isSelected ? 0.82 : 0.66),
            dark,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(
          Rect.fromCircle(center: center, radius: radius),
        );

      canvas.drawPath(path, paint);

      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 1.8 : 1
        ..color = light.withValues(alpha: isSelected ? 0.96 : 0.34);
      canvas.drawPath(path, stroke);
    }

    final hubGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.045),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: hubRadius),
      );
    canvas.drawCircle(center, hubRadius, hubGlow);
  }

  static int? indexAt(
    Offset position,
    Size size, {
    required int itemCount,
  }) {
    final center = size.center(Offset.zero);
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final outerRadius = size.shortestSide * 0.47;
    final innerRadius = size.shortestSide * 0.19;

    if (distance > outerRadius || distance < innerRadius) {
      return null;
    }

    var angle = math.atan2(dy, dx) + math.pi / 2;
    if (angle < 0) {
      angle += 2 * math.pi;
    }

    final sweep =
        (2 * math.pi - _segmentGap * itemCount) / itemCount;
    final slot = angle / (sweep + _segmentGap);
    final index = slot.floor();

    if (index < 0 || index >= itemCount) {
      return null;
    }

    final within = angle - index * (sweep + _segmentGap);
    if (within < _segmentGap / 2 ||
        within > _segmentGap / 2 + sweep) {
      return null;
    }

    return index;
  }

  @override
  bool shouldRepaint(covariant _PieMenuPainter oldDelegate) {
    return oldDelegate.itemCount != itemCount ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}

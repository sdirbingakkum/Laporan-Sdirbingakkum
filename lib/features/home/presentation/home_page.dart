import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  static const _items = <_MenuItemData>[
    _MenuItemData(
      label: 'STATISTIK PELANGGARAN',
      description: 'Ringkasan dan tren pelanggaran hukum.',
      icon: Icons.gavel_rounded,
    ),
    _MenuItemData(
      label: 'STATISTIK SIM TNI',
      description: 'Ringkasan penerbitan dan data SIM TNI.',
      icon: Icons.badge_outlined,
    ),
    _MenuItemData(
      label: 'STATISTIK PROVOS TNI-AD',
      description: 'Ringkasan data dan kinerja Provos TNI-AD.',
      icon: Icons.military_tech_rounded,
    ),
    _MenuItemData(
      label: 'STATISTIK LAKA-LALIN',
      description: 'Ringkasan dan tren kecelakaan lalu lintas.',
      icon: Icons.directions_car_filled_outlined,
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

  void _selectMenu(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 520,
                      height: 760,
                      child: _MenuContent(
                        items: _items,
                        selectedIndex: _selectedIndex,
                        onSelected: _selectMenu,
                        onSignOut: _confirmSignOut,
                      ),
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

class _MenuContent extends StatelessWidget {
  const _MenuContent({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.onSignOut,
  });

  final List<_MenuItemData> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final selected = items[selectedIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        children: [
          _MenuHeader(onSignOut: onSignOut),
          const SizedBox(height: 22),
          const Text(
            'MENU UTAMA',
            style: TextStyle(
              color: _goldLight,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Pilih layanan yang akan dibuka',
            style: TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: _PieMenu(
                items: items,
                selectedIndex: selectedIndex,
                onSelected: onSelected,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey(selected.label),
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              decoration: BoxDecoration(
                color: _surface.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _gold.withValues(alpha: 0.20)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _gold.withValues(alpha: 0.13),
                      border: Border.all(
                        color: _gold.withValues(alpha: 0.34),
                      ),
                    ),
                    child: Icon(selected.icon, color: _goldLight, size: 20),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _text,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selected.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 10.5,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: _goldLight,
                    size: 18,
                  ),
                ],
              ),
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
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _gold.withValues(alpha: 0.58),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.18),
                blurRadius: 26,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/pomad_prima.webp',
              fit: BoxFit.cover,
              semanticLabel: 'Logo POMAD PRIMA',
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
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.apps_rounded,
                      color: _goldLight,
                      size: 28,
                    ),
                    SizedBox(height: 6),
                    Text(
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
                      ? _gold.withValues(alpha: 0.24)
                      : _surface.withValues(alpha: 0.78),
                  border: Border.all(
                    color: selected
                        ? _goldLight.withValues(alpha: 0.82)
                        : _gold.withValues(alpha: 0.26),
                    width: selected ? 1.4 : 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: _gold.withValues(alpha: 0.18),
                            blurRadius: 18,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  item.icon,
                  color: selected ? _goldLight : _muted,
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
                  color: selected ? _goldLight : _text,
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

      final colors = switch (i) {
        0 => const [_goldLight, _goldDark],
        1 => const [Color(0xFFC49731), Color(0xFF765218)],
        2 => const [Color(0xFFE0B94F), Color(0xFF9A6D22)],
        3 => const [Color(0xFFCFA53B), Color(0xFF815C20)],
        _ => const [Color(0xFFE8C765), Color(0xFF8A6320)],
      };

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            selected ? colors.first : colors.first.withValues(alpha: 0.82),
            selected ? colors.last : colors.last.withValues(alpha: 0.90),
          ],
        ).createShader(
          Rect.fromCircle(center: center, radius: radius),
        );

      canvas.drawPath(path, paint);

      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 1.7 : 1
        ..color = selected
            ? _goldLight.withValues(alpha: 0.95)
            : _gold.withValues(alpha: 0.34);

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
  });

  final String label;
  final String description;
  final IconData icon;
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

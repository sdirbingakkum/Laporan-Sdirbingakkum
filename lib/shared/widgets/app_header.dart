import 'package:flutter/material.dart';

import 'app_background.dart';

const _gold = Color(0xFFD7A93C);
const _goldLight = Color(0xFFF1D37A);
const _text = Color(0xFFF8F5EC);
const _muted = Color(0xFFB7C2BC);
const _surface = Color(0xFF09231A);

/// Fixed Material 3 application header for post-login surfaces.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    required this.title,
    required this.onSignOut,
    this.subtitle = 'PUSPOMAD',
    this.onBack,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback onSignOut;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 360;

    return AppBar(
      backgroundColor: Colors.transparent,
      flexibleSpace: DecoratedBox(
        decoration: const BoxDecoration(gradient: appBackgroundGradient),
      ),
      foregroundColor: _text,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 68,
      shape: Border(
        bottom: BorderSide(color: _gold.withValues(alpha: 0.24), width: 1),
      ),
      leadingWidth: onBack == null ? (compact ? 52 : 60) : 52,
      leading: onBack == null
          ? Padding(
              padding: EdgeInsets.only(left: compact ? 10 : 14),
              child: Center(
                child: Image.asset(
                  'assets/images/pomad_puspomad.webp',
                  width: compact ? 42 : 48,
                  height: compact ? 42 : 48,
                  fit: BoxFit.contain,
                  semanticLabel: 'Logo PUSPOMAD',
                ),
              ),
            )
          : IconButton(
              tooltip: 'KEMBALI',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
      titleSpacing: 0,
      title: Row(
        children: [
          if (onBack != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Image.asset(
                'assets/images/pomad_puspomad.webp',
                width: compact ? 38 : 44,
                height: compact ? 38 : 44,
                fit: BoxFit.contain,
                semanticLabel: 'Logo PUSPOMAD',
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _goldLight,
                    fontSize: compact ? 17 : 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                    shadows: [
                      Shadow(
                        color: _gold.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _muted,
                    fontSize: compact ? 8.5 : 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          tooltip: 'MENU AKUN',
          icon: const Icon(Icons.more_vert_rounded),
          color: _surface,
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _gold.withValues(alpha: 0.28)),
          ),
          onSelected: (value) {
            if (value == 'signout') {
              onSignOut();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(
              value: 'signout',
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(Icons.logout_rounded, color: _goldLight),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'KELUAR',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _text,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

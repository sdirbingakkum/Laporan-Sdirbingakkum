import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';
import '../../../shared/widgets/app_background.dart';

const _bg = Color(0xFF03150F);
const _gold = Color(0xFFD7A93C);
const _goldLight = Color(0xFFF1D37A);
const _goldDark = Color(0xFF8D651E);
const _text = Color(0xFFF8F5EC);
const _muted = Color(0xFFB7C2BC);

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
          );
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _friendlyAuthMessage(error),
            style: const TextStyle(
              color: Color(0xFFF8F5EC),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF071F17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.4),
            side: BorderSide(color: _gold.withValues(alpha: 0.30)),
          ),
          elevation: 10,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'TERJADI KESALAHAN. SILAKAN COBA LAGI.',
            style: TextStyle(
              color: Color(0xFFF8F5EC),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF071F17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.4),
            side: BorderSide(color: _gold.withValues(alpha: 0.30)),
          ),
          elevation: 10,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _friendlyAuthMessage(AuthException error) {
    final code = error.code?.toLowerCase() ?? '';
    final message = error.message.toLowerCase();

    if (code == 'invalid_credentials' ||
        message.contains('invalid login credentials')) {
      return 'USERNAME ATAU PASSWORD SALAH.';
    }

    if (code == 'email_not_confirmed' ||
        message.contains('email not confirmed')) {
      return 'AKUN ANDA BELUM DIKONFIRMASI.';
    }

    if (code == 'over_request_rate_limit' || message.contains('rate limit')) {
      return 'TERLALU BANYAK PERCOBAAN. COBA LAGI BEBERAPA SAAT.';
    }

    return error.message.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: AppBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth >= 520
                  ? 32.0
                  : 16.0;
              final contentWidth =
                  (constraints.maxWidth - horizontalPadding * 2).clamp(
                    0.0,
                    460.0,
                  );

              return Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: contentWidth,
                    child: const _SignInContent(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SignInContent extends ConsumerStatefulWidget {
  const _SignInContent();

  @override
  ConsumerState<_SignInContent> createState() => _SignInContentState();
}

class _SignInContentState extends ConsumerState<_SignInContent> {
  @override
  Widget build(BuildContext context) {
    final parent = context.findAncestorStateOfType<_SignInPageState>()!;
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: parent._formKey,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          final logoScale = 0.88 + value * 0.12;
          final titleProgress = ((value - 0.15) / 0.85).clamp(0.0, 1.0);
          final cardProgress = ((value - 0.30) / 0.70).clamp(0.0, 1.0);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Transform.scale(
                scale: logoScale,
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _goldLight.withValues(alpha: 0.75),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withValues(alpha: 0.30),
                          blurRadius: 36,
                          spreadRadius: 2,
                          offset: const Offset(0, 14),
                        ),
                        const BoxShadow(
                          color: Colors.black87,
                          blurRadius: 26,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/pomad_prima.webp',
                        fit: BoxFit.cover,
                        semanticLabel: 'LOGO POMAD PRIMA',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Transform.translate(
                offset: Offset(
                  0,
                  (1 - Curves.easeOutCubic.transform(titleProgress)) * 10,
                ),
                child: Opacity(
                  opacity: titleProgress,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SDIRBINGAKKUM',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: textTheme.headlineMedium?.copyWith(
                          color: _goldLight,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: _gold.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PUSPOMAD',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: textTheme.titleMedium?.copyWith(
                          color: _text,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Transform.translate(
                offset: Offset(
                  0,
                  (1 - Curves.easeOutCubic.transform(cardProgress)) * 14,
                ),
                child: Opacity(
                  opacity: cardProgress,
                  child: _SignInCard(parent: parent),
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

class _SignInCard extends StatelessWidget {
  const _SignInCard({required this.parent});

  final _SignInPageState parent;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.4),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x9C183B2D), Color(0x72102C20), Color(0x7007130E)],
              stops: [0.0, 0.46, 1.0],
            ),
            borderRadius: BorderRadius.circular(6.4),
            border: Border.all(color: _gold.withValues(alpha: 0.30)),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.07),
                blurRadius: 30,
                spreadRadius: 1,
              ),
              const BoxShadow(
                color: Colors.black54,
                blurRadius: 26,
                offset: Offset(0, 14),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),
              _DarkField(
                controller: parent._usernameController,
                label: 'USERNAME',
                hint: 'MASUKKAN USERNAME ANDA',
                icon: Icons.person_outline_rounded,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                enabled: !parent._isLoading,
                dense: false,
                validator: (value) {
                  final username = value?.trim() ?? '';
                  if (username.isEmpty) {
                    return 'USERNAME WAJIB DIISI.';
                  }

                  if (username.contains('@')) {
                    return 'MASUKKAN USERNAME TANPA DOMAIN.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 10),
              _DarkField(
                controller: parent._passwordController,
                label: 'PASSWORD',
                hint: 'MASUKKAN PASSWORD ANDA',
                icon: Icons.lock_outline_rounded,
                obscureText: parent._obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                enabled: !parent._isLoading,
                dense: false,
                onFieldSubmitted: (_) => parent._signIn(),
                suffix: IconButton(
                  tooltip: parent._obscurePassword
                      ? 'TAMPILKAN PASSWORD'
                      : 'SEMBUNYIKAN PASSWORD',
                  color: _muted,
                  onPressed: parent._isLoading
                      ? null
                      : parent._togglePasswordVisibility,
                  icon: Icon(
                    parent._obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').isEmpty) {
                    return 'PASSWORD WAJIB DIISI.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 17),
              SizedBox(
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.4),
                    gradient: parent._isLoading
                        ? LinearGradient(
                            colors: [
                              _goldDark.withValues(alpha: 0.58),
                              _goldDark.withValues(alpha: 0.45),
                            ],
                          )
                        : const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFFF1BD),
                              Color(0xFFF3CE5E),
                              Color(0xFFD6A02B),
                              Color(0xFFA67417),
                            ],
                            stops: [0.0, 0.32, 0.74, 1.0],
                          ),
                    border: Border.all(
                      color: const Color(0xFFFFFAEB).withValues(alpha: 0.55),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _gold.withValues(alpha: 0.32),
                        blurRadius: 22,
                        offset: const Offset(0, 6),
                      ),
                      const BoxShadow(
                        color: Colors.black54,
                        blurRadius: 14,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: FilledButton(
                    onPressed: parent._isLoading ? null : parent._signIn,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: const Color(0xFF1B1202),
                      disabledBackgroundColor: Colors.transparent,
                      disabledForegroundColor: Colors.black54,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.4),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: parent._isLoading
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              width: 21,
                              height: 21,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Color(0xFF1B1202),
                              ),
                            )
                          : const Row(
                              key: ValueKey('label'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'MASUK',
                                  style: TextStyle(
                                    color: Color(0xFF1B1202),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.8,
                                    shadows: [
                                      Shadow(
                                        color: Color(0x66FFF7DB),
                                        offset: Offset(0, 1),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20,
                                  color: Color(0xFF1B1202),
                                ),
                              ],
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

class _DarkField extends StatelessWidget {
  const _DarkField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.enabled,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.onFieldSubmitted,
    this.suffix,
    this.validator,
    this.dense = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(
        color: _text,
        fontWeight: FontWeight.w600,
        fontSize: dense ? 13 : 14,
      ),
      cursorColor: _goldLight,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _muted, size: dense ? 19 : 21),
        suffixIcon: suffix,
        labelStyle: TextStyle(color: _muted, fontSize: dense ? 12 : 13),
        floatingLabelStyle: const TextStyle(
          color: _goldLight,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: TextStyle(
          color: const Color(0xFF75847B),
          fontSize: dense ? 12 : 13,
        ),
        filled: true,
        fillColor: const Color(0xFF071F17),
        isDense: dense,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: dense ? 12 : 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.4),
          borderSide: BorderSide(color: _gold.withValues(alpha: 0.24)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.4),
          borderSide: const BorderSide(color: _goldLight, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.4),
          borderSide: const BorderSide(color: Color(0xFFCC6D61)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.4),
          borderSide: const BorderSide(color: Color(0xFFE28C80), width: 1.3),
        ),
      ),
      validator: validator,
    );
  }
}

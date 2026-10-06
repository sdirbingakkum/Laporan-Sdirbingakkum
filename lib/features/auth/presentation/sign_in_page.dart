import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  static const _bg = Color(0xFF03150F);
  static const _surface = Color(0xFF09231A);
  static const _surfaceSoft = Color(0xFF0D2C20);
  static const _gold = Color(0xFFD7A93C);
  static const _goldLight = Color(0xFFF1D37A);
  static const _goldDark = Color(0xFF8D651E);
  static const _text = Color(0xFFF8F5EC);
  static const _muted = Color(0xFFB7C2BC);
  static const _line = Color(0xFF6E7C73);
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
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
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyAuthMessage(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan. Silakan coba lagi.'),
          behavior: SnackBarBehavior.floating,
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
      return 'Email atau password salah.';
    }

    if (code == 'email_not_confirmed' ||
        message.contains('email not confirmed')) {
      return 'Email Anda belum dikonfirmasi.';
    }

    if (code == 'over_request_rate_limit' || message.contains('rate limit')) {
      return 'Terlalu banyak percobaan. Coba lagi beberapa saat.';
    }

    return error.message;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 380;
    final logoSize = compact ? 142.0 : 168.0;
    final horizontal = compact ? 18.0 : 24.0;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          const Positioned.fill(child: _SignInBackdrop()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  compact ? 18 : 24,
                  horizontal,
                  30,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'pomad-prima-logo',
                        child: Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _gold.withValues(alpha: 0.24),
                                blurRadius: 40,
                                spreadRadius: 2,
                                offset: const Offset(0, 18),
                              ),
                            ],
                            border: Border.all(
                              color: _gold.withValues(alpha: 0.62),
                              width: 1.2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/pomad_prima.webp',
                              fit: BoxFit.cover,
                              semanticLabel: 'Logo POMAD PRIMA',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 16 : 20),
                      Text(
                        'SDIRBINGAKKUM',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          color: _goldLight,
                          fontFamily: 'serif',
                          fontSize: compact ? 27 : 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: compact ? 1.5 : 2.0,
                          shadows: const [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 14,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'P U S P O M A D',
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          color: _text,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sistem Laporan Bidang Gakkum',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: _text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Profesional • Responsif • Integritas • Modern • Adaptif',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: _muted,
                          letterSpacing: 0.15,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Container(
                        decoration: BoxDecoration(
                          color: _surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: _gold.withValues(alpha: 0.28),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 30,
                              offset: Offset(0, 16),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(compact ? 18 : 22),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Akses Sistem',
                                style: textTheme.titleLarge?.copyWith(
                                  color: _text,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Masuk menggunakan akun yang terdaftar.',
                                style: textTheme.bodySmall?.copyWith(
                                  color: _muted,
                                ),
                              ),
                              const SizedBox(height: 18),
                              _DarkField(
                                controller: _emailController,
                                label: 'Email',
                                hint: 'Masukkan email Anda',
                                icon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.username,
                                  AutofillHints.email,
                                ],
                                enabled: !_isLoading,
                                validator: (value) {
                                  final email = value?.trim() ?? '';
                                  if (email.isEmpty) {
                                    return 'Email wajib diisi.';
                                  }

                                  final emailPattern = RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  );
                                  if (!emailPattern.hasMatch(email)) {
                                    return 'Masukkan alamat email yang valid.';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _DarkField(
                                controller: _passwordController,
                                label: 'Password',
                                hint: 'Masukkan password Anda',
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                enabled: !_isLoading,
                                onFieldSubmitted: (_) => _signIn(),
                                suffix: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Tampilkan password'
                                      : 'Sembunyikan password',
                                  color: _muted,
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                                validator: (value) {
                                  if ((value ?? '').isEmpty) {
                                    return 'Password wajib diisi.';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                height: 54,
                                child: FilledButton(
                                  onPressed: _isLoading ? null : _signIn,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _goldLight,
                                    foregroundColor: const Color(0xFF10140F),
                                    disabledBackgroundColor:
                                        _goldDark.withValues(alpha: 0.58),
                                    disabledForegroundColor: Colors.black54,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 180),
                                    child: _isLoading
                                        ? const SizedBox(
                                            key: ValueKey('loading'),
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Row(
                                            key: const ValueKey('label'),
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Masuk',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 19),
                              const _OrDivider(),
                              const SizedBox(height: 17),
                              Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _gold.withValues(alpha: 0.48),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Akun terdaftar di lingkungan PUSPOMAD',
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: _muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        '© 2026 PUSPOMAD',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: _muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'SDIRBINGAKKUM — Laporan Gakkum',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(color: _muted),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'v1.0.0',
                        textAlign: TextAlign.center,
                        style: textTheme.labelSmall?.copyWith(
                          color: _gold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
      style: const TextStyle(
        color: _text,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: _goldLight,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _muted),
        suffixIcon: suffix,
        labelStyle: const TextStyle(color: _muted),
        floatingLabelStyle: const TextStyle(
          color: _goldLight,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: const TextStyle(color: Color(0xFF75847B)),
        filled: true,
        fillColor: _surfaceSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _goldLight, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCC6D61)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE28C80),
            width: 1.4,
          ),
        ),
      ),
      validator: validator,
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: _line)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'atau',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _muted,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const Expanded(child: Divider(color: _line)),
      ],
    );
  }
}

class _SignInBackdrop extends StatelessWidget {
  const _SignInBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BackdropPainter());
  }
}

class _BackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    paint.color = _gold.withValues(alpha: 0.10);
    final large = Rect.fromCircle(
      center: Offset(size.width * 0.12, size.height * 0.88),
      radius: size.width * 0.70,
    );
    canvas.drawArc(large, -0.8, 1.5, false, paint);

    final second = Rect.fromCircle(
      center: Offset(size.width * 0.94, size.height * 0.20),
      radius: size.width * 0.58,
    );
    canvas.drawArc(second, 1.9, 1.0, false, paint);

    paint
      ..strokeWidth = 0.7
      ..color = Colors.white.withValues(alpha: 0.035);

    for (var i = 0; i < 7; i++) {
      final y = size.height * 0.74 + i * 15;
      canvas.drawLine(
        Offset(-20, y),
        Offset(size.width * 0.32, y - 50),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

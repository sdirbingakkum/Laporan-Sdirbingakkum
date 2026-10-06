import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';

const _bg = Color(0xFF03150F);
const _surface = Color(0xFF09231A);
const _surfaceSoft = Color(0xFF0D2C20);
const _gold = Color(0xFFD7A93C);
const _goldLight = Color(0xFFF1D37A);
const _goldDark = Color(0xFF8D651E);
const _text = Color(0xFFF8F5EC);
const _muted = Color(0xFFB7C2BC);
const _line = Color(0xFF6E7C73);

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
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
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          const Positioned.fill(child: _SignInBackdrop()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                final compact = height < 620;
                final veryCompact = height < 520;
                final horizontal = width < 380 ? 18.0 : 24.0;
                final logoMax = compact ? 112.0 : 154.0;
                final logoSize = logoMax.clamp(92.0, 154.0);
                final topGap = veryCompact ? 8.0 : compact ? 12.0 : 20.0;
                final brandingGap = veryCompact ? 7.0 : compact ? 10.0 : 14.0;
                final formGap = veryCompact ? 12.0 : compact ? 16.0 : 24.0;
                final cardPadding = veryCompact ? 14.0 : compact ? 16.0 : 20.0;
                final fieldGap = veryCompact ? 9.0 : 12.0;
                final buttonHeight = compact ? 48.0 : 52.0;

                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontal),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: topGap),
                            Container(
                              width: logoSize,
                              height: logoSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _gold.withValues(alpha: 0.22),
                                    blurRadius: 32,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                                border: Border.all(
                                  color: _gold.withValues(alpha: 0.58),
                                  width: 1.1,
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
                            SizedBox(height: brandingGap),
                            Text(
                              'SDIRBINGAKKUM',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: _goldLight,
                                fontFamily: 'serif',
                                fontSize: veryCompact ? 23 : compact ? 26 : 31,
                                fontWeight: FontWeight.w900,
                                letterSpacing: veryCompact ? 1.0 : 1.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'P U S P O M A D',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: _text,
                                fontSize: veryCompact ? 13 : 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: veryCompact ? 2.8 : 3.8,
                              ),
                            ),
                            SizedBox(height: veryCompact ? 5 : compact ? 7 : 10),
                            Text(
                              'Sistem Laporan Bidang Gakkum',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _text,
                                fontSize: veryCompact ? 13 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: veryCompact ? 2 : 4),
                            Text(
                              'Profesional • Responsif • Integritas • Modern • Adaptif',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _muted,
                                fontSize: veryCompact ? 9 : compact ? 10 : 11,
                              ),
                            ),
                            SizedBox(height: formGap),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: _surface.withValues(alpha: 0.94),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: _gold.withValues(alpha: 0.25),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 26,
                                    offset: Offset(0, 14),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(cardPadding),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Akses Sistem',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: _text,
                                        fontSize: veryCompact ? 18 : 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Masuk menggunakan akun yang terdaftar.',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: _muted,
                                        fontSize: veryCompact ? 10 : 11,
                                      ),
                                    ),
                                    SizedBox(height: veryCompact ? 12 : 15),
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
                                      dense: compact,
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
                                    SizedBox(height: fieldGap),
                                    _DarkField(
                                      controller: _passwordController,
                                      label: 'Password',
                                      hint: 'Masukkan password Anda',
                                      icon: Icons.lock_outline_rounded,
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const [AutofillHints.password],
                                      enabled: !_isLoading,
                                      dense: compact,
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
                                          size: compact ? 19 : 22,
                                        ),
                                      ),
                                      validator: (value) {
                                        if ((value ?? '').isEmpty) {
                                          return 'Password wajib diisi.';
                                        }

                                        return null;
                                      },
                                    ),
                                    SizedBox(height: veryCompact ? 14 : 18),
                                    SizedBox(
                                      height: buttonHeight,
                                      child: FilledButton(
                                        onPressed: _isLoading ? null : _signIn,
                                        style: FilledButton.styleFrom(
                                          backgroundColor: _goldLight,
                                          foregroundColor:
                                              const Color(0xFF10140F),
                                          disabledBackgroundColor: _goldDark
                                              .withValues(alpha: 0.58),
                                          disabledForegroundColor:
                                              Colors.black54,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 180),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  key: ValueKey('loading'),
                                                  width: 21,
                                                  height: 21,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.4,
                                                  ),
                                                )
                                              : const Row(
                                                  key: ValueKey('label'),
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Masuk',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_rounded,
                                                      size: 20,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
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
        fillColor: _surfaceSoft,
        isDense: dense,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: dense ? 12 : 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _goldLight, width: 1.3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFCC6D61)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Color(0xFFE28C80),
            width: 1.3,
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
      canvas.drawLine(Offset(-20, y), Offset(size.width * 0.32, y - 50), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

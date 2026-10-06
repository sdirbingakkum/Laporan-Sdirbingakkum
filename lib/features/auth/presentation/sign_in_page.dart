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
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

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
          content: Text('TERJADI KESALAHAN. SILAKAN COBA LAGI.'),
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
      return 'EMAIL ATAU PASSWORD SALAH.';
    }

    if (code == 'email_not_confirmed' ||
        message.contains('email not confirmed')) {
      return 'EMAIL ANDA BELUM DIKONFIRMASI.';
    }

    if (code == 'over_request_rate_limit' || message.contains('rate limit')) {
      return 'TERLALU BANYAK PERCOBAAN. COBA LAGI BEBERAPA SAAT.';
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
        ],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _gold.withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.22),
                  blurRadius: 34,
                  spreadRadius: 1,
                  offset: const Offset(0, 14),
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
          const SizedBox(height: 14),
          Text(
            'SDIRBINGAKKUM',
            textAlign: TextAlign.center,
            maxLines: 1,
            style: textTheme.headlineMedium?.copyWith(
              color: _goldLight,
              fontFamily: 'serif',
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'PUSPOMAD',
            textAlign: TextAlign.center,
            maxLines: 1,
            style: textTheme.titleMedium?.copyWith(
              color: _text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'SISTEM LAPORAN BIDANG GAKKUM',
            textAlign: TextAlign.center,
            maxLines: 1,
            style: textTheme.bodyMedium?.copyWith(
              color: _text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _SignInCard(parent: parent),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SignInCard extends StatelessWidget {
  const _SignInCard({required this.parent});

  final _SignInPageState parent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withValues(alpha: 0.25)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          _DarkField(
            controller: parent._emailController,
            label: 'EMAIL',
            hint: 'MASUKKAN EMAIL ANDA',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            enabled: !parent._isLoading,
            dense: false,
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) {
                return 'EMAIL WAJIB DIISI.';
              }

              final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!emailPattern.hasMatch(email)) {
                return 'MASUKKAN ALAMAT EMAIL YANG VALID.';
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
            child: FilledButton(
              onPressed: parent._isLoading ? null : parent._signIn,
              style: FilledButton.styleFrom(
                backgroundColor: _goldLight,
                foregroundColor: const Color(0xFF10140F),
                disabledBackgroundColor: _goldDark.withValues(alpha: 0.58),
                disabledForegroundColor: Colors.black54,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: parent._isLoading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : const Row(
                        key: ValueKey('label'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'MASUK',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
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
          borderSide: const BorderSide(color: Color(0xFFE28C80), width: 1.3),
        ),
      ),
      validator: validator,
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

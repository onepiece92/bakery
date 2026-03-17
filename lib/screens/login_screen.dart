import 'package:bakery_flutter/extensions/theme_extension.dart';
import 'package:bakery_flutter/providers/customerlogin_provider.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CustomerLoginProvider>();

    await provider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;
    if (provider.isLoggedIn) context.go('/profile');
  }

  @override
  Widget build(BuildContext context) {
    // ── All theme access through ThemeX ───────────────────────────────────────
    final provider = context.watch<CustomerLoginProvider>();
    final isLoading = provider.isLoading;
    final errorMessage = provider.errorMessage;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        final maxWidth = isWide ? 500.0 : double.infinity;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300),
                  right: BorderSide(color: Colors.grey.shade300),
                  bottom: BorderSide.none,
                ),
              ),
              child: Scaffold(
                appBar: AppBar(automaticallyImplyLeading: true),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 56),
                        Image.asset('assets/images/lemon_drizzle_cake.png',
                            height: 150),
                        const SizedBox(height: 16),

                        // ✅ was: textTheme.headlineLarge
                        Text("Login to your account",
                            style: context.text.headlineLarge),
                        const SizedBox(height: 6),

                        // ✅ was: textTheme.bodyMedium
                        Text("Welcome back!", style: context.text.bodyMedium),
                        const SizedBox(height: 40),

                        // ── Error Banner ─────────────────────────────────────
                        if (errorMessage != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              // ✅ was: Colors.red.withOpacity(0.1) / Colors.red.withOpacity(0.4)
                              color: context.colors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: context.colors.error.withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                // ✅ was: Colors.redAccent (hardcoded)
                                Icon(Icons.error_outline,
                                    color: context.colors.error, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    // ✅ was: copyWith(color: Colors.redAccent)
                                    style: context.text.bodySmall?.copyWith(
                                      color: context.colors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ── Form ─────────────────────────────────────────────
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                    hintText: "Enter your email"),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Please enter your email';
                                  if (!value.contains('@'))
                                    return 'Please enter a valid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration:
                                    const InputDecoration(hintText: "Password"),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Please enter your password';
                                  if (value.length < 6)
                                    return 'Password must be at least 6 characters';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Forgot Your Password?",
                            // ✅ was: textTheme.labelMedium + colorScheme.onSecondary
                            style: context.text.labelMedium?.copyWith(
                              color: context.colors.onSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Login Button ──────────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _onLogin,
                            child: isLoading
                                ? CircularProgressIndicator(
                                    strokeWidth: 2,
                                    // ✅ was: colorScheme.surface
                                    color: context.colors.surface,
                                  )
                                : Text(
                                    "Login",
                                    // ✅ was: textTheme.labelLarge + colorScheme.surface
                                    style: context.text.labelLarge?.copyWith(
                                      color: context.colors.surface,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Create Account ────────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: isLoading
                                ? null
                                : () => context.push('/signup'),
                            // ✅ was: textTheme.labelLarge
                            child: Text("Create New Account",
                                style: context.text.labelLarge),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

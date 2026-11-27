import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/l10n/error_localizer.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/features/auth/application/auth_controller.dart';
import 'package:frontend/shared/widgets/grouped_auth_card.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/space_background.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context);
    final emailErr = FormValidators.email(_emailController.text, l10n);
    final passErr = FormValidators.password(_passwordController.text, l10n);
    final validationErr = emailErr ?? passErr;
    if (validationErr != null) {
      setState(() => _errorMessage = validationErr);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;
      context.go(AppRoutes.children);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = localizeApiError(
          l10n,
          e,
          preferServerMessage: true,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ckColors;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.welcome);
            }
          },
        ),
      ),
      body: SpaceBackground(
        showBottomClouds: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              children: [
                const AuthCosmicHeader(),
                const SizedBox(height: 8),
                Text(
                  l10n.loginTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.mutedText, fontSize: 15),
                ),
                const SizedBox(height: 24),
                GroupedAuthCard(
                  children: [
                    GroupedAuthField(
                      controller: _emailController,
                      hintText: l10n.emailAddress,
                      icon: Icons.mail_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !_isSubmitting,
                    ),
                    GroupedAuthField(
                      controller: _passwordController,
                      hintText: l10n.password,
                      icon: Icons.lock_rounded,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      enabled: !_isSubmitting,
                      onFieldSubmitted: (_) => _submit(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colors.error.withValues(alpha: 0.55),
                      ),
                    ),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.error, fontSize: 14),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: l10n.login,
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: colors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        l10n.orDivider,
                        style: TextStyle(
                          color: colors.mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: colors.border)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.noAccountYet,
                      style: TextStyle(color: colors.mutedText),
                    ),
                    TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => context.go(AppRoutes.register),
                      child: Text(
                        l10n.createAccount,
                        style: const TextStyle(
                          color: Color(0xFF915BFF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

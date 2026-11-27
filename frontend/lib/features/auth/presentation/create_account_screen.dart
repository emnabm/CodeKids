import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/features/auth/application/auth_controller.dart';
import 'package:frontend/shared/widgets/grouped_auth_card.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/space_background.dart';
import 'package:go_router/go_router.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _validationError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onContinueToPin() {
    final l10n = AppLocalizations.of(context);
    final emailErr = FormValidators.email(_emailController.text, l10n);
    final passErr = FormValidators.password(_passwordController.text, l10n);
    final confirmErr = FormValidators.confirmPassword(
      _confirmController.text,
      _passwordController.text,
      l10n,
    );

    final firstError = emailErr ?? passErr ?? confirmErr;
    if (firstError != null) {
      setState(() => _validationError = firstError);
      return;
    }

    setState(() => _validationError = null);
    ref.read(authControllerProvider.notifier).setPendingRegistration(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    context.push(AppRoutes.choosePin);
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
          onPressed: () => context.pop(),
        ),
      ),
      body: SpaceBackground(
        showBottomClouds: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AuthCosmicHeader(),
                const SizedBox(height: 8),
                Text(
                  l10n.createAccount,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        l10n.createAccountSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.mutedText, fontSize: 15),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Image.asset('assets/images/fusee.png', width: 20),
                  ],
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
                    ),
                    GroupedAuthField(
                      controller: _passwordController,
                      hintText: l10n.password,
                      icon: Icons.lock_rounded,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
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
                    GroupedAuthField(
                      controller: _confirmController,
                      hintText: l10n.confirmPassword,
                      icon: Icons.lock_rounded,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _onContinueToPin(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirm = !_obscureConfirm,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_validationError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _validationError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                PrimaryButton(
                  label: l10n.createAccount,
                  onPressed: _onContinueToPin,
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
                      l10n.alreadyHaveAccount,
                      style: TextStyle(color: colors.mutedText),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: Text(
                        l10n.login,
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

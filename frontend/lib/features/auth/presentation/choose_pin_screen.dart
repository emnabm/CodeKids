import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/l10n/error_localizer.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/l10n/locale_provider.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/auth/application/auth_controller.dart';
import 'package:frontend/shared/widgets/pin_keypad.dart';
import 'package:frontend/shared/widgets/space_background.dart';
import 'package:go_router/go_router.dart';

class ChoosePinScreen extends ConsumerStatefulWidget {
  const ChoosePinScreen({super.key});

  @override
  ConsumerState<ChoosePinScreen> createState() => _ChoosePinScreenState();
}

class _ChoosePinScreenState extends ConsumerState<ChoosePinScreen> {
  String _firstPin = '';
  String _confirmPin = '';
  bool _isConfirmStep = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  void _onDigitPressed(String digit) {
    if (_isSubmitting) return;
    setState(() {
      _errorMessage = null;
      if (!_isConfirmStep) {
        if (_firstPin.length < AppConfig.pinLength) {
          _firstPin += digit;
          if (_firstPin.length == AppConfig.pinLength) {
            _isConfirmStep = true;
          }
        }
      } else {
        if (_confirmPin.length < AppConfig.pinLength) {
          _confirmPin += digit;
          if (_confirmPin.length == AppConfig.pinLength) {
            _submitIfMatching();
          }
        }
      }
    });
  }

  void _onDeletePressed() {
    if (_isSubmitting) return;
    setState(() {
      _errorMessage = null;
      if (_isConfirmStep) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          _isConfirmStep = false;
          if (_firstPin.isNotEmpty) {
            _firstPin = _firstPin.substring(0, _firstPin.length - 1);
          }
        }
      } else if (_firstPin.isNotEmpty) {
        _firstPin = _firstPin.substring(0, _firstPin.length - 1);
      }
    });
  }

  Future<void> _submitIfMatching() async {
    final l10n = AppLocalizations.of(context);
    if (_firstPin != _confirmPin) {
      setState(() {
        _confirmPin = '';
        _errorMessage = l10n.pinMismatchError;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final language = ref.read(localeProvider).languageCode;
      await ref.read(authControllerProvider.notifier).completeRegistration(
            pin: _firstPin,
            language: language,
          );
      if (!mounted) return;
      context.go(AppRoutes.createChild);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _confirmPin = '';
        _isConfirmStep = false;
        _firstPin = '';
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
    final currentPin = _isConfirmStep ? _confirmPin : _firstPin;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _isSubmitting ? null : () => context.pop(),
        ),
      ),
      body: SpaceBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.card,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.border),
                    ),
                    child: Icon(
                      Icons.lock_person_rounded,
                      size: 32,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _isConfirmStep
                        ? l10n.confirmPinTitle
                        : l10n.choosePinTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 24,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isConfirmStep
                        ? l10n.confirmPinSubtitle
                        : l10n.choosePinSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.mutedText, fontSize: 15),
                  ),
                  const SizedBox(height: 28),
                  if (_isSubmitting) ...[
                    CircularProgressIndicator(color: colors.primary),
                    const SizedBox(height: 16),
                  ],
                  PinKeypad(
                    pinLength: currentPin.length,
                    enabled: !_isSubmitting,
                    errorText: _errorMessage,
                    onDigitPressed: _onDigitPressed,
                    onDeletePressed: _onDeletePressed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

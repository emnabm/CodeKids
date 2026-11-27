import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/avatars/avatar_catalog.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/l10n/error_localizer.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/l10n/locale_provider.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/features/children/application/children_controller.dart';
import 'package:frontend/shared/widgets/child_avatar.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/space_background.dart';
import 'package:go_router/go_router.dart';

/// Matches `docs/design/creerProfileEnfant.png` layout & styling.
class CreateChildScreen extends ConsumerStatefulWidget {
  const CreateChildScreen({super.key});

  @override
  ConsumerState<CreateChildScreen> createState() => _CreateChildScreenState();
}

class _CreateChildScreenState extends ConsumerState<CreateChildScreen> {
  final _nameController = TextEditingController();

  String _selectedAvatarId = AvatarCatalog.defaultAvatarId;
  int _selectedAge = AppConfig.minChildAge;
  late String _selectedLanguage;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = ref.read(localeProvider).languageCode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _openAvatarPicker() async {
    final l10n = AppLocalizations.of(context);
    final colors = context.ckColors;
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.chooseAvatarTitle,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.92,
                  ),
                  itemCount: AvatarCatalog.options.length,
                  itemBuilder: (context, index) {
                    final option = AvatarCatalog.options[index];
                    final isSelected = option.id == _selectedAvatarId;
                    return InkWell(
                      onTap: () => Navigator.of(sheetContext).pop(option.id),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary.withValues(alpha: 0.25)
                              : colors.cardElevated,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? colors.primary : colors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ChildAvatar(avatarId: option.id, size: 54),
                            const SizedBox(height: 6),
                            Text(
                              option.labelFor(_selectedLanguage),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _selectedAvatarId = picked);
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context);
    final nameErr = FormValidators.childName(_nameController.text, l10n);
    final ageErr = FormValidators.childAge(_selectedAge, l10n);
    final firstErr = nameErr ?? ageErr;
    if (firstErr != null) {
      setState(() => _errorMessage = firstErr);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref.read(childrenControllerProvider.notifier).createChild(
            name: _nameController.text.trim(),
            age: _selectedAge,
            avatarId: _selectedAvatarId,
            interfaceLanguage: _selectedLanguage,
          );
      if (!mounted) return;
      context.go(AppRoutes.map);
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
    final canPop = context.canPop();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _isSubmitting ? null : () => context.pop(),
              )
            : null,
      ),
      body: SpaceBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.createChildTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.createChildSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.mutedText, fontSize: 15),
                ),
                const SizedBox(height: 22),
                Center(
                  child: ChildAvatar(
                    avatarId: _selectedAvatarId,
                    size: 118,
                    borderColor: const Color(0xFF7B5CFF),
                    glow: true,
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: PrimaryButton(
                    expand: false,
                    label: l10n.changeAvatar,
                    leadingIcon: Icons.photo_camera_rounded,
                    onPressed: _isSubmitting ? null : _openAvatarPicker,
                  ),
                ),
                const SizedBox(height: 22),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colors.error.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.error),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                _FieldLabel(label: l10n.childNameLabel),
                const SizedBox(height: 6),
                _DarkBox(
                  child: TextField(
                    controller: _nameController,
                    enabled: !_isSubmitting,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: l10n.childNameHint,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Combined Age row matching creerProfileEnfant.png: "Age  |  10 v"
                _DarkBox(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 54,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.ageLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: colors.border,
                        ),
                        const SizedBox(width: 16),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedAge,
                            dropdownColor: colors.cardElevated,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: colors.mutedText,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            items: List.generate(
                              8,
                              (i) => AppConfig.minChildAge + i,
                            )
                                .map(
                                  (age) => DropdownMenuItem<int>(
                                    value: age,
                                    child: Text('$age'),
                                  ),
                                )
                                .toList(),
                            onChanged: _isSubmitting
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() => _selectedAge = value);
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _FieldLabel(label: l10n.programmingLanguageLabel),
                const SizedBox(height: 6),
                _DarkBox(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 54,
                    child: Row(
                      children: [
                        const _PythonBadgeIcon(),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Python',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: colors.mutedText,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _FieldLabel(label: l10n.interfaceLanguageLabel),
                const SizedBox(height: 6),
                _DarkBox(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 54,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedLanguage,
                        dropdownColor: colors.cardElevated,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: colors.mutedText,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'fr',
                            child: _LanguageRow(
                              code: 'fr',
                              label: 'Français',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'en',
                            child: _LanguageRow(
                              code: 'en',
                              label: 'English',
                            ),
                          ),
                        ],
                        onChanged: _isSubmitting
                            ? null
                            : (value) {
                                if (value == null) return;
                                setState(() => _selectedLanguage = value);
                                ref
                                    .read(localeProvider.notifier)
                                    .setGlobalLocale(value);
                              },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: l10n.nextButton,
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkBox extends StatelessWidget {
  const _DarkBox({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF171142),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.ckColors.border.withValues(alpha: 0.75),
        ),
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: context.ckColors.mutedText,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _PythonBadgeIcon extends StatelessWidget {
  const _PythonBadgeIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: CustomPaint(painter: _PythonLogoPainter()),
    );
  }
}

class _PythonLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blue = Paint()..color = const Color(0xFF3776AB);
    final yellow = Paint()..color = const Color(0xFFFFD43B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, size.width * 0.62, size.height * 0.56),
        const Radius.circular(6),
      ),
      blue,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.34,
          size.height * 0.4,
          size.width * 0.62,
          size.height * 0.56,
        ),
        const Radius.circular(6),
      ),
      yellow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.code, required this.label});

  final String code;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircularFlag(code: code),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }
}

class _CircularFlag extends StatelessWidget {
  const _CircularFlag({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 24,
        height: 24,
        child: code == 'fr'
            ? Row(
                children: [
                  Expanded(child: Container(color: const Color(0xFF0055A4))),
                  Expanded(child: Container(color: Colors.white)),
                  Expanded(child: Container(color: const Color(0xFFEF4135))),
                ],
              )
            : Container(
                color: const Color(0xFF012169),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(height: 6, color: Colors.white),
                    Container(width: 6, color: Colors.white),
                    Container(height: 3.5, color: const Color(0xFFC8102E)),
                    Container(width: 3.5, color: const Color(0xFFC8102E)),
                  ],
                ),
              ),
      ),
    );
  }
}

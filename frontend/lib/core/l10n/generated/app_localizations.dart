import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'CodeKids'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Play • Learn • Code'**
  String get tagline;

  /// No description provided for @welcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Learn programming while playing!'**
  String get welcomeHeadline;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete levels, earn rewards and become a coding champion!'**
  String get welcomeSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join CodeKids and start your coding adventure'**
  String get createAccountSubtitle;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountYet;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue your coding journey'**
  String get loginSubtitle;

  /// No description provided for @choosePinTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your parent PIN'**
  String get choosePinTitle;

  /// No description provided for @choosePinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a 4-digit PIN to protect the parent progress area'**
  String get choosePinSubtitle;

  /// No description provided for @confirmPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your parent PIN'**
  String get confirmPinTitle;

  /// No description provided for @confirmPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the same 4-digit PIN again'**
  String get confirmPinSubtitle;

  /// No description provided for @pinMismatchError.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Please try again.'**
  String get pinMismatchError;

  /// No description provided for @enterParentPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get enterParentPinTitle;

  /// No description provided for @enterParentPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Parent verification required to view progress'**
  String get enterParentPinSubtitle;

  /// No description provided for @pinAttemptsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} attempts remaining'**
  String pinAttemptsRemaining(int count);

  /// No description provided for @pinLockedOut.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong attempts. Please wait a moment and try again.'**
  String get pinLockedOut;

  /// No description provided for @createChildTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Child Profile'**
  String get createChildTitle;

  /// No description provided for @createChildSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your child\'s profile'**
  String get createChildSubtitle;

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change Avatar'**
  String get changeAvatar;

  /// No description provided for @chooseAvatarTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose an Avatar'**
  String get chooseAvatarTitle;

  /// No description provided for @childNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get childNameLabel;

  /// No description provided for @childNameHint.
  ///
  /// In en, this message translates to:
  /// **'Emma'**
  String get childNameHint;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @programmingLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Programming Language'**
  String get programmingLanguageLabel;

  /// No description provided for @interfaceLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Interface Language'**
  String get interfaceLanguageLabel;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @selectChildTitle.
  ///
  /// In en, this message translates to:
  /// **'Who is playing?'**
  String get selectChildTitle;

  /// No description provided for @selectChildSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a child profile or add a new explorer'**
  String get selectChildSubtitle;

  /// No description provided for @addChild.
  ///
  /// In en, this message translates to:
  /// **'Add Child'**
  String get addChild;

  /// No description provided for @switchChild.
  ///
  /// In en, this message translates to:
  /// **'Switch Child'**
  String get switchChild;

  /// No description provided for @deleteChild.
  ///
  /// In en, this message translates to:
  /// **'Delete Profile'**
  String get deleteChild;

  /// No description provided for @deleteChildConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}\'s profile?'**
  String deleteChildConfirmTitle(String name);

  /// No description provided for @deleteChildConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove all progress, flames, and badges for this child.'**
  String get deleteChildConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get navRewards;

  /// No description provided for @navChart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get navChart;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @quizProgress.
  ///
  /// In en, this message translates to:
  /// **'Quiz {current} / {total}'**
  String quizProgress(int current, int total);

  /// No description provided for @validate.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get validate;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @useHint.
  ///
  /// In en, this message translates to:
  /// **'Hint (~{price})'**
  String useHint(int price);

  /// No description provided for @hintTitle.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hintTitle;

  /// No description provided for @hintEstimatedCost.
  ///
  /// In en, this message translates to:
  /// **'Estimated cost: {price} flames'**
  String hintEstimatedCost(int price);

  /// No description provided for @hintHiddenPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tap below to unlock a helpful clue for this question.'**
  String get hintHiddenPlaceholder;

  /// No description provided for @unlockHintButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock Hint'**
  String get unlockHintButton;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @wrongAnswerTitle.
  ///
  /// In en, this message translates to:
  /// **'Incorrect!'**
  String get wrongAnswerTitle;

  /// No description provided for @correctAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {answer}'**
  String correctAnswerLabel(String answer);

  /// No description provided for @explanationLabel.
  ///
  /// In en, this message translates to:
  /// **'Explanation:'**
  String get explanationLabel;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgainLater;

  /// No description provided for @correctFeedback.
  ///
  /// In en, this message translates to:
  /// **'Awesome! Correct!'**
  String get correctFeedback;

  /// No description provided for @levelCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Level complete!'**
  String get levelCompleteTitle;

  /// No description provided for @stageCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Stage complete!'**
  String get stageCompleteTitle;

  /// No description provided for @rewardLabel.
  ///
  /// In en, this message translates to:
  /// **'Reward:'**
  String get rewardLabel;

  /// No description provided for @streakBonusLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak bonus: +{bonus}'**
  String streakBonusLabel(int bonus);

  /// No description provided for @currentStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreakLabel;

  /// No description provided for @streakDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String streakDaysCount(int days);

  /// No description provided for @replayNoFlamesNote.
  ///
  /// In en, this message translates to:
  /// **'Practice replay completed! (+0 flames)'**
  String get replayNoFlamesNote;

  /// No description provided for @newBadgesEarned.
  ///
  /// In en, this message translates to:
  /// **'New badges unlocked!'**
  String get newBadgesEarned;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @myRewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Rewards'**
  String get myRewardsTitle;

  /// No description provided for @flamesLabel.
  ///
  /// In en, this message translates to:
  /// **'Flames'**
  String get flamesLabel;

  /// No description provided for @consecutiveDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Consecutive days'**
  String get consecutiveDaysLabel;

  /// No description provided for @earnedBadgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Earned badges'**
  String get earnedBadgesTitle;

  /// No description provided for @noBadgesYet.
  ///
  /// In en, this message translates to:
  /// **'Complete stages to earn your first badge!'**
  String get noBadgesYet;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View history'**
  String get viewHistory;

  /// No description provided for @transactionHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Flame History'**
  String get transactionHistoryTitle;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No flame transactions yet.'**
  String get noTransactionsYet;

  /// No description provided for @sevenDayActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'7-day activity'**
  String get sevenDayActivityTitle;

  /// No description provided for @parentProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Progress'**
  String parentProgressTitle(String name);

  /// No description provided for @rangeSevenDays.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get rangeSevenDays;

  /// No description provided for @completedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedLabel;

  /// No description provided for @levelsLabel.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get levelsLabel;

  /// No description provided for @stagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Stages'**
  String get stagesLabel;

  /// No description provided for @flamesPerDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Flames per day'**
  String get flamesPerDayTitle;

  /// No description provided for @levelProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress by level'**
  String get levelProgressTitle;

  /// No description provided for @languageSetting.
  ///
  /// In en, this message translates to:
  /// **'Interface Language'**
  String get languageSetting;

  /// No description provided for @languageContentNote.
  ///
  /// In en, this message translates to:
  /// **'App menus update immediately. Lesson content uses the parent account language.'**
  String get languageContentNote;

  /// No description provided for @programmingLanguageSetting.
  ///
  /// In en, this message translates to:
  /// **'Programming Language'**
  String get programmingLanguageSetting;

  /// No description provided for @settingsItem.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsItem;

  /// No description provided for @aboutItem.
  ///
  /// In en, this message translates to:
  /// **'About CodeKids'**
  String get aboutItem;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'CodeKids helps kids aged 10+ learn Python programming fundamentals through playful space missions.'**
  String get aboutDescription;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email address.'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRule.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters with a letter and a digit.'**
  String get validationPasswordRule;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get validationPasswordMismatch;

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the child\'s name.'**
  String get validationNameRequired;

  /// No description provided for @validationAgeMin.
  ///
  /// In en, this message translates to:
  /// **'Age must be 10 or above.'**
  String get validationAgeMin;

  /// No description provided for @validationPinLength.
  ///
  /// In en, this message translates to:
  /// **'PIN must be exactly 4 digits.'**
  String get validationPinLength;

  /// No description provided for @errorOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get errorOfflineTitle;

  /// No description provided for @errorOfflineMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get errorOfflineMessage;

  /// No description provided for @errorGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get errorGenericTitle;

  /// No description provided for @errorGenericMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete this action right now. Please try again.'**
  String get errorGenericMessage;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please log in again.'**
  String get errorUnauthorized;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find what you were looking for.'**
  String get errorNotFound;

  /// No description provided for @errorInsufficientFlames.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have enough flames for this hint yet!'**
  String get errorInsufficientFlames;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Please check your inputs and try again.'**
  String get errorValidation;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

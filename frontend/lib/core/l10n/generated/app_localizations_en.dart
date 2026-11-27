// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'CodeKids';

  @override
  String get tagline => 'Play • Learn • Code';

  @override
  String get welcomeHeadline => 'Learn programming while playing!';

  @override
  String get welcomeSubtitle =>
      'Complete levels, earn rewards and become a coding champion!';

  @override
  String get getStarted => 'Get Started';

  @override
  String get login => 'Login';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createAccountSubtitle =>
      'Join CodeKids and start your coding adventure';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get noAccountYet => 'Don\'t have an account?';

  @override
  String get orDivider => 'OR';

  @override
  String get loginTitle => 'Welcome Back!';

  @override
  String get loginSubtitle => 'Log in to continue your coding journey';

  @override
  String get choosePinTitle => 'Choose your parent PIN';

  @override
  String get choosePinSubtitle =>
      'Create a 4-digit PIN to protect the parent progress area';

  @override
  String get confirmPinTitle => 'Confirm your parent PIN';

  @override
  String get confirmPinSubtitle => 'Enter the same 4-digit PIN again';

  @override
  String get pinMismatchError => 'PINs do not match. Please try again.';

  @override
  String get enterParentPinTitle => 'Enter your PIN';

  @override
  String get enterParentPinSubtitle =>
      'Parent verification required to view progress';

  @override
  String pinAttemptsRemaining(int count) {
    return '$count attempts remaining';
  }

  @override
  String get pinLockedOut =>
      'Too many wrong attempts. Please wait a moment and try again.';

  @override
  String get createChildTitle => 'Create Child Profile';

  @override
  String get createChildSubtitle => 'Let\'s set up your child\'s profile';

  @override
  String get changeAvatar => 'Change Avatar';

  @override
  String get chooseAvatarTitle => 'Choose an Avatar';

  @override
  String get childNameLabel => 'Name';

  @override
  String get childNameHint => 'Emma';

  @override
  String get ageLabel => 'Age';

  @override
  String get programmingLanguageLabel => 'Programming Language';

  @override
  String get interfaceLanguageLabel => 'Interface Language';

  @override
  String get nextButton => 'Next';

  @override
  String get selectChildTitle => 'Who is playing?';

  @override
  String get selectChildSubtitle =>
      'Choose a child profile or add a new explorer';

  @override
  String get addChild => 'Add Child';

  @override
  String get switchChild => 'Switch Child';

  @override
  String get deleteChild => 'Delete Profile';

  @override
  String deleteChildConfirmTitle(String name) {
    return 'Delete $name\'s profile?';
  }

  @override
  String get deleteChildConfirmMessage =>
      'This will permanently remove all progress, flames, and badges for this child.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get navMap => 'Map';

  @override
  String get navRewards => 'Rewards';

  @override
  String get navChart => 'Chart';

  @override
  String get navProfile => 'Profile';

  @override
  String quizProgress(int current, int total) {
    return 'Quiz $current / $total';
  }

  @override
  String get validate => 'Validate';

  @override
  String get gotIt => 'Got it';

  @override
  String useHint(int price) {
    return 'Hint (~$price)';
  }

  @override
  String get hintTitle => 'Hint';

  @override
  String hintEstimatedCost(int price) {
    return 'Estimated cost: $price flames';
  }

  @override
  String get hintHiddenPlaceholder =>
      'Tap below to unlock a helpful clue for this question.';

  @override
  String get unlockHintButton => 'Unlock Hint';

  @override
  String get close => 'Close';

  @override
  String get wrongAnswerTitle => 'Incorrect!';

  @override
  String correctAnswerLabel(String answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get explanationLabel => 'Explanation:';

  @override
  String get tryAgainLater => 'Try again';

  @override
  String get correctFeedback => 'Awesome! Correct!';

  @override
  String get levelCompleteTitle => 'Level complete!';

  @override
  String get stageCompleteTitle => 'Stage complete!';

  @override
  String get rewardLabel => 'Reward:';

  @override
  String streakBonusLabel(int bonus) {
    return 'Streak bonus: +$bonus';
  }

  @override
  String get currentStreakLabel => 'Current streak';

  @override
  String streakDaysCount(int days) {
    return '$days days';
  }

  @override
  String get replayNoFlamesNote => 'Practice replay completed! (+0 flames)';

  @override
  String get newBadgesEarned => 'New badges unlocked!';

  @override
  String get continueButton => 'Continue';

  @override
  String get myRewardsTitle => 'My Rewards';

  @override
  String get flamesLabel => 'Flames';

  @override
  String get consecutiveDaysLabel => 'Consecutive days';

  @override
  String get earnedBadgesTitle => 'Earned badges';

  @override
  String get noBadgesYet => 'Complete stages to earn your first badge!';

  @override
  String get viewHistory => 'View history';

  @override
  String get transactionHistoryTitle => 'Flame History';

  @override
  String get noTransactionsYet => 'No flame transactions yet.';

  @override
  String get sevenDayActivityTitle => '7-day activity';

  @override
  String parentProgressTitle(String name) {
    return '$name\'s Progress';
  }

  @override
  String get rangeSevenDays => '7 days';

  @override
  String get completedLabel => 'Completed';

  @override
  String get levelsLabel => 'Levels';

  @override
  String get stagesLabel => 'Stages';

  @override
  String get flamesPerDayTitle => 'Flames per day';

  @override
  String get levelProgressTitle => 'Progress by level';

  @override
  String get languageSetting => 'Interface Language';

  @override
  String get languageContentNote =>
      'App menus update immediately. Lesson content uses the parent account language.';

  @override
  String get programmingLanguageSetting => 'Programming Language';

  @override
  String get settingsItem => 'Settings';

  @override
  String get aboutItem => 'About CodeKids';

  @override
  String get aboutDescription =>
      'CodeKids helps kids aged 10+ learn Python programming fundamentals through playful space missions.';

  @override
  String get logout => 'Log Out';

  @override
  String get validationEmailRequired => 'Please enter an email address.';

  @override
  String get validationEmailInvalid => 'Please enter a valid email address.';

  @override
  String get validationPasswordRule =>
      'Password must be at least 8 characters with a letter and a digit.';

  @override
  String get validationPasswordMismatch => 'Passwords do not match.';

  @override
  String get validationNameRequired => 'Please enter the child\'s name.';

  @override
  String get validationAgeMin => 'Age must be 10 or above.';

  @override
  String get validationPinLength => 'PIN must be exactly 4 digits.';

  @override
  String get errorOfflineTitle => 'You are offline';

  @override
  String get errorOfflineMessage =>
      'Check your internet connection and try again.';

  @override
  String get errorGenericTitle => 'Oops! Something went wrong';

  @override
  String get errorGenericMessage =>
      'We couldn\'t complete this action right now. Please try again.';

  @override
  String get errorUnauthorized => 'Your session expired. Please log in again.';

  @override
  String get errorForbidden => 'You do not have permission to access this.';

  @override
  String get errorNotFound => 'We couldn\'t find what you were looking for.';

  @override
  String get errorInsufficientFlames =>
      'You don\'t have enough flames for this hint yet!';

  @override
  String get errorValidation => 'Please check your inputs and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';
}

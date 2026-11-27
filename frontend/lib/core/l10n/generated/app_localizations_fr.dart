// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'CodeKids';

  @override
  String get tagline => 'Jouer • Apprendre • Coder';

  @override
  String get welcomeHeadline => 'Apprends à programmer en jouant !';

  @override
  String get welcomeSubtitle =>
      'Termine des niveaux, gagne des récompenses et deviens un champion du code !';

  @override
  String get getStarted => 'Commencer';

  @override
  String get login => 'Connexion';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get createAccountSubtitle =>
      'Rejoins CodeKids et commence ton aventure';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get alreadyHaveAccount => 'Déjà un compte ?';

  @override
  String get noAccountYet => 'Pas encore de compte ?';

  @override
  String get orDivider => 'OU';

  @override
  String get loginTitle => 'Bon retour !';

  @override
  String get loginSubtitle => 'Connecte-toi pour continuer ton aventure';

  @override
  String get choosePinTitle => 'Choisis ton code PIN parent';

  @override
  String get choosePinSubtitle =>
      'Crée un code à 4 chiffres pour protéger l\'espace parent';

  @override
  String get confirmPinTitle => 'Confirme ton code PIN';

  @override
  String get confirmPinSubtitle => 'Saisis à nouveau le même code à 4 chiffres';

  @override
  String get pinMismatchError =>
      'Les codes PIN ne correspondent pas. Réessaie.';

  @override
  String get enterParentPinTitle => 'Saisissez votre PIN';

  @override
  String get enterParentPinSubtitle =>
      'Vérification parentale requise pour voir la progression';

  @override
  String pinAttemptsRemaining(int count) {
    return '$count tentatives restantes';
  }

  @override
  String get pinLockedOut =>
      'Trop de tentatives incorrectes. Patiente un instant avant de réessayer.';

  @override
  String get createChildTitle => 'Créer un profil enfant';

  @override
  String get createChildSubtitle => 'Configurons le profil de ton enfant';

  @override
  String get changeAvatar => 'Changer d\'avatar';

  @override
  String get chooseAvatarTitle => 'Choisir un avatar';

  @override
  String get childNameLabel => 'Prénom';

  @override
  String get childNameHint => 'Emma';

  @override
  String get ageLabel => 'Âge';

  @override
  String get programmingLanguageLabel => 'Langage de programmation';

  @override
  String get interfaceLanguageLabel => 'Langue de l\'interface';

  @override
  String get nextButton => 'Suivant';

  @override
  String get selectChildTitle => 'Qui joue aujourd\'hui ?';

  @override
  String get selectChildSubtitle =>
      'Choisis un profil enfant ou ajoutes-en un nouveau';

  @override
  String get addChild => 'Ajouter un enfant';

  @override
  String get switchChild => 'Changer d\'enfant';

  @override
  String get deleteChild => 'Supprimer le profil';

  @override
  String deleteChildConfirmTitle(String name) {
    return 'Supprimer le profil de $name ?';
  }

  @override
  String get deleteChildConfirmMessage =>
      'Cela supprimera définitivement toute la progression, les flammes et les badges de cet enfant.';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get navMap => 'Carte';

  @override
  String get navRewards => 'Récompenses';

  @override
  String get navChart => 'Suivi';

  @override
  String get navProfile => 'Profil';

  @override
  String quizProgress(int current, int total) {
    return 'Quiz $current / $total';
  }

  @override
  String get validate => 'Valider';

  @override
  String get gotIt => 'J\'ai compris';

  @override
  String useHint(int price) {
    return 'Indice (~$price)';
  }

  @override
  String get hintTitle => 'Indice';

  @override
  String hintEstimatedCost(int price) {
    return 'Coût estimé : $price flammes';
  }

  @override
  String get hintHiddenPlaceholder =>
      'Appuie ci-dessous pour débloquer un indice utile pour cette question.';

  @override
  String get unlockHintButton => 'Utiliser l\'indice';

  @override
  String get close => 'Fermer';

  @override
  String get wrongAnswerTitle => 'Mauvaise réponse !';

  @override
  String correctAnswerLabel(String answer) {
    return 'Bonne réponse : $answer';
  }

  @override
  String get explanationLabel => 'Explication :';

  @override
  String get tryAgainLater => 'Réessayer';

  @override
  String get correctFeedback => 'Bravo ! Bonne réponse !';

  @override
  String get levelCompleteTitle => 'Niveau terminé !';

  @override
  String get stageCompleteTitle => 'Stage terminé !';

  @override
  String get rewardLabel => 'Récompense :';

  @override
  String streakBonusLabel(int bonus) {
    return 'Bonus de série : +$bonus';
  }

  @override
  String get currentStreakLabel => 'Série actuelle';

  @override
  String streakDaysCount(int days) {
    return '$days jours';
  }

  @override
  String get replayNoFlamesNote => 'Entraînement terminé ! (+0 flamme)';

  @override
  String get newBadgesEarned => 'Nouveaux badges débloqués !';

  @override
  String get continueButton => 'Continuer';

  @override
  String get myRewardsTitle => 'Mes Récompenses';

  @override
  String get flamesLabel => 'Flammes';

  @override
  String get consecutiveDaysLabel => 'Jours consécutifs';

  @override
  String get earnedBadgesTitle => 'Badges obtenus';

  @override
  String get noBadgesYet =>
      'Termine des stages pour gagner ton premier badge !';

  @override
  String get viewHistory => 'Voir l\'historique';

  @override
  String get transactionHistoryTitle => 'Historique des flammes';

  @override
  String get noTransactionsYet =>
      'Aucune transaction de flammes pour le moment.';

  @override
  String get sevenDayActivityTitle => 'Activité sur 7 jours';

  @override
  String parentProgressTitle(String name) {
    return 'Progression de $name';
  }

  @override
  String get rangeSevenDays => '7 jours';

  @override
  String get completedLabel => 'Complété';

  @override
  String get levelsLabel => 'Niveaux';

  @override
  String get stagesLabel => 'Stages';

  @override
  String get flamesPerDayTitle => 'Flammes par jour';

  @override
  String get levelProgressTitle => 'Progression par niveau';

  @override
  String get languageSetting => 'Langue de l\'interface';

  @override
  String get languageContentNote =>
      'Les menus changent immédiatement. Le contenu des leçons reste dans la langue du compte parent.';

  @override
  String get programmingLanguageSetting => 'Langage';

  @override
  String get settingsItem => 'Paramètres';

  @override
  String get aboutItem => 'À propos de CodeKids';

  @override
  String get aboutDescription =>
      'CodeKids aide les enfants dès 10 ans à apprendre les bases de Python grâce à des missions spatiales ludiques.';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get validationEmailRequired => 'Saisis une adresse e-mail.';

  @override
  String get validationEmailInvalid => 'Saisis une adresse e-mail valide.';

  @override
  String get validationPasswordRule =>
      'Minimum 8 caractères avec au moins une lettre et un chiffre.';

  @override
  String get validationPasswordMismatch =>
      'Les mots de passe ne correspondent pas.';

  @override
  String get validationNameRequired => 'Saisis le prénom de l\'enfant.';

  @override
  String get validationAgeMin => 'L\'âge doit être d\'au moins 10 ans.';

  @override
  String get validationPinLength =>
      'Le code PIN doit contenir exactement 4 chiffres.';

  @override
  String get errorOfflineTitle => 'Hors ligne';

  @override
  String get errorOfflineMessage =>
      'Vérifie ta connexion Internet et réessaie.';

  @override
  String get errorGenericTitle => 'Oups ! Une erreur est survenue';

  @override
  String get errorGenericMessage =>
      'Impossible de terminer cette action pour le moment. Réessaie.';

  @override
  String get errorUnauthorized => 'Ta session a expiré. Reconnecte-toi.';

  @override
  String get errorForbidden =>
      'Tu n\'as pas l\'autorisation d\'accéder à cette ressource.';

  @override
  String get errorNotFound => 'Élément introuvable.';

  @override
  String get errorInsufficientFlames =>
      'Tu n\'as pas encore assez de flammes pour cet indice !';

  @override
  String get errorValidation => 'Vérifie les champs saisis et réessaie.';

  @override
  String get retry => 'Réessayer';

  @override
  String get loading => 'Chargement...';
}

/// Centralizes numeric bounds for request DTOs matching backend validation.
class RequestBounds {
  const RequestBounds._();

  static const int minAttempts = 1;
  static const int maxAttempts = 100;

  static const int minHintsUsed = 0;
  static const int maxHintsUsed = 100;

  static const int minChildAge = 10;
  static const int maxChildAge = 99;

  static int clampAttempts(int attempts) =>
      attempts.clamp(minAttempts, maxAttempts);

  static int clampHintsUsed(int hintsUsed) =>
      hintsUsed.clamp(minHintsUsed, maxHintsUsed);

  static int clampChildAge(int age) => age.clamp(minChildAge, maxChildAge);
}

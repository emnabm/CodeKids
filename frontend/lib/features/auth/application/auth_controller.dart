import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/di/providers.dart';
import 'package:frontend/core/network/problem_details.dart';
import 'package:frontend/features/auth/data/models/auth_models.dart';
import 'package:frontend/features/children/application/children_controller.dart';

enum AuthStatus {
  unknown,
  unauthenticated,
  authenticated,
}

class AuthState {
  const AuthState({
    required this.status,
    this.redirectToLogin = false,
    this.bootstrapError,
    this.pendingEmail,
    this.pendingPassword,
    this.parent,
  });

  const AuthState.unknown()
      : status = AuthStatus.unknown,
        redirectToLogin = false,
        bootstrapError = null,
        pendingEmail = null,
        pendingPassword = null,
        parent = null;

  final AuthStatus status;
  final bool redirectToLogin;
  final Object? bootstrapError;
  final String? pendingEmail;
  final String? pendingPassword;
  final ParentDto? parent;

  AuthState copyWith({
    AuthStatus? status,
    bool? redirectToLogin,
    Object? bootstrapError,
    bool clearBootstrapError = false,
    String? pendingEmail,
    String? pendingPassword,
    ParentDto? parent,
  }) {
    return AuthState(
      status: status ?? this.status,
      redirectToLogin: redirectToLogin ?? this.redirectToLogin,
      bootstrapError:
          clearBootstrapError ? null : (bootstrapError ?? this.bootstrapError),
      pendingEmail: pendingEmail ?? this.pendingEmail,
      pendingPassword: pendingPassword ?? this.pendingPassword,
      parent: parent ?? this.parent,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(bootstrap);
    return const AuthState.unknown();
  }

  /// Auto-login check at app startup.
  Future<void> bootstrap() async {
    state = state.copyWith(clearBootstrapError: true);
    final storage = ref.read(tokenStorageProvider);
    final token = await storage.readToken();
    if (token == null || token.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        redirectToLogin: false,
      );
      return;
    }

    try {
      final children = await ref.read(childrenRepositoryProvider).getChildren();
      // Auto-login with a valid stored token goes to child selection.
      await storage.saveActiveChildId(null);
      ref.read(childrenControllerProvider.notifier).setLoadedChildren(children);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        redirectToLogin: false,
      );
    } on ApiException catch (e) {
      if (e.kind == ApiErrorKind.unauthorized ||
          e.kind == ApiErrorKind.forbidden) {
        await storage.clearSession();
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          redirectToLogin: true,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unknown,
          bootstrapError: e,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unknown,
        bootstrapError: e,
      );
    }
  }

  /// Stores validated Create Account credentials locally until PIN is chosen.
  void setPendingRegistration({
    required String email,
    required String password,
  }) {
    state = state.copyWith(
      pendingEmail: email.trim(),
      pendingPassword: password,
    );
  }

  Future<void> completeRegistration({
    required String pin,
    required String language,
  }) async {
    final email = state.pendingEmail;
    final password = state.pendingPassword;
    if (email == null || password == null) {
      throw const ApiException(
        kind: ApiErrorKind.badRequest,
        fallbackMessage: 'Registration details missing.',
      );
    }

    final response = await ref.read(authRepositoryProvider).register(
          RegisterRequestDto(
            email: email,
            password: password,
            pin: pin,
            language: language,
          ),
        );
    await _persistAuthResponse(response);
    ref.read(childrenControllerProvider.notifier).reset();
    state = AuthState(
      status: AuthStatus.authenticated,
      parent: response.parent,
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await ref.read(authRepositoryProvider).login(
          LoginRequestDto(email: email.trim(), password: password),
        );
    await _persistAuthResponse(response);
    await ref.read(childrenControllerProvider.notifier).loadChildren();
    state = AuthState(
      status: AuthStatus.authenticated,
      parent: response.parent,
    );
  }

  Future<void> _persistAuthResponse(AuthResponseDto response) async {
    final storage = ref.read(tokenStorageProvider);
    if (response.token != null && response.token!.isNotEmpty) {
      await storage.saveToken(response.token!);
    }
    await storage.saveParentInfo(
      email: response.parent?.email,
      language: response.parent?.language,
    );
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clearSession();
    ref.read(childrenControllerProvider.notifier).reset();
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      redirectToLogin: false,
    );
  }

  void handleUnauthorized() {
    ref.read(childrenControllerProvider.notifier).reset();
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      redirectToLogin: true,
    );
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

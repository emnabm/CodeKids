import 'package:dio/dio.dart';

/// RFC 7807 ProblemDetails returned by the .NET 8 backend.
class ProblemDetails {
  const ProblemDetails({
    this.type,
    this.title,
    this.status,
    this.detail,
    this.instance,
    this.errors = const {},
  });

  final String? type;
  final String? title;
  final int? status;
  final String? detail;
  final String? instance;
  final Map<String, List<String>> errors;

  factory ProblemDetails.fromJson(Map<String, dynamic> json) {
    final parsedErrors = <String, List<String>>{};
    final rawErrors = json['errors'];
    if (rawErrors is Map) {
      for (final entry in rawErrors.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is List) {
          parsedErrors[key] = value.map((e) => e.toString()).toList();
        } else if (value != null) {
          parsedErrors[key] = [value.toString()];
        }
      }
    }

    return ProblemDetails(
      type: json['type'] as String?,
      title: json['title'] as String?,
      status: (json['status'] as num?)?.toInt(),
      detail: json['detail'] as String?,
      instance: json['instance'] as String?,
      errors: parsedErrors,
    );
  }

  /// Extracts the most specific human-readable server message if available.
  String? get bestMessage {
    if (detail != null && detail!.trim().isNotEmpty) {
      return detail!.trim();
    }
    if (errors.isNotEmpty) {
      final messages = errors.values.expand((list) => list).toList();
      if (messages.isNotEmpty) {
        return messages.first.trim();
      }
    }
    if (title != null && title!.trim().isNotEmpty) {
      return title!.trim();
    }
    return null;
  }
}

/// Categories of failures surfaced to the UI.
enum ApiErrorKind {
  offline,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  server,
  unknown,
}

/// Normalized exception thrown by all repositories.
class ApiException implements Exception {
  const ApiException({
    required this.kind,
    this.statusCode,
    this.problemDetails,
    this.fallbackMessage,
  });

  final ApiErrorKind kind;
  final int? statusCode;
  final ProblemDetails? problemDetails;
  final String? fallbackMessage;

  bool get isOffline => kind == ApiErrorKind.offline;

  /// Returns server ProblemDetails text when present, otherwise null.
  String? get serverMessage => problemDetails?.bestMessage ?? fallbackMessage;

  factory ApiException.fromDioException(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const ApiException(kind: ApiErrorKind.offline);
    }

    final response = error.response;
    final statusCode = response?.statusCode;
    ProblemDetails? details;

    final data = response?.data;
    if (data is Map<String, dynamic>) {
      details = ProblemDetails.fromJson(data);
    } else if (data is Map) {
      details = ProblemDetails.fromJson(Map<String, dynamic>.from(data));
    } else if (data is String && data.trim().isNotEmpty) {
      details = ProblemDetails(detail: data.trim(), status: statusCode);
    }

    final kind = switch (statusCode) {
      400 => ApiErrorKind.badRequest,
      401 => ApiErrorKind.unauthorized,
      403 => ApiErrorKind.forbidden,
      404 => ApiErrorKind.notFound,
      409 => ApiErrorKind.conflict,
      final code when code != null && code >= 500 => ApiErrorKind.server,
      _ => ApiErrorKind.unknown,
    };

    return ApiException(
      kind: kind,
      statusCode: statusCode,
      problemDetails: details,
      fallbackMessage: details?.bestMessage ?? error.message,
    );
  }

  @override
  String toString() =>
      'ApiException(kind: $kind, statusCode: $statusCode, message: $serverMessage)';
}

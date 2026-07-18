class PosOperationResult<T> {
  const PosOperationResult._(
      {required this.isSuccess,
      this.value,
      this.code,
      this.message,
      this.isIdempotent = false});

  final bool isSuccess;
  final T? value;
  final String? code;
  final String? message;
  final bool isIdempotent;

  factory PosOperationResult.success(T value, {bool isIdempotent = false}) =>
      PosOperationResult._(
          isSuccess: true, value: value, isIdempotent: isIdempotent);

  factory PosOperationResult.failure(String code, String message) =>
      PosOperationResult._(isSuccess: false, code: code, message: message);
}

class PosOperationException implements Exception {
  const PosOperationException(this.code, this.message);
  final String code;
  final String message;
  @override
  String toString() => message;
}

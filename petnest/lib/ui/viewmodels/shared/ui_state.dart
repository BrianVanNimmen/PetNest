sealed class UiState {
  const UiState();
}

class UiIdle extends UiState {
  const UiIdle();
}

class UiLoading extends UiState {
  const UiLoading();
}

class UiSuccess extends UiState {
  const UiSuccess();
}

class UiError extends UiState {
  const UiError(this.message);

  final String message;
}

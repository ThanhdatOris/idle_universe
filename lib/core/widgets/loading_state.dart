abstract class LoadingState {
  const LoadingState();
}

class LoadingStateInitial extends LoadingState {}

class LoadingStateLoading extends LoadingState {}

class LoadingStateLoaded extends LoadingState {}

class LoadingStateError extends LoadingState {
  final String message;

  const LoadingStateError(this.message);
}

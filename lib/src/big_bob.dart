/// The class that handles global Bobs Jobs configurations.
class BigBob {
  /// The function called when a failure occurs.
  ///
  /// This does not replace the `onError` callback of each job, but is called
  /// in addition to it.
  static void Function(dynamic failure, Object? error, StackTrace? stack)
      onFailure = (_, __, ___) {};
}

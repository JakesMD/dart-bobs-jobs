import 'package:bobs_jobs/bobs_jobs.dart';
import 'package:equatable/equatable.dart';

/// The status of the [RequestCubitState].
enum RequestCubitStatus {
  /// No request has been made yet.
  initial,

  /// The request is currently in progress.
  inProgress,

  /// The request failed.
  failed,

  /// The request succeeded.
  succeeded,
}

/// {@template RequestCubitState}
///
/// This is a generic class that can be extended to create a cubit state that
/// handles an asyncronous request.
///
/// This dramatically reduces the boilerplate code and creates a uniform API for
/// the UI.
///
/// {@endtemplate}
class RequestCubitState<F, S> with EquatableMixin {
  /// {@macro RequestCubitState}
  RequestCubitState({required RequestCubitStatus status, this.outcome})
      : status = outcome != null
            ? outcome is BobsFailure<F, S>
                ? RequestCubitStatus.failed
                : RequestCubitStatus.succeeded
            : status;

  /// {@macro RequestCubitState}
  ///
  /// The initial state. It sets [status] to [RequestCubitStatus.initial].
  RequestCubitState.initial({this.outcome})
      : status = RequestCubitStatus.initial;

  /// {@macro RequestCubitState}
  ///
  /// The in progress state. It sets [status] to
  /// [RequestCubitStatus.inProgress].
  RequestCubitState.inProgress({this.outcome})
      : status = RequestCubitStatus.inProgress;

  /// {@macro RequestCubitState}
  ///
  /// The completed state. It sets [status] to [RequestCubitStatus.failed] or
  /// [RequestCubitStatus.succeeded] based on the outcome.
  RequestCubitState.completed({required this.outcome})
      : status = outcome is BobsFailure<F, S>
            ? RequestCubitStatus.failed
            : RequestCubitStatus.succeeded;

  /// {@macro RequestCubitState}
  ///
  /// The completed state.
  RequestCubitState.succeeded({required this.outcome})
      : status = RequestCubitStatus.succeeded;

  /// The outcome of the latest item in the stream.
  final BobsOutcome<F, S>? outcome;

  /// The status of the request.
  final RequestCubitStatus status;

  /// The failure value of the latest item in the stream.
  F get failure => outcome!.asFailure;

  /// The success value of the latest item in the stream.
  S get success => outcome!.asSuccess;

  /// Returns true if the request is initial.
  bool get isInitial => status == RequestCubitStatus.initial;

  /// Returns true if the request is in progress.
  bool get inProgress => status == RequestCubitStatus.inProgress;

  /// Returns true if the request failed.
  bool get failed => status == RequestCubitStatus.failed;

  /// Returns true if the request succeeded.
  bool get succeeded => status == RequestCubitStatus.succeeded;

  @override
  List<Object?> get props => [outcome];

  @override
  String toString() => switch (status) {
        RequestCubitStatus.initial => 'initial()',
        RequestCubitStatus.inProgress => 'inProgress()',
        RequestCubitStatus.failed => 'failed($failure)',
        RequestCubitStatus.succeeded => 'succeeded($success)',
      };
}

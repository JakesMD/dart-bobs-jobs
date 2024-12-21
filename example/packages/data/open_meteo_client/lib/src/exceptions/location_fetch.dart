/// An exception that can occur when fetching a location.
enum LocationFetchException {
  /// The request failed.
  requestFailed,

  /// The location was not found.
  notFound;
}

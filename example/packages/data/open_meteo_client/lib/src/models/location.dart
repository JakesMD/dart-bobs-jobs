import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

/// {@template open_meteo_client.Location}
///
/// Represents a weather location on Earth.
///
/// {@endtemplate}
@JsonSerializable()
class Location with EquatableMixin {
  /// {@macro open_meteo_client.Location}
  const Location({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  /// Creates a [Location] from a JSON object.
  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  /// The unique identifier for the location.
  final int id;

  /// The name of the location.
  final String name;

  /// The latitude coordinate of the location.
  final double latitude;

  /// The longitude coordinate of the location.
  final double longitude;

  @override
  List<Object?> get props => [id, name, latitude, longitude];
}

import 'package:equatable/equatable.dart';

// Domain Models

enum TransportMode {
  bus,
  tram,
  rail,
  metro,
  water,
  air,
  coach,
  unknown;

  static TransportMode fromString(String value) {
    return TransportMode.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => TransportMode.unknown,
    );
  }
}

class LinePresentation extends Equatable {
  final String? textColour;
  final String? colour;

  const LinePresentation({this.textColour, this.colour});

  @override
  List<Object?> get props => [textColour, colour];
}

class Line extends Equatable {
  final String id;
  final String publicCode;
  final LinePresentation presentation;

  const Line({
    required this.id,
    required this.publicCode,
    required this.presentation,
  });

  @override
  List<Object?> get props => [id, publicCode, presentation];
}

class Quay extends Equatable {
  final String publicCode;
  final String name;

  const Quay({required this.publicCode, required this.name});

  @override
  List<Object?> get props => [publicCode, name];
}

class DestinationDisplay extends Equatable {
  final String frontText;
  final List<String> via;

  const DestinationDisplay({required this.frontText, required this.via});

  @override
  List<Object?> get props => [frontText, via];
}

class LocalizedText extends Equatable {
  final String value;
  final String? language;

  const LocalizedText({required this.value, this.language});

  @override
  List<Object?> get props => [value, language];
}

class Situation extends Equatable {
  final String id;
  final List<LocalizedText> description;
  final List<LocalizedText> summary;

  const Situation({
    required this.id,
    required this.description,
    required this.summary,
  });

  @override
  List<Object?> get props => [id, description, summary];
}

class Departure extends Equatable {
  final Quay quay;
  final DestinationDisplay destinationDisplay;
  final DateTime aimedDepartureTime;
  final DateTime expectedDepartureTime;
  final DateTime? expectedArrivalTime;
  final Line line;
  final TransportMode transportMode;
  final String? transportSubmode;
  final bool cancellation;
  final bool realtime;
  final Duration? delay;
  final List<Situation> situations;

  const Departure({
    required this.quay,
    required this.destinationDisplay,
    required this.aimedDepartureTime,
    required this.expectedDepartureTime,
    this.expectedArrivalTime,
    required this.line,
    required this.transportMode,
    this.transportSubmode,
    required this.cancellation,
    required this.realtime,
    this.delay,
    required this.situations,
  });

  int get untilMinutes {
    final now = DateTime.now();
    final difference = expectedDepartureTime.difference(now);
    return difference.inMinutes;
  }

  @override
  List<Object?> get props => [
    quay,
    destinationDisplay,
    aimedDepartureTime,
    expectedDepartureTime,
    expectedArrivalTime,
    line,
    transportMode,
    transportSubmode,
    cancellation,
    realtime,
    delay,
    situations,
  ];
}

class StopPlace extends Equatable {
  final String name;
  final List<TransportMode> transportModes;
  final List<Departure> departures;
  final List<Situation> situations;

  const StopPlace({
    required this.name,
    required this.transportModes,
    required this.departures,
    required this.situations,
  });

  @override
  List<Object?> get props => [name, transportModes, departures, situations];
}

// Exception Types

abstract class CollectiveTransportException implements Exception {
  final String code;
  final String message;

  const CollectiveTransportException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

class CollectiveTransportBadRequestException
    extends CollectiveTransportException {
  const CollectiveTransportBadRequestException({
    required super.code,
    required super.message,
  });
}

class CollectiveTransportUnauthorizedException
    extends CollectiveTransportException {
  const CollectiveTransportUnauthorizedException({
    required super.code,
    required super.message,
  });
}

class CollectiveTransportNotFoundException
    extends CollectiveTransportException {
  const CollectiveTransportNotFoundException({
    required super.code,
    required super.message,
  });
}

class CollectiveTransportInternalServerException
    extends CollectiveTransportException {
  const CollectiveTransportInternalServerException({
    required super.code,
    required super.message,
  });
}

class CollectiveTransportGraphQLException extends CollectiveTransportException {
  const CollectiveTransportGraphQLException({
    required super.code,
    required super.message,
  });
}

class CollectiveTransportInvalidStopException
    extends CollectiveTransportException {
  const CollectiveTransportInvalidStopException({
    required super.code,
    required super.message,
  });
}

class CollectiveTransportUnknownException extends CollectiveTransportException {
  const CollectiveTransportUnknownException({
    required super.code,
    required super.message,
  });
}

// Repository Interface

abstract interface class CollectiveTransportRepository {
  /// Gets departure information for a stop place
  ///
  /// Parameters:
  /// - [stopPlaceId]: The Entur stop place ID (e.g., "NSR:StopPlace:41613")
  /// - [startTime]: Optional start time for departures (defaults to now)
  /// - [numberOfDepartures]: Maximum number of departures to fetch (default: 20)
  /// - [whitelistedTransportModes]: Optional list of transport modes to filter by
  /// - [whitelistedLines]: Optional list of line IDs to filter by
  ///
  /// Returns a [StopPlace] with departure information
  ///
  /// Throws:
  /// - [CollectiveTransportBadRequestException] if request parameters are invalid
  /// - [CollectiveTransportUnauthorizedException] if API authentication fails
  /// - [CollectiveTransportNotFoundException] if stop place doesn't exist
  /// - [CollectiveTransportGraphQLException] if GraphQL query has errors
  /// - [CollectiveTransportInvalidStopException] if stop data is null/invalid
  /// - [CollectiveTransportInternalServerException] if Entur server error occurs
  /// - [CollectiveTransportUnknownException] if unknown error occurs
  Future<StopPlace> getDepartures({
    required String stopPlaceId,
    DateTime? startTime,
    int numberOfDepartures = 20,
    List<TransportMode>? whitelistedTransportModes,
    List<String>? whitelistedLines,
  });
}

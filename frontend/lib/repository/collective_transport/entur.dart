import 'package:dio/dio.dart';
import 'package:promillezone/api/entur_api.dart';
import 'repository.dart';

final class EnturCollectiveTransportRepository
    implements CollectiveTransportRepository {
  final EnturApi _api = EnturApi();

  static const String _stopPlaceQuery = '''
query StopPlace(\$stopPlaceId: String!, \$whitelistedTransportModes: [TransportMode], \$whitelistedLines: [ID!], \$numberOfDepartures: Int = 20, \$startTime: DateTime) {
  stopPlace(id: \$stopPlaceId) {
    name
    transportMode
    estimatedCalls(
      numberOfDepartures: \$numberOfDepartures,
      whiteListedModes: \$whitelistedTransportModes,
      whiteListed: { lines: \$whitelistedLines },
      includeCancelledTrips: true,
      startTime: \$startTime
    ) {
      quay { publicCode, name }
      destinationDisplay { frontText, via }
      aimedDepartureTime
      expectedDepartureTime
      expectedArrivalTime
      serviceJourney {
        id
        transportMode
        transportSubmode
        line {
          id
          publicCode
          presentation { textColour, colour }
        }
      }
      cancellation
      realtime
      situations { id, description { value, language }, summary { value, language } }
    }
    situations { id, description { value, language }, summary { value, language } }
  }
}
''';

  @override
  Future<StopPlace> getDepartures({
    required String stopPlaceId,
    DateTime? startTime,
    int numberOfDepartures = 20,
    List<TransportMode>? whitelistedTransportModes,
    List<String>? whitelistedLines,
  }) async {
    try {
      // Build variables
      final variables = <String, dynamic>{
        'stopPlaceId': stopPlaceId,
        'numberOfDepartures': numberOfDepartures,
        if (startTime != null) 'startTime': startTime.toIso8601String(),
        if (whitelistedTransportModes != null)
          'whitelistedTransportModes': whitelistedTransportModes
              .map((m) => m.name.toUpperCase())
              .toList(),
        if (whitelistedLines != null) 'whitelistedLines': whitelistedLines,
      };

      // Execute query
      final response = await _api.query(
        query: _stopPlaceQuery,
        variables: variables,
      );

      // Check for GraphQL errors
      if (response.data?['errors'] != null) {
        final errors = response.data!['errors'] as List;
        final firstError = errors.first as Map<String, dynamic>;
        throw CollectiveTransportGraphQLException(
          code: 'graphql_error',
          message: firstError['message']?.toString() ?? 'GraphQL query failed',
        );
      }

      // Validate response has data
      final stopPlaceData = response.data?['data']?['stopPlace'];
      if (stopPlaceData == null) {
        throw const CollectiveTransportInvalidStopException(
          code: 'invalid_stop',
          message: 'Stop place not found or returned no data',
        );
      }

      // Map to domain model
      return _mapToStopPlace(stopPlaceData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    } on CollectiveTransportException {
      rethrow;
    }
  }

  StopPlace _mapToStopPlace(Map<String, dynamic> data) {
    final name = data['name'] as String;

    // Parse transport modes
    final modesJson = data['transportMode'] as List?;
    final modes = modesJson
            ?.map((m) => TransportMode.fromString(m.toString()))
            .toList() ??
        [];

    // Parse estimated calls (departures)
    final callsJson = data['estimatedCalls'] as List?;
    final departures = callsJson
            ?.map((c) => _mapToDeparture(c as Map<String, dynamic>))
            .toList() ??
        [];

    // Parse situations
    final situationsJson = data['situations'] as List?;
    final situations = situationsJson
            ?.map((s) => _mapToSituation(s as Map<String, dynamic>))
            .toList() ??
        [];

    return StopPlace(
      name: name,
      transportModes: modes,
      departures: departures,
      situations: situations,
    );
  }

  Departure _mapToDeparture(Map<String, dynamic> data) {
    // Parse times
    final aimedTime = DateTime.parse(data['aimedDepartureTime'] as String).toLocal();
    final expectedTime =
        DateTime.parse(data['expectedDepartureTime'] as String).toLocal();
    final arrivalTime = data['expectedArrivalTime'] != null
        ? DateTime.parse(data['expectedArrivalTime'] as String).toLocal()
        : null;

    // Calculate delay
    final delay = expectedTime.difference(aimedTime);

    // Parse nested objects
    final quay = _mapToQuay(data['quay'] as Map<String, dynamic>);
    final destinationDisplay = _mapToDestinationDisplay(
      data['destinationDisplay'] as Map<String, dynamic>,
    );
    final serviceJourney = data['serviceJourney'] as Map<String, dynamic>;
    final line = _mapToLine(serviceJourney['line'] as Map<String, dynamic>);

    // Parse transport mode
    final transportMode = TransportMode.fromString(
      serviceJourney['transportMode'] as String,
    );

    // Parse situations
    final situationsJson = data['situations'] as List?;
    final situations = situationsJson
            ?.map((s) => _mapToSituation(s as Map<String, dynamic>))
            .toList() ??
        [];

    return Departure(
      quay: quay,
      destinationDisplay: destinationDisplay,
      aimedDepartureTime: aimedTime,
      expectedDepartureTime: expectedTime,
      expectedArrivalTime: arrivalTime,
      line: line,
      transportMode: transportMode,
      transportSubmode: serviceJourney['transportSubmode'] as String?,
      cancellation: data['cancellation'] as bool,
      realtime: data['realtime'] as bool,
      delay: delay,
      situations: situations,
    );
  }

  Line _mapToLine(Map<String, dynamic> data) {
    final presentationData = data['presentation'] as Map<String, dynamic>?;
    final presentation = presentationData != null
        ? LinePresentation(
            textColour: presentationData['textColour'] as String?,
            colour: presentationData['colour'] as String?,
          )
        : const LinePresentation();

    return Line(
      id: data['id'] as String,
      publicCode: data['publicCode'] as String,
      presentation: presentation,
    );
  }

  Quay _mapToQuay(Map<String, dynamic> data) {
    return Quay(
      publicCode: data['publicCode'] as String,
      name: data['name'] as String,
    );
  }

  DestinationDisplay _mapToDestinationDisplay(Map<String, dynamic> data) {
    final viaJson = data['via'] as List?;
    final via = viaJson?.map((v) => v.toString()).toList() ?? [];

    return DestinationDisplay(
      frontText: data['frontText'] as String,
      via: via,
    );
  }

  Situation _mapToSituation(Map<String, dynamic> data) {
    final descJson = data['description'] as List?;
    final descriptions = descJson
            ?.map((d) => _mapToLocalizedText(d as Map<String, dynamic>))
            .toList() ??
        [];

    final summJson = data['summary'] as List?;
    final summaries = summJson
            ?.map((s) => _mapToLocalizedText(s as Map<String, dynamic>))
            .toList() ??
        [];

    return Situation(
      id: data['id'] as String,
      description: descriptions,
      summary: summaries,
    );
  }

  LocalizedText _mapToLocalizedText(Map<String, dynamic> data) {
    return LocalizedText(
      value: data['value'] as String,
      language: data['language'] as String?,
    );
  }

  CollectiveTransportException _handleError(DioException e) {
    final response = e.response;

    // Network error (no response)
    if (response == null) {
      return CollectiveTransportUnknownException(
        code: 'network_error',
        message: e.message ?? 'Network error occurred',
      );
    }

    final data = response.data;

    // Try to extract error code and message from response
    String code = 'unknown';
    String message = 'An unknown error occurred';

    if (data is Map<String, dynamic>) {
      // Check for GraphQL errors
      if (data['errors'] != null) {
        final errors = data['errors'] as List;
        if (errors.isNotEmpty) {
          final firstError = errors.first as Map<String, dynamic>;
          code = 'graphql_error';
          message = firstError['message']?.toString() ?? message;
        }
      } else {
        // Standard error response
        code = data['code']?.toString() ?? code;
        message = data['message']?.toString() ?? message;
      }
    }

    // Map HTTP status codes to exceptions
    switch (response.statusCode) {
      case 400:
        return CollectiveTransportBadRequestException(
          code: code,
          message: message,
        );
      case 401:
        return CollectiveTransportUnauthorizedException(
          code: code,
          message: message,
        );
      case 404:
        return CollectiveTransportNotFoundException(
          code: code,
          message: message,
        );
      case 500:
        return CollectiveTransportInternalServerException(
          code: code,
          message: message,
        );
      default:
        return CollectiveTransportUnknownException(
          code: code,
          message: message,
        );
    }
  }
}

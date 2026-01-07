import 'package:dio/dio.dart';
import 'repository.dart';

final class TrvGarbageDisposalRepository implements GarbageDisposalRepository {
  final Dio _dio = Dio();

  TrvGarbageDisposalRepository();

  @override
  Future<String> getAddressId({required Address address}) async {
    try {
      final interpolated = '${address.streetName} ${address.streetNumber}';

      final response = await _dio.get(
        'https://trv.no/wp-json/wasteplan/v2/adress/',
        queryParameters: {'s': interpolated},
      );

      if (response.data == null) {
        throw const GarbageDisposalUnknownException(
          code: 'no_data',
          message: 'No data returned from server',
        );
      }

      final List<dynamic> addresses = response.data as List<dynamic>;

      if (addresses.isEmpty) {
        throw const GarbageDisposalNotFoundException(
          code: 'address_not_found',
          message: 'Address not found',
        );
      }

      final firstAddress = addresses.first as Map<String, dynamic>;
      return firstAddress['id'] as String;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<TrashScheduleEntry>> getTrashSchedule({
    required String addressId,
  }) async {
    try {
      final response = await _dio.get(
        'https://trv.no/wp-json/wasteplan/v2/calendar/$addressId',
      );

      if (response.data == null) {
        throw const GarbageDisposalUnknownException(
          code: 'no_data',
          message: 'No data returned from server',
        );
      }

      final scheduleData = response.data as Map<String, dynamic>;
      final List<dynamic> calendar = scheduleData['calendar'] as List<dynamic>;

      return calendar.map((entry) {
        final entryMap = entry as Map<String, dynamic>;
        return TrashScheduleEntry(
          date: DateTime.parse(entryMap['dato'] as String),
          type: _mapFraksjonToCategory(entryMap['fraksjon'] as String),
        );
      }).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  TrashCategory _mapFraksjonToCategory(String fraksjon) {
    switch (fraksjon) {
      case 'Glass- og metallemballasje':
        return TrashCategory.glassMetal;
      case 'Matavfall':
        return TrashCategory.food;
      case 'Papp og papir':
        return TrashCategory.cardboard;
      case 'Plastemballasje':
        return TrashCategory.plastic;
      case 'Restavfall':
        return TrashCategory.rest;
      default:
        // Default to rest for unknown categories
        return TrashCategory.rest;
    }
  }

  GarbageDisposalException _handleError(DioException e) {
    final response = e.response;

    if (response == null) {
      return GarbageDisposalUnknownException(
        code: 'network_error',
        message: e.message ?? 'Network error occurred',
      );
    }

    final data = response.data;

    // Try to extract error code and message from response
    String code = 'unknown';
    String message = 'An unknown error occurred';

    if (data is Map<String, dynamic>) {
      code = data['code']?.toString() ?? code;
      message = data['message']?.toString() ?? message;
    } else if (data is String) {
      message = data;
    }

    switch (response.statusCode) {
      case 400:
        return GarbageDisposalBadRequestException(code: code, message: message);
      case 404:
        return GarbageDisposalNotFoundException(code: code, message: message);
      case 500:
      case 502:
      case 503:
        return GarbageDisposalInternalServerException(
          code: code,
          message: message,
        );
      default:
        return GarbageDisposalUnknownException(code: code, message: message);
    }
  }
}

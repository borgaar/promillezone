import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

// Domain Models

enum TrashCategory { glassMetal, food, cardboard, plastic, rest }

class Address extends Equatable {
  final String streetName;
  final String streetNumber;

  const Address({required this.streetName, required this.streetNumber});

  @override
  List<Object?> get props => [streetName, streetNumber];
}

class TrashScheduleEntry extends Equatable {
  final DateTime date;
  final TrashCategory type;

  List<ImageProvider> get icons {
    final names = switch (type) {
      TrashCategory.glassMetal => ["glass", "metal"],
      _ => [type.name],
    };

    return names
        .map((n) => AssetImage("asset/img/garbage_disposal/$n.jpg"))
        .toList();
  }

  String get label {
    return switch (type) {
      TrashCategory.glassMetal => 'Glass/Metall',
      TrashCategory.food => 'Matavfall',
      TrashCategory.cardboard => 'Papp/Papir',
      TrashCategory.plastic => 'Plast',
      TrashCategory.rest => 'Restavfall',
    };
  }

  const TrashScheduleEntry({required this.date, required this.type});

  @override
  List<Object?> get props => [date, type];
}

// Exception Types

abstract class GarbageDisposalException implements Exception {
  final String code;
  final String message;

  const GarbageDisposalException({required this.code, required this.message});

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

class GarbageDisposalBadRequestException extends GarbageDisposalException {
  const GarbageDisposalBadRequestException({
    required super.code,
    required super.message,
  });
}

class GarbageDisposalNotFoundException extends GarbageDisposalException {
  const GarbageDisposalNotFoundException({
    required super.code,
    required super.message,
  });
}

class GarbageDisposalInternalServerException extends GarbageDisposalException {
  const GarbageDisposalInternalServerException({
    required super.code,
    required super.message,
  });
}

class GarbageDisposalUnknownException extends GarbageDisposalException {
  const GarbageDisposalUnknownException({
    required super.code,
    required super.message,
  });
}

// Repository Interface

abstract interface class GarbageDisposalRepository {
  /// Fetches the address ID for the given address from the garbage disposal provider
  ///
  /// Throws:
  /// - [GarbageDisposalBadRequestException] if address format is invalid
  /// - [GarbageDisposalNotFoundException] if address is not found
  /// - [GarbageDisposalInternalServerException] if server error occurs
  /// - [GarbageDisposalUnknownException] if an unknown error occurs
  Future<String> getAddressId({required Address address});

  /// Fetches the trash collection schedule for the given address ID
  ///
  /// Throws:
  /// - [GarbageDisposalBadRequestException] if address ID format is invalid
  /// - [GarbageDisposalNotFoundException] if address ID is not found
  /// - [GarbageDisposalInternalServerException] if server error occurs
  /// - [GarbageDisposalUnknownException] if an unknown error occurs
  Future<List<TrashScheduleEntry>> getTrashSchedule({
    required String addressId,
  });
}

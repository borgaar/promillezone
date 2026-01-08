import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract class DynamicContentRepository {
  Future<DynamicContent> pollContent();
}

final class DynamicContent extends Equatable {
  final List<DynamicContentBlock> blocks;
  final DynamicMessage? message;

  const DynamicContent({required this.blocks, required this.message});

  @override
  get props => [blocks, message];
}

final class DynamicMessage extends Equatable {
  final String author;
  final String message;

  const DynamicMessage({required this.author, required this.message});

  @override
  get props => [author, message];
}

sealed class DynamicContentBlock extends Equatable {
  const DynamicContentBlock({required this.title});

  final String title;

  @override
  get props => [title];
}

enum FontType { sansSerif, serif, comic, mono }

final class TextContentBlock extends DynamicContentBlock {
  final String text;
  final FontType fontType;

  String get fontFamily => switch (fontType) {
    FontType.sansSerif => "Inter",
    FontType.serif => "SourceSerif",
    FontType.comic => "ComicNeue",
    FontType.mono => "JetBrainsMono",
  };

  const TextContentBlock({
    required super.title,
    required this.text,
    required this.fontType,
  });

  @override
  get props => [...super.props, text, fontType];
}

final class ImageContentBlock extends DynamicContentBlock {
  final ImageProvider image;

  const ImageContentBlock({required super.title, required this.image});

  @override
  get props => [...super.props, image];
}

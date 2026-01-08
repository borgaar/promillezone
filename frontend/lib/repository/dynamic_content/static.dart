import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:promillezone/repository/dynamic_content/repository.dart';

final class StaticDynamicContentRepository extends DynamicContentRepository {
  @override
  Future<DynamicContent> pollContent() async {
    final catImageResponse = await Dio().get(
      "https://cataas.com/cat?width=300&height=300",
      options: Options(responseType: ResponseType.bytes),
    );

    final image = MemoryImage(catImageResponse.data);

    final jokeResponse = await Dio().get(
      "https://icanhazdadjoke.com/",
      options: Options(headers: {"Accept": "application/json"}),
    );

    final joke = jokeResponse.data["joke"] as String;

    final quoteResponse = await Dio().get("https://api.kanye.rest/");

    final quote = quoteResponse.data["quote"] as String;

    return DynamicContent(
      blocks: [
        ImageContentBlock(title: "Dagens katt", image: image),
        TextContentBlock(
          title: "Dagens vits",
          text: joke,
          fontType: FontType.comic,
        ),
        TextContentBlock(
          title: "Dagens visdomsord",
          text: quote,
          fontType: FontType.serif,
        ),
      ],
      message: null,
    );
  }

  @override
  Duration get pollingInterval => Duration(hours: 24);
}

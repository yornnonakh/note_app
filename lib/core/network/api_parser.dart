import 'api_exception.dart';

abstract final class ApiParser {
  static dynamic unwrapData(dynamic response) {
    if (response is Map) {
      if (response.containsKey('data')) {
        return response['data'];
      }

      if (response.containsKey('result')) {
        return response['result'];
      }
    }

    return response;
  }

  static Map<String, dynamic> asMap(
      dynamic response, {
        bool unwrap = true,
      }) {
    final dynamic value =
    unwrap ? unwrapData(response) : response;

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw ApiException(
      message:
      'Expected an object but received ${value.runtimeType}.',
      responseData: response,
    );
  }

  static List<Map<String, dynamic>> asList(
      dynamic response,
      ) {
    final List<dynamic>? foundList = _findList(response);

    if (foundList == null) {
      throw ApiException(
        message:
        'Expected a list but received ${response.runtimeType}.',
        responseData: response,
      );
    }

    return foundList
        .whereType<Map>()
        .map(
          (Map<dynamic, dynamic> item) =>
      Map<String, dynamic>.from(item),
    )
        .toList();
  }

  static List<dynamic>? _findList(dynamic value) {
    if (value is List) {
      return value;
    }

    if (value is! Map) {
      return null;
    }

    const List<String> preferredKeys = [
      'data',
      'items',
      'records',
      'rows',
      'results',
      'result',
      'list',
      'folders',
      'notes',
      'content',
    ];

    for (final String key in preferredKeys) {
      if (!value.containsKey(key)) {
        continue;
      }

      final List<dynamic>? result =
      _findList(value[key]);

      if (result != null) {
        return result;
      }
    }

    for (final dynamic nestedValue in value.values) {
      final List<dynamic>? result =
      _findList(nestedValue);

      if (result != null) {
        return result;
      }
    }

    return null;
  }

  static int readId(
      dynamic response, {
        List<String> keys = const [
          'id',
          'noteId',
          'folderId',
          'attachmentId',
        ],
      }) {
    final int? id = _findId(
      response,
      keys: keys,
    );

    if (id == null) {
      throw ApiException(
        message: 'The API response does not contain an ID.',
        responseData: response,
      );
    }

    return id;
  }

  static int? _findId(
      dynamic value, {
        required List<String> keys,
      }) {
    if (value is! Map) {
      return null;
    }

    for (final String key in keys) {
      final dynamic rawValue = value[key];

      if (rawValue is int) {
        return rawValue;
      }

      final int? parsed =
      int.tryParse(rawValue?.toString() ?? '');

      if (parsed != null) {
        return parsed;
      }
    }

    for (final dynamic nestedValue in value.values) {
      if (nestedValue is Map) {
        final int? result = _findId(
          nestedValue,
          keys: keys,
        );

        if (result != null) {
          return result;
        }
      }
    }

    return null;
  }
}
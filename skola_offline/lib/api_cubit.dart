import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiState extends Equatable {
  final Map<String, dynamic> cachedData;
  final Map<String, bool> isLoading;

  const ApiState({
    this.cachedData = const {},
    this.isLoading = const {},
  });

  @override
  List<Object> get props => [cachedData, isLoading];

  ApiState copyWith({
    Map<String, dynamic>? cachedData,
    Map<String, bool>? isLoading,
  }) {
    return ApiState(
      cachedData: cachedData ?? this.cachedData,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Map<String, dynamic> toJson() => {
        'cachedData': cachedData,
        'isLoading': isLoading,
      };

  factory ApiState.fromJson(Map<String, dynamic> json) {
    return ApiState(
      cachedData: json['cachedData'] as Map<String, dynamic>? ?? {},
      isLoading: (json['isLoading'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as bool),
          ) ??
          {},
    );
  }
}

class ApiCubit extends HydratedCubit<ApiState> {
  ApiCubit() : super(ApiState());

  Future<Map<String, dynamic>> makeRequest(
    String rawUrl,
    Map<String, dynamic>? params,
    BuildContext context,
  ) async {
    final url = Uri.parse('https://aplikace.skolaonline.cz/solapi/$rawUrl');
    final queryUrl =
        params != null ? url.replace(queryParameters: params) : url;
    final cacheKey = queryUrl.toString();

    // Emit loading state
    emit(state.copyWith(
      isLoading: {...state.isLoading, cacheKey: true},
    ));

    // Return cached data immediately if available
    if (state.cachedData.containsKey(cacheKey)) {
      // Start fetching fresh data in the background
      _fetchAndUpdateCache(cacheKey, context);
      
      // Return cached data
      return state.cachedData[cacheKey];
    }

    // If no cached data, wait for the fetch to complete
    return await _fetchAndUpdateCache(cacheKey, context);
  }

  Future<Map<String, dynamic>> _fetchAndUpdateCache(String cacheKey, BuildContext context) async {
    try {
      final storage = FlutterSecureStorage();
      final accessToken = await storage.read(key: 'accessToken');

      final response = await http.get(
        Uri.parse(cacheKey),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        emit(state.copyWith(
          cachedData: {...state.cachedData, cacheKey: responseData},
          isLoading: {...state.isLoading, cacheKey: false},
        ));
        return responseData;
      } else if (response.statusCode == 401 && accessToken != null) {
        // Token refresh logic
        final refreshToken = await storage.read(key: 'refreshToken');
        final refreshResponse = await http.post(
          Uri.parse('https://aplikace.skolaonline.cz/solapi/api/connect/token'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'grant_type': 'refresh_token',
            'refresh_token': refreshToken,
            'client_id': 'test_client',
            'scope': 'offline_access sol_api',
          },
        );

        if (refreshResponse.statusCode == 200) {
          final refreshData = json.decode(refreshResponse.body);
          await storage.write(key: 'accessToken', value: refreshData['access_token']);
          await storage.write(key: 'refreshToken', value: refreshData['refresh_token']);

          // Retry the original request with the new token
          return _fetchAndUpdateCache(cacheKey, context);
        } else {
          throw Exception('Failed to refresh token');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: {...state.isLoading, cacheKey: false},
      ));
      // Handle error (e.g., show a snackbar, navigate to login screen)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      rethrow;
    }
  }

  @override
  ApiState? fromJson(Map<String, dynamic> json) => ApiState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(ApiState state) => state.toJson();
}
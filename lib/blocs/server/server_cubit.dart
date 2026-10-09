import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parallax_mobile/demo/demo_config.dart';

/// Holds and mutates the active Parallax backend base URL.
class ServerCubit extends Cubit<String> {
  ServerCubit()
      : super(
          kDemoMode
              ? kDemoBaseUrl
              : !kIsWeb && defaultTargetPlatform == TargetPlatform.android
              ? 'http://10.0.2.2:8080'
              : 'http://localhost:8080',
        );

  void setUrl(String url) => emit(url.trim());

  void setLocalhost() => emit('http://localhost:8080');

  void setAndroidEmulator() => emit('http://10.0.2.2:8080');
}

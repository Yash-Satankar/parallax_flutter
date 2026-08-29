import 'package:flutter_test/flutter_test.dart';
import 'package:parallax_mobile/blocs/export/export_bloc.dart';
import 'package:parallax_mobile/blocs/export/export_event.dart';
import 'package:parallax_mobile/blocs/export/export_state.dart';
import 'package:parallax_mobile/blocs/server/server_cubit.dart';
import 'package:parallax_mobile/data/parallax_api.dart';
import 'package:dio/dio.dart';

void main() {
  group('ServerCubit Tests', () {
    test('initial state has default url', () {
      final cubit = ServerCubit();
      expect(cubit.state, isNotEmpty);
      cubit.close();
    });

    test('setUrl updates the server URL', () {
      final cubit = ServerCubit();
      cubit.setUrl('http://192.168.1.100:8080');
      expect(cubit.state, 'http://192.168.1.100:8080');
      cubit.close();
    });

    test('setLocalhost sets 127.0.0.1:8080', () {
      final cubit = ServerCubit();
      cubit.setLocalhost();
      expect(cubit.state, 'http://localhost:8080');
      cubit.close();
    });

    test('setAndroidEmulator sets 10.0.2.2:8080', () {
      final cubit = ServerCubit();
      cubit.setAndroidEmulator();
      expect(cubit.state, 'http://10.0.2.2:8080');
      cubit.close();
    });
  });

  group('ExportBloc Tests', () {
    late ParallaxApi mockApi;
    late ExportBloc exportBloc;

    setUp(() {
      final dio = Dio();
      mockApi = ParallaxApi(dio, baseUrl: 'http://localhost:8080');
      exportBloc = ExportBloc(api: mockApi, projectId: 'test-proj');
    });

    tearDown(() {
      exportBloc.close();
    });

    test('initial state has default settings', () {
      expect(exportBloc.state.format, 'mp4');
      expect(exportBloc.state.resolution, '1080p');
      expect(exportBloc.state.fps, 30);
      expect(exportBloc.state.burnCaptions, isFalse);
      expect(exportBloc.state.isExporting, isFalse);
    });

    test('ExportFormatChanged updates format', () async {
      exportBloc.add(const ExportFormatChanged('webm'));
      await expectLater(
        exportBloc.stream,
        emits(predicate<ExportState>((s) => s.format == 'webm')),
      );
    });

    test('ExportResolutionChanged updates resolution', () async {
      exportBloc.add(const ExportResolutionChanged('4k'));
      await expectLater(
        exportBloc.stream,
        emits(predicate<ExportState>((s) => s.resolution == '4k')),
      );
    });

    test('ExportBurnCaptionsToggled updates captions toggle', () async {
      exportBloc.add(const ExportBurnCaptionsToggled(true));
      await expectLater(
        exportBloc.stream,
        emits(predicate<ExportState>((s) => s.burnCaptions == true)),
      );
    });
  });
}

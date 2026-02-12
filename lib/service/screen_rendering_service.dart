import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';

class ScreenRenderingService {
  static ScreenRenderingService? _instance;
  static ScreenRenderingService get instance =>
      _instance ??= ScreenRenderingService._();

  ScreenRenderingService._();
  Future<void> measureScreenLoad(
      String screenName,
      Future<void> Function() loadOperation,
      ) async {
    final Trace screenTrace = FirebasePerformance.instance.newTrace(
      'screen_load_$screenName',
    );

    await screenTrace.start();

    try {
      screenTrace.putAttribute('screen_name', screenName);
      screenTrace.putAttribute(
        'load_timestamp',
        DateTime.now().millisecondsSinceEpoch.toString(),
      );

      await loadOperation();

      screenTrace.incrementMetric('successful_screen_loads', 1);
      screenTrace.putAttribute('load_result', 'success');
    } catch (e) {
      screenTrace.incrementMetric('failed_screen_loads', 1);
      screenTrace.putAttribute('load_result', 'failure');
      screenTrace.putAttribute('error', e.toString());
      rethrow;
    } finally {
      await screenTrace.stop();
    }
  }
  Future<Widget> measureWidgetBuild(
      String widgetName,
      Future<Widget> Function() buildOperation,
      ) async {
    final Trace buildTrace = FirebasePerformance.instance.newTrace(
      'widget_build_$widgetName',
    );

    await buildTrace.start();

    try {
      buildTrace.putAttribute('widget_name', widgetName);
      buildTrace.putAttribute(
        'build_timestamp',
        DateTime.now().millisecondsSinceEpoch.toString(),
      );

      final widget = await buildOperation();

      buildTrace.incrementMetric('widgets_built', 1);
      buildTrace.putAttribute('build_result', 'success');

      return widget;
    } catch (e) {
      buildTrace.incrementMetric('build_failures', 1);
      buildTrace.putAttribute('build_result', 'failure');
      rethrow;
    } finally {
      await buildTrace.stop();
    }
  }
  Future<void> measureAnimation(String animationName, Duration duration) async {
    final Trace animTrace = FirebasePerformance.instance.newTrace(
      'animation_$animationName',
    );

    await animTrace.start();

    try {
      animTrace.putAttribute('animation_name', animationName);
      animTrace.putAttribute('duration_ms', duration.inMilliseconds.toString());

      // Simulate animation
      await Future.delayed(duration);

      animTrace.incrementMetric('animations_completed', 1);
    } finally {
      await animTrace.stop();
    }
  }
}


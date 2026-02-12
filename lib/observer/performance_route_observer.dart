import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';

class PerformanceRouteObserver extends RouteObserver<PageRoute<dynamic>>{
  final Map<String, Trace> _traces = {};

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // TODO: implement didPush
    super.didPush(route, previousRoute);
    if(route is PageRoute){
      _startScreenTrace(route);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    // TODO: implement didReplace
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if(newRoute is PageRoute){
      _startScreenTrace(newRoute);
    }
    if(oldRoute is PageRoute){
      _stopScreenTrace(oldRoute);
    }
  }
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // TODO: implement didPop
    super.didPop(route, previousRoute);
    if(route is PageRoute){
      _stopScreenTrace(route);
    }
  }
  void _startScreenTrace(PageRoute<dynamic> route) {
    final String routeName =
        route.settings.name ?? route.runtimeType.toString();
    final String traceName =
        'screen_rendering_${routeName.toLowerCase().replaceAll(' ', '_')}';

    final Trace trace = FirebasePerformance.instance.newTrace(traceName);
    trace.start();

    // Add screen rendering attributes
    trace.putAttribute('screen_name', routeName);
    trace.putAttribute('route_type', route.runtimeType.toString());
    trace.putAttribute(
      'navigation_time',
      DateTime.now().millisecondsSinceEpoch.toString(),
    );

    _traces[routeName] = trace;
  }
  void _stopScreenTrace(PageRoute<dynamic> route) {
    final String routeName =
        route.settings.name ?? route.runtimeType.toString();
    if (_traces.containsKey(routeName)) {
      _traces[routeName]?.stop();
      _traces.remove(routeName);
    }
  }
}
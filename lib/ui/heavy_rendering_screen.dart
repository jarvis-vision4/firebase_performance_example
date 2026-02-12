import 'dart:math';

import 'package:flutter/material.dart';

import '../service/screen_rendering_service.dart';
class HeavyRenderingScreen extends StatefulWidget {
  const HeavyRenderingScreen({super.key});

  @override
  State<HeavyRenderingScreen> createState() => _HeavyRenderingScreenState();
}

class _HeavyRenderingScreenState extends State<HeavyRenderingScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  final ScreenRenderingService _screenService = ScreenRenderingService.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }
  Future<void> _measureHeavyRendering() async {
    await _screenService.measureScreenLoad('heavy_rendering', () async {
      // Simulate heavy loading
      await Future.delayed(Duration(milliseconds: 1000));
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Heavy Rendering Screen')
      ),
      body: AnimatedBuilder(animation: _controller, builder: (context,child){
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'This screen demonstrates heavy rendering with many animated elements. '
                    'Firebase Performance will track frame drops and rendering issues.',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                ),
                itemCount: 100,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        Colors.blue,
                        Colors.red,
                        sin(_controller.value * 2 * pi + index * 0.1) * 0.5 +
                            0.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Transform.rotate(
                        angle: _controller.value * 2 * pi + index * 0.1,
                        child: Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _screenService.measureAnimation(
            'fab_rotation',
            Duration(milliseconds: 500),
          );
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * pi,
              child: Icon(Icons.refresh),
            );
          },
        ),
      ),
    );
  }

}

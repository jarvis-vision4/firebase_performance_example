import 'package:flutter/material.dart';

import '../models/order.dart';
import '../models/post.dart';
import '../service/customer_trace_service.dart';
import '../service/network_service.dart';
import '../service/screen_rendering_service.dart';
class PerformanceHomePage extends StatefulWidget {
  const PerformanceHomePage({super.key});

  @override
  State<PerformanceHomePage> createState() => _PerformanceHomePageState();
}

class _PerformanceHomePageState extends State<PerformanceHomePage> {
  final NetworkService _networkService = NetworkService.instance;
  final CustomTraceService _customTrace = CustomTraceService.instance;
  final ScreenRenderingService _screenService = ScreenRenderingService.instance;
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _measureScreenLoad();
  }
  Future<void> _measureScreenLoad() async {
    await _screenService.measureScreenLoad('home', () async {
      await _loadPosts();
      // Simulate additional loading operations
      await Future.delayed(Duration(milliseconds: 300));
    });
  }
  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _networkService.getPosts();

    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _posts = response.data ?? [];
      } else {
        _error = response.error;
      }
    });
  }
  Future<void> _demonstrateCustomTraces() async {
    // Demonstrate login trace
    await _customTrace.performUserLogin('user@example.com', 'password123');

    // Demonstrate database trace
    await _customTrace.performDatabaseQuery(
      'SELECT * FROM users WHERE active = 1',
    );

    // Demonstrate image processing trace
    await _customTrace.processImage('sample_image.jpg', applyFilters: true);

    // Demonstrate order processing trace
    final order = Order(
      type: 'online',
      items: ['item1', 'item2'],
      totalAmount: 99.99,
      paymentMethod: 'credit_card',
    );
    await _customTrace.processOrder(order);

    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Custom traces completed! Check Firebase Console.'),
        ),
      );
    }
  }
  Future<void> _demonstrateScreenRendering() async {
    // Navigate to a heavy rendering screen
    Navigator.pushNamed(context, '/heavy');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Performance Complete'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadPosts)
        ],
      ),
      body: Column(
        children: [
          _buildActionButtons(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
  Widget _buildActionButtons(){
    return Column(
      children: [
        Text(
          '🌐 NETWORK REQUESTS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _loadPosts,
                child: Text('Load Posts\n(Auto Tracking)'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await _networkService.getPostsWithManualTracking();
                },
                child: Text('Manual\nTracking'),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          '🎯 CUSTOM TRACES',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _demonstrateCustomTraces,
            child: Text('Run Custom Traces Demo'),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
  Widget _buildContent(){
    if(_isLoading){
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading posts...'),

          ],
        ),
      );
    }
    return ListView.builder(
        padding: EdgeInsets.all(16),
        itemBuilder: (context,index){
          final post = _posts[index];
          return Card(
            margin: EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(post.title),
              subtitle: Text(
                post.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text('User ${post.userId}'),
            ),
          );
        },itemCount: _posts.length
    );
  }
}

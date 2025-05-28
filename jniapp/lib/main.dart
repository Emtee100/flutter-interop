import 'package:flutter/material.dart';
import 'package:jni/jni.dart';
import 'package:jniapp/example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'JniGen'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  // final permissions = (
  // PermissionController.create
  // )
  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }

  void _getSteps() async {
    final Set<String> neededPermissions = {
      'android.permission.health.READ_STEPS'
    };
    final healthContext = Context.fromReference(
      Jni.getCachedApplicationContext(),
    );
    final client = HealthConnectClient.getOrCreate$1(healthContext);
    final permi = PermissionController.createRequestPermissionResultContract();

    client.getPermissionController().getGrantedPermissions();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final aggregateRequest = AggregateRequest(
      {StepsRecord.COUNT_TOTAL}.toJSet(AggregateMetric.type(JLong.type))
      ,TimeRangeFilter.after(
        Instant.ofEpochMilli(yesterday.millisecondsSinceEpoch)!,

      ),
      JSet.hash(JObject.type)
    );
    try {
      final result = await client.aggregate(aggregateRequest);
      final stepCount = result.get(StepsRecord.COUNT_TOTAL);
      setState(() {
        _counter = stepCount as int;
      });
    } catch (e) {
      print("Error aggregating steps: $e");
      // Handle specific errors, e.g., if permissions were revoked
      if (e.toString().contains("SecurityException")) {
        //_permissionsGranted = false; // Mark permissions as not granted
        //_checkAndRequestPermissions(); // Prompt for permissions again
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthContext = Context.fromReference(
      Jni.getCachedApplicationContext(),
    );
    final sdkStatus = HealthConnectClient.getSdkStatus$1(healthContext);
    if (sdkStatus == HealthConnectClient.SDK_UNAVAILABLE) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Health Connect is not available'),
              Text(
                'SDK Status: $sdkStatus',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      );
    } else if (sdkStatus == HealthConnectClient.SDK_AVAILABLE) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You have walked this times:'),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              // Text(sdkStatus.toString()),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _getSteps,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
    }
    else {return Scaffold(
      body: Center(child: Text("No SDK Status")),
    );}
  }
}

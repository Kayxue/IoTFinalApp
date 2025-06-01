import 'package:flutter/material.dart';
import 'package:parking/Widgets/slotdata.dart';
import 'package:parking/Widgets/topbar.dart';
import 'package:parking/Widgets/slotprogress.dart';
import 'package:parking/Types/slotdata.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking Area Info',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: const MyHomePage(title: 'Parking Area Info'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ParkingDataState _state = ParkingDataState.loading();
  final String _apiUrl = 'http://10.0.2.2:3000/my-api';

  Future<void> _loadData() async {
    setState(() {
      _state = ParkingDataState.loading();
    });

    try {
      // Add artificial delay to show loading state longer
      await Future.delayed(Duration(seconds: 1));

      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = SlotData.fromJson(jsonData);

        setState(() {
          _state = ParkingDataState.success(data);
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _state = ParkingDataState.error('Failed to load data: ${e.toString()}');
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('連線失敗：${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: '重試',
              textColor: Colors.white,
              onPressed: _loadData,
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _showSlotsDialog() {
    final slotData = _state.data;
    if (slotData == null) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('車位狀態'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                ),
                itemCount: slotData.slots.length,
                itemBuilder: (context, index) {
                  final occupied = slotData.slots[index];
                  return Card(
                    color: occupied ? Colors.red[100] : Colors.green[100],
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '車位 #${index + 1}',
                              style: TextStyle(fontSize: 11),
                            ),
                            SizedBox(height: 2),
                            Icon(
                              occupied
                                  ? Icons.directions_car
                                  : Icons.check_box_outline_blank,
                              color: occupied ? Colors.red : Colors.green,
                              size: 18,
                            ),
                            SizedBox(height: 2),
                            Text(
                              occupied ? '有車' : '空位',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
              height:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                children: [
                  TopBar(onTap: _showSlotsDialog),
                  SizedBox(height: 8),
                  SlotDataWidget(state: _state),
                  SizedBox(height: 8),
                  SlotProgress(state: _state),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        tooltip: 'Reload',
        child: const Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

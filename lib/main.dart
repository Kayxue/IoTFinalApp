import 'package:flutter/material.dart';
import 'package:parking/Widgets/slotdata.dart';
import 'package:parking/Widgets/topbar.dart';
import 'package:parking/Widgets/slotprogress.dart';
import 'package:parking/Types/slotdata.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';

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
  final String _wsUrl = 'ws://10.0.2.2:8080';
  WebSocket? _webSocket;
  StreamSubscription? _webSocketSubscription;

  Future<void> _loadData() async {
    setState(() {
      _state = ParkingDataState.loading();
    });

    try {
      // Add timeout to the request
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException('請求超時，請檢查網絡連接');
            },
          );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = SlotData.fromJson(jsonData);

        setState(() {
          _state = ParkingDataState.success(data);
        });
      } else {
        throw Exception('服務器返回錯誤: ${response.statusCode}');
      }
    } on SocketException {
      setState(() {
        _state = ParkingDataState.error('無法連接到服務器，請檢查網絡連接');
      });
    } on TimeoutException catch (e) {
      setState(() {
        _state = ParkingDataState.error(e.message ?? '請求超時');
      });
    } on FormatException {
      setState(() {
        _state = ParkingDataState.error('數據格式錯誤');
      });
    } catch (e) {
      setState(() {
        _state = ParkingDataState.error('發生錯誤: ${e.toString()}');
      });
    }

    if (mounted && _state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_state.error!),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: '重試',
            textColor: Colors.white,
            onPressed: _loadData,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _webSocketSubscription?.cancel();
    _webSocket?.close();
    super.dispose();
  }

  void _connectWebSocket() async {
    try {
      print('Attempting to connect to WebSocket at $_wsUrl');
      final socket = await WebSocket.connect(_wsUrl);
      print('WebSocket connected successfully');
      _webSocket = socket;
      _webSocketSubscription = _webSocket?.listen(
        (data) {
          try {
            print('Received WebSocket data: $data');
            final Map<String, dynamic> jsonData = jsonDecode(data);
            if(jsonData['type'] != "parkingUpdate"){
              print('Received unexpected WebSocket data type: ${jsonData['type']}, ignoring');
              return;
            }
            final updatedData = SlotData.fromJson(jsonData['data']);
            setState(() {
              _state = ParkingDataState.success(updatedData);
            });
          } catch (e) {
            print('Error parsing WebSocket data: $e');
            setState(() {
              _state = ParkingDataState.error('WebSocket數據格式錯誤');
            });
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          setState(() {
            _state = ParkingDataState.error('WebSocket連接錯誤');
          });
          _reconnectWebSocket();
        },
        onDone: () {
          print('WebSocket connection closed');
          setState(() {
            _state = ParkingDataState.error('WebSocket連接已關閉');
          });
          _reconnectWebSocket();
        },
      );
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      setState(() {
        _state = ParkingDataState.error('無法連接到WebSocket服務器');
      });
      _reconnectWebSocket();
    }
  }

  void _reconnectWebSocket() {
    print('Attempting to reconnect WebSocket in 3 seconds...');
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _connectWebSocket();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                children: [
                  const TopBar(),
                  const SizedBox(height: 8),
                  SlotDataWidget(state: _state),
                  const SizedBox(height: 8),
                  SlotProgress(state: _state),
                  const SizedBox(height: 8),
                  if (_state.data != null)
                    SizedBox(
                      height: 300,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: _state.data!.slots.length,
                        itemBuilder: (context, index) {
                          final occupied = _state.data!.slots[index];
                          return Card(
                            color:
                                occupied ? Colors.red[100] : Colors.green[100],
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '車位 #${index + 1}',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Icon(
                                      occupied
                                          ? Icons.directions_car
                                          : Icons.check_box_outline_blank,
                                      color:
                                          occupied ? Colors.red : Colors.green,
                                      size: 18,
                                    ),
                                    const SizedBox(height: 2),
                                    Expanded(
                                      child: Text(
                                        occupied ? '有車' : '空位',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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
      ),
    );
  }
}

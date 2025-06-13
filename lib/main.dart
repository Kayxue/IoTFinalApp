import 'package:flutter/material.dart';
import 'package:parking/Widgets/slotdata.dart';
import 'package:parking/Widgets/slotstatus.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parking Area Info',
      theme: ThemeData(
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
  final String _apiUrl = 'http://192.168.50.250:3000/api/status';
  final String _wsUrl = 'ws://192.168.50.250:3000/ws';
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
              throw TimeoutException('請求超時，請檢查網路連線');
            },
          );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = SlotData.fromJson(jsonData);

        setState(() {
          _state = ParkingDataState.success(data);
        });
      } else {
        throw Exception('伺服器返回錯誤: ${response.statusCode}');
      }
    } on SocketException {
      setState(() {
        _state = ParkingDataState.error('無法連接到伺服器，請檢查網路連線');
      });
    } on TimeoutException catch (e) {
      setState(() {
        _state = ParkingDataState.error(e.message ?? '請求超時');
      });
    } on FormatException {
      setState(() {
        _state = ParkingDataState.error('資料格式錯誤');
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
            if (jsonData['type'] != "parkingUpdate") {
              print(
                'Received unexpected WebSocket data type: ${jsonData['type']}, ignoring',
              );
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
        _state = ParkingDataState.error('無法連接到伺服器');
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
                    SlotStatus(state: _state),
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
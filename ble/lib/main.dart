import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// 연결 상태 enum
enum ConnectionState { disconnected, scanning, connecting, connected }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter BLE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: const MyHomePage(title: 'BLE'),
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

  List<ScanResult> scanResults = [];
  List<BluetoothService> services = [];

  BluetoothDevice? selectedDevice;
  ConnectionState connectionState = ConnectionState.disconnected;

  String receivedData = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initBLE();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _disconnectFromDevice();
    super.dispose();
  }

  // 초기화
  void _initBLE() async {
    print("_initBLE");
  }

  // 스캔
  void _startScan() async {
    print("_startScan");
  }

  // 기기 연결
  void _connectToDevice() async {
    print("_connectToDevice");
  }

  // 연결 해제
  void _disconnectFromDevice() async {
    print("_disconnectFromDevice");
  }

  // 서비스 검색
  void _discoverServices() async {
    print("_discoverServices");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: connectionState == ConnectionState.scanning ? () => FlutterBluePlus.stopScan() : () => _startScan,
            icon: Icon(connectionState == ConnectionState.scanning ? Icons.stop : Icons.refresh),
          ),
        ],
      ),
      body: connectionState == ConnectionState.connected ? _buildConnectedDeviceView() : _buildScanResultsList(),
    );
  }
}

// 스캔 결과 목록
Widget _buildScanResultsList() {
  print("_buildScanResultsList");
  return Placeholder();
}

// 연결된 기기 화면
Widget _buildConnectedDeviceView() {
  print("_buildConnectedDeviceView");
  return Placeholder();
}
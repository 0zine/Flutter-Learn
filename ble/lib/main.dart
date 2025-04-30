import 'dart:convert';

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
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        if (connectionState == ConnectionState.disconnected) {
          _startScan();
        }
      } else if (state == BluetoothAdapterState.off) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('블루투스를 켜주세요.')));
      }
    });
  }

  // 스캔
  void _startScan() async {
    print("_startScan");
    setState(() {
      scanResults = [];
      connectionState = ConnectionState.scanning;
    });

    // 이전 스캔 중지
    await FlutterBluePlus.stopScan();

    // 스캔 결과
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    });

    // 스캔 상태
    FlutterBluePlus.isScanning.listen((scanning) {
      if (!scanning && connectionState == ConnectionState.scanning) {
        setState(() {
          connectionState = ConnectionState.disconnected;
        });
      }
    });

    // 새 스캔 시작
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
  }

  // 기기 연결
  void _connectToDevice(BluetoothDevice device) async {
    print("_connectToDevice");
    setState(() {
      connectionState = ConnectionState.connecting;
      selectedDevice = device;
    });

    try {
      await device.connect();

      setState(() {
        connectionState = ConnectionState.connected;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${device.name}에 연결되었습니다.')));

      // 연결 후 서비스 검색
      _discoverServices();
    } catch (e) {
      setState(() {
        connectionState = ConnectionState.disconnected;
        selectedDevice = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${device.name}에 연결할 수 없습니다.(${e.toString()})')),
      );
    }
  }

  // 연결 해제
  void _disconnectFromDevice() async {
    print("_disconnectFromDevice");
    if (selectedDevice != null &&
        connectionState == ConnectionState.connected) {
      await selectedDevice!.disconnect();

      setState(() {
        selectedDevice = null;
        services = [];
        connectionState = ConnectionState.disconnected;
        receivedData = "";
      });
    }
  }

  // 서비스 검색
  void _discoverServices() async {
    print("_discoverServices");
    if (selectedDevice != null) {
      return;
    }

    services = await selectedDevice!.discoverServices();
    setState(() {});

    // 각 서비스의 특성 중 Notify 가능한 특성을 찾아 구독
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.notify) {
          // 해당 특성 구독
          await characteristic.setNotifyValue(true);

          // 데이터 수신
          characteristic.lastValueStream.listen((value) {
            if (value.isNotEmpty) {
              setState(() {
                try {
                  receivedData = utf8.decode(value);
                } catch (e) {
                  receivedData = value
                      .map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}')
                      .join(' ');
                }
              });
            }
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('데이터 수신 준비 완료')));
        }
      }
    }
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
            onPressed:
                connectionState == ConnectionState.scanning
                    ? () => FlutterBluePlus.stopScan()
                    : () => _startScan,
            icon: Icon(
              connectionState == ConnectionState.scanning
                  ? Icons.stop
                  : Icons.refresh,
            ),
          ),
        ],
      ),
      body:
          connectionState == ConnectionState.connected
              ? _buildConnectedDeviceView()
              : _buildScanResultsList(),
    );
  }

  // 스캔 결과 목록
  Widget _buildScanResultsList() {
    print("_buildScanResultsList");
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.blue[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('기기 스캔중')],
          ),
        ),

        //기기 목록
        Expanded(
          child: ListView.builder(
            itemCount: scanResults.length,
            itemBuilder: (context, index) {
              final result = scanResults[index];
              final device = result.device;
              final rssi = result.rssi;

              return ListTile(
                title: Text(
                  device.name.isNotEmpty ? device.name : device.id.toString(),
                ),
                subtitle: Text('RSSI: $rssi'),
                trailing:
                    connectionState == ConnectionState.connecting &&
                            selectedDevice?.id == device.id
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: () => _connectToDevice,
                          child: const Text('연결'),
                        ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 연결된 기기 화면
  Widget _buildConnectedDeviceView() {
    print("_buildConnectedDeviceView");
    return Column(
      children: [
        // 연결된 기기 정보
        Container(
          padding: const EdgeInsets.all(16),
          color: _getConnectionStateColor(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_getConnectionStateText()),
                  Text('ID: ${selectedDevice?.id}'),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _disconnectFromDevice,
                child: const Text('연결 해제'),
              ),
            ],
          ),
        ),

        // 서비스 및 특성 정보
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 수신된 데이터 표시
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '수신된 데이터:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          receivedData.isEmpty ? '데이터를 기다리는 중...' : receivedData,
                        ),
                      ),
                    ],
                  ),
                ),

                // 발견된 서비스 목록
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 16),
                  child: Text(
                    '서비스:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return ExpansionTile(
                      title: Text('서비스: ${service.uuid.toString()}'),
                      children: service.characteristics.map((c) {
                        return ListTile(
                          title: Text('특성: ${c.uuid.toString()}'),
                          subtitle: Text(
                            '속성: ${_getCharacteristicProperties(c)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 특성 속성 문자열 생성
  String _getCharacteristicProperties(BluetoothCharacteristic c) {
    List<String> props = [];
    if (c.properties.broadcast) props.add('Broadcast');
    if (c.properties.read) props.add('Read');
    if (c.properties.writeWithoutResponse) props.add('WriteWithoutResponse');
    if (c.properties.write) props.add('Write');
    if (c.properties.notify) props.add('Notify');
    if (c.properties.indicate) props.add('Indicate');
    if (c.properties.authenticatedSignedWrites) props.add('AuthSignedWrites');
    if (c.properties.extendedProperties) props.add('ExtProps');

    return props.join(', ');
  }

  // 연결 상태별 색상 가져오기
  Color _getConnectionStateColor() {
    switch (connectionState) {
      case ConnectionState.connected:
        return Colors.green[50]!;
      case ConnectionState.connecting:
        return Colors.orange[50]!;
      case ConnectionState.scanning:
        return Colors.blue[50]!;
      case ConnectionState.disconnected:
      default:
        return Colors.grey[50]!;
    }
  }

  // 연결 상태 문자열 가져오기
  String _getConnectionStateText() {
    switch (connectionState) {
      case ConnectionState.connected:
        return '연결됨: ${selectedDevice?.name ?? "Unknown"}';
      case ConnectionState.connecting:
        return '연결 중...';
      case ConnectionState.scanning:
        return '스캔 중...';
      case ConnectionState.disconnected:
      default:
        return '연결 안됨';
    }
  }

}

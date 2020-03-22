/*
main.dart

This is the file that will start the mobile app in the main screen.
This also contains the screens for establishing Bluetooth connection/disconnection

*/

import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:aed_ble_app/widgets.dart';
BluetoothCharacteristic targetCharacteristic;

void main() {
  runApp(FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.redAccent,
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.smartphone,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'AED Cabinet Monitor',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {

  BluetoothDevice targetDevice;
  BluetoothCharacteristic targetCharacteristic;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find AED Monitor Devices'),
        backgroundColor: Colors.redAccent,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .map((d) => ListTile(
                    title: Text(d.name),
                    subtitle: Text(d.id.toString()),
                    trailing: StreamBuilder<BluetoothDeviceState>(
                      stream: d.state,
                      initialData: BluetoothDeviceState.disconnected,
                      builder: (c, snapshot) {
                        if (snapshot.data ==
                            BluetoothDeviceState.connected) {
                          return RaisedButton(
                            child: Text('OPEN'),
                            color: Colors.redAccent,
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DeviceScreen(device: d))),
                          );
                        }
                        return Text(snapshot.data.toString());
                      },
                    ),
                  ))
                      .toList(),
                ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .map(
                        (r) => ScanResultTile(
                      result: r,
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        r.device.connect();
                        return DeviceScreen(device: r.device);
                      })),
                    ),
                  )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.speaker_phone),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 4)),
                backgroundColor: Colors.redAccent
            );
          }
        },
      ),
    );
  }
}

class DeviceScreen extends StatelessWidget {
  DeviceScreen({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;
  final String SERVICE_UUID = "0434f706-7af9-4349-8de8-701c14119b5a";
  final String CHARACTERISTIC_UUID = "d1b6c2fe-b2d4-462d-9509-04d745b79d30";

  TextEditingController moduleController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  writeData(String data) async {
    if (targetCharacteristic == null) return;

    List<int> bytes = utf8.encode(data);
    await targetCharacteristic.write(bytes);
  }

  sleepAction() {
    writeData('SLEEP');
  }

  emailAction() {
    writeData('EMAIL');
  }

  configAction() {
    var configData = '${moduleController.text},${locationController.text}';
    writeData(configData);
  }


  discoverServices() async {

    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristics) {
          if (characteristics.uuid.toString() == CHARACTERISTIC_UUID) {
            targetCharacteristic = characteristics;
          }
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return FlatButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        .copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(

        child: Column(

          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: (snapshot.data == BluetoothDeviceState.connected)
                    ? Icon(Icons.bluetooth_connected)
                    : Icon(Icons.bluetooth_disabled),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data ? 1 : 0,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.settings_remote),
                        onPressed: () => discoverServices(),
                      ),
                      IconButton(
                        icon: SizedBox(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                          ),
                          width: 18.0,
                          height: 18.0,
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: RaisedButton(
                onPressed: sleepAction,
                color: Colors.redAccent,
                child: Text('Enter Sleep Mode'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: RaisedButton(
                onPressed: emailAction,
                color: Colors.redAccent,
                child: Text('Send Test Email'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: moduleController,
                decoration: InputDecoration(labelText: 'Module Number'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: RaisedButton(
                onPressed: configAction,
                color: Colors.redAccent,
                child: Text('Configure'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

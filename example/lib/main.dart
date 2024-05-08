import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:librariesplugin/librariesplugin.dart';
import 'package:librariesplugin_example/widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = '';
  final _librariesPlugin = LibrariesPlugin();

  // Controller - UI
  final inputTTL = TextEditingController();
  final inputServer = TextEditingController();
  final inputAddress = TextEditingController();
  final inputPortEnd = TextEditingController();
  final inputPortStart = TextEditingController();
  var enableTTL = false;
  var visibleTTL = false;
  var enableServer = false;
  var visibleServer = false;
  var enablePort = false;
  var visiblePort = false;
  var visibleProgress = false;
  var executeEnable = true;
  var editEnable = true;

  // Unchanged Values
  final int _initTTL = -1;
  final _initAddress = 'zing.vn';
  final int _startPort = 1;
  final String _dnsServer = "8.8.8.8";

  // Changed Values
  int _currentPort = 1;
  int _endPort = 1023;

  // DropdownList
  String actionValue = 'Ping';
  var actionValues = [
    'Ping',
    'PageLoad',
    'DnsLookup',
    'PortScan',
    'TraceRoute'
  ];

  @override
  void initState() {
    super.initState();
    initInput();
  }

  void initInput() {
    inputAddress.text = _initAddress;
    _result = "";
    executeEnable = true;
    setState(() {
      switch (actionValue) {
        case "TraceRoute":
          enableTTL = true;
          visibleTTL = true;
          enableServer = false;
          visibleServer = false;
          enablePort = false;
          visiblePort = false;
          visibleProgress = false;
          inputTTL.text = "$_initTTL";
          break;
        case "DnsLookup":
          enableTTL = false;
          visibleTTL = false;
          enableServer = true;
          visibleServer = true;
          enablePort = false;
          visiblePort = false;
          visibleProgress = false;
          inputServer.text = "$_dnsServer";
          break;
        case "PortScan":
          enableTTL = false;
          visibleTTL = false;
          enableServer = false;
          visibleServer = false;
          enablePort = true;
          visiblePort = true;
          visibleProgress = false;
          inputPortStart.text = "$_startPort";
          inputPortEnd.text = "$_endPort";
          break;
        default:
          enableTTL = false;
          visibleTTL = false;
          enableServer = false;
          visibleServer = false;
          enablePort = false;
          visiblePort = false;
          visibleProgress = false;
      }
    });
  }

  Future<void> pingState() async {
    // Start process  -------------------------------------------
    setState(() {
      executeEnable = false;
    });

    String pingResult;
    String address =
        (inputAddress.text.isNotEmpty) ? inputAddress.text : _initAddress;
    int ttl = (inputTTL.text.isNotEmpty) ? int.parse(inputTTL.text) : _initTTL;

    // Execute
    try {
      pingResult = await _librariesPlugin.getPingResult(address) ??
          'Invalid Ping Result';
    } on Exception {
      pingResult = 'Failed to get ping result.';
    }

    if (!mounted) return;

    // End process   -------------------------------------------
    setState(() {
      _result = pingResult;
      executeEnable = true;
    });
  }

  Future<void> pageLoadState() async {
    // Start process  -------------------------------------------
    setState(() {
      _result = "";
      executeEnable = false;
      editEnable = false;
    });

    int time = 10;
    String pageLoadResult = "";
    String address =
        (inputAddress.text.isNotEmpty) ? inputAddress.text : _initAddress;

    // Execute
    while (time > 0) {
      if (executeEnable) {
        break;
      } else {
        try {
          pageLoadResult = await _librariesPlugin.getPageLoadResult(address) ??
              'Invalid PageLoad Result';
        } on Exception {
          pageLoadResult = 'Failed to get page load result.';
        }
        if (!mounted) return;
        setState(() {
          _result += pageLoadResult;
        });
        time--;
      }
    }

    // End process   -------------------------------------------
    setState(() {
      executeEnable = true;
      editEnable = true;
    });
  }

  Future<void> dnsLookupState() async {
    // Start process  -------------------------------------------
    setState(() {
      _result = "";
      executeEnable = false;
    });

    String dnsLookupResult = "";
    String address =
        (inputAddress.text.isNotEmpty) ? inputAddress.text : _initAddress;
    // Execute
    try {
      dnsLookupResult = await _librariesPlugin.getDnsLookupResult(address) ??
          'Invalid dnsLookup Result';
    } on Exception {
      dnsLookupResult = 'Failed to get dnsLookup result.';
    }

    if (!mounted) return;
    // End process   -------------------------------------------
    setState(() {
      _result += dnsLookupResult;
      executeEnable = true;
    });
  }

  Future<void> portScanState() async {
    // Initialize
    String portScanResult = "";
    String address =
        (inputAddress.text.isNotEmpty) ? inputAddress.text : _initAddress;
    int start =
        inputPortStart.text.isNotEmpty ? int.parse(inputPortStart.text) : 1;
    int end =
        inputPortEnd.text.isNotEmpty ? int.parse(inputPortEnd.text) : 1023;

    // Start process  -------------------------------------------
    setState(() {
      inputAddress.text = address;
      inputPortStart.text = "$start";
      inputPortEnd.text = "$end";
      editEnable = false;
      executeEnable = false;
      visibleProgress = true;
      _result = "";
    });

    // Execute
    while (start <= end) {
      if (executeEnable) {
        break;
      } else {
        try {
          portScanResult =
              await _librariesPlugin.getPortScanResult(start, address) ??
                  'Invalid PortScan Result';
        } on Exception {
          portScanResult = 'Failed to get PortScan result.';
        }

        setState(() {
          if (portScanResult.isNotEmpty &&
              portScanResult != 'Invalid PortScan Result' &&
              portScanResult != 'Failed to get PortScan result.') {
            _result = _result.contains("Open Port List")
                ? "$_result\n$portScanResult"
                : "Open Port List\n$portScanResult";
          } else if (!_result.contains("Open Port List")) {
            _result = "Not found any opened port";
          } else {}

          _currentPort = start;
          _endPort = end;
        });
        start += 1;
      }
    }

    if (!mounted) return;
    // End process   -------------------------------------------
    setState(() {
      executeEnable = true;
      editEnable = true;
      if (_currentPort < _endPort) {
        _endPort = _currentPort;
        inputPortEnd.text = "$_endPort";
      }
      // visibleProgress = false;
    });
  }

  Future<void> traceRouteState() async {
    // Start process  -------------------------------------------
    setState(() {
      _result = "";
      executeEnable = false;
      visibleProgress = true;
    });
    // Execute

    // End process   -------------------------------------------
    if (!mounted) return;
    setState(() {});
  }

  void callState(String act) {
    switch (act) {
      case "Ping":
        pingState();
        break;
      case "PageLoad":
        pageLoadState();
        break;
      case "DnsLookup":
        dnsLookupState();
      case "PortScan":
        portScanState();
        break;
      case "TraceRoute":
        traceRouteState();
        break;
      default:
        break;
    }
  }

  void onChanged(String? newValue) {
    setState(() {
      actionValue =
          newValue!; // Update the actionValue variable with the newly selected value
      // Call any other methods or update any other variables as needed
      initInput(); // Example: Call initInput method
    });
  }

  void stopExecute(String? p1) {
    setState(() {
      executeEnable = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          // child: Text('Running on: $_platformVersion\n'),
          child: Column(
            children: [
              CustomDropdownButton(
                executeEnable: executeEnable,
                actionValue: actionValue,
                actionValues: actionValues,
                onChanged: onChanged,
              ),
              IpForm(controller: inputAddress),
              TTLForm(
                  visible: visibleTTL,
                  enabled: enableTTL,
                  controller: inputTTL),
              DNSServerForm(
                  visible: visibleServer,
                  enabled: enableServer,
                  inputServer: inputServer),
              PortRangeForm(
                  visible: visiblePort,
                  enabled: enablePort,
                  editEnable: editEnable,
                  inputPortStart: inputPortStart,
                  inputPortEnd: inputPortEnd),
              const SizedBox(height: 30),
              ExecuteButton(
                  executeEnable: executeEnable,
                  actionValue: actionValue,
                  onPressed: callState,
                  stopPressed: stopExecute),
              const SizedBox(height: 12),
              CustomResultWidget(
                visibleProgress: visibleProgress,
                currentPort: _currentPort,
                endPort: _endPort,
                actionValue: actionValue,
                result: _result,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

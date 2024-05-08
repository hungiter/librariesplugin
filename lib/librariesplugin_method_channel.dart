import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'librariesplugin_platform_interface.dart';

/// An implementation of [LibrariespluginPlatform] that uses method channels.
class MethodChannelLibrariesplugin extends LibrariespluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('librariesplugin');

  @override
  Future<PingDTO?> getPingResult(String address) async {
    try {
      var dataToPass = <String, dynamic>{'address': address};
      final jsonResult =
          await methodChannel.invokeMethod<String>('getPingResult', dataToPass);

      if (jsonResult != null) {
        final Map<String, dynamic> parsedJson = json.decode(jsonResult);
        final PingDTO pingDTO = PingDTO.fromJson(parsedJson);
        return pingDTO;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<PageLoadDTO?> getPageLoadResult(String address) async {
    try {
      var dataToPass = <String, dynamic>{'address': address};
      final jsonResult = await methodChannel.invokeMethod<String>(
          'getPageLoadResult', dataToPass);

      if (jsonResult != null) {
        final Map<String, dynamic> parsedJson = json.decode(jsonResult);
        return PageLoadDTO.fromJson(parsedJson);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getDnsLookupResult(String address) async {
    var dataToPass = <String, dynamic>{'address': address};
    final pageLoadResult = await methodChannel.invokeMethod<String>(
        'getDnsLookupResult', dataToPass);
    return pageLoadResult;
  }

  @override
  Future<String?> getPortScanResult(int port, String address) async {
    var dataToPass = <String, dynamic>{
      'address': address,
      'port': port,
    };
    final getPortScanResult = await methodChannel.invokeMethod<String>(
        'getPortScanResult', dataToPass);
    return getPortScanResult;
  }
}

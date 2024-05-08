import 'librariesplugin_platform_interface.dart';

class LibrariesPlugin {
  Future<String?> getPingResult(String address) {
    return LibrariespluginPlatform.instance.getPingResult(address);
  }

  Future<String?> getPageLoadResult(String address) {
    return LibrariespluginPlatform.instance.getPageLoadResult(address);
  }

  Future<String?> getDnsLookupResult(String address) {
    return LibrariespluginPlatform.instance.getDnsLookupResult(address);
  }

  Future<String?> getPortScanResult(int port, String address) {
    return LibrariespluginPlatform.instance
        .getPortScanResult(port, address);
  }
}

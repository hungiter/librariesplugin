import 'data.dart';
import 'librariesplugin_platform_interface.dart';

class LibrariesPlugin {
  Future<PingDTO?> getPingResult(String address) {
    return LibrariespluginPlatform.instance
        .getPingResult(address)
        .then((PingDTO? result) {
      // Check if result is not null
      if (result != null) {
        return result;
      } else {
        return null;
      }
    }).catchError((error) {
      return null;
    });
  }

  Future<PageLoadDTO?> getPageLoadResult(String address) {
    return LibrariespluginPlatform.instance
        .getPageLoadResult(address)
        .then((PageLoadDTO? result) {
      // Check if result is not null
      if (result != null) {
        return result;
      } else {
        return null;
      }
    }).catchError((error) {
      return null;
    });
  }

  Future<String?> getDnsLookupResult(String address) {
    return LibrariespluginPlatform.instance.getDnsLookupResult(address);
  }

  Future<String?> getPortScanResult(int port, String address) {
    return LibrariespluginPlatform.instance.getPortScanResult(port, address);
  }
}

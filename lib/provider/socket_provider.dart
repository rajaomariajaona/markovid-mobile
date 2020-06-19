import 'dart:async';

import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketProvider extends PropertyChangeNotifier<String> {
  io.Socket socket;
  SocketProvider() {
    socket = io.io("http://10.0.2.2:3000", <String, dynamic>{
      'transports': ['websocket'],
    });
    socket.on('changes', (_) {
      notifyListeners("changes");
    });
  }
}

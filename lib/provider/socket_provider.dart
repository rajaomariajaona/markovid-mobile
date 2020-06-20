import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketProvider extends PropertyChangeNotifier<String> {
  io.Socket socket;
  SocketProvider() {
    socket = io.io("https://markovid.herokuapp.com", <String, dynamic>{
      'transports': ['websocket'],
    });
    socket.on('changes', (_) {
      notifyListeners("changes");
    });
  }
}

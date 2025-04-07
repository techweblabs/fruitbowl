// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';

// class ConnectivityService {
//   final Connectivity _connectivity;
//   final StreamController<bool> connectionChangeController = StreamController.broadcast();
  
//   ConnectivityService({Connectivity? connectivity}) 
//       : _connectivity = connectivity ?? Connectivity() {
//     // Initialize the connection status
//     _initConnectivity();
    
//     // Listen for connectivity changes
//     _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
//   }

//   Stream<bool> get connectionChange => connectionChangeController.stream;

//   // Initialize connectivity
//   Future<void> _initConnectivity() async {
//     late ConnectivityResult result;
//     try {
//       result = await _connectivity.checkConnectivity();
//     } catch (e) {
//       return;
//     }
//     return _updateConnectionStatus(result);
//   }

//   // Convert connectivity result to boolean and add to stream
//   Future<void> _updateConnectionStatus(ConnectivityResult result) async {
//     bool isConnected = result != ConnectivityResult.none;
//     connectionChangeController.add(isConnected);
//   }

//   // Check if device is connected to the internet
//   Future<bool> isConnected() async {
//     final result = await _connectivity.checkConnectivity();
//     return result != ConnectivityResult.none;
//   }

//   void dispose() {
//     connectionChangeController.close();
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../utils/firebase_config.dart';

class PresenceService {
  static final PresenceService _instance = PresenceService._internal();
  factory PresenceService() => _instance;
  PresenceService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> goOnline(String workerId) async {
    await _firestore.collection(FirebaseConfig.workersCollection).doc(workerId).update({
      'isOnline': true,
      'lastActive': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> goOffline(String workerId) async {
    await _firestore.collection(FirebaseConfig.workersCollection).doc(workerId).update({
      'isOnline': false,
      'lastActive': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Position?> getCurrentPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> updateLocation({
    required String workerId,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    await _firestore.collection(FirebaseConfig.workersCollection).doc(workerId).update({
      'currentLocation': GeoPoint(latitude, longitude),
      'currentAddress': address,
      'lastActive': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  double calculateDistanceKm(LatLng a, LatLng b) {
    const double earthRadius = 6371; // km
    final double dLat = (b.latitude - a.latitude) * (3.141592653589793 / 180.0);
    final double dLon = (b.longitude - a.longitude) * (3.141592653589793 / 180.0);
    final double la1 = a.latitude * (3.141592653589793 / 180.0);
    final double la2 = b.latitude * (3.141592653589793 / 180.0);

    final double x = (sin(dLat / 2) * sin(dLat / 2)) +
        (sin(dLon / 2) * sin(dLon / 2)) * cos(la1) * cos(la2);
    final double c = 2 * atan2(sqrt(x), sqrt(1 - x));
    return earthRadius * c;
  }
}
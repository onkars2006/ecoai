// lib/screens/map_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  Position? _currentPosition;
  String _currentAddress = "Locating...";
  bool _isLoading = true;
  bool _locationError = false;
  bool _checkingAfterSettings = false;
  final TextEditingController _searchController = TextEditingController();

  static const String _mapsApiKey = 'AIzaSyCKgmnMiSsAKelVX9pwrdoAJW92zFsxTco';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() => _isLoading = true);
    final hasPermission = await _handleLocationPermission();
    
    if (!hasPermission) {
      setState(() {
        _isLoading = false;
        _locationError = true;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
          
      setState(() {
        _currentPosition = position;
        _isLoading = false;
        _locationError = false;
      });
      
      await _getAddressFromLatLng(position);
      await _loadNearbyPlaces(position);
      _centerMap(position);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _locationError = true;
      });
      _showError("Failed to get location: ${e.toString()}");
    }
  }

  Future<bool> _handleLocationPermission() async {
    if (_checkingAfterSettings) {
      await Future.delayed(const Duration(seconds: 1));
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (_checkingAfterSettings) {
        await _showLocationServiceDialog();
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }

  Future<void> _showLocationServiceDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Required'),
          content: const Text('Please enable location services in settings'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (result ?? false) {
      setState(() => _checkingAfterSettings = true);
      await Geolocator.openLocationSettings();
      await _initializeLocation();
      setState(() => _checkingAfterSettings = false);
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            "${place.street}, ${place.locality}, ${place.postalCode}";
      });
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  Future<void> _loadNearbyPlaces(Position position) async {
    const radius = 5000;
    const type = 'electronics_store';

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${position.latitude},${position.longitude}'
      '&radius=$radius'
      '&type=$type'
      '&key=$_mapsApiKey',
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      _updateMarkers(data['results']);
    } catch (e) {
      _showError("Failed to load places");
    }
  }

  void _updateMarkers(List<dynamic> places) {
    _markers.clear();
    for (var place in places) {
      final lat = place['geometry']['location']['lat'];
      final lng = place['geometry']['location']['lng'];
      final markerId = MarkerId(place['place_id']);
      
      _markers.add(Marker(
        markerId: markerId,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: place['name'],
          snippet: place['vicinity'],
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    }
    setState(() {});
  }

  void _centerMap(Position position) {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.0,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_locationError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 50, color: Colors.red),
            const SizedBox(height: 20),
            const Text('Location access required to find recycling centers'),
            const SizedBox(height: 15),
            _buildEnableLocationButton(),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildLocationCard(),
        Expanded(
          child: GoogleMap(
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              zoom: 14.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
        ),
      ],
    );
  }
  Widget _buildEnableLocationButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.location_searching),
      label: const Text('ENABLE LOCATION'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      onPressed: () async {
        setState(() => _isLoading = true);
        await _initializeLocation();
      },
    );
  }


  Widget _buildLocationCard() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: const Icon(Icons.location_pin, color: Colors.blue),
        title: const Text('Current Location'),
        subtitle: Text(_currentAddress),
        trailing: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _initializeLocation(),
        ),
      ),
    );
  }
}
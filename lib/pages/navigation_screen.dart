// import all the packagess required
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' show cos, sqrt, asin; // for calculating the distance between current postion to the destination
import 'search_loc.dart';

class NavigationScreen extends StatefulWidget {
  // get destination detail
  final double lat;
  final double lng;
  NavigationScreen(this.lat, this.lng);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  // declare the variables
  final Completer<GoogleMapController?> _controller = Completer(); // to access the google map
  // the line will be straight but because of the google map api, they provide us the closest direction 
  Map<PolylineId, Polyline> polylines = {}; // the line from source to destination
  PolylinePoints polylinePoints = PolylinePoints(); // polyline can be curved so the path more accurate
  Location location = Location();
  Marker? sourcePosition, destinationPosition; // to add marker for the source and destination
  loc.LocationData? _currentPosition; // update every time we change our location
  LatLng curLocation = LatLng(2.9932, 101.7162); // temporary current location so null error would not occur
  StreamSubscription<loc.LocationData>? locationSubscription; // to stop the location listener so it will not listen forever for the location update and we can go to other screen

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // function
    getNavigation();
    addMarker();
  }

  @override
  void dispose() { // for cancelling the location subscription so it will not run forever
    locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { // interface
    return Scaffold(
      body: sourcePosition == null
          ? Center(child: CircularProgressIndicator())
          : Stack( // stack
              children: [
                // the actual google map
                GoogleMap(
                  zoomControlsEnabled: false,
                  polylines: Set<Polyline>.of(polylines.values),
                  initialCameraPosition: CameraPosition(
                    target: curLocation,
                    zoom: 16,
                  ),
                  markers: {sourcePosition!, destinationPosition!},
                  onTap: (latLng) {
                    print(latLng);
                  },
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
                // button to going back
                Positioned(
                  top: 30,
                  left: 15,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => SearchLoc()), // navigator will push and replace to Search Location
                          (route) => false);
                    },
                    child: Icon(Icons.arrow_back),
                  ),
                ),
                // button at the bottom to launch the navigation from google maps appliction
                Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue),
                      child: Center(
                        child: IconButton(
                          icon: Icon(
                            Icons.navigation_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            await launchUrl(Uri.parse(
                                'google.navigation:q=${widget.lat}, ${widget.lng}&key=AIzaSyCkMM5b1fVPMs64C17SUFboWM_fQngfsug')); // navigation mode, pass lat and long along with api key then google maps will handle it
                          },
                        ),
                      ),
                    ))
              ],
            ),
    );
  }
  // draw polyline
  // show destination
  getNavigation() async {
    // ask for permission
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    final GoogleMapController? controller = await _controller.future; // here access the google map
    location.changeSettings(accuracy: loc.LocationAccuracy.high);
    _serviceEnabled = await location.serviceEnabled();

    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    if (_permissionGranted == loc.PermissionStatus.granted) {
      _currentPosition = await location.getLocation(); // assign current location which is temporary
      curLocation =
          LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
          // start location listener
          // every time location changed, new data obtained
      locationSubscription =
          location.onLocationChanged.listen((LocationData currentLocation) {
        controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition( // here google map can animate to new camera position and provide target for the current location to new position
          target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          zoom: 16,
        )));
        if (mounted) {
          // show the marker and distance
          controller
              ?.showMarkerInfoWindow(MarkerId(sourcePosition!.markerId.value));
          setState(() {
            curLocation =
                LatLng(currentLocation.latitude!, currentLocation.longitude!); // set the new current location that we get from the listener
            sourcePosition = Marker( // update the source position
              markerId: MarkerId(currentLocation.toString()), // marker
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              position:
                  LatLng(currentLocation.latitude!, currentLocation.longitude!),
              infoWindow: InfoWindow(
                  title: '${double.parse(
                          (getDistance(LatLng(widget.lat, widget.lng))
                              .toStringAsFixed(2)))} km'
                     ),
              onTap: () {
                print('market tapped');
              },
            );
          });
          // must inside the listener so every changes will be call and we will get the nearest path
          getDirections(LatLng(widget.lat, widget.lng)); // for drawing polyline
        }
      });
    }
  }

  // pass the source and destination positions from polyline package
  getDirections(LatLng dst) async { // function
    List<LatLng> polylineCoordinates = [];
    List<dynamic> points = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates( // pass the google api key
        'AIzaSyCkMM5b1fVPMs64C17SUFboWM_fQngfsug',
        PointLatLng(curLocation.latitude, curLocation.longitude),
        PointLatLng(dst.latitude, dst.longitude),
        travelMode: TravelMode.driving);
    if (result.points.isNotEmpty) { // get the point
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        points.add({'lat': point.latitude, 'lng': point.longitude});
      });
    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates); // pass the point and add the polyline into the map
  }

  addPolyLine(List<LatLng>polylineCoordinates) {
    PolylineId id = PolylineId('poly'); // how polyline looks
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 5,
    );
    polylines[id] = polyline;
    setState(() {});
  }

   double calculateDistance(lat1, lon1, lat2, lon2) { // to calculate distance between source and destination
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  double getDistance(LatLng destposition) { // pass source and destination and return the value
    return calculateDistance(curLocation.latitude, curLocation.longitude,
        destposition.latitude, destposition.longitude);
  }
  addMarker() {
    setState(() {
      sourcePosition = Marker(
        markerId: MarkerId('source'), // pass the marker id
        position: curLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      destinationPosition = Marker(
        markerId: MarkerId('destination'),
        position: LatLng(widget.lat, widget.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      );
    });
  }
}

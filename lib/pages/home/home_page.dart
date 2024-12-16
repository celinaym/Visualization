import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'pop_up_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(38.922465865598106, -77.09306602680667);
  Set<Marker> markers = {};
  String _sheetTitle = 'Cluster';
  String _sheetDescription = 'Ride Count';
  LatLng _sheetPosition = const LatLng(38.922465865598106, -77.09306602680667);
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final ValueNotifier<double> _sheetStateNotifier = ValueNotifier<double>(0.0);
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final String _regionInfo = 'Wesley Heights';

  @override
  void initState() {
    super.initState();
    _loadCsv();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 0.5).animate(_animationController);
    _sheetController.addListener(() {
      _sheetStateNotifier.value = _sheetController.size;
    });
  }

  Future<BitmapDescriptor> _createCustomMarker(String rideCount) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 100.0; // Marker size

    Paint paint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.text = TextSpan(
      text: rideCount,
      style: const TextStyle(
        fontSize: 30,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final img = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final data = await img.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadCsv() async {
    try {
      final data = await rootBundle.loadString('assets/bike_cluster_data.csv');
      List<List<dynamic>> csvTable = const CsvToListConverter(eol: '\n').convert(data);
      if (csvTable.length > 1) {
        _loadMarkers(csvTable.sublist(1)); // Skip header row
      }
    } catch (e) {
      // Handle error appropriately
    }
  }

  void _loadMarkers(List<List<dynamic>> csvTable) async {
    Set<Marker> loadedMarkers = {};
    for (var row in csvTable) {
      try {
        final clusterLat = double.tryParse(row[1].toString()) ?? 0.0;
        final clusterLng = double.tryParse(row[2].toString()) ?? 0.0;
        final rideCount = int.tryParse(row[3].toString()) ?? 0;

        if (clusterLat != 0.0 && clusterLng != 0.0 && rideCount > 10) {
          final customIcon = await _createCustomMarker(rideCount.toString());
          loadedMarkers.add(
            Marker(
              markerId: MarkerId(row[0].toString()),
              position: LatLng(clusterLat, clusterLng),
              icon: customIcon,
              infoWindow: InfoWindow(
                title: 'Cluster: ${row[0]}',
                snippet: 'Ride Count: $rideCount',
              ),
              onTap: () {
                _moveCamera(
                  LatLng(clusterLat, clusterLng),
                  'Cluster: ${row[0]}',
                  'Ride Count: $rideCount',
                );
              },
            ),
          );
        }
      } catch (e) {
        // Handle error
      }
    }
    setState(() {
      markers = loadedMarkers;
      _isLoading = false;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _moveCamera(LatLng position, String title, String description, {bool triggerSheet = true}) {
    mapController.animateCamera(CameraUpdate.newLatLng(position));
    setState(() {
      _sheetTitle = title;
      _sheetDescription = description;
      _sheetPosition = position;
      _sheetStateNotifier.value = triggerSheet ? 0.3 : 0.0;
    });
    _sheetController.animateTo(0.3, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _closeSheet() {
    setState(() {
      _sheetStateNotifier.value = 0.0;
    });
    _sheetController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ValueListenableBuilder<double>(
          valueListenable: _sheetStateNotifier,
          builder: (context, value, child) {
            return Visibility(
              visible: !_isLoading && value <= 0.75,
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color.fromRGBO(37, 37, 37, 1),
                    size: 30,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _regionInfo,
                    style: const TextStyle(
                      color: Color.fromRGBO(37, 37, 37, 1),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 14.0,
            ),
            markers: markers,
          ),
          CustomButtons(
            onButtonPressed: (label) {
              // 버튼 클릭 이벤트 처리
              print('$label 버튼 클릭됨');
            },
          ),
          PopUpSheet(
            sheetController: _sheetController,
            sheetStateNotifier: _sheetStateNotifier,
            sheetTitle: _sheetTitle,
            sheetDescription: _sheetDescription,
            closeSheet: _closeSheet,
          ),
          if (_isLoading)
            AnimatedOpacity(
              opacity: _isLoading ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                color: const Color.fromRGBO(253, 245, 235, 1), // base color
                child: Center(
                  child: FadeTransition(
                    opacity: _animation,
                    child: const Text(
                      'Loading Markers...',
                      style: TextStyle(
                        fontSize: 24.0,
                        color: Color.fromRGBO(37, 37, 37, 1), // highlight color
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomButtons extends StatelessWidget {
  final Function(String) onButtonPressed;

  const CustomButtons({Key? key, required this.onButtonPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50, // 위치 조정
      right: 16,
      child: Row(
        children: [
          _buildButton(
            label: 'Rental Rate',
            color: Colors.grey[300]!,
            textColor: Colors.black,
            onPressed: () => onButtonPressed('Rental Rate'),
          ),
          const SizedBox(width: 8),
          _buildButton(
            label: 'No. of Bike',
            color: Colors.red[400]!,
            textColor: Colors.white,
            onPressed: () => onButtonPressed('No. of Bike'),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.circle, size: 10, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const washington_regions = {
  "Western Washington": {
    "King County": {
      "Seattle": {"lat": 47.6062, "lng": -122.3321},
      "Bellevue": {"lat": 47.6101, "lng": -122.2015},
      "Redmond": {"lat": 47.6738, "lng": -122.1215},
    },
    "Pierce County": {
      "Tacoma": {"lat": 47.2529, "lng": -122.4443},
      "Puyallup": {"lat": 47.1854, "lng": -122.2929},
      "Lakewood": {"lat": 47.1718, "lng": -122.5185},
    },
  },
  "Eastern Washington": {
    "Spokane County": {
      "Spokane": {"lat": 47.6588, "lng": -117.4260},
      "Spokane Valley": {"lat": 47.6732, "lng": -117.2394},
    },
    "Yakima County": {
      "Yakima": {"lat": 46.6021, "lng": -120.5059},
      "Sunnyside": {"lat": 46.3237, "lng": -120.0081},
    },
  },
};

class RegionSelectionPage extends StatefulWidget {
  final String? initialSelectedRegion;

  RegionSelectionPage({this.initialSelectedRegion});

  @override
  _RegionSelectionPageState createState() => _RegionSelectionPageState();
}

class _RegionSelectionPageState extends State<RegionSelectionPage> {
  String? selectedRegion;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    selectedRegion = widget.initialSelectedRegion;
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Region'),
      ),
      body: Column(
        children: [
          if (selectedRegion != null)
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Selected Region: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Hero(
                    tag: 'selectedRegion',
                    child: Text(
                      selectedRegion!,
                      style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: washington_regions.entries.where((region) {
                final regionName = region.key.toLowerCase();
                final matchesRegion = regionName.contains(searchQuery.toLowerCase());
                final matchesDistrict = region.value.entries.any((district) {
                  final districtName = district.key.toLowerCase();
                  final matchesDistrictName = districtName.contains(searchQuery.toLowerCase());
                  final matchesNeighborhood = district.value.entries.any((neighborhood) {
                    final neighborhoodName = neighborhood.key.toLowerCase();
                    return neighborhoodName.contains(searchQuery.toLowerCase());
                  });
                  return matchesDistrictName || matchesNeighborhood;
                });
                return matchesRegion || matchesDistrict;
              }).map((region) {
                return ExpansionTile(
                  title: Text(
                    region.key,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: region.value.entries.where((district) {
                    final districtName = district.key.toLowerCase();
                    final matchesDistrictName = districtName.contains(searchQuery.toLowerCase());
                    final matchesNeighborhood = district.value.entries.any((neighborhood) {
                      final neighborhoodName = neighborhood.key.toLowerCase();
                      return neighborhoodName.contains(searchQuery.toLowerCase());
                    });
                    return matchesDistrictName || matchesNeighborhood;
                  }).map((district) {
                    return ExpansionTile(
                      title: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          district.key,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      children: district.value.entries.where((neighborhood) {
                        final neighborhoodName = neighborhood.key.toLowerCase();
                        return neighborhoodName.contains(searchQuery.toLowerCase());
                      }).map((neighborhood) {
                        return ListTile(
                          title: Padding(
                            padding: const EdgeInsets.only(left: 32.0),
                            child: Text(
                              neighborhood.key,
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                          ),
                          onTap: () {
                            final latLng = LatLng(
                              neighborhood.value['lat'] ?? 0.0,
                              neighborhood.value['lng'] ?? 0.0,
                            );
                            setState(() {
                              selectedRegion = neighborhood.key;
                            });
                            Get.back(result: {
                              'title': neighborhood.key,
                              'latLng': latLng,
                            });
                          },
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
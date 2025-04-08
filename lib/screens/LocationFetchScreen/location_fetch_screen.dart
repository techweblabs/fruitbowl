import 'package:flutter/material.dart';
import 'components/location_fetch_screen_body.dart';

class LocationFetchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('LocationFetchScreen'),
      // ),
      body: LocationFetchScreenBody(),
    );
  }
}

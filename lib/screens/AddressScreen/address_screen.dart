
import 'package:flutter/material.dart';
import 'components/address_screen_body.dart';

class AddressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AddressScreen'),
      ),
      body: AddressScreenBody(),
    );
  }
}
    
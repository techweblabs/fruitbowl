// import 'package:flutter/material.dart';
// import 'package:flutter_starter_kit/providers/apiProvider.dart';
// import 'package:provider/provider.dart';

// class AddAddressPageDetails extends StatefulWidget {
//   @override
//   _AddAddressPageDetailsState createState() => _AddAddressPageDetailsState();
// }

// class _AddAddressPageDetailsState extends State<AddAddressPageDetails> {
//   final _formKey = GlobalKey<FormState>();

//   // Controllers for text fields
//   final TextEditingController _addressTypeController = TextEditingController();
//   final TextEditingController _fullAddressController = TextEditingController();
//   final TextEditingController _flatNumberController = TextEditingController();
//   final TextEditingController _landmarkController = TextEditingController();
//   final TextEditingController _areaController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _stateController = TextEditingController();
//   final TextEditingController _pincodeController = TextEditingController();
//   final TextEditingController _deliveryInstructionsController =
//       TextEditingController();
//   final TextEditingController _latitudeController = TextEditingController();
//   final TextEditingController _longitudeController = TextEditingController();

//   // Variables for checkbox states
//   bool _leaveAtDoor = false;
//   bool _avoidCalling = false;
//   bool _isDefault = false;

//   @override
//   void dispose() {
//     // Dispose controllers to free up resources
//     _addressTypeController.dispose();
//     _fullAddressController.dispose();
//     _flatNumberController.dispose();
//     _landmarkController.dispose();
//     _areaController.dispose();
//     _cityController.dispose();
//     _stateController.dispose();
//     _pincodeController.dispose();
//     _deliveryInstructionsController.dispose();
//     _latitudeController.dispose();
//     _longitudeController.dispose();
//     super.dispose();
//   }

//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       final varpro = Provider.of<apiProvider>(context, listen: false);
//       varpro.latitude = _latitudeController.text.toString();
//       varpro.longitude = _longitudeController.text.toString();
//       varpro.landmark = _landmarkController.text.toString();
//       varpro.addressType = _addressTypeController.text.toString();
//       varpro.fullAddress = _fullAddressController.text.toString();
//       varpro.flatNumber = _flatNumberController.text.toString();
//       varpro.area = _areaController.text.toString();
//       varpro.city = _cityController.text.toString();
//       varpro.state = _stateController.text.toString();
//       varpro.pincode = _pincodeController.text.toString();
//       varpro.deliveryPreference =
//           _deliveryInstructionsController.text.toString();
//       varpro.isDefault = _isDefault;
//       varpro.AddAddress();

//       // Here, you can send 'addressData' to your backend or use it as needed

//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   SnackBar(content: Text('Address Saved Successfully')),
//       // );

//       // Optionally, navigate back or to another page
//       // Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Add New Address')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               _buildTextField(
//                   _addressTypeController, 'Address Type', 'Enter address type'),
//               _buildTextField(
//                   _fullAddressController, 'Full Address', 'Enter full address'),
//               _buildTextField(
//                   _flatNumberController, 'Flat Number', 'Enter flat number'),
//               _buildTextField(
//                   _landmarkController, 'Landmark', 'Enter landmark'),
//               _buildTextField(_areaController, 'Area', 'Enter area'),
//               _buildTextField(_cityController, 'City', 'Enter city'),
//               _buildTextField(_stateController, 'State', 'Enter state'),
//               _buildTextField(_pincodeController, 'Pincode', 'Enter pincode',
//                   isNumeric: true),
//               _buildCheckbox('Leave At Door', _leaveAtDoor, (value) {
//                 setState(() {
//                   _leaveAtDoor = value!;
//                 });
//               }),
//               _buildCheckbox('Avoid Calling', _avoidCalling, (value) {
//                 setState(() {
//                   _avoidCalling = value!;
//                 });
//               }),
//               _buildTextField(_deliveryInstructionsController,
//                   'Delivery Instructions', 'Enter delivery instructions'),
//               _buildCheckbox('Set as Default Address', _isDefault, (value) {
//                 setState(() {
//                   _isDefault = value!;
//                 });
//               }),
//               _buildTextField(_latitudeController, 'Latitude', 'Enter latitude',
//                   isNumeric: true),
//               _buildTextField(
//                   _longitudeController, 'Longitude', 'Enter longitude',
//                   isNumeric: true),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _submitForm,
//                 child: Text('Save Address'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//       TextEditingController controller, String label, String hint,
//       {bool isNumeric = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
//         decoration: InputDecoration(
//           labelText: label,
//           hintText: hint,
//           border: OutlineInputBorder(),
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Please enter $label';
//           }
//           return null;
//         },
//       ),
//     );
//   }

//   Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
//     return CheckboxListTile(
//       title: Text(title),
//       value: value,
//       onChanged: onChanged,
//       controlAffinity: ListTileControlAffinity.leading,
//     );
//   }
// }

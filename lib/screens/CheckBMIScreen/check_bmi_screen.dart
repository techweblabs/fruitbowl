// import 'package:flutter/material.dart';
// import 'components/check_bmi_screen_body.dart';

// class CheckBMI extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pop(context, true);
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           leading: GestureDetector(
//             onTap: () {
//               Navigator.pop(context, true);
//             },
//             child: Container(
//               margin: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.black, width: 2),
//                 boxShadow: const [
//                   BoxShadow(offset: Offset(2, 2), color: Colors.black)
//                 ],
//               ),
//               child: const Icon(Icons.arrow_back, color: Colors.black),
//             ),
//           ),
//         ),
//         body: const CheckBMIBody(),
//       ),
//     );
//   }
// }

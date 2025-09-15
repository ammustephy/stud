// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// /////////////////////////////////BusDetailsPage//////////////////////////////////////////////////////////
//
// class BusRoute {
//   final String id, busNumber, routeName, driver, driverPhone,
//       conductor, conductorPhone, pickupTime, dropTime, fare, status;
//   final List<Stop> stops;
//
//   BusRoute({
//     required this.id,
//     required this.busNumber,
//     required this.routeName,
//     required this.driver,
//     required this.driverPhone,
//     required this.conductor,
//     required this.conductorPhone,
//     required this.pickupTime,
//     required this.dropTime,
//     required this.fare,
//     required this.status,
//     required this.stops,
//   });
// }
//
// final List<BusRoute> mockBusRoutes = [
//   BusRoute(
//     id: '1',
//     busNumber: 'BUS-001',
//     routeName: 'Route A - North District',
//     driver: 'John Driver',
//     driverPhone: '+1234567890',
//     conductor: 'Mary Conductor',
//     conductorPhone: '+1234567891',
//     pickupTime: '07:30 AM',
//     dropTime: '03:45 PM',
//     stops: [
//       Stop(name: 'North Station', time: '07:30 AM'),
//       Stop(name: 'Central Park', time: '07:45 AM'),
//       Stop(name: 'Main Street', time: '08:00 AM'),
//       Stop(name: 'School Gate', time: '08:15 AM'),
//     ],
//     fare: '\$25/month',
//     status: 'active',
//   ),
//   BusRoute(
//     id: '2',
//     busNumber: 'BUS-002',
//     routeName: 'Route B - East District',
//     driver: 'Mike Wilson',
//     driverPhone: '+1234567892',
//     conductor: 'Sarah Johnson',
//     conductorPhone: '+1234567893',
//     pickupTime: '07:45 AM',
//     dropTime: '04:00 PM',
//     stops: [
//       Stop(name: 'East Plaza', time: '07:45 AM'),
//       Stop(name: 'Market Square', time: '08:00 AM'),
//       Stop(name: 'Library Corner', time: '08:10 AM'),
//       Stop(name: 'School Gate', time: '08:25 AM'),
//     ],
//     fare: '\$30/month',
//     status: 'active',
//   ),
// ];
//
//
// class Stop {
//   final String name, time;
//   Stop({required this.name, required this.time});
// }
//
//
// enum Page { home, busDetails }
//
//
// class NavigationCubit extends Cubit<Page> {
//   NavigationCubit() : super(Page.home);
//   void goHome() => emit(Page.home);
//   void goBusDetails() => emit(Page.busDetails);
// }
//
//
//
//
//
// class BusDetailsPage extends StatelessWidget {
//   final List<BusRoute> routes = mockBusRoutes; // your model data
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => context.read<NavigationCubit>().goHome(),
//         ),
//         title: Row(
//           children: [Icon(Icons.directions_bus), SizedBox(width: 8), Text('School Bus Details')],
//         ),
//       ),
//       body: ListView(padding: EdgeInsets.all(16), children: [
//         ...routes.map((route) => Card(
//           margin: EdgeInsets.only(bottom: 16),
//           child: Padding(
//             padding: EdgeInsets.all(12),
//             child: Column(children: [
//               // Header
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Text(route.busNumber, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                     Text(route.routeName, style: TextStyle(color: Colors.grey[600])),
//                   ]),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
//                     child: Text(route.status.toUpperCase(), style: TextStyle(color: Colors.green[700])),
//                   )
//                 ],
//               ),
//
//               SizedBox(height: 12),
//               // Timing
//               Row(children: [
//                 Expanded(child: _timeInfo(Icons.access_time, 'Morning Pickup', route.pickupTime, Colors.blue)),
//                 SizedBox(width: 16),
//                 Expanded(child: _timeInfo(Icons.access_time, 'Evening Drop', route.dropTime, Colors.orange)),
//               ]),
//
//               SizedBox(height: 12),
//               // Stops
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Row(children: [Icon(Icons.location_on), SizedBox(width: 4), Text('Route Stops', style: TextStyle(fontWeight: FontWeight.w500))]),
//                 ...route.stops.map((stop) => Padding(
//                   padding: EdgeInsets.symmetric(vertical: 4),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle)), SizedBox(width: 6), Text(stop.name)]),
//                       Text(stop.time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//                     ],
//                   ),
//                 )),
//               ]),
//
//               SizedBox(height: 12),
//               // Staff
//               Row(children: [
//                 Expanded(child: _staffInfo(context, 'Driver', route.driver, route.driverPhone)),
//                 SizedBox(width: 16),
//                 Expanded(child: _staffInfo(context, 'Conductor', route.conductor, route.conductorPhone)),
//               ]),
//
//               SizedBox(height: 12),
//               // Fare & Action
//               Divider(),
//               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Text('Monthly Fare', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//                   Text(route.fare, style: TextStyle(fontSize: 16, color: Colors.green[600])),
//                 ]),
//                 OutlinedButton.icon(
//                   onPressed: () => _trackBus(route.id),
//                   icon: Icon(Icons.location_on),
//                   label: Text('Track Bus'),
//                 ),
//               ])
//             ]),
//           ),
//         )),
//         // Emergency Contacts card
//         Card(
//           color: Colors.red[50],
//           child: Padding(
//             padding: EdgeInsets.all(12),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700])),
//               SizedBox(height: 12),
//               _contactRow(context, 'Transport Office', '+1234567800'),
//               SizedBox(height: 8),
//               _contactRow(context, 'School Office', '+1234567801'),
//             ]),
//           ),
//         ),
//       ]),
//     );
//   }
//
//   Widget _contactRow(BuildContext context, String label, String phone) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label),
//         OutlinedButton.icon(
//           onPressed: () {
//             // You can integrate direct dialing via url_launcher for production
//             debugPrint('Calling $phone...');
//           },
//           icon: Icon(Icons.phone, size: 16),
//           label: Text(phone),
//         ),
//       ],
//     );
//   }
//
//
//   Widget _timeInfo(IconData icon, String label, String time, Color color) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//       SizedBox(height: 4),
//       Row(children: [Icon(icon, size: 16, color: color), SizedBox(width: 4), Text(time, style: TextStyle(fontWeight: FontWeight.w500))])
//     ]);
//   }
//
//   Widget _staffInfo(BuildContext context, String role, String name, String phone) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Text(role, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
//       SizedBox(height: 4),
//       Row(children: [Icon(Icons.person, size: 16, color: Colors.grey[600]), SizedBox(width: 4), Text(name)]),
//       SizedBox(height: 4),
//       OutlinedButton.icon(
//         onPressed: () => _call(phone),
//         icon: Icon(Icons.phone, size: 16),
//         label: Text('Call'),
//         style: OutlinedButton.styleFrom(minimumSize: Size.fromHeight(32)),
//       ),
//     ]);
//   }
//
//   void _call(String phone) {
//     debugPrint('Calling $phone...');
//   }
//
//   void _trackBus(String id) {
//     debugPrint('Tracking bus $id...');
//   }
// }

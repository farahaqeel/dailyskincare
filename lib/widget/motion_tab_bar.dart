// import 'package:flutter/material.dart';
// import 'package:motion_tab_bar/MotionTabBar.dart';
// import 'package:dailyskincare/screens/todo_list.dart';
// import 'package:dailyskincare/screens/notifications.dart';
// import 'package:dailyskincare/screens/home_screens.dart';

// class BottomBar extends StatefulWidget {
//   const BottomBar({Key? key}) : super(key: key);

//   @override
//   _BottomBarState createState() => _BottomBarState();
// }

// class _BottomBarState extends State<BottomBar> {
//   int _motionTabBarIndex = 0;

//   final screens = [
//     const HomePage(),
//      const ToDoListPage(),
//     const NotificationPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _motionTabBarIndex, // Show selected tab content
//         children: screens,
//       ),
//       bottomNavigationBar: MotionTabBar(
//         labels: const ["Beranda", "Daftar-List", "Notifikasi"],
//         initialSelectedTab: "Beranda",
//         tabIconColor: Colors.purple,
//         tabSelectedColor: Colors.purpleAccent,
//         icons: const [Icons.home, Icons.list, Icons.notifications],
//         textStyle: const TextStyle(color: Colors.purple),
//         onTabItemSelected: (index) {
//           setState(() {
//             _motionTabBarIndex = index;
//           });
//         },
//       ),
//     );
//   }
// }



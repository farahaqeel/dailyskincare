import 'package:dailyskincare/screens/notifications.dart';
import 'package:dailyskincare/screens/todo_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dailyskincare/controller/bottom_nav_controller.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';

import '../screens/home_screens.dart';  // Pastikan controller diimpor

class MotionTabBarPage extends StatelessWidget {
  MotionTabBarPage({super.key});
  final BottomNavController bottomNavController =
      Get.put(BottomNavController());

  final screens = [
    const HomePage(),  // Pastikan HomePage sudah terdefinisi
    const ToDoListPage(),
    const NotificationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: bottomNavController.selectedIndex.value, // Show selected tab content
        children: screens,
      )),
      bottomNavigationBar: MotionTabBar(
        labels: const ["Beranda", "Daftar-List", "Notifikasi"],
        initialSelectedTab: "Beranda",
        tabIconColor:  Color.fromARGB(255, 127, 1, 139),
        tabSelectedColor: Color.fromARGB(255, 127, 1, 139),
        icons: const [Icons.home, Icons.list, Icons.notifications],
        textStyle: const TextStyle(color: Color.fromARGB(255, 127, 1, 139)),
        onTabItemSelected: (index) {
            bottomNavController.changeIndex(index);
          },
        ),
      );
  }
}


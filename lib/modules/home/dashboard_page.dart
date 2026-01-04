import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../scan/scan_page.dart';
import '../help/help_page.dart';
import 'home_view.dart'; 

class DashboardController extends GetxController {
  var tabIndex = 0.obs;

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.put(DashboardController());

    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.tabIndex.value,
        children: const [
          HomeView(),  
          ScanPage(),  
          HelpPage(),  
        ],
      )),
      
      
      bottomNavigationBar: Obx(() => NavigationBar(
        height: 70,
        elevation: 0,
        selectedIndex: controller.tabIndex.value,
        onDestinationSelected: controller.changeTabIndex,
        backgroundColor: Colors.white,
        indicatorColor: Colors.teal.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.teal),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.center_focus_weak_outlined),
            selectedIcon: Icon(Icons.center_focus_strong, color: Colors.teal),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.help_outline),
            selectedIcon: Icon(Icons.help, color: Colors.teal),
            label: 'Bantuan',
          ),
        ],
      )),
    );
  }
}
import 'package:flutter/material.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({
    super.key,
    required this.tabController,
    required this.currentTabIndex,
  });

  final TabController tabController;
  final int currentTabIndex;

  Widget buildTab({
    required String key,
    required String title,
    required IconData icon,
    required int tabIndex,
  }) {
    return Tab(
      key: Key(key),
      height: 64,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 30,
            child: IconButton(
              onPressed: null,
              padding: const EdgeInsets.only(top: 5),
              icon: Icon(
                icon,
                color:
                    currentTabIndex == tabIndex ? Colors.white : Colors.white70,
              ),
            ),
          ),
          Text(title),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: TabBar(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorPadding: const EdgeInsets.symmetric(vertical: 10),
        controller: tabController,
        tabs: [
          buildTab(
            key: 'disconnected',
            title: 'Disconnected',
            icon: Icons.link_off,
            tabIndex: 0,
          ),
          buildTab(
            key: 'connected',
            title: 'Connected',
            icon: Icons.link,
            tabIndex: 1,
          ),
        ],
      ),
    );
  }
}

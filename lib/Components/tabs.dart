import '../constants/colors.dart';
// import '../screens/graph.dart';
import 'package:flutter/material.dart';

class TabBarDemo extends StatelessWidget {
  const TabBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            title: const Text('Tabs Demo'),
          ),
          body: Column(
        children: [
          // TabBar is placed at the top
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            margin: EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,  // White background for the selected tab
              borderRadius: BorderRadius.circular(20),  // Optional rounded corners
            ),
            child:  TabBar(
              dividerHeight: 0,
              indicator: BoxDecoration(
                color: AppColors.backgroundColor,  // Custom color for indicator
                borderRadius: BorderRadius.circular(10),  // Optional rounded corners
              ),
              //isScrollable: true,
              indicatorColor: AppColors.darkMainColor,  // Custom color for indicator
              labelColor: AppColors.darkMainColor,  // Custom color for label
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car),
                      Text("Car"),
                    ],
                  ),
                ),
                Tab(
                  icon: Icon(Icons.directions_transit),
                ),
                Tab(
                  icon: Icon(Icons.directions_bike),
                ),
              ],
            ),
          ),
          // TabBarView is placed below the TabBar, made scrollable
          Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Icon(Icons.directions_car),
                      Text('Car tab content'),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Icon(Icons.directions_transit),
                      Text('Transit tab content'),
                    ],
                  ),
                ),
                //GraphScreen()
              ],
            ),
          ),
        ],
      ),
          ),
        ),
    );
  }
}
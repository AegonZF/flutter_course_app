import 'package:flutter/material.dart';
import 'package:flutter_course_app/Screens/Home%20Screen/create_poll_screen.dart';
import 'package:page_transition/page_transition.dart';

class HomeShowPollScreen extends StatefulWidget {
  const HomeShowPollScreen({super.key});

  @override
  State<HomeShowPollScreen> createState() => _HomeShowPollScreenState();
}

class _HomeShowPollScreenState extends State<HomeShowPollScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Poll'),
          centerTitle: true,
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.settings))],
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Colors.amberAccent,
            unselectedLabelColor: Colors.black,
            labelStyle: TextStyle(
              color: Colors.orange,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Posted'),
              Tab(text: 'Voted'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Container(child: Text('All Poll')),
            Container(child: Text('All Poll')),
            Container(child: Text('All Poll')),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: CreatePollScreen(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course_app/Screens/Home%20Screen/create_poll_screen.dart';
import 'package:page_transition/page_transition.dart';

class HomeShowPollScreen extends StatefulWidget {
  const HomeShowPollScreen({super.key});

  @override
  State<HomeShowPollScreen> createState() => _HomeShowPollScreenState();
}

class _HomeShowPollScreenState extends State<HomeShowPollScreen> {
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
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
            if (_currentUserId != null) {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: CreatePollScreen(currentUserId: _currentUserId!),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please sign in to create a poll'),
                ),
              );
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

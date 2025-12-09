import 'dart:io' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course_app/Screens/Home%20Screen/create_poll_screen.dart';
import 'package:flutter_course_app/Screens/Home%20Screen/edit_poll_screen.dart';
import 'package:flutter_course_app/Screens/signin_screen.dart';
import 'package:flutter_course_app/helper/database_helper.dart';
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
          actions: [
            IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SigninScreen()),
                );
              },
              icon: Icon(Icons.settings),
            ),
          ],
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
          children: [_buildAllPolls(), _buildPostedPolls(), _buildVotedPolls()],
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

  Widget _buildPostedPolls() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getPostedPolls(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.orange));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No posted poll available',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        final polls = snapshot.data!;
        return ListView.builder(
          itemCount: polls.length,
          itemBuilder: (context, index) {
            final poll = polls[index];
            return _buildLocalPollCard(poll);
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getPostedPolls() async {
    final localPolls = await DatabaseHelper().getLocalPolls(_currentUserId!);
    final onlineSnapshot = await FirebaseFirestore.instance
        .collection('polls')
        .where('creatorId', isEqualTo: _currentUserId)
        .get();

    final onlinePolls = onlineSnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      data['isLocal'] = false;
      return data;
    }).toList();

    final localPollsFormatted = localPolls.map((poll) {
      poll['isLocal'] = true;
      return poll;
    }).toList();

    return [...localPollsFormatted, ...onlinePolls];
  }

  Widget _buildAllPolls() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('polls')
          .where('creatorId', isNotEqualTo: _currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: Colors.orange));
        }
        final polls = snapshot.data!.docs;
        return polls.isEmpty
            ? Center(
                child: Text(
                  'No poll available',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: polls.length,
                itemBuilder: (context, index) {
                  final poll = polls[index];
                  return _buildPollCard(poll, showUserVote: true);
                },
              );
      },
    );
  }

  Widget _buildPollCard(DocumentSnapshot poll, {bool showUserVote = false}) {
    final data = poll.data() as Map<String, dynamic>;
    final options = data['options'] as List<dynamic>;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      data['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                color: Colors.orangeAccent,
                thickness: 1,
                height: 20,
              ),
              SizedBox(height: 10),
              ...[
                for (var i = 0; i < options.length; i++)
                  Container(
                    margin: EdgeInsets.symmetric(),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          spreadRadius: 1,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            options[i]['imageUrl'],
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                options[i]['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: (options[i]['votes'] ?? 0.0) / 10,
                                color: Colors.orange,
                                backgroundColor: Colors.grey[300],
                              ),
                              if (showUserVote &&
                                  options[i]['voters'] != null &&
                                  (options[i]['voters'] as List).contains(
                                    _currentUserId,
                                  ))
                                Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    'You voted',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        if (showUserVote)
                          ElevatedButton(
                            onPressed: () {
                              handleVote(poll.id, i, context, _currentUserId!);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: Text(
                              'Vote',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
              SizedBox(height: 5),
              if (!showUserVote)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPollScreen(poll: poll),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit, color: Colors.orange),
                      label: Text(
                        'Edit',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                    SizedBox(width: 5),
                    TextButton.icon(
                      onPressed: () {
                        deletePoll(poll.id, context);
                      },
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocalPollCard(Map<String, dynamic> pollData) {
    final isLocal = pollData['isLocal'] ?? false;
    final options = pollData['options'] as List<dynamic>;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      pollData['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (isLocal)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const Divider(
                color: Colors.orangeAccent,
                thickness: 1,
                height: 20,
              ),
              SizedBox(height: 10),
              ...List.generate(options.length, (i) {
                final option = options[i];
                final imageUrl = option['imageUrl'] as String?;

                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imageUrl.startsWith('http')
                              ? Image.network(
                                  imageUrl,
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    );
                                  },
                                )
                              : Image.file(
                                  io.File(imageUrl),
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                        )
                      else
                        Icon(Icons.image, size: 50, color: Colors.grey),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          option['name'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (isLocal)
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'This poll will be uploaded when you have internet connection',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVotedPolls() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('polls').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        }
        final polls = snapshot.data!.docs;

        final votedPolls = polls.where((poll) {
          final options = poll['options'] as List<dynamic>;
          // Check if the current user is in any of the 'voters' list
          for (var option in options) {
            if (option['voters'] != null &&
                (option['voters'] as List).contains(_currentUserId)) {
              return true;
            }
          }
          return false;
        }).toList();
        return votedPolls.isEmpty
            ? const Center(
                child: Text(
                  'No Voted Poll Available',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: votedPolls.length,
                itemBuilder: (context, index) {
                  final poll = votedPolls[index];
                  return _buildPollCard(poll, showUserVote: true);
                },
              );
      },
    );
  }

  Future<void> deletePoll(String pollId, BuildContext context) async {
    try {
      DocumentSnapshot pollDoc = await FirebaseFirestore.instance
          .collection('polls')
          .doc(pollId)
          .get();
      if (pollDoc.exists) {
        List<dynamic> options = pollDoc['options'] ?? [];
        for (var option in options) {
          if (option['imageUrl'] != null) {
            String imageUrl = option['imageUrl'];
            String? filepath = Uri.decodeFull(
              Uri.parse(imageUrl).pathSegments.lastWhere(
                (element) => element.contains('poll'),
                orElse: () => '',
              ),
            );
            if (filepath != null && filepath.isNotEmpty) {
              await FirebaseStorage.instance.ref(filepath).delete();
            }
          }
        }
        await FirebaseFirestore.instance
            .collection('polls')
            .doc(pollId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Poll and associated images deleted successfully'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting poll $e')));
    }
  }

  Future<void> handleVote(
    String pollId,
    int optionIndex,
    BuildContext context,
    String currentUserId,
  ) async {
    try {
      final pollDoc = FirebaseFirestore.instance
          .collection('polls')
          .doc(pollId);
      final pollSnapshot = await pollDoc.get();
      if (pollSnapshot.exists) {
        final data = pollSnapshot.data() as Map<String, dynamic>;
        final totalVotes = data['total_votes'];
        final options = data['options'] as List<dynamic>;

        for (var option in options) {
          if (option['voters'] != null &&
              (option['voters'] as List).contains(currentUserId)) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('You have already voted')));
            return;
          }
        }
        final voters = options[optionIndex]['voters'] ?? [];
        voters.add(currentUserId);
        options[optionIndex]['voters'] = voters;

        options[optionIndex]['votes'] =
            (options[optionIndex]['votes'] ?? 0) + 1;
        await pollDoc.update({'options': options});
        await pollDoc.update({'total_votes': totalVotes + 1});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vote submitted successfully!!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit vote')));
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course_app/Provider/poll_provider.dart';
import 'package:provider/provider.dart';

class EditPollScreen extends StatefulWidget {
  final DocumentSnapshot poll;
  const EditPollScreen({super.key, required this.poll});

  @override
  State<EditPollScreen> createState() => _EditPollScreenState();
}

class _EditPollScreenState extends State<EditPollScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PollProvider>(context, listen: false);
    provider.initializePoll(widget.poll);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PollProvider>(
      builder: (_, pollProvider, child) {
        return Scaffold(
          appBar: AppBar(title: Text('Edit Poll'), centerTitle: true),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: pollProvider.titleController,
                    decoration: InputDecoration(labelText: 'Poll Title'),
                  ),
                ),
                for (int i = 0; i < 3; i++)
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: pollProvider.optionNameControllers[i],
                            decoration: InputDecoration(
                              labelText: 'Option ${i + 1} Name',
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        GestureDetector(
                          onTap: () {
                            pollProvider.pickImage(i);
                          },
                          child: pollProvider.optionImages[i] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    pollProvider.optionImages[i]!,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : pollProvider.existingImages?[i] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    pollProvider.existingImages![i],
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  height: 50,
                                  width: 50,
                                  child: Icon(Icons.image),
                                ),
                        ),
                      ],
                    ),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () {
                    pollProvider.updatePoll(widget.poll.id, context);
                  },
                  child: Text(
                    'Edit Poll',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

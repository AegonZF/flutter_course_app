import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditPollScreen extends StatefulWidget {
  final DocumentSnapshot poll;
  const EditPollScreen({super.key, required this.poll});

  @override
  State<EditPollScreen> createState() => _EditPollScreenState();
}

class _EditPollScreenState extends State<EditPollScreen> {
  final titleController = TextEditingController();
  List<TextEditingController> optionNameControllers = [];
  final List<File?> optionImages = [null, null, null];
  final List<String>? existingImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool loader = false;

  @override
  void initState() {
    super.initState();
    final data = widget.poll.data() as Map<String, dynamic>;
    titleController.text = data['title'];

    optionNameControllers.clear();
    optionImages.clear();
    existingImages!.clear();

    final options = List<Map<String, dynamic>>.from(data['options']);
    for (var option in options) {
      optionNameControllers.add(TextEditingController(text: option['name']));
      existingImages!.add(option['imageUrl'] ?? '');
      optionImages.add(null);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                controller: titleController,
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
                        controller: optionNameControllers[i],
                        decoration: InputDecoration(
                          labelText: 'Option ${i + 1} Name',
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    GestureDetector(
                      onTap: () {
                        pickImage(i);
                      },
                      child: optionImages[i] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                optionImages[i]!,
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : existingImages?[i] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                existingImages![i],
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
                updatePoll(widget.poll.id, context);
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
  }

  Future<void> pickImage(int i) async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      optionImages[i] = File(pickedFile.path);
      setState(() {});
    }
  }

  bool validateForm(BuildContext context) {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Title is required")));
      return false;
    }
    for (int i = 0; i < optionNameControllers.length; i++) {
      if (optionNameControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Option ${i + 1} name is required ")),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> updatePoll(String pollId, BuildContext context) async {
    if (!validateForm(context)) return;
    setState(() {
      loader = true;
    });
    try {
      final List<Map<String, dynamic>> options = [];
      for (int i = 0; i < 3; i++) {
        log('Uploading image $i...');
        String? imageUrl = existingImages![i];
        if (optionImages[i] != null) {
          imageUrl = await uploadImage(optionImages[i]!, pollId, i);
        }
        log('Image $i uploaded: $imageUrl');
        options.add({
          'name': optionNameControllers[i].text,
          'imageUrl': imageUrl,
        });
      }
      await FirebaseFirestore.instance.collection('polls').doc(pollId).update({
        "title": titleController.text,
        "options": options,
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Poll Edited Successfully")));
    } catch (e) {
      log('Error creating poll: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to Edit poll: $e")));
    } finally {
      setState(() {
        loader = false;
      });
    }
  }

  Future<String?> uploadImage(File optionImag, String pollId, int i) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'poll/$pollId${i.toString()}_$pollId.jpg',
      );
      final uploadImage = await storageRef.putFile(optionImag);
      return await uploadImage.ref.getDownloadURL();
    } catch (e) {
      log('Error uploading Image :$e');
      return null;
    }
  }
}

import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course_app/helper/database_helper.dart';
import 'package:image_picker/image_picker.dart';

class PollProvider extends ChangeNotifier {
  final titleController = TextEditingController();
  List<TextEditingController> optionNameControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final List<File?> optionImages = [null, null, null];
  final ImagePicker _imagePicker = ImagePicker();
  bool loader = false;
  final List<String>? existingImages = [];

  Future<void> pickImage(int i) async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      optionImages[i] = File(pickedFile.path);
      notifyListeners();
    }
  }

  void initializePoll(DocumentSnapshot poll) {
    final data = poll.data() as Map<String, dynamic>;
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

  Future<void> checkSubmissionPossible(
    String creatorId,
    BuildContext context,
  ) async {
    if (!validateForm(context)) return;
    try {
      final optionNames = optionNameControllers.map((e) => e.text).toList();
      final optionFiles = optionImages;
      await DatabaseHelper().insertPollWithFiles(
        pollId: generateRandomId(),
        title: titleController.text,
        creatorId: creatorId,
        createdAt: DateTime.now(),
        optionNames: optionNames,
        optionFiles: optionFiles,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet. Poll saved locally')),
      );
    } on Exception catch (_) {
      // TODO
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save poll locally')),
      );
    }
  }

  Future<void> submitPoll(String userId, BuildContext context) async {
    if (!validateForm(context)) return;

    loader = true;
    notifyListeners();

    try {
      log('Starting poll creation...');
      final pollDoc = FirebaseFirestore.instance.collection('polls').doc();
      final pollId = pollDoc.id;
      log('Poll ID: $pollId');
      final List<Map<String, dynamic>> options = [];

      for (int i = 0; i < 3; i++) {
        log('Uploading image $i...');
        final imageUrl = await uploadImage(optionImages[i]!, pollId, i);
        if (imageUrl == null) {
          throw Exception('Image upload failed for option $i');
        }
        log('Image $i uploaded: $imageUrl');
        options.add({
          'name': optionNameControllers[i].text,
          'imageUrl': imageUrl,
          'votes': 0,
        });
      }

      log('Saving poll to Firestore...');
      await pollDoc.set({
        'pollId': pollId,
        'title': titleController.text,
        'options': options,
        'createdAt': FieldValue.serverTimestamp(),
        'creatorId': userId,
        'total_votes': 0,
      });
      log('Poll saved successfully!');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Poll Created Successfully")));
    } catch (e) {
      log('Error creating poll: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to create poll: $e")));
    } finally {
      loader = false;
      notifyListeners();
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

    loader = true;
    notifyListeners();

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
      loader = false;
      notifyListeners();
    }
  }

  String generateRandomId([int length = 20]) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890';
    final rand = math.Random.secure();
    return List.generate(
      length,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }
}

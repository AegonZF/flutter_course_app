import 'package:flutter/material.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({super.key});

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final titleController = TextEditingController();
  List<TextEditingController> optionNameControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create poll'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
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
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

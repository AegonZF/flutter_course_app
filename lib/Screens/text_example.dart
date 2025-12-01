import 'package:flutter/material.dart';

class TextExample extends StatefulWidget {
  const TextExample({super.key});

  @override
  State<TextExample> createState() => _TextExampleState();
}

class _TextExampleState extends State<TextExample> {
  int counter = 1;
  void counterAdd() {
    counter++;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Counter ${counter}'),
        ElevatedButton(
          onPressed: () {
            counterAdd();
          },
          child: Text('ClickMe'),
        ),
      ],
    );
  }
}

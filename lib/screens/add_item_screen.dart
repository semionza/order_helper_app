import 'package:flutter/material.dart';

class AddItemScreen extends StatelessWidget {
  const AddItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить предмет')),
      body: const Center(child: Text('Здесь будет форма для добавления нового предмета')),
    );
  }
}
import 'package:fiwe/src/controllers/interest_selection_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InterestSelectionView extends StatelessWidget {
  const InterestSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InterestSelectionController());
    return Scaffold(
      appBar: AppBar(title: Text('Interest Selection')),
      body: Container(),
    );
  }
}

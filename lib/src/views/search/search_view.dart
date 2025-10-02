import 'package:fiwe/src/controllers/search_controller.dart' as search;
import 'package:fiwe/src/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(search.SearchController());
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 46, right: 16),
        decoration: const BoxDecoration(color: AppColors.background),
        height: Get.height,
        width: Get.width,
        child: Column(
          children: [
            Row(
              children: [
                const BackButton(),
                Expanded(
                  child: TextField(
                    autofocus: true,
                    onChanged: controller.search,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.borderLight,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                  ),
                ),
              ],
            ),
            // Expanded(child: Container(child: ,))
          ],
        ),
      ),
    );
  }
}

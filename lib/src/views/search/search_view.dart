import 'package:fiwe/src/controllers/search_controller.dart' as search;
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe/src/utils/helper.dart';
import 'package:fiwe/src/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(search.SearchController());
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 46, right: 12),
        decoration: const BoxDecoration(color: AppColors.background),
        height: Get.height,
        width: Get.width,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                  child: AppBackButton(theme: BackButtonTheme.dark),
                ),

                Expanded(
                  child: Hero(
                    tag: 'search_bar',
                    transitionOnUserGestures: true,
                    child: Container(
                      height: 46,
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.only(left: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(15),
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return Constants.gradientDecoration.gradient!.createShader(bounds);
                            },
                            child: const Icon(LucideIcons.search, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: TextField(
                                autofocus: true,
                                onChanged: controller.search,
                                decoration: const InputDecoration.collapsed(
                                  border: InputBorder.none,
                                  hintText: 'Search',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Row(
            //   children: [
            //     const BackButton(),
            //     Expanded(
            // child: TextField(
            //   autofocus: true,
            //   onChanged: controller.search,
            //   decoration: InputDecoration(
            //     filled: true,
            //     fillColor: AppColors.borderLight,
            //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
            //   ),
            // ),
            //     ),
            //   ],
            // ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: controller.searchResult.length,
                  itemBuilder: (context, index) {
                    final user = controller.searchResult[index];
                    return Card(
                      margin: const EdgeInsets.only(left: 12, bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(child: Image.memory(Helper.base64ToBytes(user.profileImageBase64))),
                        onTap: () => controller.fetchUser(user.id),
                        title: Text(user.name ?? ''),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

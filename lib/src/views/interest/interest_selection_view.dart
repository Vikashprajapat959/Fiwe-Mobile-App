import 'dart:convert';

import 'package:fiwe/src/models/topic.model.dart';
import 'package:fiwe/src/utils/assets.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe/src/utils/strings.dart';
import 'package:fiwe/src/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../controllers/interest_selection_controller.dart';

class InterestSelectionView extends StatelessWidget {
  const InterestSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InterestSelectionController());
    const sliverGridDelegateWithFixedCrossAxisCount = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 6,
      childAspectRatio: 2 / 3,
    );
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.center,
      extendBody: true,
      extendBodyBehindAppBar: true,
      persistentFooterDecoration: BoxDecoration(color: const Color.fromRGBO(0, 0, 0, 0)),
      persistentFooterButtons: [
        // Only rebuild the button when pageIndex changes
        Obx(
          () => AppButtonElevated(
            text: controller.pageIndex() == 0 ? "Continue" : "Submit",
            onPressed: controller.onContinue(),
          ),
        ),
      ],
      body: Container(
        padding: EdgeInsets.all(Constants.paddingAll).add(const EdgeInsets.only(top: 36)),
        height: MediaQuery.of(context).size.height,
        child: PageView(
          controller: controller.pageController,
          children: [
            FutureBuilder<List<Topic>>(
              future: controller.loadTopics(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No topics found'));
                }

                final topics = snapshot.data!.toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Strings.selectInterest,
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ).paddingOnly(bottom: 6),
                    Text(
                      Strings.select5Interests,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
                    ).paddingOnly(bottom: 8),
                    Expanded(
                      // Only rebuild the grid items that change selection state
                      child: GridView.builder(
                        itemCount: topics.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.only(bottom: 75),
                        itemBuilder: (context, index) {
                          final topic = topics[index];
                          return SelactableInterestWidget(topic: topic, forPrimary: false, key: ValueKey(topic.id));
                        },
                        gridDelegate: sliverGridDelegateWithFixedCrossAxisCount,
                      ),
                    ),
                  ],
                );
              },
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButton(onPressed: controller.previousPage),
                Text(
                  Strings.selectInterest,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: AppColors.primary),
                ).paddingOnly(bottom: 6),
                Text(
                  Strings.select5Interests,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
                ).paddingOnly(bottom: 8),
                Expanded(
                  // Only rebuild the grid when selected topics change
                  child: Obx(() {
                    final selectedTopics = controller.getSelectedTopics();
                    return GridView.builder(
                      itemCount: selectedTopics.length,
                      gridDelegate: sliverGridDelegateWithFixedCrossAxisCount,
                      itemBuilder: (context, index) {
                        if (selectedTopics.isNotEmpty) {
                          return SelactableInterestWidget(
                            topic: selectedTopics[index],
                            forPrimary: true,
                            key: ValueKey(selectedTopics[index].id),
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SelactableInterestWidget extends StatelessWidget {
  final Topic topic;
  final bool forPrimary;
  const SelactableInterestWidget({super.key, required this.topic, required this.forPrimary});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InterestSelectionController>();
    // Only rebuild the selection indicator when selection changes for this topic
    return Column(
      children: [
        GestureDetector(
          onTap: () => forPrimary ? controller.primaryTopicSelection(topic.id) : controller.toggleTopic(topic.id),
          child: Container(
            height: Constants.boxHeightCircle,
            width: Constants.boxHeightCircle,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(fit: BoxFit.fill, image: _getTopicImage(topic)),
            ),
            child: _SelectionIndicator(topicId: topic.id, forPrimary: forPrimary),
          ),
        ),
        Text(
          topic.title,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ).paddingOnly(top: 4, bottom: 4),
      ],
    );
  }

  ImageProvider _getTopicImage(Topic topic) {
    if (topic.avatar != null) {
      try {
        final base64Str = topic.avatar!.split(';base64,').last;
        final bytes = Base64Decoder().convert(base64Str);
        return MemoryImage(bytes);
      } catch (e) {
        return AssetImage(Assets.images.logo);
      }
    }
    return AssetImage(Assets.images.logo);
  }
}

// This widget only rebuilds when the selection state for a specific topic changes
class _SelectionIndicator extends StatelessWidget {
  final String topicId;
  final bool forPrimary;
  const _SelectionIndicator({required this.topicId, required this.forPrimary});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InterestSelectionController>();
    return Obx(() {
      final isSelected = forPrimary ? controller.isPrimarySelected(topicId) : controller.isTopicSelected(topicId);
      return Visibility(
        visible: isSelected,
        child: Container(
          height: Constants.boxHeightCircle,
          width: Constants.boxHeightCircle,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary.withAlpha(200), AppColors.secondaryYellow.withAlpha(200)],
            ),
          ),
          child: Icon(LucideIcons.check, color: AppColors.surface, size: 45),
        ),
      );
    });
  }
}

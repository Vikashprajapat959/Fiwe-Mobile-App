import 'package:fiwe/src/controllers/create_room_controller.dart';
import 'package:fiwe/src/models/topic.model.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe/src/utils/strings.dart';
import 'package:fiwe/src/widgets/custom_button.dart';
import 'package:fiwe/src/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CreateRoomView extends StatelessWidget {
  const CreateRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateRoomController());

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.createRoom)),
      persistentFooterDecoration: BoxDecoration(),
      persistentFooterButtons: [
        AppButtonElevated(
          text: 'Create Room',
          onPressed: () {
            // Handle create room logic here
            controller.createRoom();
          },
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Select Interest
            _buildSectionTitle('Select Interest'),
            const SizedBox(height: 12),
            Obx(() {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...controller.displayedTopics.map((topic) {
                    return _buildTopicChip(topic, controller);
                  }),
                  if (controller.showShowMoreButton) _buildShowMoreButton(controller),
                ],
              );
            }),
            const SizedBox(height: 24),

            // Section 2: Room Name
            _buildSectionTitle('Room Name'),
            const SizedBox(height: 12),
            AppTextField(
              hintText: 'Enter room name',
              onChanged: controller.setRoomName,
              textCapitalization: TextCapitalization.words,
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            const SizedBox(height: 24),

            // Section 3: Tabs
            _buildSectionTitle('Choose One'),
            const SizedBox(height: 12),
            Obx(() {
              return Container(
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    _buildTab('Do you have own\nTopic', 0, controller),
                    _buildTab('Get it from\nFi.we', 1, controller),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),

            // Section 4: Content based on tab selection
            Obx(
              () => Visibility(
                visible: controller.currentTab.value == 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(width: Get.width, child: Text("Some random topic from AI")),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500));
  }

  Widget _buildShowMoreButton(CreateRoomController controller) {
    return GestureDetector(
      onTap: controller.toggleShowAllTopics,
      child: Container(
        padding: EdgeInsets.all(1),
        decoration: Constants.gradientDecoration.copyWith(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.transparent, width: 2),
          ),
          child: ShaderMask(
            shaderCallback: (bounds) => Constants.gradientDecoration.gradient!.createShader(bounds),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.showAllTopics.value ? 'Show Less' : 'Show More',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(width: 4),
                Icon(
                  controller.showAllTopics.value ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index, CreateRoomController controller) {
    final isSelected = controller.currentTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setCurrentTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: isSelected
              ? Constants.gradientDecoration.copyWith(borderRadius: BorderRadius.circular(12))
              : null,
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.white : AppColors.textDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicChip(Topic topic, CreateRoomController controller) {
    final isSelected = controller.isTopicSelected(topic.id);
    return GestureDetector(
      onTap: () => controller.toggleTopicSelection(topic.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected ? Constants.gradientDecoration.gradient : null,
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.borderDark, // Fixed color reference
          ),
        ),
        child: Text(
          topic.title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

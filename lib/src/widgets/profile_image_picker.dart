import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageController extends GetxController {
  final Rx<File?> _selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();
  
  File? get selectedImage => _selectedImage.value;
  
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) { 
        _selectedImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  void setImage(File? image) {
    _selectedImage.value = image;
  }
  
  void clearImage() {
    _selectedImage.value = null;
  }
}

class ProfileImagePicker extends StatelessWidget {
  final double size;
  final String? imageUrl;
  final Function(File?)? onImageSelected;
  final ProfileImageController? externalController;

  const ProfileImagePicker({
    super.key,
    this.size = 120,
    this.imageUrl,
    this.onImageSelected,
    this.externalController,
  });

  @override
  Widget build(BuildContext context) {
    // Use external controller if provided, otherwise create a local one
    final ProfileImageController controller = externalController ?? Get.put(ProfileImageController());
    
    return Center(
      child: GestureDetector(
        onTap: () async {
          await controller.pickImage();
          // Call the callback if provided for backward compatibility
          onImageSelected?.call(controller.selectedImage);
        },
        child: Obx(() => Stack(
          children: [
            _buildProfileImage(controller),
            _buildCameraIcon(),
          ],
        )),
      ),
    );
  }

  Widget _buildProfileImage(ProfileImageController controller) {
    if (controller.selectedImage != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: FileImage(controller.selectedImage!),
        backgroundColor: const Color(0xFFF5F5F5),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: const Color(0xFFF5F5F5),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF5F5F5),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.person_outline,
          size: 48,
          color: Color(0xFF0891B2),
        ),
      );
    }
  }

  Widget _buildCameraIcon() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF0891B2),
        ),
        child: const Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
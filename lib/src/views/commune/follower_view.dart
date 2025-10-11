import 'package:fiwe/src/controllers/commune_controller.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/views/commune/commune_view.dart' show CommuneMemberTile;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FollowerScreen extends StatelessWidget {
  const FollowerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text('My Followers'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: Get.find<CommuneController>().getAllRequests(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting || !asyncSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (asyncSnapshot.error != null) {
              return Center(child: Text(asyncSnapshot.error.toString()));
            }
            if (asyncSnapshot.data!.data!.isEmpty) {
              return const Center(child: Text('No Followers found'));
            }
            //if error
            final members = asyncSnapshot.data!.data!;
            return ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: members.length,
              separatorBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 1, color: AppColors.divider),
              ),
              itemBuilder: (context, index) {
                return CommuneMemberTile(
                  member: members[index],
                  onTap: () {
                    // Get.to(()=>UserProfileScreen(user: ))
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

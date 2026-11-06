import 'package:fiwe/src/controllers/commune_controller.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/views/commune/commune_view.dart' show CommuneMemberTile;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FollowerScreen extends StatefulWidget {
  const FollowerScreen({super.key});

  @override
  State<FollowerScreen> createState() => _FollowerScreenState();
}

class _FollowerScreenState extends State<FollowerScreen> {
  final CommuneController _controller = Get.find<CommuneController>();
  late Future _future;

  @override
  void initState() {
    super.initState();
    _future = _controller.getAllRequests();
  }

  Future<void> _refresh() async {
    final result = await _controller.getAllRequests();
    setState(() {
      _future = Future.value(result);
    });
  }

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
          future: _future,
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting || !asyncSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (asyncSnapshot.error != null) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [Center(child: Text(asyncSnapshot.error.toString()))],
                ),
              );
            }
            final members = asyncSnapshot.data!.data!;
            if (members.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [SizedBox(height: 200, child: Center(child: Text('No Followers found')))],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
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
              ),
            );
          },
        ),
      ),
    );
  }
}

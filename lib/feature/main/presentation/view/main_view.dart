import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/feature/main/presentation/widgets/liquid_bottom_navigation_widget.dart';
import '../../../folders/presentation/view/folder_list_view.dart';
import '../../../notes/presentation/view/note_list_view.dart';
import '../../../profile/presentation/views/profile_view.dart';
import '../controller/main_navigation_controller.dart';


class MainView
    extends GetView<MainNavigationController> {
  const MainView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const List<Widget> screens = <Widget>[
      FolderListView(),
      NoteListView(),
      ProfileView(),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor:
      Theme.of(context).scaffoldBackgroundColor,
      body: Obx(
            () => IndexedStack(
          index: controller.selectedIndex.value,
          children: screens,
        ),
      ),
      bottomNavigationBar: Obx(
            () => LiquidBottomNavigationWidget(
          selectedIndex:
          controller.selectedIndex.value,
          onChanged: controller.changeTab,
        ),
      ),
    );
  }
}
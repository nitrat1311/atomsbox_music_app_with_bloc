import 'package:atomsbox/atomsbox.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    return AppBottomNavBar(
      items: [
        AppBottomNavBarItem(
          icon: Icons.home_filled,
          onTap: () {
            if (index == 0) {
              return;
            }
            context.goNamed('home');
          },
        ),
        AppBottomNavBarItem(
          icon: Icons.search,
          onTap: () {
            if (index == 1) {
              return;
            }
            // context.goNamed('search');
          },
        ),
        AppBottomNavBarItem(
          icon: Icons.library_music,
          onTap: () {
            if (index == 2) {
              return;
            }
            // context.goNamed('library');
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String userName;
  final VoidCallback onLogout;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.userName,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0a7a8a),
              letterSpacing: 1,
            ),
          ),
          Text(
            'Welcome, $userName',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF0db8cc)),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF0db8cc), const Color(0xFF0a7a8a)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                onLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 18),
                    SizedBox(width: 12),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 18),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
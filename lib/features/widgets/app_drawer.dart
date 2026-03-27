import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/utils/token_manager.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFF0db8cc).withOpacity(0.05),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0db8cc), Color(0xFF0a7a8a)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.construction,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Site Management System',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.dashboard,
              title: 'Dashboard',
              onTap: () {
                Navigator.pop(context);
              },
              isSelected: true,
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.business,
              title: 'Projects',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Projects');
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.location_on,
              title: 'Sites',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Sites');
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.visibility,
              title: 'Site Visits',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Site Visits');
              },
            ),
            const Divider(height: 32, thickness: 1),
            _buildDrawerItem(
              context: context,
              icon: Icons.people,
              title: 'Clients',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Clients');
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.attach_money,
              title: 'Deals',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Deals');
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.bar_chart,
              title: 'Reports',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Reports');
              },
            ),
            const Divider(height: 32, thickness: 1),
            _buildDrawerItem(
              context: context,
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Settings');
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.help,
              title: 'Help & Support',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Help & Support');
              },
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  // Fixed: Use clearTokens() instead of clearAll()
                  await TokenManager.clearTokens();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('LOGOUT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0db8cc),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF0db8cc) : const Color(0xFF0a7a8a),
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF0db8cc) : const Color(0xFF2C3E50),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      trailing: isSelected
          ? Container(
        width: 4,
        height: 20,
        decoration: BoxDecoration(
          color: const Color(0xFF0db8cc),
          borderRadius: BorderRadius.circular(2),
        ),
      )
          : null,
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: const Color(0xFF0db8cc).withOpacity(0.05),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: const Color(0xFF0a7a8a),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
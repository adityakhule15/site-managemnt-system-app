import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/utils/token_manager.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_appbar.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Static data for testing (will be replaced with API data)
  final Map<String, dynamic> _dashboardData = {
    'totalClients': 5,
    'totalProjects': 5,
    'totalSitesVisited': 5,
    'dealsClosed': 1,
    'recentSiteVisits': [
      {
        'siteName': 'Green Valley Project',
        'date': '2024-01-15',
        'status': 'Completed',
        'executive': 'Pranav Sharma',
      },
      {
        'siteName': 'Sunrise Apartments',
        'date': '2024-01-14',
        'status': 'In Progress',
        'executive': 'Rajesh Kumar',
      },
      {
        'siteName': 'Blue Lagoon Township',
        'date': '2024-01-13',
        'status': 'Completed',
        'executive': 'Priya Patel',
      },
      {
        'siteName': 'Silver Oaks',
        'date': '2024-01-12',
        'status': 'Scheduled',
        'executive': 'Amit Singh',
      },
      {
        'siteName': 'Golden Heights',
        'date': '2024-01-11',
        'status': 'Completed',
        'executive': 'Sneha Gupta',
      },
    ],
  };

  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await TokenManager.getUserName();
    if (mounted) {
      setState(() {
        _userName = name ?? 'User';
      });
    }
  }

  Future<void> _logout() async {
    await TokenManager.clearAll();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar(
        title: 'DASHBOARD',
        userName: _userName,
        onLogout: _logout,
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            const SizedBox(height: 24),

            // Stats Grid
            _buildStatsGrid(),
            const SizedBox(height: 32),

            // Search Section
            _buildSearchSection(),
            const SizedBox(height: 32),

            // Recent Site Visits Table
            _buildRecentSiteVisits(),
            const SizedBox(height: 24),

            // Monthly Activity Section
            _buildMonthlyActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0db8cc), const Color(0xFF0a7a8a)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your site visits and manage projects efficiently',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.construction,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {
        'title': 'Total Clients',
        'value': _dashboardData['totalClients'],
        'icon': Icons.people,
        'color': const Color(0xFF0db8cc),
      },
      {
        'title': 'Total Projects',
        'value': _dashboardData['totalProjects'],
        'icon': Icons.business,
        'color': const Color(0xFF0a7a8a),
      },
      {
        'title': 'Sites Visited',
        'value': _dashboardData['totalSitesVisited'],
        'icon': Icons.location_on,
        'color': const Color(0xFF0db8cc),
      },
      {
        'title': 'Deals Closed',
        'value': _dashboardData['dealsClosed'],
        'icon': Icons.attach_money,
        'color': const Color(0xFF0a7a8a),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (stat['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  stat['value'].toString(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['title'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SEARCH LEAD BY PHONE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0a7a8a),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter phone number...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF0db8cc)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0db8cc)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Fluttertoast.showToast(
                    msg: 'Search functionality coming soon',
                    backgroundColor: const Color(0xFF0a7a8a),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0db8cc),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Fluttertoast.showToast(
                  msg: 'Add new lead functionality coming soon',
                  backgroundColor: const Color(0xFF0db8cc),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('+ Add New Lead'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0db8cc),
                side: const BorderSide(color: Color(0xFF0db8cc)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSiteVisits() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'RECENT SITE VISITS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0a7a8a),
                    letterSpacing: 1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0db8cc).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Total: ${_dashboardData['totalSitesVisited']}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0db8cc),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              headingRowColor: MaterialStateProperty.resolveWith(
                    (states) => const Color(0xFFF8F9FA),
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    'SITE NAME',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'DATE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'STATUS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'EXECUTIVE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
              ],
              rows: _dashboardData['recentSiteVisits'].map<DataRow>((visit) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        visit['siteName'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    DataCell(Text(visit['date'])),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(visit['status']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          visit['status'],
                          style: TextStyle(
                            color: _getStatusColor(visit['status']),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(visit['executive'])),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF2ECC71);
      case 'in progress':
        return const Color(0xFFF39C12);
      case 'scheduled':
        return const Color(0xFF3498DB);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  Widget _buildMonthlyActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0db8cc).withOpacity(0.05), const Color(0xFF0a7a8a).withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0db8cc).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MONTHLY SALES ACTIVITY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0a7a8a),
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Pranav Sales Executive',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          OutlinedButton(
            onPressed: () {
              Fluttertoast.showToast(
                msg: 'View detailed activity report',
                backgroundColor: const Color(0xFF0a7a8a),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0db8cc),
              side: const BorderSide(color: Color(0xFF0db8cc)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }
}
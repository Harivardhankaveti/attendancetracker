import 'package:flutter/material.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;

  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'role': 'student',
      'status': 'active',
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'faculty',
      'status': 'active',
    },
    {
      'id': '3',
      'name': 'Robert Johnson',
      'email': 'johnson@example.com',
      'role': 'admin',
      'status': 'active',
    },
  ];

  List<Map<String, dynamic>> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _filteredUsers = _users;
    _searchController.addListener(_filterUsers);
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredUsers = _users.where((user) {
        return user['name'].toLowerCase().contains(query) ||
            user['email'].toLowerCase().contains(query) ||
            user['role'].toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _refreshUsers() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    /// 🔹 Replace this with backend fetch
    setState(() => _isLoading = false);
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'faculty':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  Color _statusColor(String status) {
    return status == 'active' ? Colors.green : Colors.red;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text(
        "No users found",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.indigo.shade100,
          child: Text(
            user['name'][0],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.indigo,
            ),
          ),
        ),
        title: Text(
          user['name'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user['email']),
            const SizedBox(height: 6),
            Row(
              children: [
                /// ROLE CHIP
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _roleColor(user['role']).withOpacity(.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user['role'].toUpperCase(),
                    style: TextStyle(
                      color: _roleColor(user['role']),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                /// STATUS CHIP
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(user['status']).withOpacity(.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user['status'].toUpperCase(),
                    style: TextStyle(
                      color: _statusColor(user['status']),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          /// 🔹 Navigate to User Details Screen
        },
        trailing: PopupMenuButton(
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text("Edit")),
            PopupMenuItem(value: 'delete', child: Text("Delete")),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              /// edit user
            } else {
              /// delete user
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Users"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () {
              /// Navigate to Add User Screen
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔍 SEARCH BAR
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search users...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 👥 USER LIST
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredUsers.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: _refreshUsers,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) =>
                                _buildUserCard(_filteredUsers[index]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

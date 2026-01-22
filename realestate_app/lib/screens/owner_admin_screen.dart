import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property.dart';
import '../services/property_service.dart';
import 'property_details_screen.dart';
import 'package:intl/intl.dart';

class OwnerAdminScreen extends StatefulWidget {
  const OwnerAdminScreen({Key? key}) : super(key: key);

  @override
  State<OwnerAdminScreen> createState() => _OwnerAdminScreenState();
}

class _OwnerAdminScreenState extends State<OwnerAdminScreen>
    with SingleTickerProviderStateMixin {
  final PropertyService _propertyService = PropertyService();
  late TabController _tabController;

  List<Property> _allProperties = [];
  List<Property> _filteredProperties = [];
  List<Map<String, dynamic>> _users = [];
  
  Map<String, int> _userPropertyCounts = {}; 
  
  bool _isLoading = true;

  String _searchQuery = '';
  String _selectedVerification = 'Verified';

  int _totalProperties = 0;
  int _activeListings = 0;
  int _pendingApprovals = 0;
  int _totalUsers = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAdminData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    if (_allProperties.isEmpty) setState(() => _isLoading = true);

    final supabase = Supabase.instance.client;

    try {
      // ✅ SIMPLIFIED: Just use PropertyService - it knows how to handle all parameters!
      List<Property> properties = await _propertyService.fetchAllProperties(includeAllStatuses: true);
      
      // Calculate Property Counts per User from raw data
      Map<String, int> counts = {};
      try {
        final propertyResponse = await supabase
            .from('properties')
            .select('id, owner_id')
            .order('created_at', ascending: false);
        
        final List<dynamic> rawProperties = propertyResponse as List<dynamic>;
        for (var p in rawProperties) {
          final ownerId = p['owner_id']?.toString();
          if (ownerId != null) {
            counts[ownerId] = (counts[ownerId] ?? 0) + 1;
          }
        }
      } catch (e) {
        print('Error counting properties: $e');
      }

      // Fetch Users
      List<Map<String, dynamic>> fetchedUsers = [];
      try {
        final userResponse = await supabase
            .from('users')
            .select('*')
            .order('created_at', ascending: false);
        
        fetchedUsers = List<Map<String, dynamic>>.from(userResponse);
      } catch (e) {
        print('Error fetching users: $e');
      }

      if (mounted) {
        setState(() {
          _allProperties = properties;
          _userPropertyCounts = counts;
          _users = fetchedUsers;
          
          _totalProperties = properties.length;
          _activeListings = properties.where((p) => p.status == 'active').length;
          _pendingApprovals = properties.where((p) => p.status != 'active').length;
          _totalUsers = fetchedUsers.length;

          _isLoading = false;
        });
        _filterProperties();
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterProperties() {
    setState(() {
      _filteredProperties = _allProperties.where((property) {
        bool matchesSearch = _searchQuery.isEmpty ||
            property.propertyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (property.city?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        bool isVerified = property.status?.toLowerCase() == 'active';
        
        bool matchesVerification = true;
        if (_selectedVerification == 'Verified') {
          matchesVerification = isVerified;
        } else if (_selectedVerification == 'Unverified') {
          matchesVerification = !isVerified; 
        } 
        
        return matchesSearch && matchesVerification;
      }).toList();
    });
  }

  Future<void> _updatePropertyStatus(Property property, String newStatus) async {
    // ✅ SIMPLIFIED: Update DB first, then reload from PropertyService
    try {
      dynamic dbId = property.id;
      if (int.tryParse(property.id) != null) dbId = int.parse(property.id);

      await Supabase.instance.client
          .from('properties')
          .update({'status': newStatus})
          .eq('id', dbId);

      if (mounted) {
        String msg = newStatus == 'active' 
            ? 'Property Verified' 
            : 'Property Unverified';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: newStatus == 'active' ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Reload all data to get fresh Property objects
        _loadAdminData();
      }
    } catch (e) {
      print("Update failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : Column(
              children: [
                _buildStatsCards(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPropertiesTab(),
                      _buildUsersTab(),
                      _buildPlaceholderTab('Analytics Dashboard'),
                      _buildPlaceholderTab('Settings'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Owner Admin Panel', style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 18)),
              Text('System Management', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.refresh, color: Colors.black), onPressed: _loadAdminData),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          _buildStatCard('Total Properties', _totalProperties.toString(), Icons.home_work, const Color(0xFF10B981)),
          const SizedBox(width: 12),
          _buildStatCard('Active Listings', _activeListings.toString(), Icons.check_circle, const Color(0xFF3B82F6)),
          const SizedBox(width: 12),
          _buildStatCard('Pending', _pendingApprovals.toString(), Icons.pending, const Color(0xFFF59E0B)),
          const SizedBox(width: 12),
          _buildStatCard('Total Users', _totalUsers.toString(), Icons.people, const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF10B981),
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorColor: const Color(0xFF10B981),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Properties', icon: Icon(Icons.home)),
          Tab(text: 'Users', icon: Icon(Icons.people)),
          Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          Tab(text: 'Settings', icon: Icon(Icons.settings)),
        ],
      ),
    );
  }

  Widget _buildPropertiesTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search properties...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFB),
                ),
                onChanged: (value) {
                  _searchQuery = value;
                  _filterProperties();
                },
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildVerificationChip('Verified', 'Verified'),
                    const SizedBox(width: 8),
                    _buildVerificationChip('Unverified', 'Unverified'),
                    const SizedBox(width: 8),
                    _buildVerificationChip('All', 'All'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredProperties.isEmpty
              ? _buildEmptyState('No properties found')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredProperties.length,
                  itemBuilder: (context, index) {
                    return _buildPropertyCard(_filteredProperties[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVerificationChip(String label, String value) {
    bool isSelected = _selectedVerification == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedVerification = value;
          _filterProperties();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    bool isVerified = property.status?.toLowerCase() == 'active';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: property)));
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: property.coverImageUrl != null
                    ? Image.network(property.coverImageUrl!, width: 90, height: 90, fit: BoxFit.cover)
                    : Container(width: 90, height: 90, color: Colors.grey[200], child: const Icon(Icons.home, color: Colors.grey)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            property.propertyName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isVerified ? Colors.green.shade50 : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: isVerified ? Colors.green.shade200 : Colors.orange.shade200),
                          ),
                          child: Text(
                            isVerified ? 'VERIFIED' : 'UNVERIFIED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isVerified ? Colors.green.shade700 : Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.city ?? 'Unknown Location',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                         Text(property.propertyFor, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                         const SizedBox(width: 8),
                         Container(width: 1, height: 12, color: Colors.grey),
                         const SizedBox(width: 8),
                         Text(
                           property.status ?? 'unknown',
                           style: TextStyle(fontSize: 12, color: Colors.blue.shade300),
                         ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'verify') {
                    _updatePropertyStatus(property, 'active');
                  } else if (value == 'unverify') {
                    _updatePropertyStatus(property, 'pending');
                  }
                },
                itemBuilder: (context) => [
                  if (!isVerified)
                    const PopupMenuItem(
                      value: 'verify',
                      child: Row(children: [Icon(Icons.check, color: Colors.green), SizedBox(width: 8), Text('Verify')]),
                    ),
                  if (isVerified)
                    const PopupMenuItem(
                      value: 'unverify',
                      child: Row(children: [Icon(Icons.remove_circle_outline, color: Colors.orange), SizedBox(width: 8), Text('Unverify')]),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_users.isEmpty) {
      return _buildEmptyState('No users found in database');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        final String name = user['full_name'] ?? 'User ${index + 1}';
        final String email = user['email'] ?? user['user_email'] ?? 'No Email';
        final String plan = user['subscription_plan'] ?? 'Free';
        final String userId = user['id']?.toString() ?? '';
        final int propCount = _userPropertyCounts[userId] ?? 0;
        
        String dateStr = 'Unknown';
        if (user['created_at'] != null) {
          try {
             dateStr = DateFormat('MMM dd, yyyy').format(DateTime.parse(user['created_at']));
          } catch (e) {
             dateStr = 'Invalid Date';
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(email, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.home_work, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text('$propCount Properties', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: plan.toLowerCase() == 'premium' ? Colors.amber.shade50 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: plan.toLowerCase() == 'premium' ? Colors.amber.shade200 : Colors.blue.shade200
                        )
                      ),
                      child: Text(
                        plan.toUpperCase(), 
                        style: TextStyle(
                          fontSize: 10, 
                          color: plan.toLowerCase() == 'premium' ? Colors.amber.shade800 : Colors.blue.shade700, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Joined $dateStr', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return Center(child: Text(title));
  }
}
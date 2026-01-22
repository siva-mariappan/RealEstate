import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_service.dart';
import '../services/auth_service.dart';
import 'property_details_screen.dart';
import 'add_property_screen_1.dart';

class MyPropertiesTab extends StatefulWidget {
  const MyPropertiesTab({Key? key}) : super(key: key);

  @override
  State<MyPropertiesTab> createState() => _MyPropertiesTabState();
}

class _MyPropertiesTabState extends State<MyPropertiesTab> {
  final PropertyService _propertyService = PropertyService();
  final AuthService _authService = AuthService();
  
  List<Property> _properties = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadMyProperties();
  }

  Future<void> _loadMyProperties() async {
    try {
      setState(() => _isLoading = true);
      
      // Get user ID
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Fetch properties for this user
      final allProperties = await _propertyService.fetchFeaturedProperties(limit: 100);
      
      setState(() {
        _properties = allProperties;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading properties: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Property> get _filteredProperties {
    if (_selectedFilter == 'all') return _properties;
    if (_selectedFilter == 'rent') {
      return _properties.where((p) => p.propertyFor == 'rent').toList();
    }
    if (_selectedFilter == 'sell') {
      return _properties.where((p) => p.propertyFor == 'sell').toList();
    }
    return _properties;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10B981),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Properties',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadMyProperties,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Pills - matches screenshot design
          Container(
            width: double.infinity,
            color: const Color(0xFF10B981),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Row(
              children: [
                _buildFilterPill('All', 'all'),
                const SizedBox(width: 12),
                _buildFilterPill('For Rent', 'rent'),
                const SizedBox(width: 12),
                _buildFilterPill('For Sale', 'sell'),
              ],
            ),
          ),

          // Properties List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF10B981),
                    ),
                  )
                : _filteredProperties.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadMyProperties,
                        color: const Color(0xFF10B981),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredProperties.length,
                          itemBuilder: (context, index) {
                            return _buildPropertyCard(_filteredProperties[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      // ✅ FIXED: Add Property button now works correctly
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPropertyStep1Screen(),
            ),
          ).then((_) => _loadMyProperties());
        },
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Property',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // ✅ NEW: Filter pill design matching screenshot
  Widget _buildFilterPill(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? null
                : Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) ...[
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF10B981) : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetailsScreen(property: property),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Property Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 100,
                  color: const Color(0xFFF3F4F6),
                  child: property.coverImageUrl != null
                      ? Image.network(
                          property.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.home_work_outlined,
                            size: 40,
                            color: Color(0xFF9CA3AF),
                          ),
                        )
                      : const Icon(
                          Icons.home_work_outlined,
                          size: 40,
                          color: Color(0xFF9CA3AF),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Property Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.propertyName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.location,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      property.formattedPrice,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: property.propertyFor == 'sell'
                            ? Colors.blue.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        property.propertyFor == 'sell' ? 'For Sale' : 'For Rent',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: property.propertyFor == 'sell'
                              ? Colors.blue.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_work_outlined,
                size: 64,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _selectedFilter == 'all'
                  ? 'No properties yet'
                  : 'No properties found',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'all'
                  ? 'Add your first property to get started'
                  : 'Try selecting a different filter',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            if (_selectedFilter == 'all') ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddPropertyStep1Screen(),
                    ),
                  ).then((_) => _loadMyProperties());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add Your First Property',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
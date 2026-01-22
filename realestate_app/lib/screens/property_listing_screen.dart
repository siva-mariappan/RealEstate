import 'package:flutter/material.dart';
import '../models/property.dart';
import '../models/property_model.dart';
import '../services/property_service.dart';
import '../widgets/property_filter_sidebar.dart';

class PropertyListingScreen extends StatefulWidget {
  final String? propertyFor;
  final String? city;
  final PropertyFilters? initialFilters; // ADDED: Support for initial filters from home page

  const PropertyListingScreen({
    Key? key,
    this.propertyFor,
    this.city,
    this.initialFilters, // ADDED
  }) : super(key: key);

  @override
  State<PropertyListingScreen> createState() => _PropertyListingScreenState();
}

class _PropertyListingScreenState extends State<PropertyListingScreen> {
  final PropertyService _propertyService = PropertyService();
  
  // Data State
  List<Property> _properties = [];
  bool _isLoading = true;
  String? _error;
  
  // UI State: Controls the visibility of the sidebar on Desktop
  bool _isSidebarVisible = true; 

  // Filter State
  late PropertyFilters _currentFilters;

  @override
  void initState() {
    super.initState();
    
    // UPDATED: Use initialFilters if provided, otherwise create from propertyFor
    if (widget.initialFilters != null) {
      _currentFilters = widget.initialFilters!;
    } else {
      _currentFilters = PropertyFilters(
        lookingFor: widget.propertyFor == 'rent' ? LookingFor.rent : LookingFor.buy,
        propertyTypes: [],
      );
    }
    
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Property> properties;
      
      // Fetch logic using Supabase service
      if (widget.city != null && widget.city!.isNotEmpty) {
        properties = await _propertyService.fetchPropertiesByCity(widget.city!);
      } else if (widget.propertyFor != null) {
        properties = await _propertyService.fetchPropertiesByType(widget.propertyFor!);
      } else {
        properties = await _propertyService.fetchAllProperties();
      }

      if (!mounted) return;
      setState(() {
        _properties = properties;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load: $e';
        _isLoading = false;
      });
    }
  }

  void _onFilterChanged(PropertyFilters newFilters) {
    setState(() {
      _currentFilters = newFilters;
    });
    // On mobile, close the drawer after selection. On desktop, keep it open.
    if (MediaQuery.of(context).size.width < 900) {
      Navigator.pop(context); 
    }
    _fetchProperties(); 
  }

  @override
  Widget build(BuildContext context) {
    // Check if screen is Desktop/Wide
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "EstateHub",
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          // MOBILE ONLY: Filter Icon to open Drawer
          if (!isDesktop)
            Builder(
              builder: (context) => IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.filter_list, color: Color(0xFF111827)),
                    if (_currentFilters.propertyTypes.isNotEmpty)
                      Positioned(
                        right: 0, top: 0,
                        child: Container(
                          width: 8, 
                          height: 8, 
                          decoration: const BoxDecoration(
                            color: Colors.red, 
                            shape: BoxShape.circle
                          ),
                        ),
                      )
                  ],
                ),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
        ],
      ),
      
      // MOBILE ONLY: Drawer for Sidebar
      endDrawer: !isDesktop 
          ? Drawer(
              width: 320,
              backgroundColor: Colors.white,
              child: PropertyFilterSidebar(
                currentFilters: _currentFilters,
                onFilterChanged: _onFilterChanged,
              ),
            )
          : null,

      // MAIN BODY: Row layout for split view
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. DESKTOP SIDEBAR (Collapsible)
          if (isDesktop && _isSidebarVisible)
            Container(
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade200)),
                color: Colors.white,
              ),
              // PropertyFilterSidebar has fixed width of 320 internally
              child: PropertyFilterSidebar(
                currentFilters: _currentFilters,
                onFilterChanged: _onFilterChanged,
              ),
            ),

          // 2. MAIN CONTENT AREA
          Expanded(
            child: Column(
              children: [
                // CONTROL BAR
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // UPDATED: Show filter summary
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${_properties.length} Properties Found",
                              style: const TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827)
                              ),
                            ),
                            if (_currentFilters.propertyTypes.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                "Type: ${_currentFilters.propertyTypes.join(', ')}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      // HIDE/SHOW FILTERS BUTTON (Desktop Only)
                      if (isDesktop)
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isSidebarVisible = !_isSidebarVisible;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Icon(
                                  _isSidebarVisible ? Icons.filter_list_off : Icons.filter_list,
                                  size: 18,
                                  color: const Color(0xFF10B981),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isSidebarVisible ? "Hide Filters" : "Show Filters",
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // CONTENT GRID
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF10B981)
                          )
                        )
                      : _error != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline, 
                                    size: 64, 
                                    color: Colors.red.shade300
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _error!, 
                                    style: TextStyle(
                                      color: Colors.grey.shade600, 
                                      fontSize: 16
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _fetchProperties,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : _properties.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.home_work_outlined, 
                                        size: 64, 
                                        color: Colors.grey[300]
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "No properties found", 
                                        style: TextStyle(
                                          color: Colors.grey.shade600, 
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        )
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Try adjusting your filters", 
                                        style: TextStyle(
                                          color: Colors.grey.shade500, 
                                          fontSize: 14,
                                        )
                                      ),
                                    ],
                                  ),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.all(24),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    // Adjust columns based on Sidebar visibility
                                    crossAxisCount: isDesktop 
                                        ? (_isSidebarVisible ? 3 : 4) 
                                        : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
                                    childAspectRatio: 0.85, 
                                    crossAxisSpacing: 24,
                                    mainAxisSpacing: 24,
                                  ),
                                  itemCount: _properties.length,
                                  itemBuilder: (context, index) {
                                    return _buildPropertyCard(_properties[index]);
                                  },
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: () {
          // Navigate to property details
          // You can implement this navigation here
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('View details: ${property.propertyName}'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  property.coverImageUrl != null
                      ? Image.network(
                          property.coverImageUrl!, 
                          width: double.infinity, 
                          height: double.infinity, 
                          fit: BoxFit.cover,
                          errorBuilder: (c,o,s) => Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.home_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(
                              Icons.home_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                  
                  Positioned(
                    top: 12, 
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: property.propertyFor == 'sell' 
                            ? const Color(0xFF10B981) 
                            : const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        property.propertyFor == 'sell' ? 'For Sale' : 'For Rent',
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 10, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  
                  // Favorite icon
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.propertyName, 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis, 
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on, 
                              size: 14, 
                              color: Color(0xFF6B7280)
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                property.location, 
                                maxLines: 1, 
                                overflow: TextOverflow.ellipsis, 
                                style: const TextStyle(
                                  color: Color(0xFF6B7280), 
                                  fontSize: 12
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            property.formattedPrice, 
                            style: const TextStyle(
                              color: Color(0xFF10B981), 
                              fontWeight: FontWeight.bold, 
                              fontSize: 16
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, 
                            vertical: 6
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "View Details", 
                            style: TextStyle(
                              fontSize: 10, 
                              color: Color(0xFF10B981), 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/property.dart';
import '../models/property_model.dart';
import '../services/property_service.dart';
import '../services/auth_service.dart';
import '../widgets/advertisement_carousel.dart';
import 'property_listing_screen.dart';
import 'property_details_screen.dart';
import 'welcome_screen.dart';
import 'add_property_screen_1.dart';
import 'owner_admin_screen.dart';
import 'user_dashboard.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key? key}) : super(key: key);

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> with SingleTickerProviderStateMixin {
  final PropertyService _propertyService = PropertyService();
  final AuthService _authService = AuthService();
  final TextEditingController _generalSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late AnimationController _animationController;
  
  List<Property> _featuredProperties = [];
  bool _isLoading = true;
  String _selectedPurpose = 'buy';
  String? _selectedPropertyType;
  String _selectedBudget = 'any';
  Set<String> _selectedFilters = {};
  double _appBarElevation = 0.0;

  // Property Type Lists based on Buy/Rent
  final List<String> _buyPropertyTypes = [
    'Plot',
    'Commercial Land',
    'Flat',
    'Individual House',
    'Individual Villa',
    'Complex',
    'Commercial Building'
  ];

  final List<String> _rentPropertyTypes = [
    'Flat',
    'Individual House',
    'Individual Villa',
    'PG / Hostel',
    'Shared Room',
    'Independent Floor',
    'Commercial Building',
    'Office Space',
    'Shop / Showroom',
    'Warehouse / Godown'
  ];

  @override
  void initState() {
    super.initState();
    _loadFeaturedProperties();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final elevation = _scrollController.hasClients && _scrollController.offset > 0 ? 1.0 : 0.0;
    if (_appBarElevation != elevation) {
      setState(() => _appBarElevation = elevation);
    }
  }

  @override
  void dispose() {
    _generalSearchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadFeaturedProperties() async {
    try {
      setState(() => _isLoading = true);
      final properties = await _propertyService.fetchFeaturedProperties(limit: 6);
      if (mounted) {
        setState(() {
          _featuredProperties = properties;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading properties: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load properties: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
    });
  }

  List<String> get _currentPropertyTypes {
    return _selectedPurpose == 'buy' ? _buyPropertyTypes : _rentPropertyTypes;
  }

  // FIXED: Proper navigation with debugging
  void _handleSearch() {
    print('🔍 Search button clicked');
    print('📍 Selected Purpose: $_selectedPurpose');
    print('🏠 Selected Property Type: $_selectedPropertyType');
    
    try {
      // Create filters
      PropertyFilters initialFilters = PropertyFilters(
        lookingFor: _selectedPurpose == 'buy' ? LookingFor.buy : LookingFor.rent,
      );
      
      // Add property type if selected
      if (_selectedPropertyType != null && _selectedPropertyType!.isNotEmpty) {
        initialFilters.propertyTypes.add(_selectedPropertyType!);
        print('✅ Added property type to filters: $_selectedPropertyType');
      }
      
      print('🚀 Navigating to PropertyListingScreen...');
      
      // Navigate
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PropertyListingScreen(
            initialFilters: initialFilters,
          ),
        ),
      ).then((value) {
        print('✅ Returned from PropertyListingScreen');
      }).catchError((error) {
        print('❌ Navigation error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } catch (e) {
      print('❌ Error in _handleSearch: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // FIXED: Navigate to filter page directly from filter icon
  void _navigateToFilterPage() {
    print('🔧 Filter icon clicked');
    print('📍 Selected Purpose: $_selectedPurpose');
    print('🏠 Selected Property Type: $_selectedPropertyType');
    
    try {
      PropertyFilters initialFilters = PropertyFilters(
        lookingFor: _selectedPurpose == 'buy' ? LookingFor.buy : LookingFor.rent,
      );
      
      if (_selectedPropertyType != null && _selectedPropertyType!.isNotEmpty) {
        initialFilters.propertyTypes.add(_selectedPropertyType!);
        print('✅ Added property type to filters: $_selectedPropertyType');
      }
      
      print('🚀 Navigating to PropertyListingScreen from filter icon...');
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PropertyListingScreen(
            initialFilters: initialFilters,
          ),
        ),
      ).then((value) {
        print('✅ Returned from PropertyListingScreen');
      }).catchError((error) {
        print('❌ Navigation error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } catch (e) {
      print('❌ Error in _navigateToFilterPage: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // General search with query parameter
  void _handleGeneralSearch(String query) {
    print('🔍 General search: $query');
    
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a search term'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      PropertyFilters initialFilters = PropertyFilters(
        lookingFor: _selectedPurpose == 'buy' ? LookingFor.buy : LookingFor.rent,
      );

      print('🚀 Navigating with search query: $query');
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PropertyListingScreen(
            initialFilters: initialFilters,
            city: query,
          ),
        ),
      ).then((value) {
        print('✅ Returned from search');
      });
    } catch (e) {
      print('❌ Error in general search: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserDashboard(),
      ),
    ).then((value) {
      _loadFeaturedProperties();
    });
  }

  Widget _buildPropertyCard(Property property) {
    final amenities = property.nearbyAmenities ?? [];
    final displayAmenities = amenities.take(3).toList();
    final remainingCount = amenities.length > 3 ? amenities.length - 3 : 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFECEDEE),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _navigateToPropertyDetails(property),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.8,
                    child: property.coverImageUrl != null
                        ? Image.network(
                            property.coverImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF10B981).withOpacity(0.2),
                                      const Color(0xFF3B82F6).withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.home_work_outlined,
                                  size: 56,
                                  color: Colors.grey[300],
                                ),
                              );
                            },
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF10B981).withOpacity(0.2),
                                  const Color(0xFF3B82F6).withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.home_work_outlined,
                              size: 56,
                              color: Colors.grey[300],
                            ),
                          ),
                  ),
                  
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.verified, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite_border,
                            size: 20,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            property.propertyFor == 'sell' 
                                ? Icons.shopping_bag_outlined 
                                : Icons.key_outlined,
                            size: 16,
                            color: const Color(0xFF111827),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            property.propertyFor == 'sell' ? 'For Buy' : 'For Rent',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      property.propertyName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    
                    Text(
                      property.propertyDescription ?? property.propertyType ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            property.location,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    
                    if (property.bedrooms != null || property.builtUpArea != null || property.bathrooms != null) ...[
                      Row(
                        children: [
                          if (property.bedrooms != null) ...[
                            Icon(
                              Icons.bed_outlined,
                              size: 18,
                              color: const Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              property.bedrooms!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 20),
                          ],
                          if (property.bathrooms != null) ...[
                            Icon(
                              Icons.bathtub_outlined,
                              size: 18,
                              color: const Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${property.bathrooms} Bath',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 20),
                          ],
                          if (property.builtUpArea != null) ...[
                            Icon(
                              Icons.straighten,
                              size: 18,
                              color: const Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${property.builtUpArea!.toInt()} sqft',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (amenities.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...displayAmenities.map((amenity) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              amenity,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )),
                          if (remainingCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '+$remainingCount',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            property.formattedPrice,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        
                        ElevatedButton(
                          onPressed: () => _navigateToPropertyDetails(property),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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

  void _navigateToPropertyDetails(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailsScreen(property: property),
      ),
    );
  }

  void _handleAddProperty() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPropertyStep1Screen(),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  int _getResponsiveCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 800) return 2;
    return 1;
  }

  double _getResponsiveChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 0.85;
    if (width > 800) return 0.82;
    return 0.95;
  }

  Widget _buildAddPropertyButton(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;
    final isTablet = width > 600 && width <= 900;

    return Container(
      margin: EdgeInsets.only(
        bottom: isDesktop ? 24 : (isTablet ? 16 : 8),
        right: isDesktop ? 24 : (isTablet ? 16 : 0),
      ),
      child: FloatingActionButton.extended(
        onPressed: _handleAddProperty,
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 6,
        highlightElevation: 12,
        icon: const Icon(Icons.add_home_work_rounded, size: 24),
        label: Text(
          'Add Property',
          style: TextStyle(
            fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: _buildAppBar(),
      floatingActionButton: _buildAddPropertyButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        onRefresh: _loadFeaturedProperties,
        color: const Color(0xFF10B981),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroSection(),
              const SizedBox(height: 20),
              _buildEnhancedAdvertisementSection(),
              const SizedBox(height: 20),
              _buildSearchSection(),
              const SizedBox(height: 20),
              _buildGeneralSearchSection(),
              const SizedBox(height: 24),
              _buildFeaturesSection(),
              const SizedBox(height: 32),
              _buildFeaturedPropertiesSection(),
              const SizedBox(height: 32),
              _buildTopLocalitiesSection(),
              const SizedBox(height: 32),
              _buildTestimonialsSection(),
              _buildFooter(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: _appBarElevation,
      scrolledUnderElevation: 1,
      toolbarHeight: 70,
      title: Row(
        children: [
          Hero(
            tag: 'app_logo',
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.home_work_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'EstateHub',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Find Your Dream Home',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Filter icon with debugging
        IconButton(
          icon: const Icon(Icons.filter_list, color: Color(0xFF111827), size: 26),
          onPressed: () {
            print('🔧 Filter icon button pressed!');
            _navigateToFilterPage();
          },
          tooltip: 'Filters',
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Color(0xFF111827), size: 26),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserDashboard(initialTab: 1),
              ),
            );
          },
          tooltip: 'Favorites',
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFF111827), size: 26),
          onPressed: () {},
          tooltip: 'Notifications',
        ),
        PopupMenuButton<String>(
          icon: CircleAvatar(
            backgroundColor: const Color(0xFF10B981),
            child: Text(
              _authService.currentUser?.email?.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          offset: const Offset(0, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (context) {
            final isOwnerAdmin = _authService.currentUser?.email == 'selvakumar241301@gmail.com';

            return <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20, color: Color(0xFF374151)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _authService.currentUser?.email ?? 'User',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text(
                            'View Profile',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'dashboard',
                child: Row(
                  children: [
                    Icon(Icons.dashboard, size: 20, color: Color(0xFF10B981)),
                    SizedBox(width: 12),
                    Text(
                      'My Dashboard',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwnerAdmin) ...[
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'admin',
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings, size: 20, color: Color(0xFF10B981)),
                      SizedBox(width: 12),
                      Text(
                        'Owner Admin Panel',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Color(0xFFDC2626)),
                    SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
          onSelected: (String value) {
            if (value == 'logout') {
              _handleLogout();
            } else if (value == 'dashboard') {
              _navigateToDashboard();
            } else if (value == 'profile') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserDashboard(initialTab: 3),
                ),
              );
            } else if (value == 'admin') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OwnerAdminScreen(),
                ),
              );
            }
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroSection() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        )),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF10B981).withOpacity(0.08),
                Colors.white,
                const Color(0xFF3B82F6).withOpacity(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified,
                      color: Color(0xFF10B981),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TRUSTED BY 10,000+ CUSTOMERS',
                      style: TextStyle(
                        color: const Color(0xFF10B981),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Find Your Perfect Home',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  height: 1.1,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Without Any Hassle',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -1.2,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [
                        Color(0xFF10B981),
                        Color(0xFF3B82F6),
                      ],
                    ).createShader(const Rect.fromLTWH(0, 0, 600, 80)),
                ),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 750),
                child: const Text(
                  'Discover thousands of verified properties. Get expert assistance and transparent pricing. Your dream home is just a search away.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFF6B7280),
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAdvertisementSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const AdvertisementCarousel(),
    );
  }

  Widget _buildSearchSection() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildPurposeTab('Buy', 'buy', Icons.shopping_bag_outlined),
                const SizedBox(width: 12),
                _buildPurposeTab('Rent', 'rent', Icons.key_outlined),
              ],
            ),
            const SizedBox(height: 24),
            
            const Text(
              'What do you want to see?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButton<String>(
                value: _selectedPropertyType,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text(
                  'Select property type',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 15,
                  ),
                ),
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF10B981)),
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                items: _currentPropertyTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPropertyType = newValue;
                  });
                  print('✅ Property type selected: $newValue');
                },
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  print('🔘 Search Properties button pressed!');
                  _handleSearch();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  shadowColor: const Color(0xFF10B981).withOpacity(0.4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Search Properties',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
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

  Widget _buildGeneralSearchSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 12),
            child: Icon(Icons.search, color: Color(0xFF6B7280), size: 24),
          ),
          Expanded(
            child: TextField(
              controller: _generalSearchController,
              decoration: const InputDecoration(
                hintText: 'Search by location, property name, or ID...',
                hintStyle: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 18),
              ),
              style: const TextStyle(fontSize: 15),
              onSubmitted: (value) {
                print('⌨️ Enter key pressed in general search');
                _handleGeneralSearch(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () {
                print('🔘 General search button pressed');
                _handleGeneralSearch(_generalSearchController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeTab(String label, String value, IconData icon) {
    final isSelected = _selectedPurpose == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPurpose = value;
            _selectedPropertyType = null;
          });
          print('✅ Purpose changed to: $value');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  )
                : null,
            color: isSelected ? null : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected 
                  ? const Color(0xFF10B981) 
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container();
  }

  Widget _buildFeaturedPropertiesSection() {
    return Container();
  }

  Widget _buildTopLocalitiesSection() {
    return Container();
  }

  Widget _buildTestimonialsSection() {
    return Container();
  }

  Widget _buildFooter() {
    return Container();
  }
}
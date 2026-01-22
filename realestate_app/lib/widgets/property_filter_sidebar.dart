import 'package:flutter/material.dart';
import '../models/property_model.dart'; 

class PropertyFilterSidebar extends StatefulWidget {
  final PropertyFilters currentFilters;
  final Function(PropertyFilters) onFilterChanged;

  const PropertyFilterSidebar({
    Key? key,
    required this.currentFilters,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<PropertyFilterSidebar> createState() => _PropertyFilterSidebarState();
}

class _PropertyFilterSidebarState extends State<PropertyFilterSidebar> with SingleTickerProviderStateMixin {
  late PropertyFilters _filters;
  late TabController _tabController;

  // --- UI Constants ---
  final Color _primaryColor = const Color(0xFF10B981); // EstateHub Green
  final Color _badgeColor = const Color(0xFFEF5350);   
  final Color _textDark = const Color(0xFF111827);
  final Color _textGrey = const Color(0xFF6B7280);
  
  // --- UI State Variables ---
  String _selectedLandExtent = 'Any';
  String _selectedBuildup = 'Any';
  String _selectedFurnishing = 'Any'; 
  final List<String> _selectedAmenitiesNearby = []; 
  bool _showUnlockOverlay = false; 

  // --- Data Lists ---
  final List<String> _buyTypes = [
    'Plot', 'Commercial Land', 'Flat', 'Individual House',
    'Individual Villa', 'Complex', 'Commercial Building'
  ];

  final List<String> _rentTypes = [
    'Flat', 'Individual House', 'Individual Villa', 'PG / Hostel',
    'Shared Room', 'Independent Floor', 'Commercial Building',
    'Office Space', 'Shop / Showroom', 'Warehouse / Godown'
  ];

  // --- FILTER ID MAPPING ---
  // 1:LandExtent, 2:Buildup, 3:BHK, 4:Price, 5:Availability, 6:Tenants, 7:Furnishing
  // 8:Age, 9:Bathroom, 10:Floors, 11:Status, 12:Parking, 13:Amenities(Near), 
  // 14:Amenities(In), 15:Facing, 16:ShowOnly, 17:Occupancy, 18:Food

  final Map<String, List<List<int>>> _buyRules = {
    'Plot': [[1, 4, 13, 16], []], 
    'Commercial Land': [[1, 4, 13, 16], []],
    'Flat': [[1, 2, 3, 4, 7, 12, 15, 16], [8, 9, 10, 11, 13, 14]],
    'Individual House': [[1, 2, 3, 4, 7, 12, 15, 16], [8, 9, 10, 11, 13, 14]],
    'Individual Villa': [[1, 2, 3, 4, 7, 12, 15, 16], [8, 9, 10, 11, 13, 14]],
    'Complex': [[1, 2, 4, 12, 15, 16], [8, 10, 11, 13, 14]],
    'Commercial Building': [[1, 2, 4, 12, 15, 16], [8, 10, 11, 13, 14]],
  };

  final Map<String, List<List<int>>> _rentRules = {
    'Flat': [[3, 4, 5, 6, 7, 12, 15], [8, 9, 10, 11, 13, 14, 16]],
    'Individual House': [[3, 4, 5, 6, 7, 12, 15], [8, 9, 10, 11, 13, 14, 16]],
    'Individual Villa': [[3, 4, 5, 6, 7, 12, 15], [8, 9, 10, 11, 13, 14, 16]],
    'PG / Hostel': [[3, 4, 5, 6, 7, 12, 15, 18], [8, 9, 10, 11, 13, 14, 16]],
    'Shared Room': [[3, 4, 5, 6, 7, 12, 15, 17], [8, 9, 10, 11, 13, 14, 16]],
    'Independent Floor': [[3, 4, 5, 6, 7, 12, 15, 17], [8, 9, 10, 11, 13, 14, 16]],
    'Commercial Building': [[3, 4, 5, 6, 12, 15, 17], [8, 9, 10, 11, 13, 14, 16]],
    'Office Space': [[3, 4, 5, 6, 12, 15, 17], [8, 9, 10, 11, 13, 14, 16]],
    'Shop / Showroom': [[3, 4, 5, 6, 12, 15, 17], [8, 9, 10, 11, 13, 14, 16]],
    'Warehouse / Godown': [[3, 4, 5, 6, 12, 15, 17], [8, 9, 10, 11, 13, 14, 16]],
  };

  // --- Option Lists ---
  final List<String> _bhkOptions = ['1 BHK', '2 BHK', '3 BHK', '4 BHK', '4+ BHK'];
  final List<String> _availabilityOptions = ['Immediate', 'Within 15 Days', 'Within 30 Days', 'After 30 Days'];
  final List<String> _tenantOptions = ['Family', 'Company', 'Bachelor Male', 'Bachelor Female'];
  final List<String> _parkingOptions = ['2 Wheeler', '4 Wheeler'];
  // Display labels for furnishing
  final List<String> _furnishingDisplayOptions = ['Unfurnished', 'Semi Furnished', 'Fully Furnished'];
  final List<String> _foodOptions = ['Breakfast', 'Lunch', 'Dinner', 'All Meals'];
  final List<String> _occupancyOptions = ['Single', 'Double', 'Triple', 'Four+'];
  final List<String> _bathroomOptions = ['1', '2', '3', '4+'];
  final List<String> _floorOptions = ['Ground', '1 to 3', '4 to 7', '8+'];
  final List<String> _statusOptions = ['Ready to Move', 'Under Construction', 'New Launch'];
  final List<String> _showOnlyOptions = ['With Photos', 'With Videos'];
  
  // Premium Lists
  final List<String> _amenitiesNearby = ['School', 'Park', 'Gated Community', 'Street solar Lights', '24x7 Surveillance', 'Theater', 'Hospital', 'Bus Stand'];
  final List<String> _amenitiesInside = ['Swimming Pool', 'Portico', 'Terrace Garden', 'Pooja Room', 'Store room', 'Lift', 'Gym', 'Power Backup'];
  final List<String> _facingDirs = ['North', 'South', 'East', 'West', 'North-East', 'South-West'];
  final List<String> _ages = ['Less then 5 years', '5 to 10', '10 to 15', '15 to 20', '20+'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filters = widget.currentFilters;
    _enforceCorrectPriceRange();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _showUnlockOverlay = false);
      }
    });
  }

  // --- LOGIC ---
  bool _shouldShow(int filterId, {bool isPremium = false}) {
    if (_filters.propertyTypes.isEmpty) {
      return [1, 2, 3, 4, 12, 16].contains(filterId); 
    }

    final rulesMap = _isRentMode ? _rentRules : _buyRules;
    for (String type in _filters.propertyTypes) {
      if (rulesMap.containsKey(type)) {
        List<int> allowedIds = rulesMap[type]![isPremium ? 1 : 0];
        if (allowedIds.contains(filterId)) return true;
      }
    }
    return false;
  }

  void _enforceCorrectPriceRange() {
    double limit = _isRentMode ? 500000 : 100000000;
    if (_filters.maxPrice > limit || _filters.maxPrice == 0) _filters.maxPrice = limit;
    if (_filters.minPrice > limit) _filters.minPrice = 0;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _notify() {
    setState(() {});
    widget.onFilterChanged(_filters);
  }

  void _resetFilters() {
    setState(() {
      var currentMode = _filters.lookingFor;
      _filters = PropertyFilters(lookingFor: currentMode); 
      _showUnlockOverlay = false;
      _enforceCorrectPriceRange();
      _selectedLandExtent = 'Any';
      _selectedBuildup = 'Any';
      _selectedFurnishing = 'Any';
      _selectedAmenitiesNearby.clear();
    });
    _notify();
  }

  bool get _isRentMode => _filters.lookingFor == LookingFor.rent;

  // Helper to map Display Label back to Data Model value
  String _furnishingToInternal(String display) {
    if (display == 'Unfurnished') return 'None';
    if (display == 'Semi Furnished') return 'Semi';
    if (display == 'Fully Furnished') return 'Full';
    return 'Any';
  }

  String _formatPrice(double price) {
    if (price == 0) return "₹ 0";
    if (_isRentMode) {
      if (price >= 100000) return "₹ ${(price / 100000).toStringAsFixed(1)} L";
      if (price >= 1000) return "₹ ${(price / 1000).toStringAsFixed(0)} K";
      return "₹ ${price.toStringAsFixed(0)}";
    } else {
      if (price >= 10000000) return "₹ ${(price / 10000000).toStringAsFixed(1)} Cr";
      if (price >= 100000) return "₹ ${(price / 100000).toStringAsFixed(0)} L";
      return "₹ ${price.toStringAsFixed(0)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canReset = _filters.propertyTypes.isNotEmpty || _filters.minPrice > 0; 

    return Container(
      width: 320, 
      // *** ADDED SPACE HERE (Left Margin) ***
      margin: const EdgeInsets.only(left: 20), 
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(), 
              children: [
                // === TAB 1: MAIN FILTERS ===
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBuyRentToggle(),
                      const SizedBox(height: 24),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildSectionTitle("Property Type"), _buildResetButton(canReset)]),
                      const SizedBox(height: 8),
                      
                      ...(_isRentMode ? _rentTypes : _buyTypes).map((type) => _buildCheckbox(type, _filters.propertyTypes)),
                      const Divider(height: 32),

                      // ID 4: Price
                      if (_shouldShow(4)) _buildPriceSection(),

                      // ID 3: BHK Type
                      if (_shouldShow(3)) _buildFilterSection("BHK Type", _bhkOptions, isMultiSelect: true, selectedList: _filters.bhk.map((e) => '$e BHK').toList()),

                      // ID 5: Availability
                      if (_shouldShow(5)) _buildFilterSection("Availability", _availabilityOptions),

                      // ID 6: Preferred Tenants
                      if (_shouldShow(6)) _buildFilterSection("Preferred Tenants", _tenantOptions),

                      // ID 1: Land Extent - FIXED NULL SAFETY
                      if (_shouldShow(1)) ...[
                        _buildSectionTitle("Land Extent"),
                        _buildRadioList(
                          ['Any', '400-800 sqft', '800-1600 sqft', '1600+ sqft'], 
                          _selectedLandExtent, 
                          (val) => setState(() => _selectedLandExtent = val ?? 'Any')
                        ),
                        const Divider(height: 32),
                      ],

                      // ID 2: Buildup Area - FIXED NULL SAFETY
                      if (_shouldShow(2)) ...[
                        _buildSectionTitle("Buildup Area"),
                        _buildRadioList(
                          ['Any', '400-800 sqft', '800-1600 sqft', '1600+ sqft'], 
                          _selectedBuildup, 
                          (val) => setState(() => _selectedBuildup = val ?? 'Any')
                        ),
                        const Divider(height: 32),
                      ],

                      // ID 7: Furnishing (Updated UI)
                      if (_shouldShow(7)) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: RichText(
                            text: TextSpan(
                              text: "Furnishing Status",
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: _textDark),
                              children: const [
                                TextSpan(text: " *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                              ],
                            ),
                          ),
                        ),
                        // Horizontal List of Big Buttons
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _furnishingDisplayOptions.map((label) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: _buildFurnishingButton(label),
                              );
                            }).toList(),
                          ),
                        ),
                        const Divider(height: 32),
                      ],

                      // ID 12: Parking
                      if (_shouldShow(12)) ...[
                        _buildSectionTitle("Parking"),
                        const SizedBox(height: 8),
                        Column(children: _parkingOptions.map((e) => _buildCheckbox(e, [])).toList()),
                        const Divider(height: 32),
                      ],

                      // ID 13: Amenities Nearby (Main Tab for Plot/Commercial Land)
                      if (_shouldShow(13)) ...[
                        _buildSectionTitle("Amenities (Nearby)"),
                        const SizedBox(height: 8),
                        Column(
                          children: _amenitiesNearby.map((amenity) => _buildCheckbox(amenity, _selectedAmenitiesNearby)).toList(),
                        ),
                        const Divider(height: 32),
                      ],

                      // ID 15: Facing
                      if (_shouldShow(15)) _buildFilterSection("Property Facing", _facingDirs),

                      // ID 16: Show Only
                      if (_shouldShow(16)) ...[
                        _buildSectionTitle("Show Only"),
                        const SizedBox(height: 8),
                        Column(children: _showOnlyOptions.map((e) => _buildCheckbox(e, [])).toList()),
                        const Divider(height: 32),
                      ],

                      // ID 17: Occupancy
                      if (_shouldShow(17)) _buildFilterSection("Occupancy", _occupancyOptions),

                      // ID 18: Food Included
                      if (_shouldShow(18)) _buildFilterSection("Food Included", _foodOptions),
                    ],
                  ),
                ),

                // === TAB 2: PREMIUM FILTERS ===
                _buildPremiumFiltersTab(canReset),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER METHODS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _textDark,
        ),
      ),
    );
  }

  Widget _buildResetButton(bool canReset) {
    return TextButton(
      onPressed: canReset ? _resetFilters : null,
      child: Text(
        'Reset',
        style: TextStyle(
          color: canReset ? _primaryColor : Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCheckbox(String label, List<String> selectedList) {
    final isSelected = selectedList.contains(label);
    return CheckboxListTile(
      title: Text(label, style: TextStyle(fontSize: 14, color: _textDark)),
      value: isSelected,
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            selectedList.add(label);
          } else {
            selectedList.remove(label);
          }
        });
        _notify();
      },
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      contentPadding: EdgeInsets.zero,
      activeColor: _primaryColor,
    );
  }

  Widget _buildRadioList(List<String> options, String currentValue, Function(String?) onChanged) {
    return Column(
      children: options.map((option) {
        return RadioListTile<String>(
          title: Text(option, style: TextStyle(fontSize: 14, color: _textDark)),
          value: option,
          groupValue: currentValue,
          onChanged: (String? value) {
            onChanged(value);
            _notify();
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
          activeColor: _primaryColor,
        );
      }).toList(),
    );
  }

  Widget _buildRectOption(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.white : _textDark,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRadioUIOnly(String label) {
    return RadioListTile<String>(
      title: Text(label, style: TextStyle(fontSize: 14, color: _textDark)),
      value: label,
      groupValue: null,
      onChanged: null,
      dense: true,
      contentPadding: EdgeInsets.zero,
      activeColor: _primaryColor,
    );
  }

  Widget _buildCheckboxUIOnly(String label) {
    return CheckboxListTile(
      title: Text(label, style: TextStyle(fontSize: 14, color: _textDark)),
      value: false,
      onChanged: null,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      contentPadding: EdgeInsets.zero,
      activeColor: _primaryColor,
    );
  }

  // --- NEW WIDGET: Big Furnishing Button ---
  Widget _buildFurnishingButton(String label) {
    // Map display label to internal 'None', 'Semi', 'Full'
    final internalVal = _furnishingToInternal(label);
    final isSelected = _selectedFurnishing == internalVal;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFurnishing = isSelected ? 'Any' : internalVal;
          _filters.condition = _selectedFurnishing == 'Any' ? null : _selectedFurnishing;
        });
        _notify();
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildSectionTitle(_isRentMode ? "Rent Range" : "Price Range")]),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatPrice(_filters.minPrice), style: TextStyle(color: _textGrey, fontSize: 12, fontWeight: FontWeight.w600)),
              Text(_formatPrice(_filters.maxPrice), style: TextStyle(color: _textGrey, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _primaryColor, 
            thumbColor: _primaryColor, 
            trackHeight: 4.0,
            overlayColor: _primaryColor.withOpacity(0.1), 
            rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: RangeSlider(
            values: RangeValues(
              _filters.minPrice.clamp(0, _isRentMode ? 500000 : 100000000), 
              _filters.maxPrice.clamp(0, _isRentMode ? 500000 : 100000000)
            ),
            min: 0, 
            max: _isRentMode ? 500000 : 100000000,
            onChanged: (RangeValues values) { 
              setState(() { 
                _filters.minPrice = values.start; 
                _filters.maxPrice = values.end; 
              }); 
            },
          ),
        ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildFilterSection(String title, List<String> options, {bool isMultiSelect = false, List<String>? selectedList}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, 
          runSpacing: 8, 
          children: options.map((e) => _buildRectOption(e, false, (){})).toList()
        ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildPremiumFiltersTab(bool canReset) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _showUnlockOverlay = true),
            child: AbsorbPointer(
              absorbing: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [_buildResetButton(canReset)]),
                  
                  if (_shouldShow(8, isPremium: true)) ...[
                    _buildSectionTitle("Age of Property"),
                    ..._ages.map((a) => _buildRadioUIOnly(a)),
                    const Divider(height: 30),
                  ],
                  if (_shouldShow(9, isPremium: true)) ...[
                    _buildSectionTitle("Bathrooms"),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, children: _bathroomOptions.map((e) => _buildRectOption(e, false, (){})).toList()),
                    const Divider(height: 30),
                  ],
                  if (_shouldShow(10, isPremium: true)) ...[
                    _buildSectionTitle("Floors"),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, children: _floorOptions.map((e) => _buildRectOption(e, false, (){})).toList()),
                    const Divider(height: 30),
                  ],
                  if (_shouldShow(11, isPremium: true)) ...[
                    _buildSectionTitle("Property Status"),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, children: _statusOptions.map((e) => _buildRectOption(e, false, (){})).toList()),
                    const Divider(height: 30),
                  ],
                  if (_shouldShow(13, isPremium: true)) ...[
                    _buildSectionTitle("Amenities (Nearby)"),
                    ..._amenitiesNearby.take(5).map((a) => _buildCheckboxUIOnly(a)),
                    const Divider(height: 30),
                  ],
                  if (_shouldShow(14, isPremium: true)) ...[
                    _buildSectionTitle("Amenities (Inside)"),
                    ..._amenitiesInside.take(4).map((a) => _buildCheckboxUIOnly(a)),
                    const Divider(height: 30),
                  ],
                  if (_shouldShow(16, isPremium: true)) ...[
                    _buildSectionTitle("Show Only"),
                    ..._showOnlyOptions.map((a) => _buildCheckboxUIOnly(a)),
                    const Divider(height: 30),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),

        if (_showUnlockOverlay)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.9), 
              child: Center(
                child: Container(
                  width: 260,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(16), 
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15), 
                        blurRadius: 20, 
                        offset: const Offset(0, 8)
                      )
                    ], 
                    border: Border.all(color: Colors.grey.shade200)
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight, 
                        child: InkWell(
                          onTap: () => setState(() => _showUnlockOverlay = false), 
                          borderRadius: BorderRadius.circular(20), 
                          child: const Icon(Icons.close, size: 22, color: Colors.grey)
                        )
                      ),
                      const Icon(Icons.lock_outline_rounded, size: 48, color: Color(0xFF00796B)),
                      const SizedBox(height: 16),
                      const Text(
                        "Unlock Premium Filters", 
                        textAlign: TextAlign.center, 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Fasten your search using Exclusive Filters!", 
                        textAlign: TextAlign.center, 
                        style: TextStyle(fontSize: 12, color: Colors.grey)
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity, 
                        height: 44, 
                        child: ElevatedButton(
                          onPressed: () => setState(() => _showUnlockOverlay = false), 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), 
                            elevation: 0
                          ), 
                          child: const Text(
                            "Unlock Filters", 
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                          )
                        )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // --- BASIC WIDGETS ---
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: TabBar(
        controller: _tabController,
        labelColor: _primaryColor, 
        unselectedLabelColor: _textGrey, 
        indicatorColor: _primaryColor, 
        indicatorWeight: 3,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8), 
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        onTap: (index) => setState(() => _showUnlockOverlay = false),
        tabs: [
          const Tab(text: "Filters"),
          Tab(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Premium Filters"),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), 
                    decoration: BoxDecoration(
                      color: _badgeColor, 
                      borderRadius: BorderRadius.circular(4)
                    ), 
                    child: const Text(
                      "New", 
                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)
                    )
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyRentToggle() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _filters.lookingFor = LookingFor.buy;
                  _enforceCorrectPriceRange();
                });
                _notify();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isRentMode ? _primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    'Buy',
                    style: TextStyle(
                      color: !_isRentMode ? Colors.white : _textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _filters.lookingFor = LookingFor.rent;
                  _enforceCorrectPriceRange();
                });
                _notify();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isRentMode ? _primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    'Rent',
                    style: TextStyle(
                      color: _isRentMode ? Colors.white : _textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
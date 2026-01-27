import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_property_screen_2.dart';
import '../providers/property_form_provider.dart';

// ENUMS
enum PropertyFor { sell, rent }

enum FurnishingStatus {
  unfurnished('Unfurnished'),
  semiFurnished('Semi Furnished'),
  fullyFurnished('Fully Furnished');

  final String displayName;
  const FurnishingStatus(this.displayName);
}

enum FacingDirection {
  north('North'),
  south('South'),
  east('East'),
  west('West'),
  northEast('North-East'),
  northWest('North-West'),
  southEast('South-East'),
  southWest('South-West');

  final String displayName;
  const FacingDirection(this.displayName);
}

// NEW: Measurement Unit Enum
enum MeasurementUnit {
  acres('Acres'),
  cents('Cents'),
  ares('Ares'),
  hectare('Hectare'),
  squareFeet('Square Feet'),
  squareMeter('Square Meter');

  final String displayName;
  const MeasurementUnit(this.displayName);
}

// PROPERTY TYPES FOR SELL
enum SellPropertyType {
  plot('Plot/Land'),
  commercialLand('Commercial Land'),
  flat('Flat'),
  house('Individual House'),
  villa('Individual Villa'),
  complex('Complex'),
  commercialBuilding('Commercial Building');

  final String displayName;
  const SellPropertyType(this.displayName);
}

// PROPERTY TYPES FOR RENT
enum RentPropertyType {
  flat('Flat'),
  house('Individual House'),
  villa('Individual Villa'),
  pgHostel('PG / Hostel'),
  sharedRoom('Shared Room'),
  independentFloor('Independent Floor'),
  commercialBuilding('Commercial Building'),
  officeSpace('Office Space'),
  shopShowroom('Shop / Showroom'),
  warehouse('Warehouse / Godown');

  final String displayName;
  const RentPropertyType(this.displayName);
}

// FIELD CONFIG MODEL
class Step1Config {
  final bool builtUpArea;
  final bool bedrooms;
  final bool bathrooms;
  final bool floorNo;
  final bool totalFloors;
  final bool furnishing;
  final bool numberOfBeds; // NEW: For PG/Hostel and Shared Room
  final bool peoplePerRoom; // NEW: For PG/Hostel and Shared Room

  const Step1Config({
    this.builtUpArea = false,
    this.bedrooms = false,
    this.bathrooms = false,
    this.floorNo = false,
    this.totalFloors = false,
    this.furnishing = false,
    this.numberOfBeds = false,
    this.peoplePerRoom = false,
  });
}

// FIELD CONFIG MAP FOR SELL
final Map<SellPropertyType, Step1Config> sellFieldConfig = {
  SellPropertyType.plot: const Step1Config(),
  SellPropertyType.commercialLand: const Step1Config(),
  SellPropertyType.flat: const Step1Config(
    builtUpArea: true,
    bedrooms: true,
    bathrooms: true,
    floorNo: true,
    totalFloors: true,
    furnishing: true,
  ),
  SellPropertyType.house: const Step1Config(
    builtUpArea: true,
    bedrooms: true,
    bathrooms: true,
    totalFloors: true,
    furnishing: true,
  ),
  SellPropertyType.villa: const Step1Config(
    builtUpArea: true,
    bedrooms: true,
    bathrooms: true,
    furnishing: true,
  ),
  SellPropertyType.complex: const Step1Config(
    builtUpArea: true,
    totalFloors: true,
  ),
  SellPropertyType.commercialBuilding: const Step1Config(
    builtUpArea: true,
    totalFloors: true,
  ),
};

// FIELD CONFIG MAP FOR RENT
final Map<RentPropertyType, Step1Config> rentFieldConfig = {
  RentPropertyType.flat: const Step1Config(
    bedrooms: true,
    bathrooms: true,
    floorNo: true,
    totalFloors: true,
    furnishing: true,
  ),
  RentPropertyType.house: const Step1Config(
    bedrooms: true,
    bathrooms: true,
    totalFloors: true,
    furnishing: true,
  ),
  RentPropertyType.villa: const Step1Config(
    bedrooms: true,
    bathrooms: true,
    furnishing: true,
  ),
  // NEW: Special config for PG/Hostel
  RentPropertyType.pgHostel: const Step1Config(
    bathrooms: true,
    furnishing: true,
    numberOfBeds: true,
    peoplePerRoom: true,
  ),
  // NEW: Special config for Shared Room
  RentPropertyType.sharedRoom: const Step1Config(
    bathrooms: true,
    furnishing: true,
    numberOfBeds: true,
    peoplePerRoom: true,
  ),
  RentPropertyType.independentFloor: const Step1Config(
    floorNo: true,
    totalFloors: true,
    furnishing: true,
  ),
  RentPropertyType.commercialBuilding: const Step1Config(
    totalFloors: true,
  ),
  RentPropertyType.officeSpace: const Step1Config(),
  RentPropertyType.shopShowroom: const Step1Config(),
  RentPropertyType.warehouse: const Step1Config(),
};

// CONSTANTS
final List<String> bedroomOptions = ['1 BHK', '2 BHK', '3 BHK', '4 BHK', 'Custom'];
final List<String> bathroomOptions = ['1', '2', '3', '4', 'Custom'];
final List<String> numberOfBedsOptions = ['1', '2', '3', '4', '5', '6', 'Custom']; // NEW
final List<String> peoplePerRoomOptions = ['1', '2', '3', '4', '5', '6', 'Custom']; // NEW

final List<String> furnishingItems = [
  'Beds',
  'Wardrobe',
  'Sofa',
  'Dining Table',
  'TV',
  'AC',
  'Washing Machine',
  'Refrigerator',
  'Geyser',
  'Modular Kitchen',
];

final List<String> insideAmenities = [
  'Swimming Pool',
  'Parking',
  'Garden',
  'Gym',
  'Lift',
  'Security',
  'CCTV',
  'Water Supply',
  'Piped Gas',
];

final List<String> nearbyAmenities = [
  'School',
  'Hospital',
  'Shopping Mall',
  'Restaurant',
  'Bus Stop',
  'ATM',
  'Pharmacy',
  'Gym',
  'Market',
  'Cinema Hall',
  'Airport',
  'Railway Station',
  'Police Station',
  'Bank',
  'Library',
  'Beach',
];

// MAIN SCREEN
class AddPropertyStep1Screen extends StatefulWidget {
  const AddPropertyStep1Screen({Key? key}) : super(key: key);

  @override
  State<AddPropertyStep1Screen> createState() => _AddPropertyStep1ScreenState();
}

class _AddPropertyStep1ScreenState extends State<AddPropertyStep1Screen> {
  // Form State
  PropertyFor _propertyFor = PropertyFor.sell;
  SellPropertyType? _selectedSellType;
  RentPropertyType? _selectedRentType;

  FacingDirection? _facing;
  FurnishingStatus? _furnishing;
  String? _selectedBedroom;
  String? _selectedBathroom;
  String? _selectedNumberOfBeds; // NEW
  String? _selectedPeoplePerRoom; // NEW
  
  MeasurementUnit? _selectedMeasurementUnit;

  // Controllers
  final _propertyNameController = TextEditingController();
  final _propertyDescriptionController = TextEditingController();
  final _measurementValueController = TextEditingController();
  final _builtUpAreaController = TextEditingController();
  final _floorNoController = TextEditingController();
  final _totalFloorsController = TextEditingController();
  final _totalBlocksController = TextEditingController();
  final _customBedroomController = TextEditingController();
  final _customBathroomController = TextEditingController();
  final _customNumberOfBedsController = TextEditingController(); // NEW
  final _customPeoplePerRoomController = TextEditingController(); // NEW
  
  // Boundary Controllers
  final _boundaryNorthController = TextEditingController();
  final _boundarySouthController = TextEditingController();
  final _boundaryEastController = TextEditingController();
  final _boundaryWestController = TextEditingController();

  // Selected Items
  final Set<String> _selectedFurnishings = {};
  final Set<String> _selectedInsideAmenities = {};
  final Map<String, TextEditingController> _amenityControllers = {};
  final List<String> _customFurnishings = [];
  final List<String> _customInsideAmenities = [];
  final List<String> _customAmenities = [];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final provider = Provider.of<PropertyFormProvider>(context, listen: false);
    final formData = provider.formData;

    if (formData.propertyName != null) {
      _propertyNameController.text = formData.propertyName!;
    }
    if (formData.propertyDescription != null) {
      _propertyDescriptionController.text = formData.propertyDescription!;
    }
    if (formData.propertyFor != null) {
      _propertyFor = formData.propertyFor!;
    }
    if (formData.sellPropertyType != null) {
      _selectedSellType = formData.sellPropertyType;
    }
    if (formData.rentPropertyType != null) {
      _selectedRentType = formData.rentPropertyType;
    }
    if (formData.builtUpArea != null) {
      _builtUpAreaController.text = formData.builtUpArea!;
    }
    if (formData.bedrooms != null) {
      _selectedBedroom = formData.bedrooms;
    }
    if (formData.bathrooms != null) {
      _selectedBathroom = formData.bathrooms;
    }
    // NEW: Load beds and people data
    if (formData.numberOfBeds != null) {
      _selectedNumberOfBeds = formData.numberOfBeds;
    }
    if (formData.peoplePerRoom != null) {
      _selectedPeoplePerRoom = formData.peoplePerRoom;
    }
    if (formData.floorNo != null) {
      _floorNoController.text = formData.floorNo!;
    }
    if (formData.totalFloors != null) {
      _totalFloorsController.text = formData.totalFloors!;
    }
    if (formData.facingDirection != null) {
      _facing = formData.facingDirection;
    }
    if (formData.furnishingStatus != null) {
      _furnishing = formData.furnishingStatus;
    }
    if (formData.furnishingItems != null) {
      _selectedFurnishings.addAll(formData.furnishingItems!);
    }
    if (formData.nearbyAmenities != null) {
      for (var item in formData.nearbyAmenities!) {
        _amenityControllers[item] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    _propertyDescriptionController.dispose();
    _measurementValueController.dispose();
    _builtUpAreaController.dispose();
    _floorNoController.dispose();
    _totalFloorsController.dispose();
    _totalBlocksController.dispose();
    _customBedroomController.dispose();
    _customBathroomController.dispose();
    _customNumberOfBedsController.dispose(); // NEW
    _customPeoplePerRoomController.dispose(); // NEW
    _boundaryNorthController.dispose();
    _boundarySouthController.dispose();
    _boundaryEastController.dispose();
    _boundaryWestController.dispose();

    for (var controller in _amenityControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  Step1Config _getConfig() {
    if (_propertyFor == PropertyFor.sell && _selectedSellType != null) {
      return sellFieldConfig[_selectedSellType]!;
    } else if (_propertyFor == PropertyFor.rent && _selectedRentType != null) {
      return rentFieldConfig[_selectedRentType]!;
    }
    return const Step1Config();
  }

  String _getPropertyNameLabel() {
    if (_propertyFor == PropertyFor.sell && _selectedSellType != null) {
      switch (_selectedSellType!) {
        case SellPropertyType.plot:
          return 'Plot Name';
        case SellPropertyType.commercialLand:
          return 'Commercial Land Name';
        case SellPropertyType.flat:
          return 'Flat Name';
        case SellPropertyType.house:
          return 'House Name';
        case SellPropertyType.villa:
          return 'Villa Name';
        case SellPropertyType.complex:
          return 'Complex Name';
        case SellPropertyType.commercialBuilding:
          return 'Commercial Building Name';
      }
    } else if (_propertyFor == PropertyFor.rent && _selectedRentType != null) {
      switch (_selectedRentType!) {
        case RentPropertyType.flat:
          return 'Flat Name';
        case RentPropertyType.house:
          return 'House Name';
        case RentPropertyType.villa:
          return 'Villa Name';
        case RentPropertyType.pgHostel:
          return 'PG/Hostel Name';
        case RentPropertyType.sharedRoom:
          return 'Shared Room Name';
        case RentPropertyType.independentFloor:
          return 'Independent Floor Name';
        case RentPropertyType.commercialBuilding:
          return 'Commercial Building Name';
        case RentPropertyType.officeSpace:
          return 'Office Space Name';
        case RentPropertyType.shopShowroom:
          return 'Shop/Showroom Name';
        case RentPropertyType.warehouse:
          return 'Warehouse Name';
      }
    }
    return 'Property Name';
  }

  bool _shouldShowFacingDirection() {
    if (_propertyFor == PropertyFor.sell && _selectedSellType != null) {
      return _selectedSellType != SellPropertyType.plot &&
          _selectedSellType != SellPropertyType.commercialLand;
    }
    return true;
  }

  bool _shouldShowInsideAmenities() {
    if (_propertyFor == PropertyFor.sell && _selectedSellType != null) {
      return _selectedSellType != SellPropertyType.plot &&
          _selectedSellType != SellPropertyType.commercialLand;
    }
    return true;
  }

  bool _shouldShowTotalBlocks() {
    return _propertyFor == PropertyFor.sell &&
        _selectedSellType == SellPropertyType.complex;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleNextStep() {
    final config = _getConfig();

    // Validate required fields
    if (_propertyNameController.text.trim().isEmpty) {
      _showError('Please enter a property name');
      return;
    }

    if (_propertyFor == PropertyFor.sell && _selectedSellType == null) {
      _showError('Please select a property type');
      return;
    }

    if (_propertyFor == PropertyFor.rent && _selectedRentType == null) {
      _showError('Please select a property type');
      return;
    }

    // Validate measurement
    if (_selectedMeasurementUnit == null) {
      _showError('Please select a measurement unit');
      return;
    }
    if (_measurementValueController.text.trim().isEmpty) {
      _showError('Please enter measurement value');
      return;
    }

    // Validate built-up area
    if (config.builtUpArea && _builtUpAreaController.text.trim().isEmpty) {
      _showError('Please enter built-up area');
      return;
    }

    // Validate facing direction
    if (_shouldShowFacingDirection() && _facing == null) {
      _showError('Please select facing direction');
      return;
    }

    // Validate bedrooms
    if (config.bedrooms && _selectedBedroom == null) {
      _showError('Please select number of bedrooms');
      return;
    }
    if (_selectedBedroom == 'Custom' && _customBedroomController.text.trim().isEmpty) {
      _showError('Please enter custom bedroom count');
      return;
    }

    // Validate bathrooms
    if (config.bathrooms && _selectedBathroom == null) {
      _showError('Please select number of bathrooms');
      return;
    }
    if (_selectedBathroom == 'Custom' && _customBathroomController.text.trim().isEmpty) {
      _showError('Please enter custom bathroom count');
      return;
    }

    // NEW: Validate number of beds
    if (config.numberOfBeds && _selectedNumberOfBeds == null) {
      _showError('Please select number of beds in a room');
      return;
    }
    if (_selectedNumberOfBeds == 'Custom' && _customNumberOfBedsController.text.trim().isEmpty) {
      _showError('Please enter custom number of beds');
      return;
    }

    // NEW: Validate people per room
    if (config.peoplePerRoom && _selectedPeoplePerRoom == null) {
      _showError('Please select how many people allowed per room');
      return;
    }
    if (_selectedPeoplePerRoom == 'Custom' && _customPeoplePerRoomController.text.trim().isEmpty) {
      _showError('Please enter custom people per room count');
      return;
    }

    // Validate floor info
    if (config.floorNo && _floorNoController.text.trim().isEmpty) {
      _showError('Please enter floor number');
      return;
    }
    if (config.totalFloors && _totalFloorsController.text.trim().isEmpty) {
      _showError('Please enter total floors');
      return;
    }

    // Validate total blocks
    if (_shouldShowTotalBlocks() && _totalBlocksController.text.trim().isEmpty) {
      _showError('Please enter total number of blocks');
      return;
    }

    // Validate furnishing status
    if (config.furnishing && _furnishing == null) {
      _showError('Please select furnishing status');
      return;
    }

    // Validate nearby amenities
    for (var entry in _amenityControllers.entries) {
      if (entry.value.text.trim().isEmpty) {
        _showError('Please enter name for ${entry.key}');
        return;
      }
    }

    // Save all Step 1 data to provider
    final provider = Provider.of<PropertyFormProvider>(context, listen: false);
    final formData = provider.formData;

    formData.propertyName = _propertyNameController.text.trim();
    formData.propertyDescription = _propertyDescriptionController.text.trim();
    formData.propertyFor = _propertyFor;
    formData.sellPropertyType = _selectedSellType;
    formData.rentPropertyType = _selectedRentType;
    
    // Save measurement data
    if (_selectedMeasurementUnit != null && _measurementValueController.text.trim().isNotEmpty) {
      formData.landExtent = '${_measurementValueController.text.trim()} ${_selectedMeasurementUnit!.displayName}';
      formData.measurementValue = _measurementValueController.text.trim();
      formData.measurementUnit = _selectedMeasurementUnit!.displayName;
    }

    // Save boundary data
    if (_boundaryNorthController.text.trim().isNotEmpty) {
      formData.boundaryNorth = _boundaryNorthController.text.trim();
    }
    if (_boundarySouthController.text.trim().isNotEmpty) {
      formData.boundarySouth = _boundarySouthController.text.trim();
    }
    if (_boundaryEastController.text.trim().isNotEmpty) {
      formData.boundaryEast = _boundaryEastController.text.trim();
    }
    if (_boundaryWestController.text.trim().isNotEmpty) {
      formData.boundaryWest = _boundaryWestController.text.trim();
    }
    
    formData.builtUpArea = _builtUpAreaController.text.trim().isNotEmpty 
        ? _builtUpAreaController.text.trim() 
        : null;
    formData.bedrooms = _selectedBedroom;
    formData.bathrooms = _selectedBathroom;
    
    // NEW: Save beds and people data
    formData.numberOfBeds = _selectedNumberOfBeds;
    formData.peoplePerRoom = _selectedPeoplePerRoom;
    
    formData.floorNo = _floorNoController.text.trim().isNotEmpty 
        ? _floorNoController.text.trim() 
        : null;
    formData.totalFloors = _totalFloorsController.text.trim().isNotEmpty 
        ? _totalFloorsController.text.trim() 
        : null;
    formData.facingDirection = _facing;
    formData.furnishingStatus = _furnishing;

    // Collect selected furnishing items
    final selectedFurnishings = _selectedFurnishings.toList();
    formData.furnishingItems = selectedFurnishings.isNotEmpty ? selectedFurnishings : null;

    // Collect selected inside amenities
    final selectedInsideAmenities = _selectedInsideAmenities.toList();
    formData.insideAmenities = selectedInsideAmenities.isNotEmpty ? selectedInsideAmenities : null;

    // Collect selected nearby amenities
    final selectedAmenities = <String>[];
    for (var item in nearbyAmenities) {
      if (_amenityControllers.containsKey(item)) {
        selectedAmenities.add(item);
      }
    }
    selectedAmenities.addAll(_customAmenities);
    formData.nearbyAmenities = selectedAmenities.isNotEmpty ? selectedAmenities : null;

    provider.updateFormData(formData);

    // Navigate to Step 2
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPropertyStep2Screen(
          propertyFor: _propertyFor,
          sellType: _selectedSellType,
          rentType: _selectedRentType,
        ),
      ),
    );
  }

  void _handlePropertyForChange(PropertyFor newValue) {
    setState(() {
      _propertyFor = newValue;
      if (newValue == PropertyFor.sell) {
        _selectedSellType = null;
        _selectedRentType = null;
      } else {
        _selectedRentType = null;
        _selectedSellType = null;
      }
      _resetForm();
    });
  }

  void _resetForm() {
    _selectedBedroom = null;
    _selectedBathroom = null;
    _selectedNumberOfBeds = null; // NEW
    _selectedPeoplePerRoom = null; // NEW
    _facing = null;
    _furnishing = null;
    _selectedMeasurementUnit = null;

    _selectedFurnishings.clear();
    _selectedInsideAmenities.clear();

    for (var controller in _amenityControllers.values) {
      controller.dispose();
    }
    _amenityControllers.clear();

    _customFurnishings.clear();
    _customInsideAmenities.clear();
    _customAmenities.clear();

    _propertyNameController.clear();
    _propertyDescriptionController.clear();
    _measurementValueController.clear();
    _builtUpAreaController.clear();
    _floorNoController.clear();
    _totalFloorsController.clear();
    _totalBlocksController.clear();
    _customBedroomController.clear();
    _customBathroomController.clear();
    _customNumberOfBedsController.clear(); // NEW
    _customPeoplePerRoomController.clear(); // NEW
    _boundaryNorthController.clear();
    _boundarySouthController.clear();
    _boundaryEastController.clear();
    _boundaryWestController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF111827),
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Property',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Basic Details',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Basic Property Details',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Step 1 – Provide basic information about your property',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildPropertyForSection(),
                        const SizedBox(height: 24),

                        _buildPropertyTypeDropdown(),
                        const SizedBox(height: 24),

                        if (_selectedSellType != null || _selectedRentType != null) ...[
                          _buildPropertyNameField(),
                          const SizedBox(height: 24),

                          _buildPropertyDescriptionField(),
                          const SizedBox(height: 24),
                        ],

                        if (_shouldShowTotalBlocks()) ...[
                          _buildTextField(
                            label: 'Total Number of Blocks',
                            controller: _totalBlocksController,
                            hint: 'e.g., 5',
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Measurement Section
                        if (_selectedSellType != null || _selectedRentType != null) ...[
                          _buildMeasurementSection(),
                          const SizedBox(height: 20),
                        ],

                        // Boundaries Section
                        if (_propertyFor == PropertyFor.sell && 
                            (_selectedSellType != null)) ...[
                          _buildBoundariesSection(),
                          const SizedBox(height: 20),
                        ],

                        if (config.builtUpArea) ...[
                          _buildTextField(
                            label: 'Built-up Area (sqft)',
                            controller: _builtUpAreaController,
                            hint: 'e.g., 1200',
                          ),
                          const SizedBox(height: 20),
                        ],

                        if (config.bedrooms) ...[
                          _buildSelectionSection(
                            title: 'Bedrooms',
                            options: bedroomOptions,
                            selectedValue: _selectedBedroom,
                            onSelect: (value) => setState(() => _selectedBedroom = value),
                            customController: _customBedroomController,
                            isRequired: true,
                          ),
                          const SizedBox(height: 20),
                        ],

                        if (config.bathrooms) ...[
                          _buildSelectionSection(
                            title: 'Bathrooms',
                            options: bathroomOptions,
                            selectedValue: _selectedBathroom,
                            onSelect: (value) => setState(() => _selectedBathroom = value),
                            customController: _customBathroomController,
                            isRequired: true,
                          ),
                          const SizedBox(height: 20),
                        ],

                        // NEW: Number of Beds in a Room (for PG/Hostel and Shared Room)
                        if (config.numberOfBeds) ...[
                          _buildSelectionSection(
                            title: 'Number of Beds in a Room',
                            options: numberOfBedsOptions,
                            selectedValue: _selectedNumberOfBeds,
                            onSelect: (value) => setState(() => _selectedNumberOfBeds = value),
                            customController: _customNumberOfBedsController,
                            isRequired: true,
                          ),
                          const SizedBox(height: 20),
                        ],

                        // NEW: People Allowed Per Room (for PG/Hostel and Shared Room)
                        if (config.peoplePerRoom) ...[
                          _buildSelectionSection(
                            title: 'How Many People Allowed Per Room',
                            options: peoplePerRoomOptions,
                            selectedValue: _selectedPeoplePerRoom,
                            onSelect: (value) => setState(() => _selectedPeoplePerRoom = value),
                            customController: _customPeoplePerRoomController,
                            isRequired: true,
                          ),
                          const SizedBox(height: 20),
                        ],

                        if (config.floorNo && config.totalFloors) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: 'Floor No',
                                  controller: _floorNoController,
                                  hint: 'e.g., 2',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  label: 'Total Floors',
                                  controller: _totalFloorsController,
                                  hint: 'e.g., 10',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ] else if (config.totalFloors) ...[
                          _buildTextField(
                            label: 'Total Floors',
                            controller: _totalFloorsController,
                            hint: 'e.g., 10',
                          ),
                          const SizedBox(height: 20),
                        ],

                        if (config.furnishing) ...[
                          _buildFurnishingSection(),
                          const SizedBox(height: 20),
                        ],

                        if (_furnishing == FurnishingStatus.semiFurnished ||
                            _furnishing == FurnishingStatus.fullyFurnished) ...[
                          _buildFurnishingsSection(),
                          const SizedBox(height: 20),
                        ],

                        if (_shouldShowFacingDirection()) ...[
                          _buildFacingDirection(),
                          const SizedBox(height: 24),
                        ],

                        if (_shouldShowInsideAmenities()) ...[
                          _buildInsideAmenitiesSection(),
                          const SizedBox(height: 24),
                        ],

                        _buildNearbyAmenitiesSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildNextStepButton(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Step 1 of 5',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              Text(
                'Basic Details',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF10B981),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.home_outlined,
              color: Color(0xFF10B981),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _getPropertyNameLabel(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _propertyNameController,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g., Luxury ${_getPropertyNameLabel().replaceAll(' Name', '')} in Anna Nagar',
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.description_outlined,
              color: Color(0xFF10B981),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Property Description',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(Optional)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Describe your property in detail to attract potential buyers/tenants',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _propertyDescriptionController,
          maxLines: 6,
          minLines: 4,
          maxLength: 500,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'e.g., This beautiful property features spacious rooms, modern amenities, excellent ventilation, and is located in a prime neighborhood with easy access to schools, hospitals, and shopping centers...',
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
              height: 1.5,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            counterText: '',
          ),
          onChanged: (text) {
            setState(() {});
          },
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_propertyDescriptionController.text.length}/500 characters',
              style: TextStyle(
                fontSize: 11,
                color: _propertyDescriptionController.text.length > 450
                    ? const Color(0xFFEF4444)
                    : Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_propertyDescriptionController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _propertyDescriptionController.clear();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.clear,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyForSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Property For',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPropertyForButton(
                label: 'Sell',
                value: PropertyFor.sell,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPropertyForButton(
                label: 'Rent',
                value: PropertyFor.rent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyForButton({
    required String label,
    required PropertyFor value,
  }) {
    final isSelected = _propertyFor == value;
    return GestureDetector(
      onTap: () => _handlePropertyForChange(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Property Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _propertyFor == PropertyFor.sell
              ? DropdownButton<SellPropertyType>(
                  value: _selectedSellType,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  items: SellPropertyType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSellType = value;
                        _resetForm();
                      });
                    }
                  },
                )
              : DropdownButton<RentPropertyType>(
                  value: _selectedRentType,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  items: RentPropertyType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRentType = value;
                        _resetForm();
                      });
                    }
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMeasurementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(
              Icons.straighten,
              color: Color(0xFF10B981),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Measurement',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _measurementValueController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Measurement is required';
                  }
                  if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value.trim())) {
                    return 'Enter valid number';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: 'Enter value',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFEF4444)),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<MeasurementUnit>(
                  value: _selectedMeasurementUnit,
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text(
                    'Select unit',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  items: MeasurementUnit.values.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(unit.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMeasurementUnit = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        if (_measurementValueController.text.isNotEmpty && 
            _selectedMeasurementUnit != null &&
            RegExp(r'^\d+(\.\d+)?$').hasMatch(_measurementValueController.text))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_measurementValueController.text} ${_selectedMeasurementUnit!.displayName}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBoundariesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.border_outer,
              color: Color(0xFF10B981),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Boundaries',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(Optional)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Enter boundary measurements for each direction (in feet)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildBoundaryField(
                label: 'North',
                controller: _boundaryNorthController,
                icon: Icons.north,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBoundaryField(
                label: 'South',
                controller: _boundarySouthController,
                icon: Icons.south,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildBoundaryField(
                label: 'East',
                controller: _boundaryEastController,
                icon: Icons.east,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBoundaryField(
                label: 'West',
                controller: _boundaryWestController,
                icon: Icons.west,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBoundaryField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Color(0xFF6B7280),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value != null && value.trim().isNotEmpty) {
              if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value.trim())) {
                return 'Enter valid number';
              }
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: 'e.g., 60',
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 13,
            ),
            suffixText: 'ft',
            suffixStyle: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              if (isRequired) return '$label is required';
              return null;
            }
            if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
              return 'Enter numbers only';
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionSection({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String) onSelect,
    TextEditingController? customController,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return GestureDetector(
              onTap: () => onSelect(option),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF10B981) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (selectedValue == 'Custom' && customController != null) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: customController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter custom $title';
              }
              if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
                return 'Enter numbers only';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: 'Enter custom $title',
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFurnishingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Furnishing Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: FurnishingStatus.values.map((status) {
            final isSelected = _furnishing == status;
            return GestureDetector(
              onTap: () => setState(() => _furnishing = status),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF10B981) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  status.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFacingDirection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Facing Direction',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: FacingDirection.values.map((direction) {
            final isSelected = _facing == direction;
            return GestureDetector(
              onTap: () => setState(() => _facing = direction),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF10B981).withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  direction.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFurnishingsSection() {
    final allFurnishings = [...furnishingItems, ..._customFurnishings];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Furnishings',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...allFurnishings.map((item) {
              final isSelected = _selectedFurnishings.contains(item);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedFurnishings.remove(item);
                    } else {
                      _selectedFurnishings.add(item);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF10B981).withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              );
            }).toList(),
            GestureDetector(
              onTap: () => _showAddCustomItemDialog(isForFurnishing: true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981),
                    width: 2,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 18,
                      color: Color(0xFF10B981),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Add Custom',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsideAmenitiesSection() {
    final allInsideAmenities = [...insideAmenities, ..._customInsideAmenities];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.apartment_outlined,
              color: Color(0xFF10B981),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Inside Amenities',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Select amenities available inside the property',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...allInsideAmenities.map((item) {
              final isSelected = _selectedInsideAmenities.contains(item);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInsideAmenities.remove(item);
                    } else {
                      _selectedInsideAmenities.add(item);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF10B981).withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              );
            }).toList(),
            GestureDetector(
              onTap: () => _showAddCustomItemDialog(isForFurnishing: false, isForInsideAmenities: true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981),
                    width: 2,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 16,
                      color: Color(0xFF10B981),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Add Custom',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNearbyAmenitiesSection() {
    final allAmenities = [...nearbyAmenities, ..._customAmenities];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: Color(0xFF10B981),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Nearby Amenities',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Select amenities available within 2 km from the property',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...allAmenities.map((item) {
              final isSelected = _amenityControllers.containsKey(item);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _amenityControllers[item]?.dispose();
                      _amenityControllers.remove(item);
                    } else {
                      _amenityControllers[item] = TextEditingController();
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF10B981).withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              );
            }).toList(),
            GestureDetector(
              onTap: () => _showAddCustomItemDialog(isForFurnishing: false, isForInsideAmenities: false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981),
                    width: 2,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 16,
                      color: Color(0xFF10B981),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Add Custom',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ...(_amenityControllers.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextFormField(
              controller: entry.value,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '${entry.key} name is required';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: '${entry.key} - Enter name *',
                hintText: 'e.g., XYZ School',
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEF4444)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          );
        }).toList()),
      ],
    );
  }

  void _showAddCustomItemDialog({required bool isForFurnishing, bool isForInsideAmenities = false}) {
    final controller = TextEditingController();

    String title;
    String hint;
    if (isForFurnishing) {
      title = 'Add Custom Furnishing';
      hint = 'e.g., Smart TV';
    } else if (isForInsideAmenities) {
      title = 'Add Custom Inside Amenity';
      hint = 'e.g., Home Theater';
    } else {
      title = 'Add Custom Nearby Amenity';
      hint = 'e.g., Shopping Mall';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  if (isForFurnishing) {
                    _customFurnishings.add(controller.text.trim());
                    _selectedFurnishings.add(controller.text.trim());
                  } else if (isForInsideAmenities) {
                    _customInsideAmenities.add(controller.text.trim());
                    _selectedInsideAmenities.add(controller.text.trim());
                  } else {
                    _customAmenities.add(controller.text.trim());
                    _amenityControllers[controller.text.trim()] = TextEditingController();
                  }
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Add',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next Step',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
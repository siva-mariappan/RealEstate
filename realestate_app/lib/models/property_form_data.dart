import 'package:image_picker/image_picker.dart';
import '../screens/add_property_screen_1.dart';

// This class holds all form data from all 5 screens
class PropertyFormData {
  // Step 1: Basic Details
  String? propertyName;
  String? propertyDescription;
  PropertyFor? propertyFor;
  SellPropertyType? sellPropertyType;
  RentPropertyType? rentPropertyType;
  String? landExtent;
  String? measurementValue;
  String? measurementUnit;
  
  // Boundaries (Optional - only for sell)
  String? boundaryNorth;
  String? boundarySouth;
  String? boundaryEast;
  String? boundaryWest;
  
  String? builtUpArea;
  String? sizeRange;
  String? bedrooms;
  String? bathrooms;
  String? numberOfBeds; // NEW: For PG/Hostel and Shared Room
  String? peoplePerRoom; // NEW: For PG/Hostel and Shared Room
  String? floorNo;
  String? totalFloors;
  FacingDirection? facingDirection;
  FurnishingStatus? furnishingStatus;
  List<String>? furnishingItems;
  List<String>? insideAmenities;
  List<String>? nearbyAmenities;
  Map<String, String>? nearbyAmenityDetails;

  // Step 2: Location
  String? state;
  String? city;
  String? locality;
  String? landmark;
  String? pincode;
  String? googleMapsLink;

  // Step 3: Pricing & Details
  String? price;
  bool? priceNegotiable;
  String? pricePerSqft;
  String? udsSqft;
  String? maintenance;
  String? monthlyRent;
  String? securityDeposit;
  String? ageOfProperty;
  String? possessionStatus;
  String? transactionType;
  String? ownershipType;
  String? approvalStatus;
  String? monthlyRentalIncome;
  String? annualYield;
  String? maxOccupancy;
  String? ceilingHeight;

  // Lease Information
  bool? isLeaseProperty;
  String? leaseDuration;
  String? lockInPeriod;
  String? noticePeriod;
  String? overallLeaseAmount;
  String? rentEscalationPercent;
  String? leaseType;
  bool? registrationRequired;

  // Tenant Preferences
  List<String>? tenantPreferences;

  // Step 4: Media
  List<XFile>? images;
  XFile? video;

  // Step 5: Contact & Agent
  String? contactName;
  String? contactMobile;
  String? contactEmail;
  bool? whatsappAvailable;
  String? listedBy;
  String? agencyName;
  String? reraNumber;
  String? brokerFeePercent;
  String? officeAddress;
  String? companyName;
  String? gstNumber;
  String? companyAddress;

  PropertyFormData();

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson({
    String? userId,
    String? coverImageUrl,
    List<String>? imageUrls,
    String? videoUrl,
  }) {
    // Parse land extent to extract numeric value if possible
    double? landExtentValue;
    if (landExtent != null) {
      final parts = landExtent!.split(' ');
      if (parts.isNotEmpty) {
        landExtentValue = double.tryParse(parts[0]);
      }
    }

    return {
      'user_id': userId,
      'property_name': propertyName,
      'property_description': propertyDescription,
      'property_for': propertyFor?.name,
      'property_type_sell': sellPropertyType?.displayName,
      'property_type_rent': rentPropertyType?.displayName,
      
      // Measurement fields
      'land_extent': landExtent,
      'land_extent_value': landExtentValue,
      'measurement_value': measurementValue != null ? double.tryParse(measurementValue!) : null,
      'measurement_unit': measurementUnit,
      
      // Boundary fields (optional, only for sell)
      'boundary_north': boundaryNorth != null ? double.tryParse(boundaryNorth!) : null,
      'boundary_south': boundarySouth != null ? double.tryParse(boundarySouth!) : null,
      'boundary_east': boundaryEast != null ? double.tryParse(boundaryEast!) : null,
      'boundary_west': boundaryWest != null ? double.tryParse(boundaryWest!) : null,
      
      'built_up_area': builtUpArea != null ? double.tryParse(builtUpArea!) : null,
      'size_range': sizeRange,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'number_of_beds': numberOfBeds, // NEW
      'people_per_room': peoplePerRoom, // NEW
      'floor_no': floorNo != null ? int.tryParse(floorNo!) : null,
      'total_floors': totalFloors != null ? int.tryParse(totalFloors!) : null,
      'facing_direction': facingDirection?.displayName,
      'furnishing_status': furnishingStatus?.displayName,
      'furnishing_items': furnishingItems,
      'inside_amenities': insideAmenities,
      'nearby_amenities': nearbyAmenities,
      'nearby_amenity_details': nearbyAmenityDetails,
      
      'state': state,
      'city': city,
      'locality': locality,
      'landmark': landmark,
      'pincode': pincode,
      'google_maps_link': googleMapsLink,
      
      'price': price != null ? double.tryParse(price!) : null,
      'price_negotiable': priceNegotiable,
      'price_per_sqft': pricePerSqft != null ? double.tryParse(pricePerSqft!) : null,
      'uds_sqft': udsSqft != null ? double.tryParse(udsSqft!) : null,
      'maintenance_monthly': maintenance != null ? double.tryParse(maintenance!) : null,
      'monthly_rent': monthlyRent != null ? double.tryParse(monthlyRent!) : null,
      'security_deposit': securityDeposit != null ? double.tryParse(securityDeposit!) : null,
      'age_of_property': ageOfProperty,
      'possession_status': possessionStatus,
      'transaction_type': transactionType,
      'ownership_type': ownershipType,
      'approval_status': approvalStatus,
      'monthly_rental_income': monthlyRentalIncome != null ? double.tryParse(monthlyRentalIncome!) : null,
      'annual_yield': annualYield != null ? double.tryParse(annualYield!) : null,
      'max_occupancy': maxOccupancy != null ? int.tryParse(maxOccupancy!) : null,
      'ceiling_height': ceilingHeight != null ? double.tryParse(ceilingHeight!) : null,
      
      'is_lease_property': isLeaseProperty,
      'lease_duration': leaseDuration,
      'lock_in_period': lockInPeriod,
      'notice_period': noticePeriod,
      'overall_lease_amount': overallLeaseAmount != null ? double.tryParse(overallLeaseAmount!) : null,
      'rent_escalation_percent': rentEscalationPercent != null ? double.tryParse(rentEscalationPercent!) : null,
      'lease_type': leaseType,
      'registration_required': registrationRequired,
      
      'tenant_preferences': tenantPreferences,
      
      'cover_image_url': coverImageUrl,
      'image_urls': imageUrls,
      'video_url': videoUrl,
      
      'contact_name': contactName,
      'contact_mobile': contactMobile,
      'contact_email': contactEmail,
      'whatsapp_available': whatsappAvailable,
      'listed_by': listedBy,
      'agency_name': agencyName,
      'rera_number': reraNumber,
      'broker_fee_percent': brokerFeePercent != null ? double.tryParse(brokerFeePercent!) : null,
      'office_address': officeAddress,
      'company_name': companyName,
      'gst_number': gstNumber,
      'company_address': companyAddress,
      
      'status': 'active',
    };
  }

  // Helper method to get formatted boundary string
  String? getFormattedBoundaries() {
    if (boundaryNorth == null && 
        boundarySouth == null && 
        boundaryEast == null && 
        boundaryWest == null) {
      return null;
    }

    final boundaries = <String>[];
    if (boundaryNorth != null && boundaryNorth!.isNotEmpty) {
      boundaries.add('North: $boundaryNorth ft');
    }
    if (boundarySouth != null && boundarySouth!.isNotEmpty) {
      boundaries.add('South: $boundarySouth ft');
    }
    if (boundaryEast != null && boundaryEast!.isNotEmpty) {
      boundaries.add('East: $boundaryEast ft');
    }
    if (boundaryWest != null && boundaryWest!.isNotEmpty) {
      boundaries.add('West: $boundaryWest ft');
    }

    return boundaries.isEmpty ? null : boundaries.join(', ');
  }

  // Helper method to check if all boundaries are filled
  bool hasCompleteBoundaries() {
    return boundaryNorth != null && boundaryNorth!.isNotEmpty &&
           boundarySouth != null && boundarySouth!.isNotEmpty &&
           boundaryEast != null && boundaryEast!.isNotEmpty &&
           boundaryWest != null && boundaryWest!.isNotEmpty;
  }

  // Helper method to check if any boundary is filled
  bool hasAnyBoundary() {
    return (boundaryNorth != null && boundaryNorth!.isNotEmpty) ||
           (boundarySouth != null && boundarySouth!.isNotEmpty) ||
           (boundaryEast != null && boundaryEast!.isNotEmpty) ||
           (boundaryWest != null && boundaryWest!.isNotEmpty);
  }

  // Helper method to get measurement display string
  String? getMeasurementDisplay() {
    if (landExtent != null && landExtent!.isNotEmpty) {
      return landExtent;
    }
    if (measurementValue != null && measurementUnit != null) {
      return '$measurementValue $measurementUnit';
    }
    return null;
  }

  // Copy method for easy cloning
  PropertyFormData copyWith({
    String? propertyName,
    String? propertyDescription,
    PropertyFor? propertyFor,
    SellPropertyType? sellPropertyType,
    RentPropertyType? rentPropertyType,
    String? landExtent,
    String? measurementValue,
    String? measurementUnit,
    String? boundaryNorth,
    String? boundarySouth,
    String? boundaryEast,
    String? boundaryWest,
    String? builtUpArea,
    String? sizeRange,
    String? bedrooms,
    String? bathrooms,
    String? numberOfBeds,
    String? peoplePerRoom,
    String? floorNo,
    String? totalFloors,
    FacingDirection? facingDirection,
    FurnishingStatus? furnishingStatus,
    List<String>? furnishingItems,
    List<String>? insideAmenities,
    List<String>? nearbyAmenities,
    Map<String, String>? nearbyAmenityDetails,
  }) {
    final copy = PropertyFormData();
    
    copy.propertyName = propertyName ?? this.propertyName;
    copy.propertyDescription = propertyDescription ?? this.propertyDescription;
    copy.propertyFor = propertyFor ?? this.propertyFor;
    copy.sellPropertyType = sellPropertyType ?? this.sellPropertyType;
    copy.rentPropertyType = rentPropertyType ?? this.rentPropertyType;
    copy.landExtent = landExtent ?? this.landExtent;
    copy.measurementValue = measurementValue ?? this.measurementValue;
    copy.measurementUnit = measurementUnit ?? this.measurementUnit;
    copy.boundaryNorth = boundaryNorth ?? this.boundaryNorth;
    copy.boundarySouth = boundarySouth ?? this.boundarySouth;
    copy.boundaryEast = boundaryEast ?? this.boundaryEast;
    copy.boundaryWest = boundaryWest ?? this.boundaryWest;
    copy.builtUpArea = builtUpArea ?? this.builtUpArea;
    copy.sizeRange = sizeRange ?? this.sizeRange;
    copy.bedrooms = bedrooms ?? this.bedrooms;
    copy.bathrooms = bathrooms ?? this.bathrooms;
    copy.numberOfBeds = numberOfBeds ?? this.numberOfBeds;
    copy.peoplePerRoom = peoplePerRoom ?? this.peoplePerRoom;
    copy.floorNo = floorNo ?? this.floorNo;
    copy.totalFloors = totalFloors ?? this.totalFloors;
    copy.facingDirection = facingDirection ?? this.facingDirection;
    copy.furnishingStatus = furnishingStatus ?? this.furnishingStatus;
    copy.furnishingItems = furnishingItems ?? this.furnishingItems;
    copy.insideAmenities = insideAmenities ?? this.insideAmenities;
    copy.nearbyAmenities = nearbyAmenities ?? this.nearbyAmenities;
    copy.nearbyAmenityDetails = nearbyAmenityDetails ?? this.nearbyAmenityDetails;
    
    // Copy all other fields
    copy.state = this.state;
    copy.city = this.city;
    copy.locality = this.locality;
    copy.landmark = this.landmark;
    copy.pincode = this.pincode;
    copy.googleMapsLink = this.googleMapsLink;
    copy.price = this.price;
    copy.priceNegotiable = this.priceNegotiable;
    copy.pricePerSqft = this.pricePerSqft;
    copy.udsSqft = this.udsSqft;
    copy.maintenance = this.maintenance;
    copy.monthlyRent = this.monthlyRent;
    copy.securityDeposit = this.securityDeposit;
    copy.ageOfProperty = this.ageOfProperty;
    copy.possessionStatus = this.possessionStatus;
    copy.transactionType = this.transactionType;
    copy.ownershipType = this.ownershipType;
    copy.approvalStatus = this.approvalStatus;
    copy.monthlyRentalIncome = this.monthlyRentalIncome;
    copy.annualYield = this.annualYield;
    copy.maxOccupancy = this.maxOccupancy;
    copy.ceilingHeight = this.ceilingHeight;
    copy.isLeaseProperty = this.isLeaseProperty;
    copy.leaseDuration = this.leaseDuration;
    copy.lockInPeriod = this.lockInPeriod;
    copy.noticePeriod = this.noticePeriod;
    copy.overallLeaseAmount = this.overallLeaseAmount;
    copy.rentEscalationPercent = this.rentEscalationPercent;
    copy.leaseType = this.leaseType;
    copy.registrationRequired = this.registrationRequired;
    copy.tenantPreferences = this.tenantPreferences;
    copy.images = this.images;
    copy.video = this.video;
    copy.contactName = this.contactName;
    copy.contactMobile = this.contactMobile;
    copy.contactEmail = this.contactEmail;
    copy.whatsappAvailable = this.whatsappAvailable;
    copy.listedBy = this.listedBy;
    copy.agencyName = this.agencyName;
    copy.reraNumber = this.reraNumber;
    copy.brokerFeePercent = this.brokerFeePercent;
    copy.officeAddress = this.officeAddress;
    copy.companyName = this.companyName;
    copy.gstNumber = this.gstNumber;
    copy.companyAddress = this.companyAddress;
    
    return copy;
  }
}
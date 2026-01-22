// lib/models/property_model.dart

enum LookingFor { buy, rent }

class PropertyFilters {
  LookingFor lookingFor;
  List<String> propertyTypes;
  double minPrice;
  double maxPrice;
  List<int> bhk;
  String? condition;
  double minLandArea;
  double maxLandArea;
  double minBuildupArea;
  double maxBuildupArea;

  PropertyFilters({
    this.lookingFor = LookingFor.buy, // CHANGED: Made optional with default
    List<String>? propertyTypes, // CHANGED: Made nullable
    this.minPrice = 0,
    this.maxPrice = 100000000,
    List<int>? bhk, // CHANGED: Made nullable
    this.condition,
    this.minLandArea = 0,
    this.maxLandArea = 100000000,
    this.minBuildupArea = 0,
    this.maxBuildupArea = 100000000,
  }) : propertyTypes = propertyTypes ?? [], // CHANGED: Initialize with empty mutable list
       bhk = bhk ?? []; // CHANGED: Initialize with empty mutable list
}
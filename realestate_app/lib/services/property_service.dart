import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property.dart';

class PropertyService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Fetch All Properties
  Future<List<Property>> fetchAllProperties({bool includeAllStatuses = false}) async {
    try {
      var query = _supabase.from('properties').select();
      
      if (!includeAllStatuses) {
        query = query.eq('status', 'active');
      }

      final response = await query.order('created_at', ascending: false);
      
      final data = response as List<dynamic>;
      return data.map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      print('Supabase Error: $e');
      return []; // Return empty list instead of crashing
    }
  }

  // 2. Fetch Featured
  Future<List<Property>> fetchFeaturedProperties({int limit = 6}) async {
    try {
      final response = await _supabase
          .from('properties')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(limit);

      final data = response as List<dynamic>;
      return data.map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      print('Featured Error: $e');
      return [];
    }
  }

  // 3. Fetch by Type
  Future<List<Property>> fetchPropertiesByType(String propertyFor) async {
    try {
      final response = await _supabase
          .from('properties')
          .select()
          .eq('property_for', propertyFor.toLowerCase())
          .eq('status', 'active')
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching $propertyFor: $e');
      return [];
    }
  }

  // 4. Fetch by City
  Future<List<Property>> fetchPropertiesByCity(String city) async {
    try {
      final response = await _supabase
          .from('properties')
          .select()
          .ilike('city', '%$city%')
          .eq('status', 'active')
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching city: $e');
      return [];
    }
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/property_form_data.dart';

class PropertySubmissionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Main method to submit property with subscription plan support
  Future<String> submitProperty(
    PropertyFormData formData, {
    String? subscriptionPlan,
    bool isVerified = false,
  }) async {
    try {
      // Get current user ID
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated. Please log in first.');
      }

      // Step 1: Upload images
      print('📸 Uploading images...');
      List<String>? imageUrls;
      String? coverImageUrl;

      if (formData.images != null && formData.images!.isNotEmpty) {
        imageUrls = await _uploadImages(formData.images!, userId);
        coverImageUrl = imageUrls.isNotEmpty ? imageUrls.first : null;
      }

      // Step 2: Upload video (if exists)
      print('🎥 Uploading video...');
      String? videoUrl;
      if (formData.video != null) {
        videoUrl = await _uploadVideo(formData.video!, userId);
      }

      // Step 3: Insert property data into database
      print('💾 Saving property to database...');
      final propertyData = formData.toJson(
        userId: userId,
        coverImageUrl: coverImageUrl,
        imageUrls: imageUrls,
        videoUrl: videoUrl,
      );

      // Add subscription and verification details
      propertyData['subscription_plan'] = subscriptionPlan ?? 'free';
      propertyData['is_verified'] = isVerified;
      
      // Set verification status based on plan
      if (subscriptionPlan == null || subscriptionPlan == 'free') {
        propertyData['verification_status'] = 'not_verified';
      } else {
        propertyData['verification_status'] = 'pending_admin_review';
      }
      
      // Add timestamps
      propertyData['created_at'] = DateTime.now().toIso8601String();
      propertyData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('properties')
          .insert(propertyData)
          .select('id')
          .single();

      final propertyId = response['id'] as String;

      print('✅ Property submitted successfully! ID: $propertyId');
      print('📋 Subscription Plan: ${subscriptionPlan ?? 'free'}');
      print('🔒 Verification Status: ${propertyData['verification_status']}');
      
      return propertyId;
    } catch (e) {
      print('❌ Error submitting property: $e');
      rethrow;
    }
  }

  // Upload multiple images to Supabase Storage
  Future<List<String>> _uploadImages(List<XFile> images, String userId) async {
    final List<String> uploadedUrls = [];

    for (int i = 0; i < images.length; i++) {
      try {
        final image = images[i];
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = '$userId/property-$timestamp-$i.${image.name.split('.').last}';

        // Upload to Supabase Storage
        final bytes = await image.readAsBytes();
        await _supabase.storage
            .from('property-images')
            .uploadBinary(fileName, bytes);

        // Get public URL
        final url = _supabase.storage
            .from('property-images')
            .getPublicUrl(fileName);

        uploadedUrls.add(url);
        print('✓ Uploaded image ${i + 1}/${images.length}');
      } catch (e) {
        print('✗ Error uploading image ${i + 1}: $e');
        // Continue with other images even if one fails
      }
    }

    if (uploadedUrls.isEmpty) {
      throw Exception('Failed to upload any images. Please try again.');
    }

    return uploadedUrls;
  }

  // Upload video to Supabase Storage
  Future<String?> _uploadVideo(XFile video, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$userId/property-video-$timestamp.${video.name.split('.').last}';

      final bytes = await video.readAsBytes();
      await _supabase.storage
          .from('property-videos')
          .uploadBinary(fileName, bytes);

      final url = _supabase.storage
          .from('property-videos')
          .getPublicUrl(fileName);

      print('✓ Video uploaded successfully');
      return url;
    } catch (e) {
      print('✗ Error uploading video: $e');
      return null; // Video is optional, so return null instead of throwing
    }
  }

  // Update existing property
  Future<void> updateProperty(
    String propertyId,
    PropertyFormData formData, {
    String? subscriptionPlan,
    bool? isVerified,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Upload new media if provided
      List<String>? imageUrls;
      String? coverImageUrl;
      if (formData.images != null && formData.images!.isNotEmpty) {
        imageUrls = await _uploadImages(formData.images!, userId);
        coverImageUrl = imageUrls.first;
      }

      String? videoUrl;
      if (formData.video != null) {
        videoUrl = await _uploadVideo(formData.video!, userId);
      }

      // Update property
      final propertyData = formData.toJson(
        userId: userId,
        coverImageUrl: coverImageUrl,
        imageUrls: imageUrls,
        videoUrl: videoUrl,
      );

      // Update subscription and verification if provided
      if (subscriptionPlan != null) {
        propertyData['subscription_plan'] = subscriptionPlan;
      }
      if (isVerified != null) {
        propertyData['is_verified'] = isVerified;
      }
      
      // Update timestamp
      propertyData['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('properties')
          .update(propertyData)
          .eq('id', propertyId)
          .eq('user_id', userId); // Ensure user owns this property

      print('✅ Property updated successfully!');
    } catch (e) {
      print('❌ Error updating property: $e');
      rethrow;
    }
  }

  // Delete property
  Future<void> deleteProperty(String propertyId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('properties')
          .delete()
          .eq('id', propertyId)
          .eq('user_id', userId);

      print('✅ Property deleted successfully!');
    } catch (e) {
      print('❌ Error deleting property: $e');
      rethrow;
    }
  }

  // Admin function to verify a property
  Future<void> verifyProperty(String propertyId, bool isVerified) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('properties')
          .update({
            'is_verified': isVerified,
            'verification_status': isVerified ? 'verified' : 'pending_admin_review',
            'verified_at': isVerified ? DateTime.now().toIso8601String() : null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', propertyId);

      print('✅ Property verification status updated!');
    } catch (e) {
      print('❌ Error updating verification status: $e');
      rethrow;
    }
  }

  // Get properties by subscription plan (for admin)
  Future<List<Map<String, dynamic>>> getPropertiesByPlan(String subscriptionPlan) async {
    try {
      final response = await _supabase
          .from('properties')
          .select()
          .eq('subscription_plan', subscriptionPlan)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching properties by plan: $e');
      rethrow;
    }
  }

  // Get properties pending verification (for admin)
  Future<List<Map<String, dynamic>>> getPendingVerificationProperties() async {
    try {
      final response = await _supabase
          .from('properties')
          .select()
          .eq('verification_status', 'pending_admin_review')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching pending properties: $e');
      rethrow;
    }
  }

  // Update subscription plan (for admin after payment confirmation)
  Future<void> updateSubscriptionPlan(String propertyId, String newPlan) async {
    try {
      await _supabase
          .from('properties')
          .update({
            'subscription_plan': newPlan,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', propertyId);

      print('✅ Subscription plan updated to $newPlan');
    } catch (e) {
      print('❌ Error updating subscription plan: $e');
      rethrow;
    }
  }

  // Get user's properties
  Future<List<Map<String, dynamic>>> getUserProperties() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('properties')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching user properties: $e');
      return [];
    }
  }

  // Get property by ID
  Future<Map<String, dynamic>?> getPropertyById(String propertyId) async {
    try {
      final response = await _supabase
          .from('properties')
          .select()
          .eq('id', propertyId)
          .single();

      return response;
    } catch (e) {
      print('❌ Error fetching property: $e');
      return null;
    }
  }

  // Search properties
  Future<List<Map<String, dynamic>>> searchProperties({
    String? propertyFor,
    String? propertyType,
    String? city,
    String? locality,
    double? minPrice,
    double? maxPrice,
    String? bedrooms,
    String? bathrooms,
  }) async {
    try {
      var query = _supabase.from('properties').select();

      if (propertyFor != null) {
        query = query.eq('property_for', propertyFor);
      }

      if (propertyType != null) {
        query = query.or('property_type_sell.eq.$propertyType,property_type_rent.eq.$propertyType');
      }

      if (city != null) {
        query = query.eq('city', city);
      }

      if (locality != null) {
        query = query.eq('locality', locality);
      }

      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }

      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }

      if (bedrooms != null) {
        query = query.eq('bedrooms', bedrooms);
      }

      if (bathrooms != null) {
        query = query.eq('bathrooms', bathrooms);
      }

      final response = await query
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error searching properties: $e');
      return [];
    }
  }

  // Get all active properties
  Future<List<Map<String, dynamic>>> getAllProperties() async {
    try {
      final response = await _supabase
          .from('properties')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching properties: $e');
      return [];
    }
  }

  // Mark property as sold/rented
  Future<void> markPropertyAsSold(String propertyId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('properties')
          .update({
            'status': 'sold',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', propertyId)
          .eq('user_id', userId);

      print('✅ Property marked as sold!');
    } catch (e) {
      print('❌ Error marking property as sold: $e');
      rethrow;
    }
  }

  // Mark property as inactive
  Future<void> markPropertyAsInactive(String propertyId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('properties')
          .update({
            'status': 'inactive',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', propertyId)
          .eq('user_id', userId);

      print('✅ Property marked as inactive!');
    } catch (e) {
      print('❌ Error marking property as inactive: $e');
      rethrow;
    }
  }

  // Reactivate property
  Future<void> reactivateProperty(String propertyId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('properties')
          .update({
            'status': 'active',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', propertyId)
          .eq('user_id', userId);

      print('✅ Property reactivated!');
    } catch (e) {
      print('❌ Error reactivating property: $e');
      rethrow;
    }
  }
}
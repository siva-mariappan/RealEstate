import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/advertisement.dart';

class AdStorageService {
  static const String _storageKey = 'advertisements';
  
  // Save advertisements to local storage
  Future<bool> saveAdvertisements(List<Advertisement> ads) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adsJson = ads.map((ad) => ad.toJson()).toList();
      final jsonString = jsonEncode(adsJson);
      return await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error saving advertisements: $e');
      return false;
    }
  }

  // Load advertisements from local storage
  Future<List<Advertisement>> loadAdvertisements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return _getDefaultAdvertisements();
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Advertisement.fromJson(json)).toList();
    } catch (e) {
      print('Error loading advertisements: $e');
      return _getDefaultAdvertisements();
    }
  }

  // Get default advertisements (initial data)
  List<Advertisement> _getDefaultAdvertisements() {
    return [
      Advertisement(
        id: '1',
        title: 'Welcome to EstateHub',
        subtitle: 'Find your dream home from thousands of verified properties',
        buttonText: 'Get Started',
        isActive: true,
        order: 0,
      ),
      Advertisement(
        id: '2',
        title: 'Special Offer',
        subtitle: 'Get 20% off on brokerage fees for new customers this month',
        buttonText: 'Learn More',
        isActive: true,
        order: 1,
      ),
      Advertisement(
        id: '3',
        title: 'Premium Properties',
        subtitle: 'Explore luxury apartments and villas in prime locations',
        buttonText: 'View Properties',
        isActive: true,
        order: 2,
      ),
    ];
  }

  // Add a new advertisement
  Future<bool> addAdvertisement(Advertisement ad) async {
    final ads = await loadAdvertisements();
    ads.add(ad);
    return await saveAdvertisements(ads);
  }

  // Update an existing advertisement
  Future<bool> updateAdvertisement(Advertisement updatedAd) async {
    final ads = await loadAdvertisements();
    final index = ads.indexWhere((ad) => ad.id == updatedAd.id);
    
    if (index != -1) {
      ads[index] = updatedAd;
      return await saveAdvertisements(ads);
    }
    return false;
  }

  // Delete an advertisement
  Future<bool> deleteAdvertisement(String id) async {
    final ads = await loadAdvertisements();
    ads.removeWhere((ad) => ad.id == id);
    return await saveAdvertisements(ads);
  }

  // Get active advertisements only
  Future<List<Advertisement>> getActiveAdvertisements() async {
    final ads = await loadAdvertisements();
    final activeAds = ads.where((ad) => ad.isActive).toList();
    activeAds.sort((a, b) => a.order.compareTo(b.order));
    return activeAds;
  }

  // Clear all advertisements (reset)
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_storageKey);
    } catch (e) {
      print('Error clearing advertisements: $e');
      return false;
    }
  }
}
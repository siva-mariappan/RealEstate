import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FavouritesTab extends StatefulWidget {
  const FavouritesTab({Key? key}) : super(key: key);

  @override
  State<FavouritesTab> createState() => _FavouritesTabState();
}

class _FavouritesTabState extends State<FavouritesTab> {
  List<dynamic> _favourites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavourites();
  }

  Future<void> _fetchFavourites() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse('https://your-api.com/api/favourites'),
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _favourites = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching favourites: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavourite(String propertyId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://your-api.com/api/favourites/$propertyId'),
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _favourites.removeWhere((item) => item['property']['id'] == propertyId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favourites')),
        );
      }
    } catch (e) {
      print('Error removing favourite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
        backgroundColor: const Color(0xFF10B981), // CHANGED: Emerald green
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchFavourites,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favourites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No favourites yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Save properties you like to view them here',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchFavourites,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favourites.length,
                    itemBuilder: (context, index) {
                      final favourite = _favourites[index];
                      final property = favourite['property'];
                      return _buildPropertyCard(property);
                    },
                  ),
                ),
    );
  }

  Widget _buildPropertyCard(dynamic property) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to property details
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property image with favourite button
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: property['images'] != null &&
                          property['images'].isNotEmpty
                      ? Image.network(
                          property['images'][0],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 64),
                            );
                          },
                        )
                      : Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 64),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        _removeFavourite(property['id'].toString());
                      },
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    property['title'] ?? 'Untitled Property',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property['location'] ?? 'Location not specified',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Price
                  Row(
                    children: [
                      Text(
                        '\$${property['price'] ?? '0'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981), // CHANGED: Emerald green
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          property['listing_type'] == 'sale'
                              ? 'For Sale'
                              : 'For Rent',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Property details
                  Row(
                    children: [
                      _buildDetailChip(
                        Icons.bed,
                        '${property['bedrooms'] ?? 0} Beds',
                      ),
                      const SizedBox(width: 8),
                      _buildDetailChip(
                        Icons.bathtub,
                        '${property['bathrooms'] ?? 0} Baths',
                      ),
                      const SizedBox(width: 8),
                      _buildDetailChip(
                        Icons.square_foot,
                        '${property['area'] ?? 0} sqft',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
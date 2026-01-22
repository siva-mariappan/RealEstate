import 'dart:convert';

class Advertisement {
  final String id;
  final String title;
  final String subtitle;
  final String? mediaUrl;  // Changed from imageUrl - can be image or video
  final String? mediaType; // 'image' or 'video'
  final String? buttonText;
  final String? buttonLink; // URL to redirect when button clicked
  final String? externalLink; // URL to redirect when ad is clicked
  final bool isActive;
  final int order;

  Advertisement({
    required this.id,
    required this.title,
    required this.subtitle,
    this.mediaUrl,
    this.mediaType,
    this.buttonText,
    this.buttonLink,
    this.externalLink,
    this.isActive = true,
    this.order = 0,
  });

  // Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'buttonText': buttonText,
      'buttonLink': buttonLink,
      'externalLink': externalLink,
      'isActive': isActive,
      'order': order,
    };
  }

  // Create from JSON
  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      mediaUrl: json['mediaUrl'] as String?,
      mediaType: json['mediaType'] as String?,
      buttonText: json['buttonText'] as String?,
      buttonLink: json['buttonLink'] as String?,
      externalLink: json['externalLink'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
    );
  }

  // Create copy with modifications
  Advertisement copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? mediaUrl,
    String? mediaType,
    String? buttonText,
    String? buttonLink,
    String? externalLink,
    bool? isActive,
    int? order,
  }) {
    return Advertisement(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      buttonText: buttonText ?? this.buttonText,
      buttonLink: buttonLink ?? this.buttonLink,
      externalLink: externalLink ?? this.externalLink,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
    );
  }

  // Backward compatibility - check if it's an image
  bool get isImage => mediaType == 'image';
  
  // Check if it's a video
  bool get isVideo => mediaType == 'video';
  
  // Backward compatibility getter
  String? get imageUrl => isImage ? mediaUrl : null;
}
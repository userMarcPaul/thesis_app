import 'package:cloud_firestore/cloud_firestore.dart';

const Map<String, List<String>> categories = {
  "audiovisualMedia": [
    "Music Composers",
    "Filmmakers",
    "Podcasts",
    "Radio & TV Producers",
    "Voiceover artists",
    "Radio & TV Hosts",
    "Film Production Companies",
    "News Anchors & Reporters",
    "Broadcasting Stations",
    "Animators",
    "Animation Studios",
    "Vloggers",
    "Digital Streaming Platforms"
  ],
  "digitalInteractiveMedia": [
    "Game Developers",
    "Mobile App Developers",
    "Video Game Designers",
    "Virtual Reality Creators",
    "Augmented Reality Specialists",
    "Digital Content Producers",
    "Gaming Studios",
    "Mobile App Development Firms",
    "Digital Content Platforms"
  ],
  "creativeServices": [
    "Advertising creatives",
    "Marketing Professionals",
    "Research & Development Experts",
    "Event planners & coordinators",
    "Live performance artists",
    "Cultural experience providers",
    "Communication specialists",
    "Graphic Designers"
  ],
  "design": [
    "Architects",
    "Urban Landscape Artists",
    "Environmental Planners",
    "Interior & Spatial Planners",
    "Product Designers",
    "Fashion Designers",
    "Accessory makers",
    "Textile developers",
    "Furniture makers",
    "Jewelry artisans",
    "Toy makers"
  ],
  "publishingAndPrintMedia": [
    "Authors",
    "Editorial Writers and Columnists",
    "Print Journalists",
    "Magazine Editors",
    "Comic Artists and Publishers",
    "Newspaper editors and companies",
    "Novelists",
    "Cartoonist"
  ],
  "performingArts": [
    "Choir Director/Trainer",
    "Musicians",
    "Actors",
    "Dance Choreographer",
    "Dancers/Dance Troupe",
    "Theater Directors",
    "Circus Performers",
    "Spoken word poets",
    "Orchestras",
    "Theater companies"
  ],
  "visualArts": [
    "Painters",
    "Tattoo artists",
    "Sculptors",
    "Art galleries/studios",
    "Photographers",
    "Photography studios",
    "Multimedia Artists",
    "Collage artists"
  ],
  "traditionalAndCulturalExpressions": [
    "Traditional craftsmen/women",
    "Cultural event organizers",
    "Folk musicians",
    "Artisans of indigenous crafts",
    "Crafts cooperatives",
    "Cultural Festivals",
    "Traditional Cuisine Restaurants",
    "Folk music ensembles"
  ],
  "culturalSites": [
    "Museum Curators",
    "Archeologists",
    "Librarians",
    "Provincial, Municipal/City Planners",
    "Monumental Sculptors",
    "Event Curators"
  ]
};

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Upload all categories to Firestore
  Future<void> uploadCategories() async {
    for (final entry in categories.entries) {
      final categoryName = entry.key;
      final items = entry.value;

      await _db.collection('categories').doc(categoryName).set({
        'items': items,
      });

      print('Uploaded $categoryName');
    }
    print('All categories uploaded successfully!');
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../role_selection_page.dart'; // ✅ adjust path if needed

class ClientHomePage extends StatefulWidget {
  final String clientName; // comes from Firestore

  const ClientHomePage({super.key, required this.clientName});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showAllCategories = false;

  final List<Map<String, dynamic>> _categories = [
    {'title': 'Visual Arts', 'icon': Icons.palette},
    {'title': 'Audiovisual Media', 'icon': Icons.movie},
    {'title': 'Digital Interactive Media', 'icon': Icons.videogame_asset},
    {'title': 'Creative Services', 'icon': Icons.work},
    {'title': 'Design', 'icon': Icons.design_services},
    {'title': 'Publishing & Print', 'icon': Icons.menu_book},
    {'title': 'Performing Arts', 'icon': Icons.theater_comedy},
  ];

  final PageController _categoryPageController = PageController();

  @override
  void dispose() {
    _categoryPageController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            const ListTile(leading: Icon(Icons.home), title: Text('Home')),
            const ListTile(leading: Icon(Icons.person), title: Text('Profile')),
            const ListTile(
                leading: Icon(Icons.settings), title: Text('Settings')),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Logout
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    child: const Icon(Icons.menu, size: 28),
                  ),
                  Column(
                    children: [
                      Text(
                        'Current Location',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const Text(
                        'Naval, Biliran',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red, size: 28),
                    onPressed: _logout,
                  ),
                ],
              ),
            ),
            // Body scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Welcome, ${widget.clientName}",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const Text(
                      "Discover Amazing Artists",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    // Search Bar
                    GestureDetector(
                      onTap: () => debugPrint("Search tapped"),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "Search...",
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.teal[600],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.tune,
                                color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Category Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Category",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            _showAllCategories = !_showAllCategories;
                          }),
                          child: Text(
                            _showAllCategories ? "Show less" : "View all",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 16),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Swipe Categories (Shopee-style)
                    _showAllCategories
                        ? Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _categories.map((category) {
                              return SizedBox(
                                width: (MediaQuery.of(context).size.width -
                                        32 -
                                        24) /
                                    3,
                                child: CategoryCard(
                                    title: category['title'],
                                    icon: category['icon']),
                              );
                            }).toList(),
                          )
                        : SizedBox(
                            height: 180,
                            child: Column(
                              children: [
                                Expanded(
                                  child: PageView.builder(
                                    controller: _categoryPageController,
                                    itemCount: (_categories.length / 3).ceil(),
                                    itemBuilder: (context, pageIndex) {
                                      final startIndex = pageIndex * 3;
                                      final endIndex =
                                          (startIndex + 3 <=
                                                  _categories.length)
                                              ? startIndex + 3
                                              : _categories.length;
                                      final pageItems = _categories.sublist(
                                          startIndex, endIndex);

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: pageItems.map((category) {
                                          return Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6),
                                              child: CategoryCard(
                                                title: category['title'],
                                                icon: category['icon'],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SmoothPageIndicator(
                                  controller: _categoryPageController,
                                  count: (_categories.length / 3).ceil(),
                                  effect: WormEffect(
                                    dotHeight: 8,
                                    dotWidth: 8,
                                    activeDotColor: Colors.teal,
                                    dotColor: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),

                    const SizedBox(height: 30),
                    const Text(
                      "Popular Artists & Venues",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: PopularArtistCard(isVenue: true)),
                        SizedBox(width: 12),
                        Expanded(child: PopularArtistCard(isVenue: false)),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const CategoryCard({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => debugPrint("$title tapped!"),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.teal[600]),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }
}

class PopularArtistCard extends StatelessWidget {
  final bool isVenue;

  const PopularArtistCard({super.key, required this.isVenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.teal[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                color: isVenue ? Colors.purple[100] : Colors.amber[100],
              ),
              child: Center(
                child: isVenue
                    ? Icon(Icons.event, size: 60, color: Colors.purple[300])
                    : Icon(Icons.restaurant,
                        size: 60, color: Colors.amber[600]),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Name",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Location",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

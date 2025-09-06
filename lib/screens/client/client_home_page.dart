import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../role_selection_page.dart';
import '../../widgets/category_card.dart';
import '../../widgets/popular_artist_card.dart';
import 'client_inbox_page.dart';
import 'client_saved_page.dart';
import 'client_profile_page.dart';

class ClientHomePage extends StatefulWidget {
  final String clientName;

  const ClientHomePage({super.key, required this.clientName});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showAllCategories = false;
  int _currentIndex = 0;
  final PageController _categoryPageController = PageController();

  final List<Map<String, dynamic>> _categories = [
    {'title': 'Visual Arts', 'icon': Icons.palette},
    {'title': 'Audiovisual Media', 'icon': Icons.movie},
    {'title': 'Digital Interactive Media', 'icon': Icons.videogame_asset},
    {'title': 'Creative Services', 'icon': Icons.work},
    {'title': 'Design', 'icon': Icons.design_services},
    {'title': 'Publishing & Print', 'icon': Icons.menu_book},
    {'title': 'Performing Arts', 'icon': Icons.theater_comedy},
  ];

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
    final List<Widget> _pages = [
      _buildHomePage(),
      const InboxPage(),
      const SavedPage(),
      ProfilePage(clientName: widget.clientName, clientEmail: FirebaseAuth.instance.currentUser?.email ?? "No Email",),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      drawer: _buildDrawer(),
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60,
        backgroundColor: Colors.grey[100]!,
        color: Colors.teal,
        buttonBackgroundColor: Colors.green,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        items: [
          Icon(Icons.home,
              size: 30,
              color: _currentIndex == 0 ? Colors.white : Colors.white70),
          Icon(Icons.inbox,
              size: 30,
              color: _currentIndex == 1 ? Colors.white : Colors.white70),
          Icon(Icons.bookmark,
              size: 30,
              color: _currentIndex == 2 ? Colors.white : Colors.white70),
          Icon(Icons.person,
              size: 30,
              color: _currentIndex == 3 ? Colors.white : Colors.white70),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
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
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              setState(() => _currentIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              setState(() => _currentIndex = 3);
              Navigator.pop(context);
            },
          ),
          const ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 30),
                  _buildCategorySection(),
                  const SizedBox(height: 30),
                  const Text(
                    "Popular Artists & Venues",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildHeader() {
    return Container(
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
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const Text(
                'Naval, Biliran',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red, size: 28),
            onPressed: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => debugPrint("Search tapped"),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blueGrey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    "Search...",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
            child: const Icon(Icons.tune, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Category",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () => setState(() => _showAllCategories = !_showAllCategories),
              child: Text(
                _showAllCategories ? "Show less" : "View all",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        _showAllCategories ? _buildAllCategories() : _buildPageCategories(),
      ],
    );
  }

  Widget _buildAllCategories() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _categories.map((category) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 32 - 24) / 3,
          child: CategoryCard(title: category['title'], icon: category['icon']),
        );
      }).toList(),
    );
  }

  Widget _buildPageCategories() {
    return SizedBox(
      height: 180,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _categoryPageController,
              itemCount: (_categories.length / 3).ceil(),
              itemBuilder: (context, pageIndex) {
                final startIndex = pageIndex * 3;
                final endIndex = (startIndex + 3 <= _categories.length)
                    ? startIndex + 3
                    : _categories.length;
                final pageItems = _categories.sublist(startIndex, endIndex);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: pageItems.map((category) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
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
    );
  }
}

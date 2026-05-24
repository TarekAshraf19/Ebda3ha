import 'package:ebad3a_ecommerce/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cart_screen/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// اللون الأساسي للتطبيق
const Color kPrimaryPink = Color(0xFFB71A6B);

class _HomeScreenState extends State<HomeScreen> {
  int _bottomIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // =============== SIDE DRAWER ===============
      drawer: _buildSideDrawer(),

      // ================== APP BAR ==================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primaryColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Ebda3a",
          style: TextStyle(
            fontSize: 24,
            color: kPrimaryPink,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: kPrimaryPink,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),

      // ================== BODY ==================
      body: _bottomIndex == 0
          ? _buildHomeBody()
          : _buildPlaceholderPage(_bottomIndex),

      // ================== BOTTOM NAV ==================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: (i) => setState(() => _bottomIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: kPrimaryPink,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined, color: Colors.white),
            activeIcon: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.home_outlined, color: kPrimaryPink),
            ),
            label: "Home",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.white),
            label: "Search",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined, color: Colors.white),
            label: "Bag",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border, color: Colors.white),
            label: "Fav",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, color: Colors.white),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  // صفحات الـ bottom nav التانية مؤقتًا
  Widget _buildPlaceholderPage(int index) {
    final titles = ["Home", "Search", "Bag", "Favorites", "Profile"];
    return Center(
      child: Text(
        titles[index],
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ================== SIDE DRAWER ==================
  Widget _buildSideDrawer() {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? "Tarek Ashraf";
    final email = user?.email ?? "Tarek@gmail.com";

    return Drawer(
      child: Container(
        color: kPrimaryPink,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage(
                        'assets/images/Tarek Ashraf.png', // لو عندك صورة بروفايل حطها هنا
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _drawerItem(Icons.home_outlined, "Homepage", true, () {
                Navigator.pop(context);
              }),
              _drawerItem(Icons.search, "Discover", false, () {}),
              _drawerItem(Icons.shopping_bag_outlined, "My Order", false, () {}),
              _drawerItem(Icons.favorite_border, "Wishlist", false, () {}),
              _drawerItem(Icons.person_outline, "My profile", false, () {}),
              _drawerItem(Icons.chat_bubble_outline, "Chat support", false, () {}),
              const Spacer(),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: kPrimaryPink,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Light",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            "Dark",
                            style: TextStyle(
                              color: kPrimaryPink,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(
      IconData icon, String title, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: selected ? kPrimaryPink : Colors.white,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: selected ? kPrimaryPink : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  // ================== HOME CONTENT ==================
  Widget _buildHomeBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildMainBanner(),
            const SizedBox(height: 8),
            _buildDots(),
            const SizedBox(height: 18),

            // لو في search text نعرض النتائج الأول
            if (_searchText.isNotEmpty) ...[
              _buildSearchResults(),
              const SizedBox(height: 24),
            ] else ...[
              // -------- Categories --------
              _buildSectionHeader("Categories", showArrow: true),
              const SizedBox(height: 10),
              _buildCategoriesList(),
              const SizedBox(height: 22),

              // -------- Recommended --------
              _buildSectionHeader("Recommended", showArrow: true),
              const SizedBox(height: 10),
              _buildProductsStrip(
                query:
                FirebaseFirestore.instance.collection('products'),
              ),
              const SizedBox(height: 22),

              // -------- Middle Offer Banner --------
              _buildSmallOffer(),
              const SizedBox(height: 22),

              // -------- Feature Products --------
              _buildSectionHeader("Feature Products", showArrow: true),
              const SizedBox(height: 10),
              _buildProductsStrip(
                query: FirebaseFirestore.instance
                    .collection('products')
                    .where('isFeatured', isEqualTo: true),
              ),
              const SizedBox(height: 22),

              // -------- Bags Products --------
              _buildSectionHeader("Bags Products", showArrow: true),
              const SizedBox(height: 10),
              _buildProductsStrip(
                query: FirebaseFirestore.instance
                    .collection('products')
                    .where('category', isEqualTo: "Bags"),
              ),
              const SizedBox(height: 22),

              // -------- New Arrival --------
              _buildSectionHeader("New Arrival", showArrow: true),
              const SizedBox(height: 10),
              _buildProductsStrip(
                query: FirebaseFirestore.instance
                    .collection('products')
                    .orderBy('createdAt', descending: true),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  // ================== UI PARTS ==================

  // --- Search Bar + search functionality ---
  Widget _buildSearchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: kPrimaryPink, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchText = value.trim();
            });
          },
          decoration: const InputDecoration(
            icon: Icon(Icons.search, color: kPrimaryPink),
            hintText: "what do you search for?",
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // --- Search Results from Firestore ---
  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Search Results",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Error loading products");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            final query = _searchText.toLowerCase();

            final results = docs.where((doc) {
              final name =
              (doc['name'] ?? '').toString().toLowerCase();
              return name.contains(query);
            }).toList();

            if (results.isEmpty) {
              return const Text("No products found");
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final p = results[index];
                final name = p['name'] ?? '';
                final image = p['image'] ??
                    "https://via.placeholder.com/300x300.png?text=Product";
                final price = p['price'] ?? 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(18),
                        ),
                        child: Image.network(
                          image,
                          width: 90,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "\$ ${price.toString()}",
                                style: const TextStyle(
                                  color: kPrimaryPink,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // --- Big Sale Banner (asset image) ---
  Widget _buildMainBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Image.asset(
        'assets/images/Banner 1.png',
        height: 170,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  // --- Dots تحت البانر ---
  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
            (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == 1 ? 14 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: i == 1 ? kPrimaryPink : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // --- Section Header (Categories / Recommended / ...) ---
  Widget _buildSectionHeader(String title, {bool showArrow = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style:
          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            const Text(
              "See All",
              style: TextStyle(
                color: kPrimaryPink,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 6),
              Container(
                height: 22,
                width: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: const Icon(Icons.arrow_forward_ios,
                    size: 11, color: Colors.white),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // --- Categories List (4 صور مختلفة + اسم + عدد) ---
  Widget _buildCategoriesList() {
    return SizedBox(
      height: 160,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading categories"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No categories yet"));
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final cat = docs[index];

              final String name =
              cat.data().toString().contains('name')
                  ? (cat['name'] as String)
                  : '';
              final int count =
              cat.data().toString().contains('count')
                  ? (cat['count'] as int)
                  : 0;

              List<String> imagesList = [];
              if (cat.data().toString().contains('images') &&
                  cat['images'] is List) {
                imagesList =
                List<String>.from(cat['images'] as List<dynamic>);
              }

              const String fallbackImage =
                  "https://via.placeholder.com/150x150.png?text=Category";

              return Container(
                width: 130,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        physics:
                        const NeverScrollableScrollPhysics(),
                        children: List.generate(
                          4,
                              (i) {
                            final String imgUrl =
                            (i < imagesList.length &&
                                imagesList[i].isNotEmpty)
                                ? imagesList[i]
                                : fallbackImage;

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imgUrl,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE3ED),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "$count",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryPink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- شريط منتجات أفقي (زي التصميم: صورة شمال + نص يمين) ---
  Widget _buildProductsStrip({required Query query}) {
    return SizedBox(
      height: 130,
      child: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading products"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No products yet"));
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final p = docs[index];
              final name = p['name'] ?? '';
              final image = p['image'] ??
                  "https://via.placeholder.com/300x300.png?text=Product";
              final priceValue = p['price'] ?? 0;
              final priceText = priceValue is num
                  ? priceValue.toStringAsFixed(2)
                  : priceValue.toString();

              return Container(
                width: 230,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(18),
                      ),
                      child: Image.network(
                        image,
                        width: 90,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "\$ $priceText",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryPink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- البانر الصغير الوردي في النص ---
  Widget _buildSmallOffer() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: kPrimaryPink,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      alignment: Alignment.centerLeft,
      child: const Text(
        "Accessories\nup to 50% off",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
    );
  }
}
// file: home_content_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rent_app/colors.dart';
import 'car_detail_screen.dart';
import 'car_model.dart';
import 'auth_service.dart';

class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({super.key});

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  int _selectedCategory = 0;
  final categories = ['All', 'Beat', 'Nmax', 'Mercedes', 'Audi'];

  late Future<List<Car>> futureCars;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  String _userName = '';

  @override
  void initState() {
    super.initState();
    futureCars = fetchKendaraan();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final authService = AuthService();
    await authService.loadToken();
    final response = await authService.fetchUser();

    if (response != null && response.statusCode == 200) {
      setState(() {
        _userName = response.data['name'] ?? 'User';
      });
    }
  }

  Future<List<Car>> fetchKendaraan() async {
    final response = await http.get(Uri.parse('http://192.168.100.7:8080/api/kendaraan'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Car.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data kendaraan');
    }
  }

  List<Car> _filterFeaturedCars(List<Car> cars) {
    final category = categories[_selectedCategory].toLowerCase();
    if (category == 'all') return cars;
    return cars.where((car) => car.merk.toLowerCase() == category).toList();
  }

  List<Car> _filterPopularDeals(List<Car> cars) {
    final query = _searchQuery.toLowerCase();
    return cars.where((car) {
      return car.merk.toLowerCase().contains(query) ||
          car.lokasi.toLowerCase().contains(query) ||
          car.warna.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    _buildCategories(),
                    const SizedBox(height: 30),
                    _buildSectionTitle('Featured Cars'),
                    const SizedBox(height: 15),
                    _buildFeaturedCars(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Popular Deals'),
                    const SizedBox(height: 15),
                    _buildPopularDeals(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hello, $_userName", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 5),
                  const Text("Find your dream car", style: TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.notifications_rounded, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: AppColors.textLight),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search for your dream car',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    color: AppColors.textLight,
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.tune, color: AppColors.secondary, size: 20),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondary : AppColors.cardBg,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textLight,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        TextButton(
          onPressed: () {},
          child: Text("View All", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildFeaturedCars() {
    return FutureBuilder<List<Car>>(
      future: futureCars,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final cars = _filterFeaturedCars(snapshot.data!);
        return SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailScreen(car: car))),
                child: Container(
                  width: 220,
                  margin: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(
                            'http://192.168.100.7:8080/storage/${car.image}',
                            width: double.infinity,
                            height: 140,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.car_rental),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(car.warna, style: TextStyle(color: AppColors.textLight)),
                            const SizedBox(height: 5),
                            Text(car.merk, style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Text('Rp ${car.harga}', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPopularDeals() {
    return FutureBuilder<List<Car>>(
      future: futureCars,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final cars = _filterPopularDeals(snapshot.data!);
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cars.length,
          itemBuilder: (context, index) {
            final car = cars[index];
            return InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailScreen(car: car))),
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Container(
                        height: 80,
                        width: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'http://192.168.100.7:8080/storage/${car.image}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.car_rental),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(car.merk, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 5),
                            Text('Lokasi: ${car.lokasi}'),
                            const SizedBox(height: 5),
                            Text('Rp ${car.harga}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

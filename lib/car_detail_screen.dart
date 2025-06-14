import 'package:flutter/material.dart';
import 'package:rent_app/colors.dart';
import 'car_model.dart';
import 'sewa_form_screen.dart'; // ✅ Tambahkan import ini

class CarDetailScreen extends StatelessWidget {
  final Car car;

  const CarDetailScreen({required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Positioned.fill(
                        child: Hero(
                          tag: car.id,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0.8),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Image.network(
                              'http://192.168.100.7:8080/storage/${car.image}',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.car_rental),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.primary.withOpacity(0.8),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.favorite,
                          color: AppColors.secondary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: Offset(0, -30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 25),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(car.bahanBakar,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          car.merk,
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: AppColors.textDark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Rp ${car.harga}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: AppColors.secondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'per day',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildInfoChip(Icons.speed, '300 km/h'),
                                    _buildInfoChip(Icons.account_tree_outlined, 'Automatic'),
                                    _buildInfoChip(Icons.local_gas_station, car.bahanBakar),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                          _buildSpecSection(),
                          SizedBox(height: 30),
                          _buildFeatureSection(),
                          SizedBox(height: 30),
                          _buildDescriptionSection(),
                          SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(context), // ✅ konteks ditambahkan
          )
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) => Container(
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        SizedBox(width: 8),
        Text(label, style: TextStyle(color: AppColors.textDark)),
      ],
    ),
  );

  Widget _buildSpecSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Specifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
      SizedBox(height: 15),
      Row(
        children: [
          Expanded(child: _buildSpecItem("Power", "350 HP", Icons.bolt)),
          Expanded(child: _buildSpecItem("0-60 mph", "4.5", Icons.timer)),
          Expanded(child: _buildSpecItem("Top Speed", "300 km/h", Icons.speed)),
        ],
      )
    ],
  );

  Widget _buildFeatureSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Features', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
      SizedBox(height: 15),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _buildFeatureChip("Bluetooth"),
          _buildFeatureChip("Apple CarPlay"),
          _buildFeatureChip("Android Auto"),
          _buildFeatureChip("360 Camera"),
          _buildFeatureChip("Parking Sensors"),
          _buildFeatureChip("Navigation"),
        ],
      )
    ],
  );

  Widget _buildDescriptionSection() => Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Description", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        SizedBox(height: 15),
        Text("Experience luxury and performance with the ${car.merk}. This stunning vehicle combines cutting-edge technology with elegant design to deliver an unforgettable driving experience.",
          style: TextStyle(color: AppColors.textLight, height: 1.5),
        ),
      ],
    ),
  );

  Widget _buildSpecItem(String label, String value, IconData icon) => Container(
    padding: EdgeInsets.all(15),
    margin: EdgeInsets.symmetric(horizontal: 5),
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      children: [
        Icon(icon, color: AppColors.secondary, size: 20),
        SizedBox(height: 10),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
        SizedBox(height: 5),
        Text(label, style: TextStyle(color: AppColors.textLight, fontSize: 12)),
      ],
    ),
  );

  Widget _buildFeatureChip(String label) => Container(
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.secondary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 1),
    ),
    child: Text(label, style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w500)),
  );

  Widget _buildBottomBar(BuildContext context) => Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: Offset(0, -5),
        )
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Price", style: TextStyle(color: AppColors.textLight, fontSize: 14)),
              SizedBox(height: 5),
              Text("Rp ${car.harga}/day", style: TextStyle(color: AppColors.textLight, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SewaFormScreen(
                    kendaraanId: car.id,
                    merk: car.merk,
                    harga: double.tryParse(car.harga.toString()) ?? 0,
                  ),
                ),
              );
            },
            child: Text("Book Now", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    ),
  );
}

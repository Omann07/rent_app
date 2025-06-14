import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'auth_service.dart';
import 'colors.dart';

class SewaFormScreen extends StatefulWidget {
  final int kendaraanId;
  final String merk;
  final double harga;
  final String? image;

  const SewaFormScreen({
    Key? key,
    required this.kendaraanId,
    required this.merk,
    required this.harga,
    this.image,
  }) : super(key: key);

  @override
  State<SewaFormScreen> createState() => _SewaFormScreenState();
}

class _SewaFormScreenState extends State<SewaFormScreen> {
  String namaUser = '';
  String email = '';
  int? userId;
  DateTime? tanggalSewa;
  DateTime? tanggalKembali;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final auth = AuthService();
    await auth.loadToken();
    final res = await auth.fetchUser();
    if (res != null && res.statusCode == 200) {
      setState(() {
        userId = res.data['id'];
        namaUser = res.data['name'] ?? '';
        email = res.data['email'] ?? '';
      });
    }
  }

  double getTotalHarga() {
    if (tanggalSewa != null && tanggalKembali != null) {
      final days = tanggalKembali!.difference(tanggalSewa!).inDays + 1;
      return days * widget.harga;
    }
    return 0;
  }

  Future<void> submitSewa() async {
    if (tanggalSewa == null || tanggalKembali == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap pilih tanggal sewa dan kembali.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final auth = AuthService();
      final res = await auth.createSewa({
        'user_id': userId,
        'kendaraan_id': widget.kendaraanId,
        'nama_user': namaUser,
        'harga': widget.harga,
        'tanggal_sewa': DateFormat('yyyy-MM-dd').format(tanggalSewa!),
        'tanggal_kembali': DateFormat('yyyy-MM-dd').format(tanggalKembali!),
        'total_harga': getTotalHarga(),
        'merk_kendaraan': widget.merk,
      });

      if (res != null && res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sewa berhasil disimpan')),
        );
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.response?.data['message'] ?? 'Terjadi kesalahan'}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildHorizontalField(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: AppBar(
            title: const Text('Form Sewa', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.image != null && widget.image!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'http://192.168.100.7:8080/storage/${widget.image!}',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.car_rental, size: 60, color: Colors.grey)),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            buildHorizontalField("Nama", namaUser),
            const SizedBox(height: 10),
            buildHorizontalField("Email", email),
            const SizedBox(height: 10),
            buildHorizontalField("User ID", userId?.toString() ?? '-'),
            const SizedBox(height: 10),
            buildHorizontalField("Kendaraan", widget.merk),
            const SizedBox(height: 10),
            buildHorizontalField("Harga", "Rp ${widget.harga.toStringAsFixed(0)}"),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => tanggalSewa = picked);
                }
              },
              child: buildHorizontalField(
                "Tgl Sewa",
                tanggalSewa != null ? DateFormat('dd MMM yyyy').format(tanggalSewa!) : 'Pilih Tanggal',
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: tanggalSewa ?? DateTime.now(),
                  firstDate: tanggalSewa ?? DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => tanggalKembali = picked);
                }
              },
              child: buildHorizontalField(
                "Tgl Kembali",
                tanggalKembali != null ? DateFormat('dd MMM yyyy').format(tanggalKembali!) : 'Pilih Tanggal',
              ),
            ),
            const SizedBox(height: 10),
            buildHorizontalField("Total", "Rp ${getTotalHarga().toStringAsFixed(0)}"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: submitSewa,
              child: const Text('Sewa Sekarang'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

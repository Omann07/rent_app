import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'auth_service.dart';
import 'colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> history = [];
  bool isLoading = true;

  DateTime? tanggalMulai;
  DateTime? tanggalAkhir;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final auth = AuthService();
    await auth.loadToken();
    final res = await auth.dio.get('/riwayat');

    if (res.statusCode == 200) {
      final allHistory = res.data;
      setState(() {
        history = _filterByDate(allHistory);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      print("Failed to fetch history: ${res.data}");
    }
  }

  List<dynamic> _filterByDate(List<dynamic> data) {
    if (tanggalMulai == null || tanggalAkhir == null) return data;
    return data.where((item) {
      final tanggal = DateTime.parse(item['tanggal_sewa']);
      return tanggal.isAfter(tanggalMulai!.subtract(const Duration(days: 1))) &&
          tanggal.isBefore(tanggalAkhir!.add(const Duration(days: 1)));
    }).toList();
  }

  String formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd MMM yyyy').format(date);
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: tanggalMulai ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        tanggalMulai = picked;
        isLoading = true;
      });
      fetchHistory();
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: tanggalAkhir ?? DateTime.now(),
      firstDate: DateTime(2020), // ← tidak tergantung tanggalMulai
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        tanggalAkhir = picked;
        isLoading = true;
      });
      fetchHistory();
    }
  }

  Widget buildDateField({
    required String label,
    required String? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: value ?? 'Pilih Tanggal',
                hintStyle: const TextStyle(color: Colors.black87),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text(
          'History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Filter",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: buildDateField(
                        label: "Tanggal Mulai",
                        value: tanggalMulai != null
                            ? DateFormat('dd MMM yyyy').format(tanggalMulai!)
                            : null,
                        onTap: _pickStartDate,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Icon(Icons.arrow_forward, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: buildDateField(
                        label: "Tanggal Akhir",
                        value: tanggalAkhir != null
                            ? DateFormat('dd MMM yyyy').format(tanggalAkhir!)
                            : null,
                        onTap: _pickEndDate,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: history.isEmpty
                ? const Center(child: Text("Tidak ada riwayat dalam rentang ini."))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Kendaraan: ${item['merk_kendaraan']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 6),
                              Text(
                                "Tanggal: ${formatDate(item['tanggal_sewa'])} - ${formatDate(item['tanggal_kembali'])}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                "Total Harga: Rp ${item['total_harga']}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            'http://192.168.100.7:8080/storage/${item['kendaraan']['image']}',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.car_rental),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

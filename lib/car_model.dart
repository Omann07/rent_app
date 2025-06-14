class Car {
  final int id;
  final String tanggal;
  final String image;
  final String merk;
  final String nomorPlat;
  final String lokasi;
  final String warna;
  final String bahanBakar;
  final String status;
  final String harga;

  Car({
    required this.id,
    required this.tanggal,
    required this.image,
    required this.merk,
    required this.nomorPlat,
    required this.lokasi,
    required this.warna,
    required this.bahanBakar,
    required this.status,
    required this.harga,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      tanggal: json['tanggal'],
      image: json['image'],
      merk: json['merk_kendaraan'],
      nomorPlat: json['nomor_plat'],
      lokasi: json['lokasi'],
      warna: json['warna'],
      bahanBakar: json['bahan_bakar'],
      status: json['status'],
      harga: json['harga'],
    );
  }
}

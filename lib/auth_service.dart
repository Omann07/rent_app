import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://192.168.100.7:8080/api',
      headers: {
        'Accept': 'application/json',
      },
    ));
    loadToken();
  }

  late Dio _dio;
  String? token;

  /// Public getter agar _dio bisa diakses dari luar class
  Dio get dio => _dio;

  /// Load token dari SharedPreferences dan set header Authorization
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Login dan simpan token
  Future<Response?> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      token = response.data['token'];
      _dio.options.headers['Authorization'] = 'Bearer $token';

      // Simpan token ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token!);

      return response;
    } on DioException catch (e) {
      print("Login error: ${e.response?.data}");
      return e.response;
    }
  }

  /// Fetch user login saat ini
  Future<Response?> fetchUser() async {
    try {
      return await _dio.get('/user');
    } on DioException catch (e) {
      print("Fetch user error: ${e.response?.data}");
      return null;
    }
  }

  /// Logout dan hapus token
  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    token = null;
    _dio.options.headers.remove('Authorization');
  }

  /// Register user baru
  Future<Response> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      });

      token = response.data['token'];
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token!);

      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!;
      } else {
        rethrow;
      }
    }
  }

  /// Kirim data sewa
  Future<Response?> createSewa(Map<String, dynamic> data) async {
    try {
      await loadToken(); // pastikan token aktif
      final response = await _dio.post('/riwayat', data: data);
      return response;
    } on DioException catch (e) {
      print('Create sewa error: ${e.response?.data}');
      return e.response;
    }
  }

  /// Cek login
  bool isLoggedIn() => token != null;
}

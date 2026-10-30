// saya nanti mau tambahkan fitur inputan judul latihan soalnya, kelas dan mapelnya sehingga bisa nampil juga di halaman guru dan dihalaman siswa muncul judul latihan soalnya, kelas dan mapelnya muncul juga di bagian hasil skor yang di akhir beserta nama siswa juga tampil. dan tampilkan juga waktu selesai pengerjaan



import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const WebQuizApp());
}

// Global ValueNotifier untuk mengatur perubahan tema secara dinamis
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class WebQuizApp extends StatelessWidget {
  const WebQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          title: 'Latihan Soal RPL - SMKN 1 Semparuk',
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          themeMode: currentThemeMode,
          home: const MainRouter(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// ==========================================
// WIDGET TOMBOL PILIHAN TEMA MODERN (TERANG / GELAP)
// ==========================================
Widget _buildModernThemeToggle() {
  return ValueListenableBuilder<ThemeMode>(
    valueListenable: themeNotifier,
    builder: (context, currentMode, child) {
      final isLight = currentMode == ThemeMode.light;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  themeNotifier.value = ThemeMode.light;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isLight
                        ? [const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.light_mode,
                        size: 16,
                        color: isLight ? Colors.orange.shade800 : Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Terang',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isLight ? Colors.black87 : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  themeNotifier.value = ThemeMode.dark;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: !isLight ? Colors.blue.shade900 : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: !isLight
                        ? [const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.dark_mode,
                        size: 16,
                        color: !isLight ? Colors.amberAccent : Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Gelap',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: !isLight ? Colors.white : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class MainRouter extends StatefulWidget {
  const MainRouter({super.key});

  @override
  State<MainRouter> createState() => _MainRouterState();
}

class _MainRouterState extends State<MainRouter> {
  bool _isLoading = true;
  bool _isStudentMode = false;

  @override
  void initState() {
    super.initState();
    _checkMode();
  }

  void _checkMode() {
    try {
      final uri = Uri.base;
      if (uri.queryParameters['mode'] == 'student') {
        setState(() {
          _isStudentMode = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isStudentMode = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isStudentMode = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isStudentMode) {
      return const StudentWelcomeScreen();
    } else {
      return const TeacherDashboardScreen();
    }
  }
}

// ==========================================
// 1. TAMPILAN GURU (DI LAPTOP)
// ==========================================
class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  // Fungsi mengunduh template CSV panduan pengisian Google Sheets
  void _downloadExcelTemplate() {
    final csvContent = 
        "soal,opsi_1,opsi_2,opsi_3,opsi_4,opsi_5,kunci_jawaban\n"
        "Apa yang dimaksud dengan UI (User Interface)?,Proses logika alur dalam aplikasi,Struktur dasar aplikasi tanpa warna,Tampilan visual dari aplikasi,Pengujian kenyamanan pengguna,Tombol dan fitur yang bisa diklik langsung,Tampilan visual dari aplikasi\n"
        "Contoh dari UX (User Experience) yang baik adalah...,Warna aplikasi yang cerah,Proses login yang cepat dan mudah,Tombol besar dan mencolok,Gambar ikon yang menarik,Layout penuh efek animasi,Proses login yang cepat dan mudah";

    final bytes = utf8.encode(csvContent);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute("download", "format_bank_soal_sheets.csv")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final currentUrl = Uri.base.toString();
    final baseUrl = currentUrl.contains('?') 
        ? currentUrl.substring(0, currentUrl.indexOf('?')) 
        : currentUrl;
    final studentQuizUrl = "$baseUrl?mode=student";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Guru - Latihan Soal RPL'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          _buildModernThemeToggle(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Dashboard Pengawasan & Bank Soal Online - SMKN 1 Semparuk',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bank soal terhubung langsung ke Google Sheets secara real-time. Guru dapat memperbarui soal langsung di Spreadsheet.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.cloud_sync, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Pengelolaan Bank Soal Google Sheets:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('Pastikan tab sheet bernama "BankSoal" di Google Spreadsheet Anda sudah diisi dengan kolom: Soal, Opsi 1-5, dan Kunci Jawaban. Bobot nilai otomatis membagi rata hingga maksimal total 100 poin.'),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                            onPressed: _downloadExcelTemplate,
                            icon: const Icon(Icons.download),
                            label: const Text('Unduh Panduan / Format Contoh CSV'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: studentQuizUrl,
                    version: QrVersions.auto,
                    size: 220.0,
                  ),
                ),
                const SizedBox(height: 16),
                SelectableText(
                  'Link Siswa: $studentQuizUrl',
                  style: TextStyle(fontSize: 14, color: Colors.blue.shade800, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Panduan Pengawasan:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text('1. Pastikan siswa mengisi nama dan kelas dengan benar sebelum mulai.'),
                        SizedBox(height: 6),
                        Text('2. Sistem mengaktifkan mode Fullscreen otomatis dengan batas toleransi 3 kali pelanggaran.'),
                        SizedBox(height: 6),
                        Text('3. Rekapitulasi nilai akhir otomatis tersimpan dan terkirim ke Google Sheets guru.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. HALAMAN SAMBUTAN & IDENTITAS SISWA
// ==========================================
class StudentWelcomeScreen extends StatefulWidget {
  const StudentWelcomeScreen({super.key});

  @override
  State<StudentWelcomeScreen> createState() => _StudentWelcomeScreenState();
}

class _StudentWelcomeScreenState extends State<StudentWelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? selectedClass = 'XII RPL 1';
  bool isLoadingStatus = true;
  bool hasAlreadyCompleted = false;
  int savedScore = 0;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool completed = prefs.getBool('quiz_flutter_completed') ?? false;
    int finalScore = prefs.getInt('quiz_flutter_score') ?? 0;

    setState(() {
      hasAlreadyCompleted = completed;
      savedScore = finalScore;
      isLoadingStatus = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingStatus) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasAlreadyCompleted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Latihan Selesai'),
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            _buildModernThemeToggle(),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.task_alt, color: Colors.green, size: 90),
                const SizedBox(height: 16),
                const Text(
                  'Latihan Soal Ini Sudah Selesai Dikerjakan!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Perangkat ini tercatat sudah mengirimkan hasil dan nilai ke sistem guru.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text('Nilai Anda:', style: TextStyle(fontSize: 16, color: Colors.grey)),
                Text(
                  '$savedScore',
                  style: const TextStyle(fontSize: 60, color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identitas Peserta Latihan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          _buildModernThemeToggle(),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.badge, size: 60, color: Colors.blue),
                    const SizedBox(height: 12),
                    const Text(
                      'Latihan Soal RPL (5 Pilihan A-E)\nSMKN 1 Semparuk',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap Siswa',
                        hintText: 'Contoh: Ahmad Rizki',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedClass,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Kelas',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.class_),
                      ),
                      items: ['XII RPL 1', 'XII RPL 2', 'XI RPL 1', 'XI RPL 2'].map((String className) {
                        return DropdownMenuItem(value: className, child: Text(className));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedClass = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '📌 PETUNJUK PENGERJAAN LATIHAN:',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                          ),
                          SizedBox(height: 8),
                          Text('1. Masukkan Nama Lengkap dan pilih Kelas Anda dengan benar.'),
                          SizedBox(height: 4),
                          Text('2. Setiap soal memiliki 5 opsi pilihan jawaban (A, B, C, D, E).'),
                          SizedBox(height: 4),
                          Text('3. Klik tombol "Mulai Latihan" untuk masuk ke mode Layar Penuh (Fullscreen).'),
                          SizedBox(height: 4),
                          Text('4. Dilarang keluar dari layar penuh atau berpindah tab aplikasi (maksimal 3 pelanggaran).'),
                          SizedBox(height: 4),
                          Text('5. Nilai akhir Anda otomatis tersimpan dan terkirim ke Google Sheets guru setelah selesai.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        if (_nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Silakan masukkan nama lengkap terlebih dahulu!')),
                          );
                          return;
                        }

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('student_name', _nameController.text.trim());
                        await prefs.setString('student_class', selectedClass ?? 'XII RPL 1');

                        try {
                          html.document.documentElement?.requestFullscreen();
                        } catch (e) {}

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const StudentQuizScreen()),
                        );
                      },
                      icon: const Icon(Icons.fullscreen),
                      label: const Text('Mulai Latihan & Masuk Layar Penuh'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. TAMPILAN KUIS SISWA (AMBIL SOAL ONLINE DARI SHEETS)
// ==========================================
class StudentQuizScreen extends StatefulWidget {
  const StudentQuizScreen({super.key});

  @override
  State<StudentQuizScreen> createState() => _StudentQuizScreenState();
}

class _StudentQuizScreenState extends State<StudentQuizScreen> with WidgetsBindingObserver {
  int currentIndex = 0;
  double score = 0.0;
  int? selectedOption;
  bool isCompleted = false;
  bool _isShowingExitDialog = false;
  bool _isLoadingState = true;
  
  int _violationCount = 0;
  Timer? _timer;
  Timer? _dialogTimer;
  int _remainingSeconds = 120 * 60;
  int _dialogCountdown = 10;
  DateTime? _dialogTargetTime;

  late List<Map<String, dynamic>> shuffledQuizData = [];

  // Data cadangan default jika koneksi online gagal
  final List<Map<String, dynamic>> defaultQuizData = [
    {
      'question': 'Apa tujuan utama dari menginstal Visual Studio Code dalam pengembangan aplikasi berbasis Flutter?',
      'options': [
        'Sebagai tempat penyimpanan database lokal',
        'Sebagai teks editor dan lingkungan pengembangan utama (IDE)',
        'Sebagai emulator perangkat seluler fisik',
        'Sebagai server untuk mengunggah aplikasi ke internet',
        'Sebagai pengganti sistem operasi Windows'
      ],
      'answer': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadQuizDataAndStart();
  }

  Future<void> _loadQuizDataAndStart() async {
    const String webAppUrl = "https://script.google.com/macros/s/AKfycbyXbKMK00KytNYmessV_r4jeqWstLPNppuOLs_6ys-kjw1mRewEnEQTxs-57MXKxQ/exec";

    List<Map<String, dynamic>> sourceData = defaultQuizData;

    try {
      // Ambil soal secara online dari Google Sheets (metode GET)
      var response = await html.window.fetch(webAppUrl);
      String jsonString = await response.text();
      List decoded = jsonDecode(jsonString);

      if (decoded.isNotEmpty) {
        sourceData = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print("Gagal mengambil bank soal online, menggunakan soal default: $e");
    }

    // Acak urutan soal dan pilihan opsi untuk setiap siswa
    shuffledQuizData = _randomizeQuestions(sourceData);
    _loadSavedProgress();
    _listenFullScreenChange();
    _listenWindowFocus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _dialogTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentIndex = prefs.getInt('quiz_saved_index') ?? 0;
      score = prefs.getDouble('quiz_saved_score') ?? 0.0;
      _remainingSeconds = prefs.getInt('quiz_saved_timer') ?? (120 * 60);
      _violationCount = prefs.getInt('quiz_saved_violations') ?? 0;
      _isLoadingState = false;
    });
    startTimer();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quiz_saved_index', currentIndex);
    await prefs.setDouble('quiz_saved_score', score);
    await prefs.setInt('quiz_saved_timer', _remainingSeconds);
    await prefs.setInt('quiz_saved_violations', _violationCount);
  }

  void _listenWindowFocus() {
    html.window.onFocus.listen((event) {
      _checkAndUpdateDialogTime();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!isCompleted && !_isShowingExitDialog) {
      if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
        _handleViolation();
      }
    }
    if (state == AppLifecycleState.resumed) {
      _checkAndUpdateDialogTime();
    }
  }

  void _checkAndUpdateDialogTime() {
    if (_isShowingExitDialog && _dialogTargetTime != null) {
      final now = DateTime.now();
      final remaining = _dialogTargetTime!.difference(now).inSeconds + 1;
      if (remaining > 0) {
        setState(() {
          _dialogCountdown = remaining;
        });
      } else {
        _dialogTimer?.cancel();
        if (_isShowingExitDialog && mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          setState(() {
            _isShowingExitDialog = false;
          });
          finishQuiz();
        }
      }
    }
  }

  void _listenFullScreenChange() {
    html.document.onFullscreenChange.listen((event) {
      bool isFullscreen = html.document.fullscreenElement != null;
      if (!isFullscreen && !isCompleted && !_isShowingExitDialog) {
        _handleViolation();
      }
    });
  }

  void _handleViolation() {
    setState(() {
      _violationCount++;
    });
    _saveProgress();

    if (_violationCount > 3) {
      finishQuiz();
      return;
    }

    _showExitConfirmationDialog();
  }

  void _showExitConfirmationDialog() {
    setState(() {
      _isShowingExitDialog = true;
      _dialogCountdown = 10;
    });

    _dialogTargetTime = DateTime.now().add(const Duration(seconds: 10));
    StateSetter? setDialogState;

    _dialogTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      final now = DateTime.now();
      final remaining = _dialogTargetTime!.difference(now).inSeconds + 1;

      if (remaining > 0) {
        if (_dialogCountdown != remaining) {
          setState(() {
            _dialogCountdown = remaining;
          });
          if (setDialogState != null) {
            setDialogState!(() {});
          }
        }
      } else {
        timer.cancel();
        if (_isShowingExitDialog && mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          setState(() {
            _isShowingExitDialog = false;
          });
          finishQuiz();
        }
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WillPopScope(
        onWillPop: () async => false,
        child: StatefulBuilder(
          builder: (context, setStateDialog) {
            setDialogState = setStateDialog;
            
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
                  SizedBox(width: 10),
                  Text('PERINGATAN PELANGGARAN!', style: TextStyle(color: Colors.red)),
                ],
              ),
              content: Text(
                'Aplikasi terdeteksi keluar dari Layar Penuh atau berpindah aplikasi/tab!\n\n⚠️ Pelanggaran ke-$_violationCount dari 3 batas maksimal.\n\nSegera kembali atau latihan otomatis selesai dalam:\n⏳ $_dialogCountdown Detik',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _dialogTimer?.cancel();
                    Navigator.pop(ctx);
                    setState(() {
                      _isShowingExitDialog = false;
                    });
                    try {
                      html.document.documentElement?.requestFullscreen();
                    } catch (e) {}
                  },
                  child: const Text('Tidak, Lanjutkan Latihan', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  onPressed: () {
                    _dialogTimer?.cancel();
                    Navigator.pop(ctx);
                    setState(() {
                      _isShowingExitDialog = false;
                    });
                    finishQuiz();
                  },
                  child: const Text('Ya, Keluar & Selesaikan'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _randomizeQuestions(List<Map<String, dynamic>> inputData) {
    List<Map<String, dynamic>> copiedData = List.from(inputData);
    copiedData.shuffle();

    List<Map<String, dynamic>> result = [];
    for (var q in copiedData) {
      List<String> options = List<String>.from(q['options']);
      int oldAnswerIdx = q['answer'];
      String correctAnswerText = options[oldAnswerIdx];

      options.shuffle();
      int newAnswerIndex = options.indexOf(correctAnswerText);

      result.add({
        'question': q['question'],
        'options': options,
        'answer': newAnswerIndex,
      });
    }
    return result;
  }

  Future<void> saveQuizResult(int finalScore) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quiz_flutter_completed', true);
    await prefs.setInt('quiz_flutter_score', finalScore);

    await sendScoreToGoogleSheets(finalScore, _violationCount);
  }

  Future<void> sendScoreToGoogleSheets(int finalScore, int violationCount) async {
    final prefs = await SharedPreferences.getInstance();
    String nama = prefs.getString('student_name') ?? 'Tanpa Nama';
    String kelas = prefs.getString('student_class') ?? 'XII RPL 1';
    
    const String webAppUrl = "https://script.google.com/macros/s/AKfycbyXbKMK00KytNYmessV_r4jeqWstLPNppuOLs_6ys-kjw1mRewEnEQTxs-57MXKxQ/exec";

    try {
      await html.window.fetch(
        webAppUrl,
        <String, dynamic>{
          'method': 'POST',
          'mode': 'no-cors',
          'headers': {
            'Content-Type': 'application/json',
          },
          'body': jsonEncode({
            "namaSiswa": nama,
            "kelas": kelas,
            "nilaiAkhir": finalScore,
            "status": finalScore >= 80 ? "Lulus" : "Remedial",
            "pelanggaran": violationCount,
          }),
        },
      );
      print("Data berhasil dikirim ke Google Sheets.");
    } catch (e) {
      print("Gagal mengirim data ke Sheets: $e");
    }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        if (_remainingSeconds % 5 == 0) {
          _saveProgress();
        }
      } else {
        _timer?.cancel();
        finishQuiz();
      }
    });
  }

  void finishQuiz() {
    if (isCompleted) return;
    _timer?.cancel();
    _dialogTimer?.cancel();
    
    int finalRoundedScore = score.round();
    saveQuizResult(finalRoundedScore);

    setState(() {
      isCompleted = true;
    });
  }

  String get timerFormatted {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void answerQuestion(int selectedIndex) {
    setState(() {
      selectedOption = selectedIndex;
    });

    // Bobot nilai otomatis membagi rata agar total maksimal 100
    double pointsPerQuestion = 100 / shuffledQuizData.length;
    if (selectedIndex == shuffledQuizData[currentIndex]['answer']) {
      score += pointsPerQuestion;
    }

    _saveProgress();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        if (currentIndex < shuffledQuizData.length - 1) {
          currentIndex++;
          selectedOption = null;
          _saveProgress();
        } else {
          finishQuiz();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingState) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isCompleted) {
      int finalRoundedScore = score.round();
      return Scaffold(
        appBar: AppBar(
          title: const Text('Latihan Selesai'),
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            _buildModernThemeToggle(),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.task_alt, color: Colors.green, size: 90),
                const SizedBox(height: 16),
                const Text(
                  'Latihan Telah Berakhir & Nilai Telah Dikirim!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Berikut adalah perolehan nilai akhir Anda:',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text('Nilai Anda:', style: TextStyle(fontSize: 16, color: Colors.grey)),
                Text(
                  '$finalRoundedScore',
                  style: const TextStyle(fontSize: 60, color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQ = shuffledQuizData[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Soal (${currentIndex + 1}/${shuffledQuizData.length}) [Pelanggaran: $_violationCount/3]'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.timer, size: 20, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    timerFormatted,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          _buildModernThemeToggle(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (currentIndex + 1) / shuffledQuizData.length,
              backgroundColor: Colors.grey.shade200,
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 20),
            Text(
              currentQ['question'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              currentQ['options'].length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedOption == index ? Colors.blue.shade100 : null,
                    foregroundColor: selectedOption == index ? Colors.black87 : null,
                    elevation: 2,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: selectedOption == index ? Colors.blue : Colors.grey.shade400,
                      ),
                    ),
                  ),
                  onPressed: selectedOption == null ? () => answerQuestion(index) : null,
                  child: Text(
                    currentQ['options'][index],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
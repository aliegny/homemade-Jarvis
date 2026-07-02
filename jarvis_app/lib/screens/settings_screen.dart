import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../services/gemini_service.dart';
import '../services/bluetooth_service.dart' as bt;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _backendUrlController = TextEditingController();

  late bt.BluetoothService _bluetoothService;
  late GeminiService _geminiService;

  bool _geminiConfigured = false;
  bool _isApiKeyVisible = false;
  bool _isSavingKey = false;
  bool _isScanningBT = false;

  List<ScanResult> _btDevices = [];

  @override
  void initState() {
    super.initState();
    _bluetoothService = context.read<bt.BluetoothService>();
    _geminiService = context.read<GeminiService>();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString('gemini_api_key') ?? '';
    final savedUrl =
        prefs.getString('backend_url') ?? 'http://127.0.0.1:5000';

    setState(() {
      _apiKeyController.text = savedKey;
      _backendUrlController.text = savedUrl;
      _geminiConfigured = _geminiService.isInitialized;
    });
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      _showSnack('API key boş olamaz', isError: true);
      return;
    }

    setState(() => _isSavingKey = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gemini_api_key', key);
      await _geminiService.initialize(key);

      setState(() {
        _geminiConfigured = true;
        _isSavingKey = false;
      });
      _showSnack('✅ Gemini başarıyla yapılandırıldı');
    } catch (e) {
      setState(() => _isSavingKey = false);
      _showSnack('Hata: $e', isError: true);
    }
  }

  Future<void> _saveBackendUrl() async {
    final url = _backendUrlController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backend_url', url);
    _showSnack('Backend URL kaydedildi');
  }

  Future<void> _scanBluetooth() async {
    setState(() {
      _isScanningBT = true;
      _btDevices = [];
    });

    try {
      await for (final results
          in _bluetoothService.scanForDevices(timeout: const Duration(seconds: 8))) {
        if (!mounted) break;
        setState(() => _btDevices = results);
      }
    } catch (e) {
      _showSnack('Bluetooth tarama hatası: $e', isError: true);
    }

    if (mounted) setState(() => _isScanningBT = false);
  }

  Future<void> _connectToTG1() async {
    _showSnack('TG-1 aranıyor...');
    final success = await _bluetoothService.connectToTG1();
    _showSnack(
      success ? '✅ TG-1\'e bağlandı' : '❌ TG-1 bulunamadı',
      isError: !success,
    );
    setState(() {});
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    final success = await _bluetoothService.connectToDevice(device);
    _showSnack(
      success
          ? '✅ ${device.platformName} bağlandı'
          : '❌ Bağlantı başarısız',
      isError: !success,
    );
    setState(() {});
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF060A1A),
        elevation: 0,
        title: Text(
          'Ayarlar',
          style: GoogleFonts.orbitron(
            color: Colors.blue.shade300,
            fontSize: 18,
            letterSpacing: 3,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionHeader('🌐 Gemini API'),
          const SizedBox(height: 12),
          _settingsCard(
            children: [
              const Text(
                'Google AI Studio\'dan ücretsiz API key alabilirsiniz:',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              const Text(
                'https://aistudio.google.com',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 16),
              _inputField(
                controller: _apiKeyController,
                label: 'Gemini API Key',
                hint: 'AIza...',
                obscure: !_isApiKeyVisible,
                suffix: IconButton(
                  icon: Icon(
                    _isApiKeyVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _isApiKeyVisible = !_isApiKeyVisible),
                ),
              ),
              const SizedBox(height: 12),
              _actionButton(
                label: 'Kaydet & Test Et',
                icon: Icons.save_alt,
                isLoading: _isSavingKey,
                onPressed: _saveApiKey,
              ),
              if (_geminiConfigured)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Gemini 1.5 Flash hazır',
                        style: TextStyle(
                            color: Colors.green.shade400, fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 28),
          _sectionHeader('🖥️ Lokal Model (Termux)'),
          const SizedBox(height: 12),
          _settingsCard(
            children: [
              const Text(
                'Termux\'ta Flask backend çalışıyorsa buradaki URL\'yi girin.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              _inputField(
                controller: _backendUrlController,
                label: 'Backend URL',
                hint: 'http://127.0.0.1:5000',
              ),
              const SizedBox(height: 12),
              _actionButton(
                label: 'URL Kaydet',
                icon: Icons.link,
                onPressed: _saveBackendUrl,
              ),
            ],
          ),

          const SizedBox(height: 28),
          _sectionHeader('📡 Bluetooth (TG-1)'),
          const SizedBox(height: 12),
          _settingsCard(
            children: [
              if (_bluetoothService.isConnected)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.bluetooth_connected,
                          color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_bluetoothService.connectedDevice?.platformName ?? "Bilinmeyen"} bağlı',
                          style: TextStyle(
                              color: Colors.blue.shade300, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _bluetoothService.disconnect();
                          setState(() {});
                        },
                        child: const Text('Bağlantıyı Kes',
                            style: TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      label: 'TG-1\'e Otomatik Bağlan',
                      icon: Icons.watch,
                      onPressed: _connectToTG1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _actionButton(
                    label: _isScanningBT ? 'Tarıyor...' : 'Tara',
                    icon: Icons.bluetooth_searching,
                    isLoading: _isScanningBT,
                    onPressed: _isScanningBT ? () {} : _scanBluetooth,
                    compact: true,
                  ),
                ],
              ),
              if (_btDevices.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  'Bulunan cihazlar:',
                  style: TextStyle(
                      color: Colors.grey, fontSize: 12, height: 1.5),
                ),
                const SizedBox(height: 6),
                ..._btDevices
                    .where((r) => r.device.platformName.isNotEmpty)
                    .map(
                      (r) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.bluetooth,
                            color: Colors.blue, size: 18),
                        title: Text(
                          r.device.platformName,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                        subtitle: Text(
                          'RSSI: ${r.rssi} dBm',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 11),
                        ),
                        trailing: TextButton(
                          onPressed: () => _connectToDevice(r.device),
                          child: const Text('Bağlan',
                              style: TextStyle(
                                  color: Colors.blue, fontSize: 12)),
                        ),
                      ),
                    ),
              ],
            ],
          ),

          const SizedBox(height: 40),
          Center(
            child: Text(
              'Jarvis v1.0.0 · Gemini 1.5 Flash',
              style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 11,
                  letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.orbitron(
        color: Colors.blue.shade300,
        fontSize: 13,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _settingsCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1229),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade900.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.04),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blue.shade300, fontSize: 12),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF151A35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.blue.shade900.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
        ),
        suffixIcon: suffix,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool compact = false,
  }) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon, size: 16),
      label: compact ? const SizedBox.shrink() : Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A2A5E),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 18,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.blue.shade700.withOpacity(0.5)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _backendUrlController.dispose();
    super.dispose();
  }
}

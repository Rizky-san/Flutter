import 'package:flutter/material.dart';
import 'package:flutter_firebase/screen/admin/pesanan/daftar_pesanan.dart';
import 'package:flutter_firebase/screen/admin/pesanan/pesanan_siap.dart';
import 'package:flutter_firebase/screen/admin/pesanan/pesanan_dibatalkan.dart';
import 'package:flutter_firebase/screen/admin/pesanan/pesanan_selesai.dart';


class DaftarMenuPesanan extends StatelessWidget {
  const DaftarMenuPesanan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF5865F2),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(50)),
            ),
            child: Row(
              children: const [
                Icon(Icons.arrow_back, color: Colors.white),
                Spacer(),
                Text(
                  'Pesanan',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Daftar Menu', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildMenuButton(context, Icons.note_alt, 'Konfirmasi Pesanan', const DaftarPesanan()),
          _buildMenuButton(context, Icons.note_alt, 'Pesanan Siap', const PesananSiap()),
          _buildMenuButton(context, Icons.note_alt, 'Pesanan Dibatalkan', const PesananDibatalkan()),
          _buildMenuButton(context, Icons.note_alt, 'daftar Riwayat', const PesananSelesai()),

        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, IconData icon, String label, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD6DFFF),
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_firebase/screen/admin/daftar_produk.dart';
import 'package:flutter_firebase/screen/admin/pesanan/daftar_menu.dart';
import 'package:flutter_firebase/screen/admin/profile.dart';
import 'package:flutter_firebase/screen/admin/pencarian.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: Column(
        children: [
          // Bagian atas dengan header dan tulisan DASHBOARD
          Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF5865F2),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(50),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.white),
                Spacer(),
                Text(
                  'DASHBOARD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Spacer(),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Grafik Penjualan + Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grafik Penjualan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E7FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Text('Today', style: TextStyle(color: Colors.black)),
                      Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Box grafik dummy
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Center(
                child: Icon(
                  Icons.show_chart,
                  color: Colors.blue,
                  size: 100,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Tombol daftar produk
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DaftarProduk()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFD6DFFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment, color: Colors.black),
                  SizedBox(width: 10),
                  Text(
                    'Daftar Produk',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Bottom navigation (static)
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey)),
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Icon(Icons.home, color: Colors.black),
                // Event Note icon dengan navigasi ke DaftarMenu
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DaftarMenuPesanan()),
                    );
                  },
                  child: const Icon(Icons.event_note, color: Colors.black),
                ),
                const Icon(Icons.hourglass_bottom, color: Colors.black),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                    MaterialPageRoute(builder: (_) => const PencarianUserPage()),
                    );
                  },
  child: const Icon(Icons.group, color: Colors.black),
),
                
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                    MaterialPageRoute(builder: (_) => const AdminProfilePage()),
                    );
                  },
  child: const Icon(Icons.person, color: Colors.black),
),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'berhasil':
        return Colors.green;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User belum login")),
      );
    }

    final uid = user.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Pesanan")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('pesanan')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Riwayat pesanan kosong."));
          }

          final riwayat = snapshot.data!.docs.where((doc) {
            final status = (doc.data() as Map<String, dynamic>)['status'] ?? '';
            return status == 'Berhasil' || status == 'Dibatalkan';
          }).toList();

          if (riwayat.isEmpty) {
            return const Center(child: Text("Belum ada riwayat pesanan."));
          }

          return ListView.builder(
            itemCount: riwayat.length,
            itemBuilder: (context, index) {
              final item = riwayat[index];
              final data = item.data() as Map<String, dynamic>;

              final nama = data['nama'] ?? 'Tanpa Nama';
              final harga = (data['harga'] ?? 0) as int;
              final jumlah = (data['jumlah'] ?? 0) as int;
              final subtotal = harga * jumlah;
              final image = data['image'] ?? '';
              final status = data['status'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: image.isNotEmpty
                      ? Image.network(
                          image,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(nama),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Jumlah: $jumlah"),
                      Text("Harga: Rp $harga"),
                      Text("Subtotal: Rp $subtotal"),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: getStatusColor(status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

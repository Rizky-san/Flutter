import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PesananDibatalkan extends StatelessWidget {
  const PesananDibatalkan({super.key});

  Future<String> getUserEmail(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc['email'] ?? 'Email tidak tersedia';
      } else {
        return 'User tidak ditemukan';
      }
    } catch (e) {
      return 'Gagal mengambil email';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Dibatalkan'),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pesanan_dibatalkan').orderBy('tanggal', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada pesanan dibatalkan'));
          }

          final pesananList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pesananList.length,
            itemBuilder: (context, index) {
              final pesanan = pesananList[index];
              final data = pesanan.data() as Map<String, dynamic>;
              final pesananId = pesanan.id;
              final status = data['status'] ?? '-';
              final totalHarga = data['total_harga'] ?? 0;
              final timestamp = data['tanggal'] as Timestamp?;
              final tanggal = timestamp != null
                  ? timestamp.toDate().toString().substring(0, 16)
                  : '-';
              final userId = data['userId'] ?? '';

              return FutureBuilder<String>(
                future: getUserEmail(userId),
                builder: (context, emailSnapshot) {
                  final email = emailSnapshot.data ?? 'Memuat email...';

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    child: ExpansionTile(
                      title: Text(email),
                      subtitle: Text('Status: $status\nTanggal: $tanggal'),
                      children: [
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('pesanan_dibatalkan')
                              .doc(pesananId)
                              .collection('detail')
                              .get(),
                          builder: (context, detailSnapshot) {
                            if (detailSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (!detailSnapshot.hasData || detailSnapshot.data!.docs.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Tidak ada detail pesanan'),
                              );
                            }

                            final detailList = detailSnapshot.data!.docs;

                            return Column(
                              children: detailList.map((detailDoc) {
                                final detail = detailDoc.data() as Map<String, dynamic>;
                                final namaProduk = detail['nama_produk'] ?? '-';
                                final jumlah = detail['jumlah'] ?? 0;
                                final harga = detail['harga'] ?? 0;

                                return ListTile(
                                  title: Text(namaProduk),
                                  subtitle: Text('Jumlah: $jumlah\nHarga: Rp $harga'),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Total Harga: Rp $totalHarga',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

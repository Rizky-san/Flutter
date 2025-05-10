import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DaftarPesanan extends StatelessWidget {
  const DaftarPesanan({super.key});

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

  Future<void> pindahkanPesanan(String pesananId, Map<String, dynamic> data, String statusBaru, String koleksiTujuan) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Buat salinan dari data agar tidak memengaruhi tampilan lainnya
  final updatedData = Map<String, dynamic>.from(data);
  updatedData['status'] = statusBaru;

  // Tambahkan ke koleksi baru
  await firestore.collection(koleksiTujuan).doc(pesananId).set(updatedData);

  // Pindahkan juga subcollection "detail"
  final detailSnapshot = await firestore.collection('pesanan').doc(pesananId).collection('detail').get();
  for (var doc in detailSnapshot.docs) {
    await firestore.collection(koleksiTujuan).doc(pesananId).collection('detail').doc(doc.id).set(doc.data());
  }

  // Hapus dari koleksi lama
  await firestore.collection('pesanan').doc(pesananId).delete();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pesanan').orderBy('tanggal', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada pesanan'));
          }

          final pesananList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pesananList.length,
            itemBuilder: (context, index) {
              final pesanan = pesananList[index];
              final pesananId = pesanan.id;
              final data = pesanan.data() as Map<String, dynamic>;
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
                  final emailTitle = emailSnapshot.data ?? 'Memuat email...';

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    child: ExpansionTile(
                      title: Text(emailTitle),
                      subtitle: Text('Status: $status\nTanggal: $tanggal'),
                      children: [
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance.collection('pesanan').doc(pesananId).collection('detail').get(),
                          builder: (context, detailSnapshot) {
                            if (detailSnapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
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
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                        if (status == 'Diproses')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await pindahkanPesanan(pesananId, data, 'Siap', 'pesanan_siap');
                                  },
                                  icon: const Icon(Icons.check),
                                  label: const Text('Terima'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await pindahkanPesanan(pesananId, data, 'Dibatalkan', 'pesanan_dibatalkan');
                                  },
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('Batalkan'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                ),
                              ],
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

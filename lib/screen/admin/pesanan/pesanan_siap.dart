import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> pindahkanPesanan(String koleksiAsal, String pesananId, Map<String, dynamic> data, String statusBaru, String koleksiTujuan) async {
  final firestore = FirebaseFirestore.instance;

  data['status'] = statusBaru;

  await firestore.collection(koleksiTujuan).doc(pesananId).set(data);

  final detailSnapshot = await firestore.collection(koleksiAsal).doc(pesananId).collection('detail').get();
  for (var doc in detailSnapshot.docs) {
    await firestore.collection(koleksiTujuan).doc(pesananId).collection('detail').doc(doc.id).set(doc.data());
  }

  await firestore.collection(koleksiAsal).doc(pesananId).delete();
}

class PesananSiap extends StatelessWidget {
  const PesananSiap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Siap'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pesanan_siap').orderBy('tanggal', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada pesanan siap'));
          }

          final pesananList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pesananList.length,
            itemBuilder: (context, index) {
              final pesanan = pesananList[index];
              final pesananId = pesanan.id;
              final data = pesanan.data() as Map<String, dynamic>;
              final userId = data['userId'] ?? '';
              final status = data['status'] ?? '-';
              final totalHarga = data['total_harga'] ?? 0;
              final tanggal = (data['tanggal'] as Timestamp?)?.toDate().toString().substring(0, 16) ?? '-';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                builder: (context, snapshot) {
                  final email = snapshot.data?.get('email') ?? 'Email tidak ditemukan';

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ExpansionTile(
                      title: Text(email),
                      subtitle: Text('Status: $status\nTanggal: $tanggal'),
                      children: [
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance.collection('pesanan_siap').doc(pesananId).collection('detail').get(),
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
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Total Harga: Rp $totalHarga',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await pindahkanPesanan('pesanan_siap', pesananId, data, 'Selesai', 'pesanan_selesai');
                            },
                            icon: const Icon(Icons.done_all),
                            label: const Text('Selesai'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                          ),
                        )
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

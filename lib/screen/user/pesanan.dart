import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class PesananPage extends StatelessWidget {
  const PesananPage({super.key});

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return Colors.amber;
      case 'siap':
        return Colors.blue;
      case 'dibatalkan':
        return Colors.red;
      case 'selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget buildStatusBadge(String status) {
    final color = getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  void showDetailDialog(BuildContext context, Map<String, dynamic> data) {
    final formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final harga = data['harga'] ?? 0;
    final jumlah = data['jumlah'] ?? 0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(data['nama_produk'] ?? 'Detail Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data['image'] != null && data['image'].toString().isNotEmpty)
              Image.network(data['image'], height: 100),
            const SizedBox(height: 8),
            Text("Harga: ${formatter.format(harga)}"),
            Text("Jumlah: $jumlah"),
            Text("Subtotal: ${formatter.format(harga * jumlah)}"),
            Text("ID Produk: ${data['id_produk']}"),
            Text("Status: ${data['status'] ?? 'Diproses'}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  Future<void> batalkanPesanan(
      BuildContext context, String pesananId, String collection) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin membatalkan pesanan ini?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Tidak")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Ya")),
        ],
      ),
    );

    if (konfirmasi == true) {
      final pesananRef =
          FirebaseFirestore.instance.collection(collection).doc(pesananId);

      await pesananRef.update({'status': 'Dibatalkan'});

      final detailSnapshot = await pesananRef.collection('detail').get();
      for (var doc in detailSnapshot.docs) {
        await doc.reference.update({'status': 'Dibatalkan'});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pesanan berhasil dibatalkan"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllPesanan(String uid) async {
    final List<String> koleksi = [
      'pesanan',
      'pesanan_dibatalkan',
      'pesanan_siap',
      'pesanan_selesai'
    ];

    List<Map<String, dynamic>> semuaPesanan = [];

    for (final namaKoleksi in koleksi) {
      final snapshot = await FirebaseFirestore.instance
          .collection(namaKoleksi)
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        data['collection'] = namaKoleksi;
        semuaPesanan.add(data);
      }
    }

    return semuaPesanan;
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
    final formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text("Semua Pesanan Anda")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAllPesanan(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada pesanan."));
          }

          final pesananList = snapshot.data!;

          return ListView.builder(
            itemCount: pesananList.length,
            itemBuilder: (context, index) {
              final pesanan = pesananList[index];
              final status = pesanan['status'] ?? 'Diproses';
              final tanggal = pesanan['tanggal'];
              final totalHarga = pesanan['total_harga'] ?? 0;
              final collection = pesanan['collection'];
              final pesananId = pesanan['id'];

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection(collection)
                    .doc(pesananId)
                    .collection('detail')
                    .get(),
                builder: (context, detailSnapshot) {
                  if (detailSnapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: LinearProgressIndicator(),
                    );
                  }

                  if (!detailSnapshot.hasData ||
                      detailSnapshot.data!.docs.isEmpty) {
                    return const SizedBox();
                  }

                  final detailDocs = detailSnapshot.data!.docs;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(
                                "Tanggal: ${tanggal?.toDate() != null ? dateFormat.format(tanggal.toDate()) : '-'}"),
                            subtitle:
                                Text("Total: ${formatter.format(totalHarga)}"),
                            trailing: buildStatusBadge(status),
                          ),
                          const Divider(),
                          ...detailDocs.map((detail) {
                            final data = detail.data() as Map<String, dynamic>;
                            final namaProduk =
                                data['nama_produk'] ?? 'Tanpa Nama';
                            final harga = (data['harga'] ?? 0) as int;
                            final jumlah = (data['jumlah'] ?? 0) as int;
                            final subtotal = harga * jumlah;
                            final image = data['image'] ?? '';

                            return ListTile(
                              leading: image.isNotEmpty
                                  ? Image.network(image,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover)
                                  : const Icon(Icons.image_not_supported),
                              title: Text(namaProduk),
                              subtitle: Text(
                                  "Jumlah: $jumlah\nHarga: ${formatter.format(harga)}\nSubtotal: ${formatter.format(subtotal)}"),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Wrap(
                                      spacing: 4,
                                      children: [
                                        TextButton(
                                          onPressed: () =>
                                              showDetailDialog(context, data),
                                          child: const Text("Lihat Detail"),
                                        ),
                                        if (status.toLowerCase() != 'dibatalkan' &&
                                            collection == 'pesanan')
                                          TextButton(
                                            onPressed: () => batalkanPesanan(
                                                context, pesananId, collection),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(50, 30),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: const Text("Batalkan"),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
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

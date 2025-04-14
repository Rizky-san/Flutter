import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PesananPage extends StatelessWidget {
  const PesananPage({super.key});

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return Colors.amber;
      case 'siap':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void showDetailDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(data['nama'] ?? 'Detail Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data['image'] != null && data['image'].toString().isNotEmpty)
              Image.network(data['image'], height: 100),
            const SizedBox(height: 8),
            Text("Harga: Rp ${data['harga']}"),
            Text("Jumlah: ${data['jumlah']}"),
            Text("Subtotal: Rp ${(data['harga'] ?? 0) * (data['jumlah'] ?? 0)}"),
            Text("Status: ${data['status']}"),
            Text("Deskripsi: ${data['deskripsi'] ?? '-'}"),
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

  void batalkanPesanan(BuildContext context, String uid, String docId) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin membatalkan pesanan ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Tidak")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Ya")),
        ],
      ),
    );

    if (confirmation == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('pesanan')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pesanan berhasil dibatalkan")),
      );
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
      appBar: AppBar(title: const Text("Pesanan Anda")),
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
            return const Center(child: Text("Belum ada pesanan."));
          }

          final pesanan = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = (data['status'] ?? '').toString().toLowerCase();
            return status == 'diproses' || status == 'siap';
          }).toList();

          if (pesanan.isEmpty) {
            return const Center(child: Text("Belum ada pesanan yang sedang berjalan."));
          }

          return ListView.builder(
            itemCount: pesanan.length,
            itemBuilder: (context, index) {
              final item = pesanan[index];
              final data = item.data() as Map<String, dynamic>;
              final docId = item.id;

              final nama = data['nama'] ?? 'Tanpa Nama';
              final harga = (data['harga'] ?? 0) as int;
              final jumlah = (data['jumlah'] ?? 0) as int;
              final subtotal = harga * jumlah;
              final image = data['image'] ?? '';
              final status = data['status'] ?? 'Diproses';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  children: [
                    ListTile(
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
                    ButtonBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => showDetailDialog(context, data),
                          child: const Text("Lihat Detail"),
                        ),
                        TextButton(
                          onPressed: () => batalkanPesanan(context, uid, docId),
                          child: const Text(
                            "Batalkan",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

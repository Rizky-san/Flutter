import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class KeranjangPage extends StatelessWidget {
  const KeranjangPage({super.key});

  int getInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  void _hapusItem(String uid, String docId) async {
    await FirebaseFirestore.instance
        .collection('keranjang')
        .doc(uid)
        .collection('items')
        .doc(docId)
        .delete();
  }

  void _updateJumlah(String uid, String docId, int jumlah) {
    FirebaseFirestore.instance
        .collection('keranjang')
        .doc(uid)
        .collection('items')
        .doc(docId)
        .update({'jumlah': jumlah});
  }

  void _checkout(BuildContext context, String uid, List<QueryDocumentSnapshot> items) async {
  final pesananRef = FirebaseFirestore.instance.collection('pesanan').doc();

  int totalHarga = 0;

  for (var item in items) {
    final data = item.data() as Map<String, dynamic>;
    final harga = getInt(data['harga']);
    final jumlah = getInt(data['jumlah']);
    totalHarga += harga * jumlah;
  }

  // Tambahkan data pesanan utama
  await pesananRef.set({
    'userId': uid,
    'tanggal': Timestamp.now(),
    'status': 'Diproses',
    'total_harga': totalHarga,
  });

  // Tambahkan detail pesanan
  for (var item in items) {
    final data = item.data() as Map<String, dynamic>;

    await pesananRef.collection('detail').add({
      'id_produk': data['id_produk'],
      'nama_produk': data['nama_produk'],
      'jumlah': data['jumlah'],
      'harga': data['harga'],
      'image': data['image'],
    });

    // Hapus item dari keranjang
    await FirebaseFirestore.instance
        .collection('keranjang')
        .doc(uid)
        .collection('items')
        .doc(item.id)
        .delete();
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Checkout berhasil, semua item diproses.")),
  );
}


  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Keranjang")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('keranjang')
            .doc(uid)
            .collection('items')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Keranjang kosong."));
          }

          final items = snapshot.data!.docs;

          int totalHargaKeseluruhan = items.fold(0, (total, item) {
            final data = item.data() as Map<String, dynamic>;
            final harga = getInt(data['harga']);
            final jumlah = getInt(data['jumlah']);
            return total + (harga * jumlah);
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final data = item.data() as Map<String, dynamic>;

                    final nama = data['nama'] ?? '';
                    final harga = getInt(data['harga']);
                    final jumlah = getInt(data['jumlah']);
                    final stok = getInt(data['stok']);
                    final imageUrl = data['image'] ?? '';

                    return ListTile(
                      leading: Image.network(
                        imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(nama),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Harga: Rp $harga"),
                          Text("Stok: $stok"),
                          Row(
                            children: [
                              const Text('Jumlah: '),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: jumlah.toString(),
                                  keyboardType: TextInputType.number,
                                  onFieldSubmitted: (value) {
                                    final inputJumlah = int.tryParse(value);
                                    if (inputJumlah != null &&
                                        inputJumlah > 0 &&
                                        inputJumlah <= stok) {
                                      _updateJumlah(uid, item.id, inputJumlah);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                            "Jumlah tidak valid atau melebihi stok."),
                                      ));
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _hapusItem(uid, item.id),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "Total Harga Keseluruhan: Rp $totalHargaKeseluruhan",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _checkout(context, uid, items),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text("Checkout Semua"),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

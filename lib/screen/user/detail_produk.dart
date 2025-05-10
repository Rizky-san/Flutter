import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DetailProdukScreen extends StatefulWidget {
  final Map<String, dynamic> produk;
  const DetailProdukScreen({super.key, required this.produk});

  @override
  State<DetailProdukScreen> createState() => _DetailProdukScreenState();
}

class _DetailProdukScreenState extends State<DetailProdukScreen> {
  int jumlah = 1;

  @override
  Widget build(BuildContext context) {
    final produk = widget.produk;
    final stok = produk['stok'] ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(produk['nama'] ?? 'Detail Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (produk['image'] != null)
              Image.network(produk['image'], height: 200, fit: BoxFit.cover)
            else
              const Placeholder(fallbackHeight: 200),
            const SizedBox(height: 12),
            Text("Harga: Rp ${produk['harga']}", style: const TextStyle(fontSize: 16)),
            Text("Stok: $stok", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Deskripsi:", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(produk['deskripsi'] ?? 'Tidak ada deskripsi'),
            const SizedBox(height: 8),
            Text("Tags: ${produk['tags'] ?? '-'}"),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Jumlah: "),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (jumlah > 1) {
                      setState(() => jumlah--);
                    }
                  },
                ),
                Text('$jumlah'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (jumlah < stok) {
                      setState(() => jumlah++);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text("Tambah ke Keranjang"),
                    onPressed: () => tambahKeKeranjang(produk, jumlah),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => beliSekarang(produk, jumlah),
                    child: const Text("Beli Sekarang"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> tambahKeKeranjang(Map<String, dynamic> produk, int jumlah) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final keranjangItemRef = FirebaseFirestore.instance
        .collection('keranjang')
        .doc(uid)
        .collection('items')
        .doc(produk['id']); // ID produk sebagai ID dokumen

    await keranjangItemRef.set({
      'id_produk': produk['id'],
      'nama_produk': produk['nama'],
      'jumlah': jumlah,
      'harga': produk['harga'],
      'image': produk['image'],
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk ditambahkan ke keranjang')),
    );
  }

  Future<void> beliSekarang(Map<String, dynamic> produk, int jumlah) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final pesananRef = FirebaseFirestore.instance.collection('pesanan').doc();

    final totalHarga = jumlah * (produk['harga'] ?? 0);

    // Buat pesanan utama
    await pesananRef.set({
      'userId': uid,
      'tanggal': Timestamp.now(),
      'status': 'Diproses',
      'total_harga': totalHarga,
    });

    // Tambahkan ke subcollection detail
    await pesananRef.collection('detail').add({
      'id_produk': produk['id'],
      'nama_produk': produk['nama'],
      'jumlah': jumlah,
      'harga': produk['harga'],
      'image': produk['image'],
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pembelian berhasil dibuat')),
    );
  }
}

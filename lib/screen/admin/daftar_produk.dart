// lib/screen/admin/daftar_produk.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase/screen/admin/tambah_produk.dart';
import 'package:flutter_firebase/screen/admin/edit_produk.dart';

class DaftarProduk extends StatelessWidget {
  const DaftarProduk({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        backgroundColor: const Color(0xFF5865F2),
        leading: const BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TambahProduk()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('produk').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('Belum ada produk'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index];
                    final id = data.id;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              data['image'],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nama: ${data['nama']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('Stok : ${data['stok']}'),
                                Text('Harga : Rp. ${data['harga']}'),
                                Text('Detail : ${data['deskripsi']}', maxLines: 2, overflow: TextOverflow.ellipsis),
                                Wrap(
                                  spacing: 4,
                                  children: List<Widget>.from(
                                    (data['tags'] as List).map(
                                      (tag) => Chip(label: Text(tag, style: const TextStyle(fontSize: 10))),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.yellow.shade700,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProduk(docId: id),
                                    ),
                                  );
                                },
                                child: const Text('Edit'),
                              ),
                              const SizedBox(height: 4),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Hapus Produk'),
                                          GestureDetector(
                                            onTap: () => Navigator.pop(context),
                                            child: const Icon(Icons.close),
                                          )
                                        ],
                                      ),
                                      content: const Text('Apakah anda yakin ingin menghapus produk ini?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Tidak'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance.collection('produk').doc(id).delete();
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Ya'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

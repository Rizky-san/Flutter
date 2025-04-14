import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/screen/user/detail_produk.dart';
import 'package:flutter_firebase/screen/user/favorit.dart';
import 'package:flutter_firebase/screen/user/keranjang.dart';
import 'package:flutter_firebase/screen/user/pesanan.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final produkRef = FirebaseFirestore.instance.collection('produk');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Beranda"),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: produkRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada produk tersedia."));
          }

          final produkList = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Text("Produk Tersedia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...produkList.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        data['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text("Nama : ${data['nama']}"),
                    subtitle: Text("Harga: Rp ${data['harga']}\nStok: ${data['stok']}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.star_border),
                      onPressed: () => toggleFavorit(uid, data),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailProdukScreen(produk: data),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Keranjang'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Pesanan'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const KeranjangPage()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PesananPage()));
          }
        },
      ),
    );
  }

  Future<void> toggleFavorit(String uid, Map<String, dynamic> produk) async {
    if (produk['id'] == null) {
      print('Produk ID is null');
      return;
    }

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorit')
        .doc(produk['id']);

    final favSnap = await favRef.get();

    if (favSnap.exists) {
      await favRef.delete();
    } else {
      await favRef.set(produk);
    }
  }
}

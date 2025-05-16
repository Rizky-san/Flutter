import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/screen/user/detail_produk.dart';
import 'package:flutter_firebase/screen/user/favorit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final produkRef = FirebaseFirestore.instance.collection('produk');
  Set<String> favoritIds = {};

  @override
  void initState() {
    super.initState();
    loadFavoritIds();
  }

  Future<void> loadFavoritIds() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorit')
        .get();

    setState(() {
      favoritIds = snapshot.docs.map((doc) => doc.id).toSet();
    });
  }

  Future<void> toggleFavorit(String produkId, Map<String, dynamic> produk) async {
    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorit')
        .doc(produkId);

    final favSnap = await favRef.get();

    if (favSnap.exists) {
      await favRef.delete();
      setState(() {
        favoritIds.remove(produkId);
      });
    } else {
      await favRef.set(produk);
      setState(() {
        favoritIds.add(produkId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Produk Tersedia",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.star_border),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritPage()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...produkList.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final produkId = doc.id;
              data['id'] = produkId;

              final isFavorit = favoritIds.contains(produkId);

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
                    icon: Icon(
                      isFavorit ? Icons.star : Icons.star_border,
                      color: isFavorit ? Colors.yellow : null,
                    ),
                    onPressed: () => toggleFavorit(produkId, data),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailProdukScreen(produk: data),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

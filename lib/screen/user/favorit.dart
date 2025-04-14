import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritPage extends StatelessWidget {
  const FavoritPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Favorit")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('favorit')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada produk favorit."));
          }

          final favoritList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: favoritList.length,
            itemBuilder: (context, index) {
              final item = favoritList[index];
              final data = item.data() as Map<String, dynamic>;

              return ListTile(
                leading: Image.network(
                  data['image'] ?? '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(data['nama'] ?? ''),
                subtitle: Text("Harga: Rp ${data['harga']}"),
              );
            },
          );
        },
      ),
    );
  }
}

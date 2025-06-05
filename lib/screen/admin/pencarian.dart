import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PencarianUserPage extends StatefulWidget {
  const PencarianUserPage({super.key});

  @override
  State<PencarianUserPage> createState() => _PencarianUserPageState();
}

class _PencarianUserPageState extends State<PencarianUserPage> {
  String searchQuery = '';

Future<List<Map<String, dynamic>>> fetchUsers() async {
  final usersSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'user')
      .get();

  List<Map<String, dynamic>> combinedUsers = [];

  for (var doc in usersSnapshot.docs) {
    final uid = doc.id;
    final userEmail = doc.data()['email'] ?? '';

    String? nama;
    String? noTelepon;
    String? alamat;

    try {
      final detailSnapshot = await FirebaseFirestore.instance
          .collection('detail_user')
          .doc(uid)
          .get();

      if (detailSnapshot.exists) {
        final detailData = detailSnapshot.data()!;
        nama = detailData['nama'];
        noTelepon = detailData['no_telepon'];
        alamat = detailData['alamat'];
      }
    } catch (e) {
      // Tidak ada data di detail_user atau error lainnya, biarkan kosong
    }

    // Filter berdasarkan searchQuery walaupun nama dari detail_user bisa null
    final lowerCaseNama = nama?.toLowerCase() ?? '';
    if (searchQuery.isEmpty || lowerCaseNama.contains(searchQuery.toLowerCase())) {
      combinedUsers.add({
        'uid': uid,
        'email': userEmail,
        'nama': nama ?? 'Tidak ada nama',
        'no_telepon': noTelepon ?? 'Tidak tersedia',
        'alamat': alamat ?? 'Tidak tersedia',
      });
    }
  }

  return combinedUsers;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pencarian User')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Cari Nama User',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val.trim();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada user ditemukan.'));
                }

                final users = snapshot.data!;

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(user['nama']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${user['email']}'),
                            Text('Telepon: ${user['no_telepon']}'),
                            Text('Alamat: ${user['alamat']}'),
                          ],
                        ),
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

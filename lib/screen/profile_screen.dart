import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController namaController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  String email = '';
  bool isEditing = false;
  bool isLoading = true;

  final InputDecorationTheme _inputDecorationTheme = const InputDecorationTheme(
    labelStyle: TextStyle(color: Colors.black),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white70),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
  );

  @override
  void initState() {
    super.initState();
    fetchUserDetail();
  }

  Future<void> fetchUserDetail() async {
    final userRef = FirebaseFirestore.instance.collection('detail_user').doc(uid);
    final snapshot = await userRef.get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      namaController.text = data['nama'] ?? '';
      teleponController.text = data['no_telepon'] ?? '';
      alamatController.text = data['alamat'] ?? '';
      email = data['email'] ?? '';
    } else {
      namaController.text = '';
      teleponController.text = '';
      alamatController.text = '';
      email = FirebaseAuth.instance.currentUser!.email ?? '';
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveProfile() async {
    final userRef = FirebaseFirestore.instance.collection('detail_user').doc(uid);

    await userRef.set({
      'nama': namaController.text.trim(),
      'no_telepon': teleponController.text.trim(),
      'alamat': alamatController.text.trim(),
      'email': email,
    });

    setState(() {
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: _inputDecorationTheme,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profil Pengguna"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (!isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    isEditing = true;
                  });
                },
              ),
          ],
        ),
        backgroundColor: Colors.white, // Latar belakang gelap untuk kontras teks terang
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextField(
                controller: namaController,
                enabled: isEditing,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: teleponController,
                enabled: isEditing,
                style: const TextStyle(color: Colors.black),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'No Telepon'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: alamatController,
                enabled: isEditing,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: TextEditingController(text: email),
                enabled: false,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 20),
              if (isEditing)
                ElevatedButton.icon(
                  onPressed: saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

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

  // Data backup untuk tombol Batal
  String _originalNama = '';
  String _originalTelepon = '';
  String _originalAlamat = '';

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

    // Simpan data asli
    _originalNama = namaController.text;
    _originalTelepon = teleponController.text;
    _originalAlamat = alamatController.text;

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

    // Update data backup setelah simpan
    _originalNama = namaController.text;
    _originalTelepon = teleponController.text;
    _originalAlamat = alamatController.text;

    setState(() {
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui')),
    );
  }

  void cancelEdit() {
    setState(() {
      namaController.text = _originalNama;
      teleponController.text = _originalTelepon;
      alamatController.text = _originalAlamat;
      isEditing = false;
    });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
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
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: logout,
            ),
          ],
        ),
        backgroundColor: Colors.white,
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
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: saveProfile,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan'),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: cancelEdit,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Batal'),
                    ),
                  ],
                ),
              if (!isEditing)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isEditing = true;
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profil'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

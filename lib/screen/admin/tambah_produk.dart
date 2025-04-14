import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TambahProduk extends StatefulWidget {
  const TambahProduk({super.key});

  @override
  State<TambahProduk> createState() => _TambahProdukState();
}

class _TambahProdukState extends State<TambahProduk> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nama = TextEditingController();
  final TextEditingController _stok = TextEditingController();
  final TextEditingController _harga = TextEditingController();
  final TextEditingController _deskripsi = TextEditingController();
  final TextEditingController _image = TextEditingController();

  Future<void> _tambahProduk() async {
    if (_formKey.currentState!.validate()) {
      // Ambil jumlah produk sekarang untuk generate ID
      final produkSnapshot = await FirebaseFirestore.instance.collection('produk').get();
      final newId = 'produk${(produkSnapshot.docs.length + 1).toString().padLeft(3, '0')}';

      await FirebaseFirestore.instance.collection('produk').doc(newId).set({
        'nama': _nama.text,
        'stok': int.parse(_stok.text),
        'harga': int.parse(_harga.text),
        'deskripsi': _deskripsi.text,
        'image': _image.text,
        'tags': [],
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nama,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _stok,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _harga,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _deskripsi,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _image,
                decoration: const InputDecoration(labelText: 'URL Gambar'),
              ),
              const SizedBox(height: 16),
              _image.text.isNotEmpty
                  ? Image.network(_image.text, height: 150)
                  : const SizedBox(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _tambahProduk,
                child: const Text('Simpan Produk'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

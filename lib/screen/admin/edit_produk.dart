import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProduk extends StatefulWidget {
  final String docId;
  const EditProduk({super.key, required this.docId});

  @override
  State<EditProduk> createState() => _EditProdukState();
}

class _EditProdukState extends State<EditProduk> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _stokController;
  late TextEditingController _hargaController;
  late TextEditingController _deskripsiController;
  late TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _stokController = TextEditingController();
    _hargaController = TextEditingController();
    _deskripsiController = TextEditingController();
    _imageController = TextEditingController();
    _loadData();
  }

  void _loadData() async {
    final doc = await FirebaseFirestore.instance.collection('produk').doc(widget.docId).get();
    final data = doc.data();
    if (data != null) {
      _namaController.text = data['nama'] ?? '';
      _stokController.text = data['stok'].toString();
      _hargaController.text = data['harga'].toString();
      _deskripsiController.text = data['deskripsi'] ?? '';
      _imageController.text = data['image'] ?? '';
    }
  }

  void _updateProduk() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('produk').doc(widget.docId).update({
        'nama': _namaController.text,
        'stok': int.parse(_stokController.text),
        'harga': int.parse(_hargaController.text),
        'deskripsi': _deskripsiController.text,
        'image': _imageController.text,
      });
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _stokController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (value) => value!.isEmpty ? 'Tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'URL Gambar'),
              ),
              const SizedBox(height: 16),
              _imageController.text.isNotEmpty
                  ? Image.network(_imageController.text, height: 150)
                  : const SizedBox(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateProduk,
                child: const Text('Simpan Perubahan'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

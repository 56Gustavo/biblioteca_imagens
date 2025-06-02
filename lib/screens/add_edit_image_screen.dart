import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/image_item.dart';
import '../providers/images_provider.dart';

class AddEditImageScreen extends StatefulWidget {
  final ImageItem? imageItem;

  AddEditImageScreen({this.imageItem});

  @override
  _AddEditImageScreenState createState() => _AddEditImageScreenState();
}

class _AddEditImageScreenState extends State<AddEditImageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isInit = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.imageItem != null) {
      _titleController.text = widget.imageItem!.title;
      _pickedImage = File(widget.imageItem!.imagePath);
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(pickedFile.path);
      final String savedPath = path.join(appDir.path, fileName);

      // Copia o arquivo para o diretório do app
      final File localImage = await File(pickedFile.path).copy(savedPath);

      setState(() {
        _pickedImage = localImage;
      });
    }
  }

  Future<void> _saveImage() async {
    if (!_formKey.currentState!.validate() || _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos e selecione uma imagem')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final newImage = ImageItem(
      id: widget.imageItem?.id,
      title: _titleController.text.trim(),
      imagePath: _pickedImage!.path,
    );

    final imagesProvider = Provider.of<ImagesProvider>(context, listen: false);

    if (widget.imageItem == null) {
      await imagesProvider.addImage(newImage);
    } else {
      await imagesProvider.updateImage(newImage);
    }

    setState(() {
      _isSaving = false;
    });

    Navigator.of(context).pop();
  }

  Future<void> _deleteImage() async {
    if (widget.imageItem == null) return;

    final imagesProvider = Provider.of<ImagesProvider>(context, listen: false);
    await imagesProvider.deleteImage(widget.imageItem!.id!);

    // Também pode apagar o arquivo físico (opcional)
    try {
      final file = File(widget.imageItem!.imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.imageItem != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Imagem' : 'Adicionar Imagem'),
        actions: isEditing
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Confirmar exclusão'),
                        content: Text('Deseja realmente excluir esta imagem?'),
                        actions: [
                          TextButton(
                            child: Text('Cancelar'),
                            onPressed: () => Navigator.of(ctx).pop(false),
                          ),
                          ElevatedButton(
                            child: Text('Excluir'),
                            onPressed: () => Navigator.of(ctx).pop(true),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _deleteImage();
                    }
                  },
                )
              ]
            : null,
      ),
      body: _isSaving
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_pickedImage != null)
                      Image.file(
                        _pickedImage!,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image,
                          size: 100,
                          color: Colors.grey[600],
                        ),
                      ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.photo_library),
                      label: Text('Selecionar imagem'),
                    ),
                    SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(labelText: 'Título'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe um título';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveImage,
                      child: Text(isEditing ? 'Salvar Alterações' : 'Adicionar'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

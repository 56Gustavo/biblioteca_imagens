import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/images_provider.dart';
import '../models/image_item.dart';
import 'add_edit_image_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Provider.of<ImagesProvider>(context, listen: false).initDB().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final imagesData = Provider.of<ImagesProvider>(context);
    final images = imagesData.images;

    return Scaffold(
      appBar: AppBar(
        title: Text('Biblioteca de Imagens'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditImageScreen(),
                ),
              );
            },
            tooltip: 'Adicionar Imagem',
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : images.isEmpty
              ? Center(child: Text('Nenhuma imagem adicionada.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: images.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 3 / 4,
                  ),
                  itemBuilder: (ctx, i) {
                    final img = images[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddEditImageScreen(imageItem: img),
                          ),
                        );
                      },
                      child: GridTile(
                        child: Image.file(
                          File(img.imagePath),
                          fit: BoxFit.cover,
                        ),
                        footer: GridTileBar(
                          backgroundColor: Colors.black54,
                          title: Text(
                            img.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

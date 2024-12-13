import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListaexternaScreen extends StatelessWidget {
  const ListaexternaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listado de peliculas"),
      ),
      body: listViewExterno("https://jritsqmet.github.io/web-api/peliculas2.json"),
    );
  }
}

Future<List> jsonExterno(url) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['peliculas'];
  } else {
    throw Exception("Sin conexión");
  }
}

Widget listViewExterno(url) {
  return FutureBuilder(
    future: jsonExterno(url),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final data = snapshot.data!;
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];

            final titulo = item['titulo'] ?? 'Sin título';
            final descripcion = item['descripcion'] ?? 'Sin descripción';
            final image = item['image'] ?? 'https://via.placeholder.com/150';
            final anio = item['anio'] ?? 'Año no disponible';
            final duracion = item['detalles'] != null 
                              ? item['detalles']['duracion'] ?? 'Duración no disponible'
                              : 'Duración no disponible';
            final director = item['detalles'] != null 
                              ? item['detalles']['director'] ?? 'Director no disponible'
                              : 'Director no disponible';

            return Card(
              child: ListTile(
                title: Text(titulo),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        image.isNotEmpty
                            ? Image.network(
                                image,
                                width: 120,
                                height: 180,
                                fit: BoxFit.cover,
                              )
                            : Container(),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              descripcion,
                              style: TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Año: $anio",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Duración: $duracion",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Director: $director",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else {
        return Center(child: CircularProgressIndicator());
      }
    },
  );
}

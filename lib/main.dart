import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Filmes Favoritos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  TextEditingController _movieNameController = TextEditingController();
  List<Map<String, dynamic>> favoriteMovies = [];

  final apiKey = 'ae6d07503a79d2c355f6a60c32263ca9';

  Future<Map<String, dynamic>?> _fetchMovie(String movieName) async {
    final baseUrl = 'https://api.themoviedb.org/3/search/movie';
    final query = Uri.encodeQueryComponent(movieName);
    final url = '$baseUrl?query=$query&api_key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];

      if (results.isNotEmpty) {
        return results[0];
      }
    } else {
      throw Exception('Falha ao carregar filme');
    }
    return null;
  }

  Future<void> _addMovieToFavorite(String movieName) async {
    Map<String, dynamic>? movieData = await _fetchMovie(movieName);
    if (movieData != null) {
      setState(() {
        favoriteMovies.add(movieData);
      });
    }
  }

  void _removeMovie(int index) {
    setState(() {
      favoriteMovies.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filmes Favoritos'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _movieNameController,
                    decoration: InputDecoration(
                      hintText: 'Nome do Filme',
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () async {
                    String movieName = _movieNameController.text;
                    if (movieName.isNotEmpty) {
                      await _addMovieToFavorite(movieName);
                      _movieNameController.clear();
                    }
                  },
                  child: Text('Adicionar'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              'Filmes Favoritos:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: favoriteMovies.length,
                itemBuilder: (context, index) {
                  final movie = favoriteMovies[index];
                  final posterPath = movie['poster_path'];
                  final posterUrl =
                      'https://image.tmdb.org/t/p/w200$posterPath';

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Image.network(
                              posterUrl,
                              width: 200,
                              height: 300,
                            ),
                            SizedBox(width: 4.0),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _removeMovie(index),
                                child: Text('Remover'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _movieNameController.dispose();
    super.dispose();
  }
}

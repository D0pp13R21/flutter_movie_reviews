import 'package:flutter/material.dart';
import 'dart:convert'; // Biblioteca para manipulação de JSON
import 'package:http/http.dart' as http; // Biblioteca para requisições HTTP

// =====================================================================
// CHAVE DA TMDb API – Substitua pela sua chave válida da TMDb
// =====================================================================
String tmdbApiKey = "8f9134b03d087ac24b862efcb7eecede";

// =====================================================================
// FUNÇÃO MAIN: PONTO DE ENTRADA DO APLICATIVO
// =====================================================================
void main() {
  runApp(MyApp());
}

// =====================================================================
// CLASSE PRINCIPAL DO APLICATIVO (MyApp)
// Configura o tema e define a tela inicial (HomeScreen)
// =====================================================================
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filmes e Reviews',
      debugShowCheckedModeBanner: false,
      // Configuração do tema com visual de cinema: fundo preto, detalhes em vermelho e textos brancos
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black, // Fundo geral preto
        primaryColor: Colors.red, // Cor primária vermelho
        colorScheme: ThemeData.dark()
            .colorScheme
            .copyWith(secondary: Colors.red), // Define a cor secundária
        appBarTheme: AppBarTheme(
          color: Colors.black, // AppBar com fundo preto
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white), // Textos em branco
        ),
      ),
      // Define a tela inicial do app como HomeScreen
      home: HomeScreen(),
    );
  }
}

// =====================================================================
// HOME SCREEN: Tela principal que contém o campo de pesquisa e
// seções horizontais (roletas) de filmes e séries
// =====================================================================
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// =====================================================================
// Estado da HomeScreen
// =====================================================================
class _HomeScreenState extends State<HomeScreen> {
  // Controlador para capturar o texto digitado na área de pesquisa
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar com título centralizado
      appBar: AppBar(
        title: Text("Filmes e Reviews", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      // Corpo da tela em formato de ListView para permitir rolagem vertical
      body: ListView(
        children: [
          // =====================================================
          // Área de Pesquisa
          // =====================================================
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Campo de entrada de texto para a pesquisa
                Expanded(
                  child: TextField(
                    controller: _searchController, // Captura o texto digitado
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Digite o nome do filme ou série",
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[900], // Fundo do campo de pesquisa
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius:
                            BorderRadius.circular(8), // Bordas arredondadas
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // Botão de pesquisa com fundo vermelho e ícone de lupa
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      // Fecha o teclado ao clicar no botão
                      FocusScope.of(context).unfocus();
                      // Se o campo não estiver vazio, navega para a tela de resultados de pesquisa
                      if (_searchController.text.trim().isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchResultScreen(
                                query: _searchController.text.trim()),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // =====================================================
          // Seções horizontais (roletas) com dados obtidos via TMDb
          // =====================================================
          // Seção: Novos Lançamentos (filmes em cartaz)
          HorizontalListSection(
            sectionTitle: "Novos Lançamentos",
            futureFunction: fetchNowPlayingMovies,
          ),
          // Seção: Próximos Lançamentos
          HorizontalListSection(
            sectionTitle: "Próximos Lançamentos",
            futureFunction: fetchUpcomingMovies,
          ),
          // Seção: Melhores Filmes de Todos os Tempos
          HorizontalListSection(
            sectionTitle: "Melhores Filmes de Todos os Tempos",
            futureFunction: fetchTopRatedMovies,
          ),
          // Seção: Melhores Séries de Todos os Tempos
          HorizontalListSection(
            sectionTitle: "Melhores Séries de Todos os Tempos",
            futureFunction: fetchTopRatedTV,
          ),
          // Seção: Piores Filmes e Séries de Todos os Tempos
          HorizontalListSection(
            sectionTitle: "Piores Filmes e Séries de Todos os Tempos",
            futureFunction: fetchWorstMoviesAndTV,
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// WIDGET HORIZONTAL LIST SECTION: Widget reutilizável para exibir
// uma seção com título e uma lista horizontal (roleta) de itens.
// =====================================================================
class HorizontalListSection extends StatelessWidget {
  final String sectionTitle;
  // Função que retorna um Future<List> com os dados para a seção
  final Future<List<dynamic>> Function() futureFunction;

  HorizontalListSection({
    required this.sectionTitle,
    required this.futureFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          EdgeInsets.symmetric(vertical: 16), // Espaço acima e abaixo da seção
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Título alinhado à esquerda
        children: [
          // Título da seção com destaque em vermelho
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              sectionTitle,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
          SizedBox(height: 8),
          // FutureBuilder para buscar e exibir os dados da seção
          FutureBuilder<List<dynamic>>(
            future: futureFunction(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Enquanto os dados não chegam, exibe um indicador de carregamento
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // Se ocorrer um erro, exibe uma mensagem
                return Center(
                    child: Text("Erro ao carregar dados",
                        style: TextStyle(color: Colors.red)));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // Se não houver dados, informa que nenhum resultado foi encontrado
                return Center(
                    child: Text("Nenhum resultado encontrado",
                        style: TextStyle(color: Colors.white)));
              } else {
                // Se os dados estiverem disponíveis, exibe uma lista horizontal com até 10 resultados
                final items = snapshot.data!;
                return Container(
                  height: 240, // Altura da lista
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length >= 10 ? 10 : items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      // Determina o tipo de mídia: "movie" ou "tv"
                      String mediaType =
                          item.containsKey("title") ? "movie" : "tv";
                      // Para séries, o título vem em "name"
                      String title =
                          mediaType == "movie" ? item["title"] : item["name"];
                      // Data de lançamento (para filmes: "release_date", para séries: "first_air_date")
                      String date = mediaType == "movie"
                          ? item["release_date"] ?? ""
                          : item["first_air_date"] ?? "";
                      // Caminho do poster – concatenado com a URL base da TMDb
                      String posterPath = item["poster_path"] ?? "";
                      String posterUrl = posterPath.isNotEmpty
                          ? "https://image.tmdb.org/t/p/w200$posterPath"
                          : "";

                      return GestureDetector(
                        // Ao tocar, navega para a tela de detalhe
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailScreen(
                                id: item["id"],
                                mediaType: mediaType,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 160, // Largura do cartão
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Container para a imagem (poster)
                              Container(
                                height: 180, // Altura definida para a imagem
                                width: double
                                    .infinity, // Ocupa toda a largura do cartão
                                margin: EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  image: posterUrl.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(posterUrl),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: Colors.black26,
                                ),
                              ),
                              SizedBox(height: 8),
                              // Título do item: agora com maxLines definido como 1
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1, // Limita a 1 linha
                                  overflow: TextOverflow
                                      .ellipsis, // Exibe reticências se ultrapassar
                                ),
                              ),
                              SizedBox(height: 4),
                              // Data de lançamento (apenas o ano, se disponível)
                              Text(
                                date.length >= 4 ? date.substring(0, 4) : date,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// FUNÇÕES PARA OBTER DADOS DO TMDb
// =====================================================================

// 1. Filmes em cartaz (Now Playing)
Future<List<dynamic>> fetchNowPlayingMovies() async {
  final url =
      "https://api.themoviedb.org/3/movie/now_playing?api_key=$tmdbApiKey&language=pt-BR&page=1";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data["results"];
  }
  return [];
}

// 2. Filmes que serão lançados (Upcoming)
Future<List<dynamic>> fetchUpcomingMovies() async {
  final url =
      "https://api.themoviedb.org/3/movie/upcoming?api_key=$tmdbApiKey&language=pt-BR&page=1";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data["results"];
  }
  return [];
}

// 3. Melhores Filmes (Top Rated Movies)
Future<List<dynamic>> fetchTopRatedMovies() async {
  final url =
      "https://api.themoviedb.org/3/movie/top_rated?api_key=$tmdbApiKey&language=pt-BR&page=1";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data["results"];
  }
  return [];
}

// 4. Melhores Séries (Top Rated TV)
Future<List<dynamic>> fetchTopRatedTV() async {
  final url =
      "https://api.themoviedb.org/3/tv/top_rated?api_key=$tmdbApiKey&language=pt-BR&page=1";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data["results"];
  }
  return [];
}

// 5. Piores Filmes e Séries
// Utiliza os endpoints "discover" para filmes e TV ordenados por avaliação ascendente
Future<List<dynamic>> fetchWorstMoviesAndTV() async {
  final urlMovies =
      "https://api.themoviedb.org/3/discover/movie?api_key=$tmdbApiKey&language=pt-BR&sort_by=vote_average.asc&vote_count.gte=100&page=1";
  final urlTV =
      "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR&sort_by=vote_average.asc&vote_count.gte=50&page=1";
  final responseMovies = await http.get(Uri.parse(urlMovies));
  final responseTV = await http.get(Uri.parse(urlTV));
  List<dynamic> movies = [];
  List<dynamic> tv = [];
  if (responseMovies.statusCode == 200) {
    movies = json.decode(responseMovies.body)["results"];
  }
  if (responseTV.statusCode == 200) {
    tv = json.decode(responseTV.body)["results"];
  }
  List<dynamic> combined = []
    ..addAll(movies)
    ..addAll(tv);
  combined.sort(
      (a, b) => (a["vote_average"] as num).compareTo(b["vote_average"] as num));
  return combined;
}

// =====================================================================
// FUNÇÃO DE PESQUISA NA TMDb
// Utiliza o endpoint "search/multi" para buscar filmes e séries
// =====================================================================
Future<List<dynamic>> searchTMDb(String query) async {
  final url =
      "https://api.themoviedb.org/3/search/multi?api_key=$tmdbApiKey&language=pt-BR&query=$query&page=1&include_adult=false";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data["results"];
  }
  return [];
}

// =====================================================================
// TELA DE RESULTADO DE PESQUISA (SearchResultScreen)
// Exibe os resultados obtidos pela função searchTMDb
// =====================================================================
class SearchResultScreen extends StatelessWidget {
  final String query;

  SearchResultScreen({required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Resultado da Pesquisa",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: searchTMDb(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text("Erro: ${snapshot.error}",
                    style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text("Nenhum resultado encontrado",
                    style: TextStyle(color: Colors.white)));
          } else {
            final results = snapshot.data!;
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final item = results[index];
                String mediaType = item.containsKey("title") ? "movie" : "tv";
                String title =
                    mediaType == "movie" ? item["title"] : item["name"];
                String date = mediaType == "movie"
                    ? item["release_date"] ?? ""
                    : item["first_air_date"] ?? "";
                String posterPath = item["poster_path"] ?? "";
                String posterUrl = posterPath.isNotEmpty
                    ? "https://image.tmdb.org/t/p/w200$posterPath"
                    : "";

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(
                          id: item["id"],
                          mediaType: mediaType,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.grey[900],
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          if (posterUrl.isNotEmpty)
                            Image.network(
                              posterUrl,
                              width: 80,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Data: ${date.length >= 4 ? date.substring(0, 4) : date}",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// =====================================================================
// TELA DE DETALHE (MovieDetailScreen)
// Exibe detalhes completos de um item (filme ou série) obtidos via TMDb
// =====================================================================
class MovieDetailScreen extends StatelessWidget {
  final int id; // ID do item na TMDb
  final String mediaType; // "movie" ou "tv"

  MovieDetailScreen({required this.id, required this.mediaType});

  // Função para buscar os detalhes do item via TMDb
  Future<Map<String, dynamic>> fetchDetails() async {
    String url = "";
    if (mediaType == "movie") {
      url =
          "https://api.themoviedb.org/3/movie/$id?api_key=$tmdbApiKey&language=pt-BR";
    } else {
      url =
          "https://api.themoviedb.org/3/tv/$id?api_key=$tmdbApiKey&language=pt-BR";
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception("Falha ao carregar detalhes");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text("Erro: ${snapshot.error}",
                    style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData) {
            return Center(
                child: Text("Nenhum dado disponível",
                    style: TextStyle(color: Colors.white)));
          } else {
            final details = snapshot.data!;
            String title =
                mediaType == "movie" ? details["title"] : details["name"];
            String date = mediaType == "movie"
                ? details["release_date"] ?? ""
                : details["first_air_date"] ?? "";
            String overview = details["overview"] ?? "";
            String posterPath = details["poster_path"] ?? "";
            String posterUrl = posterPath.isNotEmpty
                ? "https://image.tmdb.org/t/p/w300$posterPath"
                : "";
            double rating = details["vote_average"]?.toDouble() ?? 0.0;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (posterUrl.isNotEmpty)
                      Center(
                        child: Image.network(posterUrl, height: 400),
                      ),
                    SizedBox(height: 16),
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Data: ${date.length >= 10 ? date.substring(0, 10) : date}",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Nota: ${rating.toString()}",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 16),
                    Text(
                      overview,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

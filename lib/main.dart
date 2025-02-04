import 'package:flutter/material.dart';
import 'dart:convert'; // Biblioteca para trabalhar com JSON
import 'package:http/http.dart'
    as http; // Biblioteca para fazer requisições HTTP

// Função principal que inicia o aplicativo
void main() {
  runApp(MyApp()); // Inicia o app chamando a classe MyApp
}

// Classe principal do aplicativo que configura o MaterialApp
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove a faixa de debug
      title: 'Filmes e Reviews', // Título do app
      theme: ThemeData(
        primarySwatch: Colors.blue, // Define a cor principal do app
      ),
      home: MovieSearchScreen(), // Define a tela inicial como MovieSearchScreen
    );
  }
}

// Tela onde o usuário pode pesquisar filmes
class MovieSearchScreen extends StatefulWidget {
  @override
  _MovieSearchScreenState createState() => _MovieSearchScreenState();
}

// Estado da tela MovieSearchScreen
class _MovieSearchScreenState extends State<MovieSearchScreen> {
  // Controlador para capturar o texto digitado pelo usuário no campo de pesquisa
  final TextEditingController _controller = TextEditingController();

  // Variável para armazenar os dados do filme retornados pela API (em formato Map)
  Map<String, dynamic>? _movieData;

  // Chave da API OMDb - substitua "SUA_OMDB_API_KEY" pela sua chave válida!
  String apiKey = "e1bc131f";

  // Função para buscar informações do filme na API OMDb
  Future<void> _searchMovie(String title) async {
    // Monta a URL da requisição com o título, a chave da API e o parâmetro plot=full para sinopse completa
    final url =
        Uri.parse("https://www.omdbapi.com/?t=$title&apikey=$apiKey&plot=full");

    // Envia a requisição GET para a API OMDb
    final response = await http.get(url);

    // Imprime no console a resposta da API para fins de depuração
    print("Resposta da API: ${response.body}");

    // Se a requisição retornar o status 200 (sucesso), processa os dados
    if (response.statusCode == 200) {
      setState(() {
        // Decodifica o JSON retornado e armazena no _movieData
        _movieData = json.decode(response.body);
      });
    } else {
      // Se ocorrer algum erro na requisição, define _movieData como null
      setState(() {
        _movieData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra de aplicativo com título "Buscar Filmes"
      appBar: AppBar(title: Text("Buscar Filmes")),
      // Corpo do Scaffold com padding para espaçamento
      body: Padding(
        padding: EdgeInsets.all(16.0), // Espaço ao redor do conteúdo
        child: Column(
          children: [
            // Campo de texto para entrada do título do filme
            TextField(
              controller:
                  _controller, // Associa o controlador para capturar a entrada
              decoration: InputDecoration(
                labelText: "Digite o nome do filme", // Rótulo do campo
                // Ícone de pesquisa que chama a função de busca ao ser pressionado
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Fecha o teclado ao pressionar o botão de pesquisa
                    FocusScope.of(context).unfocus();
                    // Atualiza a tela (opcional, mas pode forçar reconstrução da UI)
                    setState(() {});
                    // Chama a função de pesquisa passando o texto digitado
                    _searchMovie(_controller.text);
                  },
                ),
              ),
            ),
            SizedBox(
                height:
                    20), // Espaçamento entre o campo de entrada e os resultados
            // Verifica se há dados de filme carregados
            _movieData != null
                ? Expanded(
                    // Permite scroll se o conteúdo exceder o tamanho da tela
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Alinha os elementos à esquerda
                        children: [
                          // Verifica se a API retornou um erro (por exemplo, filme não encontrado)
                          if (_movieData!["Response"] == "False")
                            Text(
                              "Erro: ${_movieData!["Error"]}", // Exibe a mensagem de erro retornada pela API
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            )
                          else ...[
                            // Caso a resposta seja positiva, exibe os dados do filme:

                            // Exibe o título do filme com formatação destacada
                            Text(
                              "Título: ${_movieData!["Title"]}",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            // Exibe o ano de lançamento
                            Text("Ano: ${_movieData!["Year"]}"),
                            // Exibe a nota do IMDb
                            Text("Nota IMDb: ${_movieData!["imdbRating"]}"),
                            // Exibe a pontuação do Metascore
                            Text("Metascore: ${_movieData!["Metascore"]}"),
                            // Exibe a sinopse do filme
                            Text("Sinopse: ${_movieData!["Plot"]}"),
                            // Se houver um pôster disponível (valor diferente de "N/A"), exibe a imagem
                            if (_movieData!["Poster"] != "N/A")
                              Image.network(_movieData!["Poster"]),
                          ]
                        ],
                      ),
                    ),
                  )
                : Text(
                    "Nenhum resultado encontrado."), // Mensagem padrão caso _movieData seja nulo
          ],
        ),
      ),
    );
  }
}

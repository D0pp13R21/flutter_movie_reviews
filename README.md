# 🎬 Filmes & Reviews

Bem-vindo ao **Filmes & Reviews**!  
Um aplicativo Flutter incrível, desenvolvido para exibir lançamentos, melhores e piores filmes/séries e possibilitar pesquisas detalhadas usando a TMDb API. Tudo isso com um visual estiloso e moderno, que remete à atmosfera de cinema e teatro, com um toque de fundo preto e detalhes em vermelho! 💥🍿

---

## 📚 Sobre o Projeto

Este projeto foi criado **únicamente para fins acadêmicos** e **não possui nenhum propósito comercial**. Ele foi desenvolvido por **Lucas Marinho** com o objetivo de demonstrar como integrar e consumir APIs reais (neste caso, a TMDb API) em um aplicativo Flutter, enquanto se explora conceitos de design de interface e boas práticas de desenvolvimento.

---

## 🚀 Funcionalidades

- **Home Screen:**
  - Área de pesquisa para filmes e séries.
  - Seções horizontais (roletas) exibindo:
    - **Novos Lançamentos** (filmes em cartaz)
    - **Próximos Lançamentos**
    - **Melhores Filmes**
    - **Melhores Séries**
    - **Piores Filmes e Séries**
  
- **Pesquisa:**
  - Utiliza o endpoint `search/multi` da TMDb para buscar filmes e séries.
  - Exibe os resultados de forma organizada e estilizada.
  
- **Detalhes:**
  - Ao clicar em um item, o app abre uma página com detalhes completos (nome, ano, sinopse, nota, etc).

- **Visual:**
  - Tema escuro com fundo preto, textos em branco e destaques em vermelho – criando um visual imersivo, digno de um cinema! 🎥✨

---

## 🛠 Tecnologias Utilizadas

- **Flutter**: Para o desenvolvimento de interfaces nativas e responsivas.
- **Dart**: Linguagem de programação utilizada no Flutter.
- **HTTP**: Para realizar requisições e consumir a TMDb API.
- **TMDb API**: Base de dados utilizada para obter informações reais de filmes e séries (em português).

---

## 🔧 Configuração do Projeto

1. **Clone o repositório:**

   ```bash
   git clone https://github.com/D0pp13R21/flutter_movie_reviews
   cd filmes-reviews
   ```

2. **Instale as dependências:**

   ```bash
   flutter pub get
   ```

3. **Configure as chaves de API:**

   - Abra o arquivo principal (onde a variável `tmdbApiKey` é definida).
   - Substitua `"SUA_TMDB_API_KEY"` pela sua chave válida da TMDb.
  
4. **Execute o aplicativo:**

   ```bash
   flutter run
   ```

---

## 📄 Licença

Este projeto é **apenas para fins acadêmicos** e não deve ser utilizado para fins comerciais.  
Desenvolvido com ❤️ por **Lucas Marinho**.

---

## 💡 Considerações Finais

- Sinta-se à vontade para explorar o código e aprender mais sobre integração de APIs com Flutter!  
- Caso tenha dúvidas ou sugestões, não hesite em entrar em contato.  
- Este projeto é uma iniciativa para aprendizado e desenvolvimento pessoal, sem fins lucrativos. 😊

---

Divirta-se e aproveite o visual de cinema com o **Filmes & Reviews**! 🎬🍿✨

---

> **Nota:**  
> Este aplicativo foi desenvolvido em um ambiente acadêmico e não possui garantias de estabilidade para produção. Utilize-o para aprendizado, experimentação e inspiração.  
> Se você fizer melhorias ou ajustes, compartilhe com a comunidade! 🚀

---

*Obrigado por visitar o repositório e bons códigos!*  
**Lucas Marinho**  
🧑‍💻💡🎥
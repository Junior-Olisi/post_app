# Post App

### Aplicação de gerenciamento de posts e perfis de usuário

Esta aplicação tem por objetivo exemplificar o consumo de APIs externas e envio de formulários.

Para criar uma aplicação realista, que encara desafios cotidianos reais, serão consumidas 2 APIs, sendo elas:

- #### [Random User API](https://randomuser.me/documentation#intro) 
Uma API versátil que possibilita a busca de diversos perfis de usuários fake, com vários dados

- #### [JSON Placeholder API](https://jsonplaceholder.typicode.com/)
A API responsável por fornecer a maior parte do que será o domínio da aplicação.


A Aplicação foi criada com base no projeto de design criado por mim mesmo, [Júnior Olisi](https://github.com/Junior-Olisi), e que pode ser encontrado [aqui](https://www.figma.com/design/Xp4LNaItGIDwtXAtqNmera/Post-App?node-id=63-1941&p=f&t=6ewqbbAlAx5emcyS-0).



## Arquitetura

Tratando-se de uma aplicação mobile trabalhando como cliente num cenário de comunicação entre cliente e servidor a arquitetura abordada a App Architecture, por ser uma recomendação da equipe do Flutter, e por atender bem aos requisitos da aplicação.

As camadas que compõem tal arquitetura, possuem funções muito bem definidas, possibilitando uma melhor divisão de papéis entre seus componentes.

Para mais informações sobre a arquitetura, veja o [artigo oficial](https://docs.flutter.dev/app-architecture/guide).

### Componentes arquiteturais (Camadas)

#### Domain Layer
O domínio, que é o core de tudo o que será exposto na aplicação, irá conter todas as entidades visuais e não visuais, como os **usuários** responsáveis pelos **posts**, cada um destes com seus respectivos **comentários**.

#### Data Layer
Esta camada será a responsável pelo acesso a dados externos (consumo de APIs, cache, etc), funcionará de forma que seus componentes, os **repositories** funcionem como proposto na app architecture, atuando como fonte única de verdade (Single Source of Truth - SSoT), sendo os responsáveis por fazer com que os dados cheguem até a camada de **UI**.

#### UI Layer
Esta camada realizará a apresenação visual dos dados obtidos pela **Data Layer**, possibilitando a interação do usuário, que será orquestrada pela **View Model** que será responsável por lidar com **gerenciamento de estado**, regras visuais, e ações disparadas pelo usuário.

Na **View**, que também pertence à UI Layer, o usuário terá o visual do funcionamento de todas as outras camadas em conjunto, e poderá interagir de acordo com as funcionalidades da aplicação.


## Design Patterns

Com o propósito de criar uma aplicação de fácil administração, bom proveito da **orientação a objetos**, e com possibilidades de ser modificada posteriormente, alguns padrões de design de código serão utilizados, como:

- Observer Pattern - Observa objetos de interesse e reproduz instantâneamente mudanças ocorridas;
- Repository Pattern - Dedica uma camada específica para aquisição e tratamento dos dados;
- Controll Inversion Pattern - Utiliza interfaces para chamadas de métodos ao invés de implementações concreteas;
- Dependency Injection Pattern - Por meio de recursos da orientação a objetos, permite separar e organizar o código;
- TDD (Test Driven Development) - Por meio de testes valida o funcionamento do código antes mesmo da execução da aplicação;

## Packages externos

- [Flutter Modular](https://pub.dev/packages/flutter_modular) - Injeção de dependências e navegação;
- [Dio](https://pub.dev/packages/dio) - Requisições HTTP, para o consumo das APIs;
- [Freezed Annotation](https://pub.dev/packages/freezed#motivation) - Auxilia na definição dos modelos de entidade da aplicação;
- [Result Dart](https://pub.dev/packages/result_dart) - Auxilia no tratamento de erros na aplicação;
- [Lucid Validation](https://pub.dev/packages/lucid_validation) - Auxilia na criação de modelos de formulário;
- [Result Command](https://pub.dev/packages/result_command) - Auxilia na 
- [Sqflite](https://pub.dev/packages/sqflite) - Banco de dados SQL para administração de dados localmente.

## Funcionalidades

- Administração de perfil de usuário;
- Gerenciamento de posts (criação, remoção, atualização, opção de curtir);
- Monitoramento de atividade do perfil principal (Comentários feitos);
- Visualização de perfis de outros usuários

# Xeque — Cadastro de jogadores, torneios e partidas de xadrez

Mesmo sistema visual do Hermes (tema claro/escuro com botão sol/lua animado),
aplicado a um app de clube de xadrez: cadastro de jogadores, criação de
torneios todos-contra-todos com geração automática de confrontos, lançamento
de resultado (vitória/empate/derrota) e classificação em tempo real — tudo
sincronizado via Firebase Firestore, então qualquer pessoa com o app vê a
mesma tabela ao vivo.

## ⚠️ Antes de rodar

Igual ao Hermes: este pacote só tem a pasta `lib/` e o `pubspec.yaml` — sem
`android/`, `ios/` etc., porque isso precisa ser gerado pelo Flutter SDK na
sua máquina. **Além disso, esse projeto depende de um banco Firebase de
verdade** (diferente do Hermes, que era tudo mockado) — sem configurar isso,
o app não abre.

### Passo a passo completo

1. **Criar o projeto Flutter e copiar os arquivos**
   ```bash
   flutter create xeque_app
   ```
   Copie a pasta `lib/` e o `pubspec.yaml` deste pacote por cima do projeto criado.

2. **Criar o projeto no Firebase** (grátis)
   - Vá em [console.firebase.google.com](https://console.firebase.google.com) → "Adicionar projeto"
   - Dentro do projeto, vá em **Firestore Database** → "Criar banco de dados" → modo **produção** → escolha a região

3. **Aplicar as regras de segurança**
   - Ainda no Firestore, aba **Regras** → cole o conteúdo do arquivo `firestore.rules` (incluído neste pacote) → Publicar

4. **Conectar o app Flutter ao seu projeto Firebase**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Escolha o projeto que você criou no passo 2, e marque as plataformas que for usar
   (Android/iOS/Web). Isso **substitui** o `lib/firebase_options.dart` (que no
   pacote está só com um placeholder) pelo arquivo de verdade, com as chaves reais.

5. **Instalar dependências e rodar**
   ```bash
   flutter pub get
   flutter run
   ```

## PIN do organizador

Por padrão é `1234`, definido em `lib/data/organizer_auth.dart` (constante `_pin`).
Troque antes de usar de verdade. Veja o aviso no topo desse mesmo arquivo —
essa trava é só de interface, não é segurança de banco de dados (a regra do
Firestore libera escrita geral). Para um clube entre amigos, tranquilo; se um
dia quiser trava "de verdade" (impedir escrita direto na API), o próximo passo
seria trocar por Firebase Authentication + regra checando um usuário
autenticado específico.

## Estrutura

```
lib/
  theme/              # Mesma paleta dinâmica clara/escura do Hermes
  widgets/            # AppCard, PrimaryButton, SectionLabel, toggle de tema,
                       # cadeado do organizador, app bar
  models/             # Player, Tournament, ChessMatch, Standing
  data/
    tournament_logic.dart      # Gera rodadas todos-contra-todos (método do
                                # círculo, com bye pra número ímpar) e calcula
                                # a classificação (1 / 0,5 / 0 ponto)
    player_repository.dart     # CRUD de jogadores no Firestore
    tournament_repository.dart # CRUD de torneios no Firestore
    match_repository.dart      # Gera/edita partidas no Firestore
    organizer_auth.dart        # PIN do organizador
  screens/
    home_shell.dart             # Abas: Torneios / Jogadores
    players_screen.dart         # Lista + cadastro de jogadores
    tournaments_list_screen.dart
    new_tournament_screen.dart  # Escolher nome + participantes → gera confrontos
    tournament_detail_screen.dart  # Abas: Rodadas (lançar resultado) / Classificação
```

## Como funciona a geração de confrontos

Todos contra todos, método do círculo: com N jogadores, são geradas N-1
rodadas (ou N rodadas se N for ímpar, com 1 pessoa de folga por rodada). Isso
roda 100% no celular, sem precisar do Firebase — só o resultado final (as
partidas geradas) é salvo no banco. Se depois de gerar você quiser editar a
lista de participantes, use `MatchRepository.regeneratePairing(...)`: ele
preserva partidas que já têm resultado lançado e refaz só as pendentes.

## Torneio concluído → exclusão

Quando todas as partidas "de verdade" (sem contar as folgas/bye) de um torneio
já têm resultado lançado, o app marca o torneio como **encerrado** sozinho
(sem o organizador precisar fazer nada) e mostra um banner verde na tela do
torneio. Só o organizador vê o botão de lixeira nesse banner — apertar pede
confirmação e, se confirmado, apaga o torneio **e todas as suas partidas**
do Firestore. Não tem como desfazer.

## Relógio de xadrez

Nova aba "Relógio", aberta pra qualquer pessoa (não passa pelo PIN, já que
não grava nada no banco — é só uma ferramenta local rodando no aparelho).
Escolhe o tempo (3/5/10/15/30 min), aperta "Começar", e cada jogador toca no
próprio lado da tela assim que termina a jogada — igual um relógio físico de
verdade: tocar no seu lado para o SEU tempo e começa o do adversário. O lado
de cima fica de cabeça pra baixo de propósito (pra ficar de frente pra quem
senta daquele lado, com o celular deitado na mesa). Trocar de aba não reseta
a contagem (o app guarda as 3 abas montadas ao mesmo tempo, só esconde as que
não estão em foco).

## O que ainda não tem (ideias pra próxima sessão)

- Desempate mais sofisticado (hoje é só nº de vitórias; xadrez geralmente usa Buchholz)
- Histórico/estatísticas por jogador entre todos os torneios
- Editar nome de jogador/torneio depois de criado
- Exportar classificação (PDF/imagem) pra compartilhar fora do app
- Incremento tipo Fischer no relógio (hoje é só contagem regressiva simples)
- Som/vibração quando o tempo de alguém acabar

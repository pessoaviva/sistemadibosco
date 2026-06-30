# CLAUDE.md

Guia técnico para instâncias futuras do Claude Code trabalhando neste repositório.

## Visão geral do projeto

Sistema Dibosco é o sistema de gestão de uma sorveteria (vendas e despesas). Todo o
texto da interface é em português do Brasil (pt-BR), os valores monetários são
exibidos em reais (R$) e as datas no formato `dd/mm/aaaa`. O sistema tem três
seções principais: **Resumo**, **Vendas** e **Despesas**.

O projeto nasceu como uma demonstração comercial para sorveterias (ver
`Contexto.txt` e `contexto_conversa_1.md` para o histórico da conversa original
que originou o sistema) e hoje serve a sorveteria Dibosco de fato.

## Arquitetura

- **Single-file**: toda a aplicação (HTML, CSS e JavaScript) vive em
  `index.html`. Não há build, bundler, framework ou dependências de
  desenvolvimento — é um arquivo estático servido diretamente.
- A única dependência externa é a biblioteca `@supabase/supabase-js@2`,
  carregada via CDN (`<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2">`).
- **Camada de dados com dois modos**:
  - **Modo nuvem**: usa Supabase (Postgres + Auth) quando `SUPABASE_URL` e
    `SUPABASE_ANON_KEY` (constantes no topo do `<script>`) estão configuradas
    com valores reais.
  - **Modo local**: fallback/demonstração que usa `localStorage` (chave
    `dibosco_dados_v1`) quando o Supabase não está configurado. Não exige
    login e já vem com dados de exemplo na primeira execução.
  - A função `nuvemAtiva()` decide qual modo está ativo, checando se
    `supabase` está definido, se `SUPABASE_URL` começa com `http` e se
    `SUPABASE_ANON_KEY` não é mais o placeholder `'COLE_AQUI...'`.

## Login

- Autenticação via **Supabase Auth** (e-mail/senha), tela `#telaLogin`.
- Funções principais:
  - `entrar()` — faz login ou cadastro (`signInWithPassword` /
    `signUp`), dependendo do modo (`modoCadastro`).
  - `sair()` — chama `sb.auth.signOut()` (quando em modo nuvem) e recarrega
    a página.
  - `iniciar()` — ponto de entrada chamado no fim do script. Em modo nuvem,
    verifica sessão existente (`sb.auth.getSession()`) e assina
    `onAuthStateChange`; em modo local, pula login e carrega os dados
    diretamente.
  - `aposLogin(session)` — roda depois de autenticar: mostra o e-mail do
    usuário, chama `carregarNuvem()`, esconde a tela de login e renderiza.
- **Em modo local não existe login** — o app abre direto nos dados salvos no
  navegador.

## Banco de dados (Supabase)

Schema completo em `supabase/schema.sql`. Tabelas:

- `vendas` (id uuid, produto, data, hora, metodo, valor, created_at)
- `materia_prima` (id uuid, data, item, preco, created_at)
- `manutencao` (id uuid, data, descricao, equipamento, custo, created_at)
- `config` (chave text primary key, valor jsonb, updated_at) — usada como
  armazenamento chave/valor genérico; a configuração da máquina de cartão
  fica guardada na linha com `chave = 'maquina'`.

RLS (Row Level Security) está habilitado em todas as tabelas, mas as
políticas liberam leitura e escrita para **qualquer usuário autenticado**
(`for all to authenticated using (true) with check (true)`) — os dados são
compartilhados entre todos os funcionários da loja, não há escopo por
usuário.

## Funções-chave da camada de dados

Todas em `index.html`, dentro do bloco "CAMADA DE DADOS (local x nuvem)":

- `carregarNuvem()` — busca as quatro tabelas em paralelo via `Promise.all` e
  popula o objeto `dados` em memória.
- `carregarLocal()` — lê `localStorage[CHAVE]`; se não houver nada salvo,
  devolve um conjunto de dados de exemplo (vendas, matéria-prima e
  manutenção fictícias).
- `salvarLocal()` — grava o objeto `dados` inteiro em `localStorage`.
- `inserir(tabela, registro)` — insere um registro; na nuvem faz
  `sb.from(tabela).insert(...).select().single()`, no local apenas gera um
  id novo (`novoId()`) e devolve o objeto. **Não** altera o estado em
  memória — quem chama é responsável por dar `push` no array correspondente.
- `remover(tabela, id)` — exclui um registro pelo id; na nuvem faz
  `sb.from(tabela).delete().eq('id', id)`, no local não faz nada (quem chama
  filtra o array em memória).
- `persistirMaquina(maquina)` — salva a configuração da máquina de cartão
  (upsert na tabela `config` na nuvem, ou `salvarLocal()` no modo local).
- `persistirSeLocal()` — chama `salvarLocal()` apenas quando `nuvemAtiva()`
  é falso; usado depois de cada `inserir`/`remover` para manter o
  localStorage em sincronia no modo local.

**IDs**: na nuvem são `uuid` (string); no modo local são números
sequenciais (`++dados.seq`, começando em 100). Por isso todas as
comparações de id no código usam `String(x.id) !== String(id)` (ver
`excluir()`), para funcionar igualmente nos dois modos.

## Estrutura das três seções

- **Resumo** (`#pg-resumo`): rollup do mês selecionado — faturamento
  (soma de `vendas.valor`), despesas totais (matéria-prima + manutenção),
  lucro (faturamento − despesas), detalhamento de matéria-prima e
  manutenção, e quantidade de vendas no mês.
- **Vendas** (`#pg-vendas`): vendas agrupadas por dia (mais recente
  primeiro), com expand/collapse por dia (`alternarDia`, conjunto
  `diasAbertos`). Lançamento manual via modal (`abrirModalVenda` /
  `salvarVenda`). Cada venda tem produto, data, hora, método de pagamento
  (Pix/Crédito/Débito/Dinheiro) e valor.
- **Despesas** (`#pg-despesas`): duas sub-abas — **Matéria-prima**
  (`trocarSubDespesa('materia')`) e **Manutenção de máquinas**
  (`trocarSubDespesa('manutencao')`), cada uma com tabela e modal próprios.

Há um filtro global de **mês** (Jan–Dez) e **ano** (2024–2050) no topo do
Resumo (`#filtroMesNum`, `#filtroAno`), que determina `mesSelecionado` e
filtra os dados usados em todas as três seções. A função `render()`
centraliza toda a re-renderização da UI a partir do objeto `dados` em
memória.

## Máquina de cartão

Funcionalidade em **modo demonstração**. `dados.maquina` é `null` quando
nenhuma máquina está cadastrada. O cadastro (`abrirModalMaquina` /
`salvarMaquina` / `desconectarMaquina`) só guarda operadora, número de
série e apelido — é um cadastro manual, sem integração real com nenhuma
adquirente. A integração automática de fato (que registraria vendas
sozinha quando a maquininha processa um pagamento) **ainda não está
implementada**; o aviso na tela de Vendas (`#avisoVendas`) deixa isso
explícito para o usuário.

## Como rodar/testar localmente

Basta abrir `index.html` diretamente no navegador — não há servidor nem
etapa de build. Como `SUPABASE_URL`/`SUPABASE_ANON_KEY` vêm com o
placeholder `COLE_AQUI...` por padrão, o app roda em **modo local**
automaticamente, sem precisar de login, usando dados de exemplo.

Para resetar os dados de exemplo/testes locais, apague a chave
`dibosco_dados_v1` do `localStorage` do navegador (DevTools → Application →
Local Storage).

## Deploy

- **Hospedagem**: Vercel (site estático, sem etapa de build).
- **Banco de dados e login**: Supabase (Postgres + Auth), schema em
  `supabase/schema.sql`.
- **Domínio**: registrado no registro.br e apontado para a Vercel.
- Guia passo a passo para o usuário final (não técnico) configurar tudo
  isso: `GUIA_SUPABASE_VERCEL.md`.

## Convenções

- Todo texto voltado ao usuário (labels, botões, mensagens de erro,
  placeholders) deve estar em **português do Brasil**.
- Moeda sempre formatada como R$ (`fmtMoeda`, usa
  `toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })`).
- Datas armazenadas em formato ISO (`aaaa-mm-dd`) e exibidas como
  `dd/mm/aaaa` (`fmtData`).
- Não editar `index.html` nem `supabase/schema.sql` sem instrução explícita
  do usuário — são os dois arquivos centrais do produto em produção.

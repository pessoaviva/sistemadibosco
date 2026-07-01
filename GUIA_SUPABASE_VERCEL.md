# Guia Passo a Passo — Colocar o Sistema Dibosco no Ar

Este guia foi escrito para quem **nunca mexeu com programação**. Siga os passos
na ordem, com calma. Sempre que aparecer um nome entre aspas, é exatamente o
que você vai ver na tela (botão, menu ou campo).

No final, você vai ter:

- Um banco de dados na nuvem (Supabase) onde ficam as vendas, matéria-prima,
  manutenção etc.
- Um site publicado (Vercel) que todos os funcionários acessam pelo navegador
  ou celular.
- Login por funcionário, com todo mundo vendo os **mesmos dados**, em tempo real.

---

## 1. Criar conta e projeto no Supabase

1. Acesse **https://supabase.com** e clique em **"Start your project"** (ou
   **"Sign in"** se já tiver conta).
2. Entre com sua conta do Google ou GitHub (o mais simples é usar a mesma
   conta do GitHub que já tem o sistema, se você tiver uma).
3. Dentro do painel, clique em **"New project"**.
4. Preencha:
   - **Organization**: deixe a que já vier selecionada (ou crie uma com o
     nome "Dibosco").
   - **Name**: digite, por exemplo, `dibosco`.
   - **Database Password**: crie uma senha forte e **guarde em um lugar
     seguro** (ex.: anote no celular ou em um gerenciador de senhas). Você
     não vai precisar dela no dia a dia, mas pode precisar no futuro.
   - **Region**: escolha **"South America (São Paulo)"**. Isso deixa o
     sistema mais rápido para quem usa no Brasil.
5. Clique em **"Create new project"**.
6. Aguarde 1 a 2 minutos enquanto o Supabase prepara o banco de dados (vai
   aparecer uma tela de carregamento).

---

## 2. Criar as tabelas (o "banco de dados" da sorveteria)

O projeto já tem um arquivo pronto com tudo que o banco precisa, em:

```
supabase/schema.sql
```

Você só precisa copiar e colar. Veja como:

1. No painel do Supabase, no menu da esquerda, clique em **"SQL Editor"**.
2. Clique em **"New query"** (novo script).
3. Abra o arquivo `supabase/schema.sql` (está dentro da pasta do projeto, no
   GitHub ou no seu computador) e **copie todo o conteúdo**, do início ao fim.
4. Cole tudo dentro da caixa de texto do SQL Editor no Supabase.
5. Clique no botão **"Run"** (ou use o atalho que aparece na tela).
6. Deve aparecer uma mensagem de sucesso (algo como "Success. No rows
   returned").

O que isso faz, em palavras simples: cria as quatro "gavetas" do sistema —
**vendas**, **materia_prima** (matéria-prima), **manutencao** e **config** —
e liga uma proteção chamada **RLS** (Row Level Security). Essa proteção
garante que **só quem está logado** consegue ver e mexer nos dados, e que
**todos os funcionários logados enxergam as mesmas informações** — ou seja,
o que um lança na sorveteria, os outros já veem na hora.

> Se algo der errado e você quiser refazer, pode rodar o script de novo
> sem problema: ele foi escrito para não duplicar nada.

---

## 3. Pegar as duas chaves de conexão

O site precisa de duas informações do Supabase para "conversar" com o banco:
a **URL do projeto** e a **chave pública (anon)**.

1. No painel do Supabase, clique no ícone de engrenagem **"Project Settings"**
   (geralmente no menu da esquerda, embaixo).
2. Clique em **"API"**.
3. Você vai ver duas informações importantes:
   - **Project URL**: algo como `https://abcdxyz.supabase.co`.
   - **Project API keys** → a chave marcada como **"anon" / "public"**.
4. Copie os dois valores (use o botão de copiar do lado de cada campo) e
   guarde-os por perto — você vai usar no próximo passo.

**Isso é seguro?** Sim. A chave "anon public" foi feita para ficar dentro do
site, visível para qualquer pessoa que olhar o código. Ela sozinha não dá
acesso a nada: quem protege os dados é a combinação do **RLS** (passo 2) com
o **login obrigatório**. Sem estar logado, ninguém lê ou grava nada.

---

## 4. Colar as chaves no `index.html`

1. Abra o arquivo `index.html` (na raiz do projeto) em um editor de texto.
2. Procure, perto do início da tag `<script>`, estas duas linhas:

   ```js
   const SUPABASE_URL = 'COLE_AQUI_SUA_URL';
   const SUPABASE_ANON_KEY = 'COLE_AQUI_SUA_CHAVE';
   ```

3. Substitua o texto `COLE_AQUI_SUA_URL` pela **Project URL** que você copiou
   no passo 3, e `COLE_AQUI_SUA_CHAVE` pela chave **anon public**. Mantenha as
   aspas. Vai ficar parecido com isto (exemplo fictício):

   ```js
   const SUPABASE_URL = 'https://abcdxyz.supabase.co';
   const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
   ```

4. Salve o arquivo.

**Atenção:** enquanto essas duas linhas continuarem com `COLE_AQUI...`, o
sistema funciona em **"modo local"** — ou seja, os dados ficam guardados
apenas no navegador de cada computador, sem login e sem compartilhamento
entre lojas/funcionários. Só depois de colar a URL e a chave reais é que o
sistema passa a usar a nuvem de verdade.

---

## 5. Configurar o login dos funcionários (Authentication)

O sistema já vem pronto com as telas de **"Entrar"** e **"Criar conta"** —
você não precisa programar nada, só configurar o Supabase.

### 5.1. Facilitar o cadastro (recomendado)

Por padrão, o Supabase exige que cada novo usuário confirme o e-mail antes de
conseguir entrar. Para não complicar o dia a dia da equipe, é recomendado
desligar essa exigência:

1. No painel do Supabase, vá em **"Authentication"** no menu da esquerda.
2. Clique em **"Providers"** (ou **"Sign In / Providers"**, dependendo da
   versão do painel).
3. Clique no provedor **"Email"**.
4. Desmarque a opção **"Confirm email"**.
5. Clique em **"Save"**.

Assim, quando um funcionário clicar em **"Criar conta"** dentro do próprio
site, ele já consegue entrar na hora, sem precisar abrir o e-mail.

### 5.2. Criando uma conta para cada funcionário

Você tem duas opções:

**Opção A — Deixar cada funcionário se cadastrar sozinho:**
No site, na tela de login, peça para cada funcionário clicar em **"Ainda não
tem conta? Criar conta"**, digitar um e-mail e uma senha, e clicar em
**"Criar conta"**.

**Opção B — Você mesmo cria as contas pelo painel:**
1. No Supabase, vá em **"Authentication" → "Users"**.
2. Clique em **"Add user"** (em alguns painéis aparece como **"Invite"** /
   **"Add user" → "Create new user"**).
3. Preencha o e-mail (ex.: `funcionario.a@dibosco.com`) e uma senha inicial.
4. Repita para cada funcionário.

**Sugestão:** crie um e-mail simples para cada pessoa, mesmo que não seja um
e-mail real, por exemplo `joao@dibosco.com`, `maria@dibosco.com`. Isso ajuda
a identificar quem lançou cada venda e facilita trocar a senha depois, se
precisar.

---

## 6. Publicar o site na Vercel

O repositório do projeto já está no GitHub. Agora é só conectar com a Vercel
para o site ficar acessível pela internet.

1. Acesse **https://vercel.com** e clique em **"Sign Up"** (ou **"Log in"**
   se já tiver conta) — escolha **entrar com o GitHub** para facilitar.
2. Dentro do painel da Vercel, clique em **"Add New..."** e depois em
   **"Project"**.
3. Na lista de repositórios, procure e selecione **`pessoaviva/sistemadibosco`**
   e clique em **"Import"**.
   - Se o repositório não aparecer, clique em **"Adjust GitHub App
     Permissions"** e autorize a Vercel a acessá-lo.
4. Na tela de configuração:
   - **Framework Preset**: deixe como **"Other"** (o projeto é um site
     estático simples, não precisa de nenhum framework).
   - Não é necessário mexer em "Build Command" nem "Output Directory" — pode
     deixar em branco/padrão.
5. Clique em **"Deploy"**.
6. Aguarde 1 ou 2 minutos. Quando terminar, a Vercel mostra uma tela de
   sucesso com um link parecido com `sistemadibosco.vercel.app`.

O arquivo `index.html`, por estar na raiz do projeto, é servido
automaticamente nesse endereço — não precisa configurar mais nada.

> **Importante:** toda vez que você (ou alguém) alterar o `index.html` no
> GitHub, a Vercel publica a atualização sozinha em poucos segundos.

---

## 7. Conectar o domínio do registro.br

Aqui vale esclarecer um ponto que costuma confundir: **quem hospeda e exibe o
site é a Vercel, não o Supabase**. O Supabase cuida apenas do banco de dados
e do login. Então o domínio (o endereço bonito, tipo `www.dibosco.com.br`)
deve ser apontado para a **Vercel**, e não para o Supabase.

1. No painel da Vercel, abra o projeto e vá em **"Settings" → "Domains"**.
2. Digite o seu domínio (ex.: `dibosco.com.br` ou `www.dibosco.com.br`) e
   clique em **"Add"**.
3. A Vercel vai mostrar os registros DNS que você precisa cadastrar — algo
   como um registro **A** (apontando para um número IP) ou um **CNAME**
   (apontando para um endereço tipo `cname.vercel-dns.com`).
4. Acesse o painel do **registro.br** com a conta do seu domínio.
5. Procure a opção de editar o **DNS** (às vezes chamada de "Editar Zona" ou
   "DNS Avançado").
6. Cadastre exatamente os registros que a Vercel indicou no passo 3 (mesmo
   tipo, mesmo nome/host, mesmo valor).
7. Salve. A propagação pode levar de alguns minutos até algumas horas.
8. Volte na Vercel, na tela de **"Domains"**: quando o domínio ficar com um
   símbolo de "OK"/checkmark verde, está tudo certo.

**Resumindo a relação entre as duas ferramentas:**
- **Domínio (registro.br) → aponta para → Vercel** (que exibe o site).
- **Vercel (o site) → conversa com → Supabase** (usando as duas chaves que
  você colou no passo 4, para guardar e ler os dados).

O Supabase não hospeda domínio nenhum — ele só fornece o banco de dados e o
login que o site usa por trás dos panos.

---

## 8. Testar se está tudo funcionando

1. Abra o link do site (o da Vercel, ou já o seu domínio próprio se tiver
   conectado).
2. Crie uma conta ou entre com um login de funcionário (passo 5).
3. Lance uma venda de teste no sistema.
4. Abra o mesmo site em **outro computador ou no celular** (pode ser com
   outro funcionário logado) e confira se a venda que você lançou aparece lá
   também.
5. Se aparecer, os dados estão realmente compartilhados na nuvem — tudo
   funcionando.

---

## 9. Problemas comuns (perguntas frequentes)

**"O sistema diz que está em modo local" / "os dados não aparecem em outro
computador"**
→ As chaves `SUPABASE_URL` e `SUPABASE_ANON_KEY` ainda não foram coladas
corretamente no `index.html` (ou ainda têm o texto `COLE_AQUI...`). Revise o
passo 3 e o passo 4.

**"Apareceu uma mensagem dizendo que o e-mail não foi confirmado"**
→ Vá em **Authentication → Providers → Email** no Supabase e desmarque
**"Confirm email"**, como no passo 5.1. Se um funcionário já tinha criado
conta antes disso, vá em **Authentication → Users**, abra o usuário e
confirme manualmente o e-mail por lá (ou crie a conta de novo).

**"Erro ao carregar dados" / a tela fica vazia ou trava ao abrir**
→ Confira se você rodou o `supabase/schema.sql` completo no **SQL Editor**
(passo 2). Sem as tabelas e as regras de segurança (RLS) criadas, o sistema
não consegue ler nem gravar nada.

**"Esqueci a senha de um funcionário"**
→ No Supabase, vá em **Authentication → Users**, clique no usuário e procure
a opção de redefinir/enviar nova senha.

**"O domínio não conecta"**
→ Confirme se os registros DNS cadastrados no registro.br são *exatamente*
os que a Vercel pediu (passo 7). Pequenas diferenças de digitação impedem a
conexão. A propagação do DNS pode demorar algumas horas.

---

Pronto! Com esses 9 passos, o Sistema Dibosco fica publicado, seguro e com
dados compartilhados entre todos os funcionários e dispositivos.

# Contexto — Conversa 1 (Sistema Dibosco)

Registro completo do que foi conversado e construído na primeira sessão de
desenvolvimento do Sistema Dibosco. Guarde este arquivo para retomar o trabalho
em conversas futuras.

---

## 1. O que é o projeto

**Sistema Dibosco** — sistema de gestão de vendas e despesas para uma sorveteria
chamada **Dibosco**.

- A ideia principal: o sistema se conecta com a **máquina de cartão** (crédito,
  débito e Pix) para que cada compra do cliente já fique **registrada
  automaticamente** no momento da venda.
- **Restrição importante do brief:** a primeira versão deve ser entregue **SEM**
  a integração com a máquina (é só uma demonstração para apresentar ao cliente).
- A máquina precisa poder ser **cadastrada depois**, e também deve ser possível
  lançar vendas **manualmente**.
- Idioma de toda a interface: **português do Brasil (pt-BR)**.
- Moeda em **R$** e datas no formato brasileiro (dd/mm/aaaa).

## 2. Stack e hospedagem pretendidas

- **Hospedagem:** Vercel
- **Backend / banco de dados:** Supabase
- **Domínio:** comprado no registro.br, apontado para o deploy (conectado via Supabase)

> Observação: a versão atual é um **único arquivo `index.html`** estático, sem
> build, sem framework. Os dados ficam salvos no `localStorage` do navegador.
> As funções `carregar()` e `salvar()` no código são os pontos de troca para,
> no futuro, plugar o Supabase.

## 3. As três seções do sistema

### Resumo (rollup mensal)
- Total de despesas com matéria-prima do mês.
- Total de despesas com manutenção do mês.
- Total de despesas = matéria-prima + manutenção.
- **Faturamento** (apenas vendas) do mês.
- **Lucro** = Faturamento − Despesas.

### Vendas
- Agrupadas por dia (ex.: "Dia 28/09", "Dia 27/09"...).
- Ao abrir um dia, lista cada venda: hora · compra · método de pagamento · valor.
  - Ex.: `dia: 28/09 · hora: 13:40 · compra: pote M · método: Pix · valor: 20,90`
- Botão **"adicionar venda"** para lançamento manual.

### Despesas (duas categorias)
- **Matéria-prima** — ex.: `dia: 20/09 · item: 15KG de casquinha · preço: 1000`,
  com botão de adicionar.
- **Manutenção de máquinas** — ex.: `manutenção: do freezer · equipamento ·
  custo: 850 · dia: 20/09`, com botão de adicionar.

## 4. Arquivos do projeto

| Arquivo | O que é |
|---|---|
| `Contexto.txt` | Brief original do projeto (em português) — fonte da verdade dos requisitos. |
| `CLAUDE.md` | Documentação do projeto para futuras instâncias do Claude Code. |
| `index.html` | **O sistema completo** (HTML + CSS + JS em um único arquivo). |
| `Captura de tela *.png` (2) | Designs de referência — apenas exemplos visuais, não para copiar. |
| `contexto conversa 1.md` | Este arquivo. |

## 5. O que foi feito nesta conversa

1. **Criado o `CLAUDE.md`** documentando o projeto greenfield, a stack e a spec
   funcional.
2. **Criado o `index.html`** — sistema Dibosco completo, single-file, com:
   - As três seções (Resumo, Vendas, Despesas) funcionais.
   - Dados salvos em `localStorage` (chave `dibosco_dados_v1`).
   - Estado da máquina de cartão: `dados.maquina` fica `null` quando não conectada
     (modo demonstração), preparado para cadastro futuro.
   - Lançamento manual de vendas, despesas de matéria-prima e manutenções.
   - Modal "Adicionar venda" com campo de **hora editável** (sugere a hora atual,
     mas pode trocar à vontade).

3. **Modificações "ERRO A"** (pedidas pelo dono):
   - Ano alterado para **2026** em todos os dados de exemplo.
   - Filtro do Resumo trocado por **dois seletores**:
     - **Mês:** Janeiro a Dezembro (todos sempre disponíveis).
     - **Ano:** de 2024 até **2050**.
   - O dono pode escolher **qualquer mês e qualquer ano** quando quiser; o Resumo e
     a lista de vendas se atualizam na hora.
   - Ao abrir, o sistema já vem no mês/ano dos lançamentos mais recentes.
   - A **hora** já era livremente editável no formulário de adicionar venda.

## 6. Detalhes técnicos úteis para retomar

Variáveis de estado principais no topo do `<script>` do `index.html`:

```js
const CHAVE = 'dibosco_dados_v1';
let dados = carregar();
let subDespesaAtual = 'materia';
let mesSelecionado = null;
let filtroIniciado = false;   // controla a inicialização única dos seletores
```

- A função central `render()` redesenha toda a interface a partir do objeto `dados`.
- Os seletores de mês (`filtroMesNum`) e ano (`filtroAno`) são populados **uma
  única vez** (via flag `filtroIniciado`) para que o valor inicial seja o
  mês/ano mais recente, e não Janeiro/2024.

### Como testar
Abra o `index.html` com dois cliques. **Atenção:** se o sistema já foi aberto
antes, o navegador guardou dados antigos no `localStorage`. Para ver os dados de
exemplo de 2026, use uma **aba anônima** ou limpe os dados do site
(F12 → Application → Local Storage → apague `dibosco_dados_v1`). Os dados que
**você** cadastrar continuam salvos normalmente.

## 7. Pendências e próximos passos

- Integração real com a máquina de cartão (deixada para depois, conforme o brief).
- Migração do `localStorage` para o **Supabase** (trocar `carregar()`/`salvar()`).
- Deploy na **Vercel** e conexão do domínio do **registro.br**.
- O resto das telas/funcionalidades fica a cargo do dono ("faça o index e deixa
  que eu faço o resto").

## 8. Agentes usados

O brief pediu para informar quais **agentes (subagents)** foram usados.
**Até aqui: NENHUM subagent foi utilizado** — todo o trabalho foi feito
diretamente. Se em conversas futuras forem usados, registrar aqui.

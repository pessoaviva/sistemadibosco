# Sistema Dibosco 🍦

Sistema de gestão para a sorveteria **Dibosco**: controle de vendas e
despesas (matéria-prima e manutenção de máquinas) com um resumo mensal de
faturamento, despesas e lucro. Interface 100% em português, valores em
reais (R$) e datas no formato dd/mm/aaaa.

## Arquivos do projeto

- `index.html` — a aplicação inteira (HTML, CSS e JavaScript), sem build.
- `supabase/schema.sql` — script SQL para criar as tabelas e as regras de
  segurança (RLS) no Supabase.
- `GUIA_SUPABASE_VERCEL.md` — guia passo a passo para colocar o sistema no
  ar de verdade (Supabase + Vercel).
- `CLAUDE.md` — documentação técnica do projeto para desenvolvimento com
  Claude Code.
- `Contexto.txt` e `contexto_conversa_1.md` — histórico da conversa que deu
  origem ao sistema.

## Como usar agora

Modo local/demonstração: basta abrir o arquivo `index.html` no navegador.
Não precisa de login nem de internet — os dados ficam salvos no próprio
navegador (localStorage), com alguns dados de exemplo já cadastrados.

## Como colocar no ar de verdade

Para ter login de verdade e dados compartilhados entre todos os
funcionários da loja (Supabase + Vercel + domínio próprio), siga o passo a
passo em [`GUIA_SUPABASE_VERCEL.md`](./GUIA_SUPABASE_VERCEL.md).

## Stack

HTML, CSS e JavaScript puros (sem framework nem build) + [Supabase](https://supabase.com)
(banco de dados e login) + [Vercel](https://vercel.com) (hospedagem).

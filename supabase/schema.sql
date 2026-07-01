-- ============================================================
-- Sistema Dibosco — Banco de dados (Supabase / PostgreSQL)
-- ------------------------------------------------------------
-- Como usar:
--   1. No painel do Supabase, abra "SQL Editor".
--   2. Cole TODO este arquivo e clique em "Run".
-- Isso cria as tabelas e as regras de segurança (RLS) para que
-- QUALQUER funcionário logado veja e edite os MESMOS dados
-- (dados compartilhados da loja, independente de quem abre o site).
-- ============================================================

-- ---------- Tabela: vendas ----------
create table if not exists public.vendas (
  id         uuid primary key default gen_random_uuid(),
  produto    text not null,
  data       date not null,
  hora       text not null default '00:00',
  metodo     text not null,
  valor      numeric(12,2) not null,
  created_at timestamptz not null default now()
);

-- ---------- Tabela: materia_prima ----------
create table if not exists public.materia_prima (
  id         uuid primary key default gen_random_uuid(),
  data       date not null,
  item       text not null,
  preco      numeric(12,2) not null,
  created_at timestamptz not null default now()
);

-- ---------- Tabela: manutencao ----------
create table if not exists public.manutencao (
  id          uuid primary key default gen_random_uuid(),
  data        date not null,
  descricao   text not null,
  equipamento text,
  custo       numeric(12,2) not null,
  created_at  timestamptz not null default now()
);

-- ---------- Tabela: config (estado da máquina, etc.) ----------
-- Guarda valores diversos no formato chave/valor (JSON).
-- A máquina de cartão fica na chave 'maquina'.
create table if not exists public.config (
  chave      text primary key,
  valor      jsonb,
  updated_at timestamptz not null default now()
);

-- ============================================================
-- SEGURANÇA (Row Level Security)
-- Liga o RLS e permite que apenas usuários AUTENTICADOS
-- (que fizeram login) leiam e gravem. Dados compartilhados:
-- todos os funcionários enxergam a mesma informação.
-- ============================================================
alter table public.vendas        enable row level security;
alter table public.materia_prima enable row level security;
alter table public.manutencao    enable row level security;
alter table public.config        enable row level security;

-- vendas
drop policy if exists "dibosco_vendas" on public.vendas;
create policy "dibosco_vendas" on public.vendas
  for all to authenticated using (true) with check (true);

-- materia_prima
drop policy if exists "dibosco_materia" on public.materia_prima;
create policy "dibosco_materia" on public.materia_prima
  for all to authenticated using (true) with check (true);

-- manutencao
drop policy if exists "dibosco_manutencao" on public.manutencao;
create policy "dibosco_manutencao" on public.manutencao
  for all to authenticated using (true) with check (true);

-- config
drop policy if exists "dibosco_config" on public.config;
create policy "dibosco_config" on public.config
  for all to authenticated using (true) with check (true);

-- ============================================================
-- (Opcional) Dados de exemplo para testar.
-- Descomente as linhas abaixo se quiser ver o sistema com dados.
-- ============================================================
-- insert into public.vendas (produto, data, hora, metodo, valor) values
--   ('Pote M', '2026-09-28', '13:40', 'Pix', 20.90),
--   ('Açaí 500ml', '2026-09-28', '16:20', 'Crédito', 28.50);
-- insert into public.materia_prima (data, item, preco) values
--   ('2026-09-20', '15KG de casquinha', 1000.00);
-- insert into public.manutencao (data, descricao, equipamento, custo) values
--   ('2026-09-20', 'Manutenção do freezer', 'Freezer', 850.00);

-- Exercício 04 - Cadastro de Categorias
-- Como usar: Supabase > SQL Editor > New query > colar este script > Run

-- 1) Tabela de categorias
create table public.categorias (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);

-- 2) Segurança (RLS): cada usuário só vê e cria as suas próprias categorias
alter table public.categorias enable row level security;

create policy "categorias_select"
  on public.categorias for select
  to authenticated
  using (auth.uid() = user_id);

create policy "categorias_insert"
  on public.categorias for insert
  to authenticated
  with check (auth.uid() = user_id);

-- 3) Chave estrangeira na tabela de transações
--    (a coluna aceita nulo para não quebrar as transações antigas que já existem)
alter table public.transacoes
  add column categoria_id uuid references public.categorias (id);

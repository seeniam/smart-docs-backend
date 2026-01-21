Gamificação de Tarefas & Smart Docs (Base de Conhecimento Semântica)

Este repositório contém a implementação completa do Desafio Técnico Fraktal, dividido em duas partes independentes, conforme solicitado:

Parte I: Módulo de Gamificação para Sistema de Tarefas

Parte II: Smart Docs – Base de Conhecimento Semântica com IA

O foco da entrega é demonstrar capacidade técnica, arquitetura, boas práticas, segurança e uso correto de IA, utilizando Supabase como backend central.

🧩 Tecnologias Utilizadas
Geral

Supabase

PostgreSQL

Row Level Security (RLS)

Edge Functions (Deno)

pgvector

OpenAI

Embeddings

LLM para geração de respostas

Parte I

Frontend: FlutterFlow (low-code)

Backend: Supabase

Parte II

Frontend: React (Next.js)

Backend: Supabase

IA: OpenAI (via Edge Functions)

🚀 Parte I – Gamificação de Tarefas
🎯 Objetivo

Criar um módulo de gamificação onde o usuário:

Visualiza uma lista de tarefas

Marca cada tarefa como Feito ou Não feito

Recebe uma pontuação automática

Visualiza resultado final, gráfico e classificação

🧮 Regras de Pontuação
Ação	Pontos
Feito	+3
Não feito	-5

A pontuação é calculada e persistida no backend, garantindo integridade dos dados.

🗂️ Modelagem de Dados
Tabela: tasks
id uuid PRIMARY KEY
title text
description text
created_at timestamp

Tabela: task_responses
id uuid PRIMARY KEY
user_id uuid REFERENCES auth.users
task_id uuid REFERENCES tasks
status text -- 'feito' | 'nao_feito'
points integer
created_at timestamp

📊 Funcionalidades Implementadas
✔ Pontuação Total

Soma automática dos pontos com base nas respostas do usuário.

✔ Card de Totalização

Exibido apenas quando todas as tarefas forem respondidas.

✔ Gráfico de Pizza

Distribuição visual:

Quantidade de tarefas Feito

Quantidade de tarefas Não feito

✔ Classificação Final

Faixas de classificação definidas:

Pontuação Final	Classificação
≥ 15 pontos	🟢 Bom
5 a 14 pontos	🟡 Médio
< 5 pontos	🔴 Ruim
🔐 Segurança

Autenticação via Supabase Auth

Dados vinculados ao usuário autenticado

🔗 Link da Aplicação – Parte I

👉 [Inserir link do FlutterFlow publicado]

🧠 Parte II – Smart Docs (Base de Conhecimento Semântica)
🎯 Objetivo

Criar um sistema interno de documentação inteligente que:

Evite duplicidade de conteúdo

Permita busca semântica

Ofereça um chat de perguntas e respostas (Q&A) com base nas notas

Garanta isolamento total dos dados por usuário

🧱 Arquitetura Geral
Frontend (React / Next.js)
        ↓
Supabase Edge Functions (Deno)
        ↓
PostgreSQL + pgvector
        ↓
OpenAI (Embeddings + LLM)


⚠️ Nenhuma chave da OpenAI é exposta ao frontend.

🗂️ Modelagem de Dados
Extensão Vetorial
CREATE EXTENSION IF NOT EXISTS vector;

Tabela: documents
id uuid PRIMARY KEY
user_id uuid REFERENCES auth.users
title text
content text
embedding vector(1536)
is_public boolean default false
created_at timestamp

🔐 Row Level Security (RLS)

RLS é obrigatório e crítico neste projeto.

ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

Política de Leitura
CREATE POLICY "Users read own or public docs"
ON documents
FOR SELECT
USING (
  auth.uid() = user_id OR is_public = true
);


Garante que um usuário jamais consiga acessar notas de outro usuário.

🔍 Busca Semântica (RPC)
CREATE OR REPLACE FUNCTION match_documents(
  query_embedding vector(1536),
  match_threshold float,
  match_count int
)
RETURNS TABLE (
  id uuid,
  title text,
  content text,
  similarity float
)
LANGUAGE sql STABLE
AS $$
  SELECT
    id,
    title,
    content,
    1 - (embedding <=> query_embedding) AS similarity
  FROM documents
  WHERE 1 - (embedding <=> query_embedding) > match_threshold
  ORDER BY similarity DESC
  LIMIT match_count;
$$;

⚡ Edge Functions (Deno)
Responsabilidades

Gerar embeddings

Consultar similaridade

Interagir com a LLM

Proteger API Keys

Reduzir latência

Trigger Automático

Ao salvar uma nota:

Database Trigger/Webhook

Chama Edge Function

Gera e salva o embedding

Frontend não executa lógica pesada

✍️ Funcionalidades do Frontend
📝 Editor de Notas

Campo de texto simples

Busca semântica em tempo real (debounce)

Sugestão automática:

“Parece que já existe uma nota similar a esta: [Link]”

💬 Chat com a Base (Q&A)

Usuário faz perguntas em linguagem natural

Sistema:

Gera embedding da pergunta

Busca notas relevantes

Envia contexto para a LLM

Retorna resposta citando fontes

Exemplo:

“Segundo a nota Política de Home Office, …”

🤖 Prompt Controlado da LLM

A LLM responde somente com base nas notas encontradas, evitando alucinações.

🔗 Link da Aplicação – Parte II

👉 [Inserir link do app React / Next.js]

📌 Considerações Finais

Este desafio foi desenvolvido com foco em:

Arquitetura escalável

Segurança (RLS)

Desacoplamento frontend/backend

Uso responsável e profissional de IA

Boas práticas de engenharia de software

👤 Autor

Neemias Santos
Frontend / Full Stack Developer
React • Next.js • Supabase • IA aplicada
# Desafio Técnico – FRAKTAL (Supabase + Embeddings + Q&A)

Backend do sistema de notas com busca semântica e chat Q&A, usando Supabase (Postgres + RLS + Triggers + Edge Functions) e OpenAI.

## Visão geral

### Fluxo de embeddings (automático, desacoplado do frontend)
1. O usuário salva uma nota em `documents`.
2. Um **trigger no Postgres** enfileira um job em `document_embedding_jobs`.
3. Uma **Edge Function (worker)** processa jobs `pending`, gera o embedding e atualiza `documents.embedding`.
4. O frontend não roda lógica pesada: só cria a nota e consulta.

### Fluxo de Q&A (Chat)
1. O usuário envia uma pergunta.
2. A Edge Function `answer-question`:
   - gera embedding da pergunta
   - busca notas relevantes via RPC `match_documents`
   - chama o modelo de chat e retorna a resposta
   - retorna também as **fontes** (IDs das notas)

## Estrutura do backend (repo)

- `backend/supabase/migrations/`
  - Criação da fila `document_embedding_jobs`
  - Trigger `documents_after_insert` → enfileira job
  - RLS + policies em `documents`
  - RPC `match_documents` (busca por similaridade usando pgvector)
- `backend/supabase/functions/`
  - `generate-embedding/` → Worker que processa a fila e grava embeddings
  - `answer-question/` → Q&A com fontes usando notas do usuário

## Segurança (RLS)

- `documents` possui RLS habilitado.
- Usuários só acessam suas próprias notas (ou públicas, se aplicável).
- `document_embedding_jobs` é acessada apenas pela service role (Edge Functions).

## Secrets / Variáveis de ambiente (Supabase Cloud)

Configurar em **Supabase Dashboard → Edge Functions → Secrets**:

- `OPENAI_API_KEY`
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`


## Como aplicar no Supabase Cloud (migrations)

Este projeto foi construído e testado no Supabase Cloud. Para reproduzir:

1. Abra **SQL Editor** no Supabase.
2. Execute os arquivos em `backend/supabase/migrations/` na ordem (01 → 04).

## Teste rápido no Supabase Cloud

### 1) Inserir uma nota
No SQL Editor (use um UUID real de usuário):

```sql
insert into documents (content, user_id)
values ('Minha nota de teste', 'UUID_DO_USUARIO');
```

### 2) Verificar job enfileirado
```sql
select id, document_id, status, attempts, last_error, created_at
from document_embedding_jobs
order by created_at desc
limit 5;
```

Esperado: status = 'pending'.

### 3) Rodar worker (Edge Function)

No Dashboard:

Edge Functions → generate-embedding

Test → POST

Body {}

Esperado: retorno com processed: 1 e job done.

### 4) Confirmar embedding gravado
```sql
select
  content,
  embedding is not null as gerou_embedding,
  vector_dims(embedding) as dims
from documents
order by created_at desc
limit 1;
```

Esperado: gerou_embedding = true e dims = 1536.

### 5) Testar Q&A (Edge Function)

No Dashboard:

Edge Functions → answer-question

Test → POST

Body:

{
  "question": "Sobre o que falam minhas notas?",
  "top_k": 5
}


Esperado: JSON com answer e sources (IDs das notas utilizadas).

Observações

O processamento de embeddings é assíncrono (fila + worker), evitando acoplamento com o frontend.

A avaliação pode ser feita pelo comportamento na demo e pelo código (migrations + edge functions).
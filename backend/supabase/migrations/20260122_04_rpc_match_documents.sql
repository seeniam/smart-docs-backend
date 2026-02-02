create or replace function match_documents_for_user(
  query_embedding vector(1536),
  match_count int default 5
)
returns table (
  id uuid,
  content text,
  similarity float
)
language sql stable
as $$
  select
    d.id,
    d.content,
    1 - (d.embedding <=> query_embedding) as similarity
  from documents d
  where d.user_id = auth.uid()
  order by d.embedding <=> query_embedding
  limit match_count;
$$;
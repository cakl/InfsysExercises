--dump fulltextsearch table
/*
\d fulltextsearch
+----------+---------+-------------------------------------------------------------+
| Column   | Type    | Modifiers                                                   |
|----------+---------+-------------------------------------------------------------|
| id       | integer | not null default nextval('fulltextsearch_id_seq'::regclass) |
| docid    | integer | default 0                                                   |
| title    | text    |                                                             |
| content  | text    | not null                                                    |
+----------+---------+-------------------------------------------------------------+
Indexes:
    "fulltextsearch_pkey" PRIMARY KEY, btree (id)
*/

-- slow search
SELECT id, length(content) FROM fulltextsearch WHERE to_tsquery('mistress') @@ to_tsvector('english', content);

-- add gin and gist indices 
ALTER TABLE fulltextsearch ADD COLUMN content_tsv_gin tsvector;
UPDATE fulltextsearch SET content_tsv_gin = to_tsvector('english', content);
ALTER TABLE fulltextsearch ADD COLUMN content_tsv_gist tsvector;
UPDATE fulltextsearch SET content_tsv_gist = to_tsvector('english', content);

--dump fulltextsearch table
/*
\d fulltextsearch
+------------------+----------+-------------------------------------------------------------+
| Column           | Type     | Modifiers                                                   |
|------------------+----------+-------------------------------------------------------------|
| id               | integer  | not null default nextval('fulltextsearch_id_seq'::regclass) |
| docid            | integer  | default 0                                                   |
| title            | text     |                                                             |
| content          | text     | not null                                                    |
| content_tsv_gin  | tsvector |                                                             |
| content_tsv_gist | tsvector |                                                             |
+------------------+----------+-------------------------------------------------------------+
Indexes:
    "fulltextsearch_pkey" PRIMARY KEY, btree (id)
    "fulltextsearch_content_tsv_gin" gin (content_tsv_gin)
    "fulltextsearch_content_tsv_gist" gist (content_tsv_gist)
Triggers:
    tsv_gin_update BEFORE INSERT OR UPDATE ON fulltextsearch FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('content_tsv_gin', 'english', 'content')
    tsv_gist_update BEFORE INSERT OR UPDATE ON fulltextsearch FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('content_tsv_gist', 'english', 'content')
*/

-- perform query on indexex and triggered columns thats way faster
select docid from fulltextsearch where content_tsv_gin @@ to_tsquery('mistress');
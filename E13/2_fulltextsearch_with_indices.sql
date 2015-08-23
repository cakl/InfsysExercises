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

-- perform query with rank
-- ts_rank([ weights float4[], ] vector tsvector, query tsquery [, normalization integer ]) returns float4
-- Ranks vectors based on the frequency of their matching lexemes.
-- ts_rank_cd([ weights float4[], ] vector tsvector, query tsquery [, normalization integer ]) returns float4
-- This function computes the cover density ranking for the given document vector and query [...]
SELECT id, left(content,40), ts_rank_cd(content_tsv_gin, query) as rank, ts_rank_cd(content_tsv_gin, query, 32 /* rank/(rank+1)
*/) AS normalized_rank FROM FullTextSearch, to_tsquery('wonderful | good'
) query WHERE query @@ content_tsv_gin
ORDER BY rank DESC LIMIT 10;
/*
+------+------------------------------------------+--------+-------------------+
|   id | left                                     |   rank |   normalized_rank |
|------+------------------------------------------+--------+-------------------|
| 1200 | As Good As It Gets (1997) reviewed by St |    1.8 |          0.642857 |
|   74 | Batman Forever (1995) reviewed by Andy J |    1.4 |          0.583333 |
|  431 | Wonder Boys (2000) reviewed by Christoph |    1.1 |          0.52381  |
| 1518 | People Under the Stairs, The (1992) revi |    1.1 |          0.52381  |
|  521 | Star Trek: Insurrection (1998) reviewed  |    1   |          0.5      |
| 1349 | Good Will Hunting (1997) reviewed by Jas |    1   |          0.5      |
|  186 | Dogma (1999) reviewed by Shay Casey ***  |    1   |          0.5      |
| 1305 | Go (1999) reviewed by DeWyNGaLe GO by De |    0.9 |          0.473684 |
|  359 | Birdcage, The (1996) reviewed by Will Fi |    0.8 |          0.444444 |
| 1439 | Elvira, Mistress of the Dark (1988) revi |    0.8 |          0.444444 |
+------+------------------------------------------+--------+-------------------+
*/


-- create own dictionary (with postgres.app from matt installed)
-- cd /Applications/Postgres.app/Contents/Versions/9.4/share/postgresql/tsearch_data
-- echo temp > synonym_movies.syn
-- nano synonym_movies.syn #add lines of http://wiki.hsr.ch/Datenbanken/files/synonym_movies.syn
-- ctrl+x, ctrl+y to save

 -- Dictionary 'objekt' synonym_movies anlegen:
  CREATE TEXT SEARCH DICTIONARY synonym_movies (
    TEMPLATE = synonym,
    SYNONYMS = synonym_movies
  );
  -- Dictionary 'objekt' synonym_movies der Konfiguration übergeben:
  ALTER TEXT SEARCH CONFIGURATION english 
    ALTER MAPPING FOR asciiword, asciihword, hword
    WITH synonym_movies, english_stem;

SELECT * FROM ts_debug('english', 'Paris');
/*
+-----------+-----------------+---------+-------------------------------+----------------+------------+
| alias     | description     | token   | dictionaries                  | dictionary     | lexemes    |
|-----------+-----------------+---------+-------------------------------+----------------+------------|
| asciiword | Word, all ASCII | Paris   | {synonym_movies,english_stem} | synonym_movies | [u'paris'] |
+-----------+-----------------+---------+-------------------------------+----------------+------------+
*/

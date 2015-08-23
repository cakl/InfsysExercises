-- tokenize 'ate':3 'cat':2,11 'fat':1 'hate':7 'kind':9 'rat':4
select to_tsvector('fat cats ate rats and I hate these kind of cats');
-- query on tokens with boolean result TRUE
select to_tsvector('fat cats ate rats') @@ to_tsquery('cat & rat');
-- more complex to_tsquery
select to_tsvector('german', 'Ich würz den ganzen Tag und ich würz die ganze Nacht') @@ to_tsquery('würzen|(Tag & Nacht)');
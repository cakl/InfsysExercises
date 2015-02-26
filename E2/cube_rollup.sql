select 
  dimtime.YEAR,
  DECODE(GROUPING(dimtime.month), 1, 'ALL', dimtime.month) as month,
  sum(factsales.QUANTITY)
from 
  factsales,
  dimtime
where
  factsales.TIMEID = dimtime.timeid
group by
  ROLLUP(dimtime.year, dimtime.MONTH)
;

select
  DECODE(GROUPING(dimtime.year), 1, 'ALL', dimtime.year) as year,
  DECODE(GROUPING(dimtime.season), 1, 'ALL', dimtime.SEASON) as season,
  DECODE(GROUPING(dimtime.month), 1, 'ALL', dimtime.month) as month,
  sum(factsales.QUANTITY)
from 
  factsales,
  dimtime
where
  factsales.TIMEID = dimtime.timeid
group by
  ROLLUP(dimtime.year, dimtime.MONTH, dimtime.season)
;

select
  dimmovie.GENRE,
  dimcustomer.gender,
  sum(factsales.quantity)
from
  factsales,
  dimmovie,
  dimcustomer
where
  factsales.movieid = dimmovie.movieid
  and
  factsales.custid = dimcustomer.custid
group by 
  cube(dimmovie.genre, dimcustomer.gender)
;
  
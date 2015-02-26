select
  dimmovie.subgenre,
  sum(factsales.QUANTITY) as anzsales,
  RANK() OVER (ORDER BY sum(factsales.quantity) ASC) rang
from
  factsales,
  dimmovie
where
  factsales.movieid = dimmovie.movieid
group by
  dimmovie.subgenre
;

select
  dimmovie.subgenre,
  dimcustomer.gender,
  sum(factsales.quantity),
  GROUPING_ID(dimmovie.subgenre, dimcustomer.gender) groupingid,
  RANK() OVER(PARTITION BY GROUPING_ID(dimmovie.subgenre, dimcustomer.gender) ORDER BY SUM(factsales.QUANTITY) DESC) as rank
from
  factsales,
  dimmovie,
  dimcustomer
where
  factsales.movieid = dimmovie.movieid
  and
  factsales.custid = dimcustomer.custid
group by 
  cube(dimmovie.subgenre, dimcustomer.gender)
order by
  dimmovie.subgenre
;



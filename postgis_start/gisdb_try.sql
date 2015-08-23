-- C

-- create db
CREATE DATABASE gueselGIS OWNER sebastianbock;

-- create postgis extension 
CREATE EXTENSION postgis;

-- check if extension is available with spatial sys ref table
select * from spatial_ref_sys where srid = 4326;

--create sample table
CREATE TABLE loots (id int PRIMARY key, name text, geom geometry('LINESTRING', 4326));

--create index on geometry object 
CREATE INDEX in_loots_the_geom ON loots USING gist(geom);

--create validation constraint on geom object
ALTER TABLE loots ADD CONSTRAINT mygeom_check CHECK (ST_isvalid(geom));


-- R

--distance (1.41421)
select st_distance(
 st_geomfromtext('POINT(0 0)'),
 st_geomfromtext('POINT(1 1)')
);

--sphere distance (55120.6)
select 
  o.name, 
  st_distance_sphere(st_transform(o.the_geom,4326),st_transform(herisau.the_geom, 4326)) 
from 
  orte o, 
  (select * from orte where gid=858) herisau 
order by 
  herisau.the_geom <-> o.the_geom ;

--spheroid distance (55152)
select 
	st_distance_spheroid(
		(select st_transform(the_geom,4326) from orte where gid=388), --winti 
		(select st_transform(the_geom,4326) from orte where gid=690), --ebikon
		'SPHEROID["Bessel 1841",6377397.155,299.1528128]'
);

-- ST_AREA: surface (4), (alle gemeinden mit A > 100km^2) 
select st_area(ST_geomfromtext('POLYGON((0 0, 0 2, 2 2, 2 0, 0 0))'));
select name, (ST_Area(geom) / 1000000) as surface from gemeinden where (ST_Area(geom) / 1000000) > 100 order by st_area(geom) des
c;

-- ST_TOUCHES (freienbach, eschenbach...)
select g.name from gemeinden g, (select * from gemeinden where gid=120)rapperswil where st_touches(g.geom, rapperswil.geom) = '1'
;

-- ST_DWithin (alle orte 10km um HSR)
-- ST_DWithin — Returns true if the geometries are within the specified distance of one another.
select name from orte where st_dwithin(orte.the_geom, ST_Geomfromtext('POINT(704472 231216)', 21781), 10000) = '1';

-- ST_Within — Returns true if the geometry A is completely inside geometry B
select o.name from  (select * from fluesse where gid =38) emme, orte o where
st_within(o.the_geom, st_buffer(emme.the_geom, 2000)) = TRUE;

-- ST_Intersects — Returns TRUE if the Geometries/Geography "spatially intersect in 2D" - (share any portion of space)
SELECT g.name FROM gemeinden g, zecken z
WHERE g.kt = 1 AND z.gebiet='hochrisiko' 
AND NOT ST_Intersects(g.the_geom, z.the_geom);

-- ST_Crosses — Returns TRUE if the supplied geometries have some, but not all, interior points in common
SELECT g.name FROM gemeinden g, fluesse f WHERE f.name = 'Emme'  AND ST_Crosses(f.the_geom, g.the_geom);

-- ST_Equals — Returns true if the given geometries represent the same geometry
-- ST_Disjoint — Returns TRUE if the Geometries do not "spatially intersect" - if they do not share any space together.
-- ST_Contains — Returns true if and only if no points of B lie in the exterior of A, and at least one point of the interior of B lies in the interior of A.
-- ST_Overlaps — Returns TRUE if the Geometries share space, are of the same dimension, but are not completely contained by each other.
-- ST_Union — Returns a geometry that represents the point set union of the Geometries.
-- ST_Centroid — Returns the geometric center of a geometry.
-- ST_Difference — Returns a geometry that represents that part of geometry A that does not intersect with geometry B.
-- ST_SymDifference — Returns a geometry that represents the portions of A and B that do not intersect.

--ST_Summary (MultiPolygon[BS] with 1 elements Polygon[S] with 1 rings, ring 0 has 5 points)
select st_summary(geom) from gemeinden where gid = 1;

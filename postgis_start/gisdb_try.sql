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


-- R

--distance (1.41421)
select st_distance(
 st_geomfromtext('POINT(0 0)'),
 st_geomfromtext('POINT(1 1)')
);

--spheroid distance (55120.6)
select 
	st_distance_sphere(
		(select st_transform(the_geom,4326) from orte where gid=388), --winti 
		(select st_transform(the_geom,4326) from orte where gid=690)  --ebikon
	);

--summary (MultiPolygon[BS] with 1 elements Polygon[S] with 1 rings, ring 0 has 5 points)
select st_summary(geom) from gemeinden where gid = 1;


\set ON_ERROR_STOP 1

\ir create_clustered_db.sql

\set ECHO ALL
\c meta
SELECT add_cluster_user('postgres', NULL);

SELECT add_node('Test1' :: NAME, 'localhost');
SELECT add_node('test2' :: NAME, 'localhost');

SELECT add_namespace('testNs' :: NAME);
SELECT add_field('testNs' :: NAME, 'Device_id', 'text', TRUE, TRUE, ARRAY['TIME-VALUE'] :: field_index_type []);
SELECT add_field('testNs' :: NAME, 'temp', 'double precision', FALSE, FALSE, ARRAY['VALUE-TIME'] :: field_index_type []);
SELECT add_field('testNs' :: NAME, 'occupied', 'boolean', FALSE, FALSE, ARRAY[] :: field_index_type []);
SELECT add_field('testNs' :: NAME, 'latitude', 'bigint', FALSE, FALSE, ARRAY[] :: field_index_type []);
SELECT add_field('testNs' :: NAME, 'really_long_field_goes_on_and_on_and_on_and_on_and_on_and_on_and_on_and_on', 'bigint', FALSE, FALSE, ARRAY['TIME-VALUE','VALUE-TIME'] :: field_index_type []);

SELECT *
FROM node;
SELECT *
FROM namespace;
SELECT *
FROM namespace_node;
SELECT *
FROM field;

\c Test1

SELECT *
FROM node;
SELECT *
FROM namespace;
SELECT *
FROM namespace_node;
SELECT *
FROM field;
\dt "testNs".*
\det "testNs".*
\d+ "testNs".distinct
\d+ "testNs".cluster

--test idempotence
\c meta
SELECT add_namespace('testNs' :: NAME);
SELECT add_field('testNs' :: NAME, 'Device_id', 'text', TRUE, TRUE, ARRAY['TIME-VALUE'] :: field_index_type []);
SELECT add_field('testNs' :: NAME, 'temp', 'double precision', FALSE, FALSE, ARRAY['VALUE-TIME'] :: field_index_type []);
SELECT add_field('testNs' :: NAME, 'occupied', 'boolean', FALSE, FALSE, ARRAY[] :: field_index_type []);
SELECT add_field('testNs' :: NAME, 'latitude', 'bigint', FALSE, FALSE, ARRAY[] :: field_index_type []);
SELECT add_field('testNs' :: NAME, 'really_long_field_goes_on_and_on_and_on_and_on_and_on_and_on_and_on_and_on', 'bigint', FALSE, FALSE, ARRAY['TIME-VALUE','VALUE-TIME'] :: field_index_type []);
\c Test1
\d+ "testNs".cluster

SELECT get_or_create_data_table((1477075243*1e9)::bigint, 'testNs'::NAME, 0::SMALLINT, 10::SMALLINT);
\dt "testNs".*
\det "testNs".*
\d+ "testNs".data_0_10_1477008000
\d+ "testNs".partition_0_10

SELECT close_data_table_end('"testNs".data_0_10_1477008000');
\d+ "testNs".data_0_10_1477008000

SELECT get_or_create_data_table((1477075243*1e9)::bigint, 'testNs'::NAME, 0::SMALLINT, 10::SMALLINT);
\dt "testNs".*
SELECT get_or_create_data_table(((1477075243+(60*60*25))*1e9)::bigint, 'testNs'::NAME, 0::SMALLINT, 10::SMALLINT);
\dt "testNs".*
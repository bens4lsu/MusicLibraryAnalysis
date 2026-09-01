-- Databricks notebook source
-- CREATE OR REPLACE TABLE ml.test_parquet AS
SELECT *
FROM parquet.`/Volumes/workspace/default/s3vol/test1_parquet/`;

-- COMMAND ----------

select * from default.test_parquet
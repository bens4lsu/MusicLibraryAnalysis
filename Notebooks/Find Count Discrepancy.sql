-- Databricks notebook source
-- MAGIC %skip
-- MAGIC %python
-- MAGIC # Load a CSV file into a DataFrame
-- MAGIC df = (
-- MAGIC     spark.read
-- MAGIC     .format("csv")
-- MAGIC     .option("header", False)
-- MAGIC     .option("inferSchema", True)
-- MAGIC     .option("delimiter", "\t")
-- MAGIC     .load("/Volumes/workspace/default/s3vol/MusicLibrary/FileData/report.txt")
-- MAGIC )
-- MAGIC
-- MAGIC from pyspark.sql.functions import concat, lit
-- MAGIC
-- MAGIC df = df.withColumn(
-- MAGIC     "_c0",
-- MAGIC     concat(lit("file://"), df["_c0"])
-- MAGIC )
-- MAGIC
-- MAGIC # Register the DataFrame as a temporary view
-- MAGIC df.createOrReplaceTempView("library_paths")
-- MAGIC
-- MAGIC display(spark.sql("SELECT * FROM library_paths LIMIT 100"))

-- COMMAND ----------

-- MAGIC %python
-- MAGIC df = (
-- MAGIC     spark.read
-- MAGIC     .format("csv")
-- MAGIC     .option("header", False)
-- MAGIC     .option("inferSchema", True)
-- MAGIC     .option("delimiter", "\t")
-- MAGIC     .load("/Volumes/workspace/default/s3vol/MusicLibrary/FileData/Music_Persistent_IDs.txt")
-- MAGIC )
-- MAGIC
-- MAGIC df.createOrReplaceTempView("persistent_ids")

-- COMMAND ----------

-- MAGIC %skip
-- MAGIC -- 29,134 showing in app 2026-01-12
-- MAGIC select count(*) from workspace.ml.library_latest;  --29143
-- MAGIC --select count(*) from library_paths  --29142

-- COMMAND ----------

-- MAGIC %skip
-- MAGIC %sql
-- MAGIC
-- MAGIC WITH ctePaths(path) AS (
-- MAGIC   SELECT location 
-- MAGIC   FROM ml.library_latest p
-- MAGIC   WHERE NOT EXISTS (
-- MAGIC     SELECT 1
-- MAGIC     FROM library_paths p
-- MAGIC     WHERE p._c0 = p.location
-- MAGIC   )
-- MAGIC )
-- MAGIC SELECT * FROM ml.library_latest where location in (select path from ctepaths) 
-- MAGIC
-- MAGIC

-- COMMAND ----------

select count(*) from persistent_ids; -- 29143
select count(*) from workspace.ml.library_latest  -- 29143

-- COMMAND ----------

-- MAGIC %md
-- MAGIC file:///Users/ben/Music_/Music/Beyonce%CC%81/HOMECOMING_ THE LIVE ALBUM/35 Single Ladies (Put a Ring on It) [Homecoming Live].m4a
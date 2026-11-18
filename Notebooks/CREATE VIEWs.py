# Databricks notebook source
# /// script
# [tool.databricks.environment]
# environment_version = "6"
# ///
# MAGIC %sql
# MAGIC CREATE OR REPLACE VIEW ml.library_latest AS
# MAGIC
# MAGIC WITH cteLatest AS (
# MAGIC   SELECT MAX(library_date) AS MaxLibraryDate from ml.library_snapshots
# MAGIC )
# MAGIC SELECT ls.*
# MAGIC     , ly.lyrics
# MAGIC FROM ml.library_snapshots ls
# MAGIC INNER JOIN cteLatest ON ls.library_date = cteLatest.MaxLibraryDate
# MAGIC LEFT OUTER JOIN ml.lyrics ly on ls.persistent_id = ly.persistentID
# MAGIC

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE VIEW ml.library_snapshot_meta AS
# MAGIC
# MAGIC SELECT library_snapshot_id
# MAGIC   , library_date
# MAGIC   , RANK() OVER (ORDER BY library_date) AS RankASC
# MAGIC   , RANK() OVER (ORDER BY library_date DESC) AS RankDESC
# MAGIC FROM ml.library_snapshots
# MAGIC GROUP BY library_snapshot_id, library_date;
# MAGIC
# MAGIC
# MAGIC select * from ml.library_snapshot_meta
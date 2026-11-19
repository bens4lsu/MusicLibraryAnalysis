# Databricks notebook source
# /// script
# [tool.databricks.environment]
# environment_version = "6"
# ///
# DBTITLE 1,Overview
# MAGIC %md
# MAGIC # Load Lyrics to Table
# MAGIC
# MAGIC Reads `Lyrics.xml` (one `<track>` per row, with `persistentID` and `lyrics` fields) into a Spark DataFrame and saves it to the Unity Catalog table `workspace.ml.lyrics`.

# COMMAND ----------

# DBTITLE 1,Load XML into a DataFrame
lyrics_df = (
    spark.read.format("xml")
    .option("rowTag", "track")
    .option("excludeAttribute", "false")
    .load("/Workspace/Users/ben@concordbusinessservicesllc.com/MusicLibraryAnalysis/Files/Lyrics.xml")
)

display(lyrics_df)

# COMMAND ----------

# DBTITLE 1,Save to workspace.ml.lyrics
lyrics_df.write.mode("overwrite").saveAsTable("workspace.ml.lyrics")

display(spark.sql("SELECT COUNT(*) AS row_count, COUNT(DISTINCT persistentID) AS distinct_tracks FROM workspace.ml.lyrics"))

# COMMAND ----------


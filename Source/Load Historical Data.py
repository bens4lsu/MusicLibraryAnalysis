# Databricks notebook source
import pandas as pd
import re
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, BooleanType, DateType
from pyspark.sql.functions import col, to_date, try_to_date, coalesce

# Read CSV with Pandas using UTF-16 encoding
pandas_df = pd.read_csv("/Volumes/workspace/default/s3vol/MusicLibrary/FileData/LibraryDetails.txt", encoding='utf-16', on_bad_lines='skip', delimiter="|")

schema = StructType([
    StructField("library_snapshot_id", IntegerType(), True),
    StructField("library_date",        StringType(),  False),  # non-nullable
    StructField("id",                  IntegerType(), False),  # non-nullable
    StructField("persistent_id",       StringType(),  False),  # non-nullable
    StructField("artist",              StringType(),  False),  # non-nullable
    StructField("album",               StringType(),  True),
    StructField("track_name",          StringType(),  False),  # non-nullable
    StructField("rating",              IntegerType(), True),
    StructField("playcount",           IntegerType(), True),
    StructField("genre",               StringType(),  True),
    StructField("last_played",         StringType(),  True),
    StructField("date_added",          StringType(),  False),  # non-nullable
    StructField("bit_rate",            IntegerType(), True),
    StructField("year",                IntegerType(), True),
    StructField("loved",               BooleanType(), True),   # bool
    StructField("checked",             BooleanType(), True),   # bool
    StructField("skip_count",          IntegerType(), True),
    StructField("last_skipped",        StringType(),  True),
    StructField("disk_number",         IntegerType(), True),
    StructField("disk_count",          IntegerType(), True),
    StructField("track_number",        IntegerType(), True),
    StructField("track_count",         IntegerType(), True),
])


# Convert to Spark DataFrame
dftemp = spark.createDataFrame(pandas_df, schema=schema)
dftemp = dftemp \
    .withColumn("library_date", coalesce(try_to_date(col("library_date"), "yyyy-MM-dd HH:mm:ss.SSSSSSS"), try_to_date(col("library_date"), "yyyy-MM-dd"))) \
    .withColumn("last_played", coalesce(try_to_date(col("last_played"), "yyyy-MM-dd HH:mm:ss.SSSSSSS"), try_to_date(col("last_played"), "yyyy-MM-dd"))) \
    .withColumn("date_added", coalesce(try_to_date(col("date_added"), "yyyy-MM-dd HH:mm:ss.SSSSSSS"), try_to_date(col("date_added"), "yyyy-MM-dd"))) \
    .withColumn("last_skipped", coalesce(try_to_date(col("last_skipped"), "yyyy-MM-dd HH:mm:ss.SSSSSSS"), try_to_date(col("last_skipped"), "yyyy-MM-dd")))


df.display()

# COMMAND ----------

# MAGIC %sql
# MAGIC drop view workspace.ml.library_snapshots

# COMMAND ----------

# MAGIC %sql
# MAGIC -- DROP TABLE IF EXISTS workspace.ml.library_snapshots;
# MAGIC
# MAGIC CREATE TABLE IF NOT EXISTS workspace.ml.library_snapshots (
# MAGIC   library_snapshot_id INT       NOT NULL,
# MAGIC   library_date        DATE      NOT NULL,
# MAGIC   id                  INT       NOT NULL,
# MAGIC   persistent_id       STRING    NOT NULL,
# MAGIC   artist              STRING    NOT NULL,
# MAGIC   album               STRING,
# MAGIC   track_name          STRING    NOT NULL,
# MAGIC   rating              INT,
# MAGIC   playcount           INT,
# MAGIC   genre               STRING,
# MAGIC   last_played         DATE,
# MAGIC   date_added          DATE      NOT NULL,
# MAGIC   bit_rate            INT,
# MAGIC   year                INT,
# MAGIC   loved               BOOLEAN,
# MAGIC   checked             BOOLEAN,
# MAGIC   skip_count          INT,
# MAGIC   last_skipped        DATE,
# MAGIC   disk_number         INT,
# MAGIC   disk_count          INT,
# MAGIC   track_number        INT,
# MAGIC   track_count         INT
# MAGIC )
# MAGIC USING DELTA
# MAGIC
# MAGIC

# COMMAND ----------

df.writeTo("workspace.ml.library_snapshots").append()

# COMMAND ----------

# MAGIC %sql
# MAGIC ALTER TABLE workspace.ml.library_snapshots ADD COLUMNS(location String)
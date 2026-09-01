# Databricks notebook source
from datetime import datetime

libDate = dbutils.widgets.get("my_date")
dtLibDate = datetime.strptime(libDate, "%Y-%m-%d").date()
strLibDate = dtLibDate.strftime("%Y%m%d")
print(strLibDate)



# COMMAND ----------

# DBTITLE 1,Archive library.xml file
from pathlib import Path

oldp = Path("/Volumes/workspace/default/s3vol/MusicLibrary/Library.xml")
newp = "/Volumes/workspace/default/s3vol/MusicLibrary/FileData/Library_" + strLibDate + ".xml"

oldp.rename(newp)

# COMMAND ----------

# DBTITLE 1,plist to python dictionary
import plistlib

with open(newp, 'rb') as f:
    xml_content = f.read()
    
pldict = plistlib.loads(xml_content)
pldict = pldict['Tracks']

print(pldict)

# COMMAND ----------

# DBTITLE 1,dictionary to dataframe
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
import datetime
import re

def preserve_plus(val):
    if isinstance(val, str):
        return val.replace('+', '___PLUS___')
    return val

# rename columns to snake_case for easier SQL querying
def snake(name):
    name = re.sub(r"[^\w]+", "_", name).strip("_")
    return name.lower()


spark = SparkSession.builder.getOrCreate()


# Build a unified set of columns across all tracks
all_cols = set()
for d in pldict.values():
    all_cols.update(d.keys())
# Add the top-level key as a column (string track key)
all_cols.add("Track Key")
all_cols = sorted(all_cols)

# Normalize values (keep datetimes as Python datetime so Spark casts to TimestampType)
def normalize_value(v):
    if isinstance(v, datetime.date) and not isinstance(v, datetime.datetime):
        return datetime.datetime(v.year, v.month, v.day)
    return v

records = []
for track_key, attrs in pldict.items():
    rec = {"Track Key": str(track_key)}
    for col in all_cols:
        if col == "Track Key":
            continue
        rec[col] = preserve_plus(normalize_value(attrs.get(col)))
    records.append(rec)

df = spark.createDataFrame(records)



for c in df.columns:
    df = df.withColumn(
        c,
        F.when(
            F.col(c).contains('___PLUS___'),
            F.regexp_replace(F.col(c), '___PLUS___', '+')
        ).otherwise(F.col(c))
    ).withColumnRenamed(c, snake(c))

display(df)

# COMMAND ----------

# DBTITLE 1,dataframe to sql table
df.createOrReplaceTempView("tbl")

display(df)

# COMMAND ----------

# DBTITLE 1,insert to workspace.ml.library_snapshots
# MAGIC %sql
# MAGIC DELETE FROM workspace.ml.library_snapshots WHERE library_date = :my_date
# MAGIC -- args: {'my_date': my_date}
# MAGIC
# MAGIC
# MAGIC ;WITH RECURSIVE cteCurrIDs MAX RECURSION LEVEL 10000000 AS (
# MAGIC   SELECT MAX(library_snapshot_id) AS max_snapshot_id
# MAGIC     , MAX(ID) AS max_id
# MAGIC   FROM workspace.ml.library_snapshots
# MAGIC )
# MAGIC
# MAGIC INSERT INTO workspace.ml.library_snapshots
# MAGIC SELECT currId.max_snapshot_id + 1 AS snapshot_id 
# MAGIC   , :my_date AS library_date
# MAGIC   , currId.max_id + ROW_NUMBER() OVER (PARTITION BY 1 ORDER BY 1) AS id
# MAGIC   , tbl.persistent_id
# MAGIC   , IFNULL(tbl.artist, '') AS artist
# MAGIC   , tbl.album 
# MAGIC   , tbl.name
# MAGIC   , tbl.rating
# MAGIC   , tbl.play_count
# MAGIC   , tbl.genre
# MAGIC   , tbl.play_date_utc
# MAGIC   , tbl.date_added
# MAGIC   , tbl.bit_rate
# MAGIC   , tbl.year
# MAGIC   , IFNULL(tbl.loved, false) AS loved
# MAGIC   , NOT IFNULL(tbl.disabled, false) AS checked
# MAGIC   , tbl.skip_count
# MAGIC   , tbl.skip_date
# MAGIC   , tbl.disc_number
# MAGIC   , tbl.disc_count
# MAGIC   , tbl.track_number
# MAGIC   , tbl.track_count
# MAGIC   , REPLACE(
# MAGIC       REPLACE(
# MAGIC         REPLACE(
# MAGIC           REPLACE(
# MAGIC             REPLACE(
# MAGIC               try_url_decode(
# MAGIC                 REPLACE(
# MAGIC                   REPLACE(
# MAGIC                     REPLACE(
# MAGIC                       REPLACE(
# MAGIC                           REPLACE(
# MAGIC                             REPLACE(
# MAGIC                               REPLACE(tbl.location, '100%20', '100 ')       -- doesn't url decode for some reason
# MAGIC                               , '10%20', '10 ')                             -- doesn't url decode for some reason
# MAGIC                           , '99.9\%', '___99POINT9PERCENT___')
# MAGIC                           , '99\%', '___99PERCENT___')
# MAGIC                       , '10\%', '___10PERCENT___')
# MAGIC                     , '100\%', '___100PERCENT___'
# MAGIC                   )
# MAGIC                   , '+', '___PLUS___'
# MAGIC                 )
# MAGIC             )
# MAGIC             , '___PLUS___', '+'
# MAGIC           ) 
# MAGIC           , '___100PERCENT___', '100%'
# MAGIC         )
# MAGIC         , '___10PERCENT___', '10%'
# MAGIC       )
# MAGIC       , '___99PERCENT___', '99%'
# MAGIC     )
# MAGIC     , '___99POINT9PERCENT___', '99.9%'
# MAGIC   ) AS location
# MAGIC FROM tbl
# MAGIC CROSS JOIN cteCurrIDs currId
# MAGIC WHERE NOT EXISTS (
# MAGIC   SELECT 1 FROM workspace.ml.library_snapshots
# MAGIC   WHERE library_date = :my_date
# MAGIC )
# MAGIC -- args: {'my_date': my_date}
# MAGIC

# COMMAND ----------

# DBTITLE 1,verify
# MAGIC %sql
# MAGIC select library_date, count(*)
# MAGIC from workspace.ml.library_snapshots
# MAGIC group by library_date
# MAGIC order by library_date desc

# COMMAND ----------

# DBTITLE 1,Create Parquet Table from Snapshots
df = spark.table("workspace.ml.library_snapshots")
df.write.mode("overwrite").format("delta").save("s3://ben-personal-s3-bucket-01/MusicLibrary/DeltaData/library_snapshots")



# COMMAND ----------

# MAGIC %md
# MAGIC ### create DataTable latest.  
# MAGIC Table metadata can be used to see older entries.  Data starts 2026-02-11
# MAGIC

# COMMAND ----------

# DBTITLE 1,Untitled
# MAGIC %skip
# MAGIC
# MAGIC # run this block only once
# MAGIC df = spark.table("workspace.ml.library_latest")
# MAGIC df.write.mode("overwrite").format("delta").save("s3://ben-personal-s3-bucket-01/MusicLibrary/DeltaData/library_snapshot_1")
# MAGIC

# COMMAND ----------

# DBTITLE 1,Delta Lake MERGE (Upsert) Example
from delta.tables import DeltaTable

# Path to your Delta table on S3
delta_path = "s3://ben-personal-s3-bucket-01/MusicLibrary/DeltaData/library_snapshot_1"

# Load the Delta table
delta_table = DeltaTable.forPath(spark, delta_path)

new_data = spark.table("workspace.ml.library_latest")

# Perform the MERGE (upsert) operation
# Replace 'id' with your actual unique key column

(
    delta_table.alias("t")
    .merge(
        new_data.alias("s"),
        "t.persistent_id = s.persistent_id"
    )
    .whenMatchedUpdateAll()
    .whenNotMatchedInsertAll()
    .execute()
)

# No need to save again; Delta Lake handles transactional updates in place.
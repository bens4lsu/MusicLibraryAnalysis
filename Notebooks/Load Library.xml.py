# Databricks notebook source
# /// script
# [tool.databricks.environment]
# environment_version = "6"
# ///
from datetime import datetime

libDate = input("Enter the library date (YYYY-MM-DD): ")
dtLibDate = datetime.strptime(libDate, "%Y-%m-%d").date()
strLibDate = dtLibDate.strftime("%Y%m%d")
print(strLibDate)



# COMMAND ----------

# DBTITLE 1,Archive library.xml file
import shutil
from pathlib import Path

oldp = Path("/Workspace/Users/ben@concordbusinessservicesllc.com/MusicLibraryAnalysis/Files/Library.xml")
newp = "/Volumes/workspace/default/s3vol/MusicLibrary/FileData/Library_" + strLibDate + ".xml"

shutil.copy(oldp, newp)

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
delete_sql = "DELETE FROM workspace.ml.library_snapshots WHERE library_date = :my_date"
spark.sql(delete_sql, args={"my_date": dtLibDate})

insert_sql = r"""
WITH RECURSIVE cteCurrIDs MAX RECURSION LEVEL 10000000 AS (
  SELECT MAX(library_snapshot_id) AS max_snapshot_id
    , MAX(ID) AS max_id
  FROM workspace.ml.library_snapshots
)

INSERT INTO workspace.ml.library_snapshots
SELECT currId.max_snapshot_id + 1 AS snapshot_id 
  , :my_date AS library_date
  , currId.max_id + ROW_NUMBER() OVER (PARTITION BY 1 ORDER BY 1) AS id
  , tbl.persistent_id
  , IFNULL(tbl.artist, '') AS artist
  , tbl.album 
  , tbl.name
  , tbl.rating
  , tbl.play_count
  , tbl.genre
  , tbl.play_date_utc
  , tbl.date_added
  , tbl.bit_rate
  , tbl.year
  , IFNULL(tbl.loved, false) AS loved
  , NOT IFNULL(tbl.disabled, false) AS checked
  , tbl.skip_count
  , tbl.skip_date
  , tbl.disc_number
  , tbl.disc_count
  , tbl.track_number
  , tbl.track_count
  , REPLACE(
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(
              try_url_decode(
                REPLACE(
                  REPLACE(
                    REPLACE(
                      REPLACE(
                          REPLACE(
                            REPLACE(
                              REPLACE(tbl.location, '100%20', '100 ')       -- doesn't url decode for some reason
                              , '10%20', '10 ')                             -- doesn't url decode for some reason
                          , '99.9\%', '___99POINT9PERCENT___')
                          , '99\%', '___99PERCENT___')
                      , '10\%', '___10PERCENT___')
                    , '100\%', '___100PERCENT___'
                  )
                  , '+', '___PLUS___'
                )
            )
            , '___PLUS___', '+'
          ) 
          , '___100PERCENT___', '100%'
        )
        , '___10PERCENT___', '10%'
      )
      , '___99PERCENT___', '99%'
    )
    , '___99POINT9PERCENT___', '99.9%'
  ) AS location
FROM tbl
CROSS JOIN cteCurrIDs currId
WHERE NOT EXISTS (
  SELECT 1 FROM workspace.ml.library_snapshots
  WHERE library_date = :my_date
)
"""
spark.sql(insert_sql, args={"my_date": dtLibDate})


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
    .withSchemaEvolution()
    .whenMatchedUpdateAll()
    .whenNotMatchedInsertAll()
    .execute()
)

# No need to save again; Delta Lake handles transactional updates in place.
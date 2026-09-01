# Databricks notebook source
# MAGIC %md
# MAGIC ## Parse plist xml file and return results in a dataframe
# MAGIC
# MAGIC At the end, we write the result data to both a delta table and a parquet table.

# COMMAND ----------

# MAGIC %md
# MAGIC ### Load the plist file into a python dictionary

# COMMAND ----------

import plistlib

with open('/Volumes/workspace/default/s3vol/lite.xml', 'r') as f:
    xml_content = f.read()
    
pldict = plistlib.loads(xml_content.encode())
pldict = pldict['Tracks']
#print(pldict)

# COMMAND ----------

# MAGIC %md
# MAGIC ### go from python dictionary to a dataframe

# COMMAND ----------

from pyspark.sql import SparkSession
import datetime
import re

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
        rec[col] = normalize_value(attrs.get(col))
    records.append(rec)

df = spark.createDataFrame(records)

# Optional: rename columns to snake_case for easier SQL querying
def snake(name):
    name = re.sub(r"[^\w]+", "_", name).strip("_")
    return name.lower()

for c in df.columns:
    df = df.withColumnRenamed(c, snake(c))

display(df)

# COMMAND ----------

#df.write.format("delta").mode("overwrite").save('/Volumes/workspace/default/s3vol/test1_delta')
df.write.format("parquet").mode("overwrite").save('/Volumes/workspace/default/s3vol/test1_parquet')
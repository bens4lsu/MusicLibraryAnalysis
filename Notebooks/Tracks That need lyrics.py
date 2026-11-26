# Databricks notebook source
# /// script
# [tool.databricks.environment]
# environment_version = "6"
# ///
# Write the cell-10 query results (tracks missing lyrics, top 100 by playcount)
# to a single parquet file: needLyrics.parquet
#
# Note: Spark's parquet writer cannot write directly into /Workspace on this
# workspace (Mkdirs failed), so collect the small LIMIT 100 result and write it
# locally with pyarrow. Requires Python-capable compute (not a SQL warehouse).

import os
import shutil

import pyarrow as pa
import pyarrow.parquet as pq

need_lyrics_df = spark.sql("""
select *
from ml.library_latest
where lyrics is null
    and (genre like '10%')
order by playcount desc
--limit 100
""")

target_file = "/Workspace/Users/ben@concordbusinessservicesllc.com/MusicLibraryAnalysis/Files/needLyrics.parquet"
tmp_file = target_file + ".tmp"

rows = [r.asDict() for r in need_lyrics_df.collect()]

pa_types = {
    "int": pa.int32(), "string": pa.string(), "date": pa.date32(), "boolean": pa.bool_(),
}
schema = pa.schema([
    pa.field(f.name, pa_types[f.dataType.simpleString()], nullable=f.nullable)
    for f in need_lyrics_df.schema.fields
])

pq.write_table(pa.Table.from_pylist(rows, schema=schema), tmp_file)
shutil.move(tmp_file, target_file)  # replaces any existing file

print(f"Wrote {len(rows)} rows to {target_file}")
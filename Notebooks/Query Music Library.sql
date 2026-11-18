-- Databricks notebook source
SELECT *
FROM ml.library_latest ll
ORDER BY library_date DESC
LIMIT 100



-- COMMAND ----------

select count(*) from ml.library_latest

-- COMMAND ----------

-- anything missing from previous?
with ctedt as (
  select distinct library_date, dense_rank() over (order by library_date desc) as R
  from ml.library_snapshots
)
select *
from ml.library_snapshots ls
join ctedt c on ls.library_date = c.library_date and 2 = c.R
where not exists (
  select 1
  from ml.library_latest ll
  where ll.persistent_id = ls.persistent_id
)

-- COMMAND ----------

-- play counts since previous snapshot

select lscurr.track_name
  , lscurr.artist
  , lscurr.album
  , lscurr.playcount  - ifnull(lsprev.playcount, 0) as num_plays
  , lscurr.library_date
  , datediff(lscurr.library_date, lsprev.library_date) as num_days
from ml.library_snapshots lscurr
inner join ml.library_snapshot_meta c on lscurr.library_snapshot_id = c.library_snapshot_id and c.RankDESC = 1
left outer join ml.library_snapshots lsprev on lscurr.persistent_id = lsprev.persistent_id 
inner join ml.library_snapshot_meta c2 on lsprev.library_snapshot_id = c2.library_snapshot_id and c2.RankDESC = 2
where lscurr.playcount > ifnull(lsprev.playcount, 0)
order by lscurr.playcount  - ifnull(lsprev.playcount, 0) desc



-- COMMAND ----------

-- DBTITLE 1,Pct of Library Per Artist
with cteAG as (
    select artist
        , count(*) as c
    from workspace.ml.library_latest
    group by artist
)
, cteRank as (
    select cteag.*
        , c / sum(c) over (partition by (select null)) as pct
        , rank() over (order by c desc) as rank
    from cteag
)
, cteMain as (
    select cter.artist
        , cter.rank
        , c
        , cter.pct * 100 as pct
        , SUM(pct) OVER (ORDER BY rank ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) * 100 as cum
    from cterank cter
    order by c desc
)
-- select * from cteMain
select rank, c, count(*) as NumArtists, max(cum) as cum from ctemain group by rank, c

-- COMMAND ----------

select min(library_snapshot_id) from ml.library_snapshot_meta where library_snapshot_id > (select max(library_snapshot_id) from ml.library_snapshot_meta where year(library_date) < year(getdate()))

-- COMMAND ----------

-- play counts this year
with cteFirstSnapshotThisYear as (
  select min(library_snapshot_id) as library_snapshot_id
  from ml.library_snapshot_meta 
  where library_snapshot_id > (
    select max(library_snapshot_id) 
    from ml.library_snapshot_meta 
    where year(library_date) < year(getdate())
  )
)
select lscurr.track_name
  , lscurr.artist
  , lscurr.album
  , lscurr.playcount  - ifnull(lsprev.playcount, 0) as num_plays
  , lscurr.library_date
  , datediff(lscurr.library_date, lsprev.library_date) as num_days
from ml.library_snapshots lscurr
inner join ml.library_snapshot_meta c on lscurr.library_snapshot_id = c.library_snapshot_id and c.RankDESC = 1
left outer join ml.library_snapshots lsprev on lscurr.persistent_id = lsprev.persistent_id 
inner join ctefirstsnapshotthisyear c2 on lsprev.library_snapshot_id = c2.library_snapshot_id 
where lscurr.playcount > ifnull(lsprev.playcount, 0)
order by lscurr.playcount  - ifnull(lsprev.playcount, 0) desc


-- COMMAND ----------

-- play counts this year
with cteFirstSnapshotThisYear as (
  select min(library_snapshot_id) as library_snapshot_id
  from ml.library_snapshot_meta 
  where library_snapshot_id > (
    select max(library_snapshot_id) 
    from ml.library_snapshot_meta 
    where year(library_date) < year(getdate())
  )
)
select lscurr.track_name
  , lscurr.artist
  , lscurr.album
  , lscurr.genre
  , lsprev.genre
  , lscurr.persistent_id
from ml.library_snapshots lscurr
inner join ml.library_snapshot_meta c on lscurr.library_snapshot_id = c.library_snapshot_id and c.RankDESC = 1
left outer join ml.library_snapshots lsprev on lscurr.persistent_id = lsprev.persistent_id 
inner join ctefirstsnapshotthisyear c2 on lsprev.library_snapshot_id = c2.library_snapshot_id 
where lscurr.genre not like '84%' 
    and lsprev.genre = 'Christmas'

-- COMMAND ----------

--select distinct library_date from ml.library_snapshots  order by library_date desc limit 1000

select * from ml.library_snapshots where library_date = '2026-10-03' and lower(artist) like 'miles%davis%'

-- COMMAND ----------

select *
from ml.library_latest
where lyrics is null
order by playcount desc
limit 100

-- COMMAND ----------

-- DBTITLE 1,Write need-lyrics tracks to needLyrics.parquet
-- MAGIC %python
-- MAGIC # Write the cell-10 query results (tracks missing lyrics, top 100 by playcount)
-- MAGIC # to a single parquet file: needLyrics.parquet
-- MAGIC #
-- MAGIC # Note: Spark's parquet writer cannot write directly into /Workspace on this
-- MAGIC # workspace (Mkdirs failed), so collect the small LIMIT 100 result and write it
-- MAGIC # locally with pyarrow. Requires Python-capable compute (not a SQL warehouse).
-- MAGIC
-- MAGIC import os
-- MAGIC import shutil
-- MAGIC
-- MAGIC import pyarrow as pa
-- MAGIC import pyarrow.parquet as pq
-- MAGIC
-- MAGIC need_lyrics_df = spark.sql("""
-- MAGIC select *
-- MAGIC from ml.library_latest
-- MAGIC where lyrics is null
-- MAGIC order by playcount desc
-- MAGIC limit 100
-- MAGIC """)
-- MAGIC
-- MAGIC target_file = "/Workspace/Users/ben@concordbusinessservicesllc.com/MusicLibraryAnalysis/Files/needLyrics.parquet"
-- MAGIC tmp_file = target_file + ".tmp"
-- MAGIC
-- MAGIC rows = [r.asDict() for r in need_lyrics_df.collect()]
-- MAGIC
-- MAGIC pa_types = {
-- MAGIC     "int": pa.int32(), "string": pa.string(), "date": pa.date32(), "boolean": pa.bool_(),
-- MAGIC }
-- MAGIC schema = pa.schema([
-- MAGIC     pa.field(f.name, pa_types[f.dataType.simpleString()], nullable=f.nullable)
-- MAGIC     for f in need_lyrics_df.schema.fields
-- MAGIC ])
-- MAGIC
-- MAGIC pq.write_table(pa.Table.from_pylist(rows, schema=schema), tmp_file)
-- MAGIC shutil.move(tmp_file, target_file)  # replaces any existing file
-- MAGIC
-- MAGIC print(f"Wrote {len(rows)} rows to {target_file}")
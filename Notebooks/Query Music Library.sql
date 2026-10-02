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
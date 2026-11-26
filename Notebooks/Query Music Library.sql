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

-- DBTITLE 1,Lyrics
select count(1)
from ml.library_latest
where checked and lyrics is  null



-- COMMAND ----------

-- DBTITLE 1,albums without years
with cte1 as (
    select album, artist, max(year) as year, count(*) as C
    from ml.library_latest
    where album != 'Top 1000 Pop Hits of the 80\'s'
    group by album, artist
) , cte2 as (
    select *
    from cte1
    where c >= 3
    and (year is null or year < 1900 or year > 2026)
)
select * from cte2

-- COMMAND ----------

-- DBTITLE 1,suggested album years
-- Suggested album years for the albums missing/invalid year data (researched 2026-11-19)
-- confidence: 'high' = well-known studio/live release; 'low' = compilation, bootleg, single, or custom recording; NULL year = could not determine
with cteSuggested(album, artist, suggested_year, confidence) as (
    values

      ('Greatest Hits','Stevie Wonder',1971,'low - compilation, year varies by edition'),
      ('Loverboy Classics:  Their Greatest Hits','Loverboy',1994,'high'),
      ('In A Soulful Mood','John Coltrane',1997,'low - posthumous compilation (32 Jazz), approx'),
      ('Back for the First Time','Ludacris',2000,'high'),
      ('Candlewyck','Candlewyck',2004,'low - self-titled debut, approx'),
      ('John Prine','John Prine',1971,'high'),
      ('New York City','Malick, Peter Group/Norah Jones',2003,'high'),
      ('How Does Your Garden Grow-','Better Than Ezra',1998,'high'),
      ('Hand on the Torch','US3',1993,'high'),
      ('Something About Airplanes','Death Cab for Cutie',1998,'high'),
      ('All That I Am','Carlos Santana',2005,'high'),
      ('Flight of the Conchords','Flight Of The Conchords',2008,'high'),
      ('Have a Little Faith','Delbert McClinton',1993,'low - approx'),
      ('Live on Tour','John Prine',1997,'medium - Oh Boy Records live album'),
      ('Summer Knights','Joey Bada$$',2013,'high - Summer Knights mixtape'),
      ('Merry Christmas Lil Mama','Chance The Rapper & Jeremih',2016,'high'),
      ('RTJ4','Run The Jewels',2020,'high'),
      ('Half-baked Serenade','Self',1997,'high'),
      ('The Globe Sessions','Sheryl Crow',1998,'high'),
      ('Another side of Bob Dylan','Bob Dylan',1964,'high'),
      ('No Fools, No Fun [Explicit]','Puss N Boots',2014,'high'),
      ('1996 World Pipe Band Championships','World Pipe Band Championships',1996,'high - year is in the title'),
      ('Buena Vista Social Club','Buena Vista Social Club',1997,'high'),
      ('The Freewheelin' || chr(39) || ' Bob Dylan','Bob Dylan',1963,'high'),
      ('RTJ3','Run The Jewels',2016,'high'),
      ('God Bless The Child','Billie Holiday',1949,'low - compilation; year varies by edition'),
      ('Flower Of Scotland','Alexander Brothers',1990,'low - Scottish folk recording, no reliable date found'),
      ('Live Through This','Hole',1994,'high'),
      ('Brand New Key','Melanie Safka',1971,'low - song is from Gather Me (1971); this looks like a compilation'),
      ('Diamonds On The Inside','Ben Harper',2003,'high'),
      ('The Missing Years','John Prine',1991,'high'),
      ('Fiyo At The Fillmore Volume 1','The Meters',1998,'medium - live compilation released 1998, recorded at the Fillmore in the mid-1970s'),
      ('Sticky Fingers','The Rolling Stones',1971,'high'),
      ('Good Single','Better Than Ezra',1993,'low - single/unidentified release'),
      ('Summerhouse (bootleg)','Better Than Ezra',1995,'low - bootleg, no reliable date found'),
      ('Natty Dread','Bob Marley & The Wailers',1974,'high'),
      ('O Brother Where Art Thou Soundrack','Soggy Bottom Boys',2000,'high - soundtrack release year'),
      ('Living in America','The Sounds',2002,'high'),
      ('The Renaissance Guitar','Frederick Noad',1964,'low - classical guitar series, approx 1960s'),
      ('They' || chr(39) || 're All Gonna Laugh at You','Adam Sandler',1993,'high'),
      ('Toys In The Attic','Aerosmith',1975,'high'),
      ('Swing Low Sweet Chariot + Uncloudy Day','The Staple Singers',1963,'low - 1950s gospel recordings, no reliable album date'),
      ('Injected','Phunk Junkeez',1995,'high'),
      ('The Soft Bulletin','The Flaming Lips',1999,'high'),
      ('John Prine Live','John Prine',1988,'high'),
      ('The Barbecue Swingers Live','Kermit Ruffins',1998,'medium'),
      ('Fashion Nugget','Cake',1996,'high'),
      ('Second Wind','Michael Reno Harrell',2000,'low - independent folk release, no reliable date found'),
      ('The Voice Of Emotion','Montserrat Figueras',1996,'low - classical recording, no reliable date found'),
      ('Dying To Say This To You','The Sounds',2006,'high'),
      ('Acid Rap','Chance The Rapper',2013,'high')
)
select s.album, s.artist, s.suggested_year, s.confidence, ll.current_year, ll.album is not null as matched
from cteSuggested s
left join (
    select album, artist, max(year) as current_year
    from ml.library_latest
    group by album, artist
) ll on ll.album = s.album and ll.artist = s.artist
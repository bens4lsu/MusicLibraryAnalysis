-- Databricks notebook source
with cteAddMatchedColumns as (
    select case when g.genre_id is not null then ll.artist end as matched_artist
        , case when g.genre_id is not null then 1 end as matched_track
        , ll.*
    from ml.library_latest ll
    left outer join ml.genre g on ll.genre = g.full_path
)
select sum(matched_track) as tracks_matched
    , count(*) as tracks_total
    , sum(matched_track) / count(*) * 100 as tracks_pct
    , count(distinct matched_artist) as artists_matched
    , count(distinct artist) as artists_total
    , count(distinct matched_artist) / count(distinct artist) * 100 as artists_pct
from cteaddmatchedcolumns

-- Databricks notebook source


create or replace table workspace.ml.temp_artist_genre_working_list as
WITH cteMain AS (
    select artist
        , genre
        , count(*) as C
        , CAST (NULL AS STRING) as new_genre
        , CAST (NULL AS STRING) AS match_type
    from workspace.ml.library_latest ll
    left outer join workspace.ml.genre g on ll.genre = g.full_path
    where 1=1
        and g.genre_id is null
        --and (lower(ll.genre) like 'rock/pop')
        and ll.genre Not in  ( 'Classical')
        --and ll.artist not in ('King Gizzard & The Lizard Wizard', 'Prince', 'Madonna', 'G. Love & Special Sauce', 'Donnie Trumpet & The Social Experiment', 'Grimes')
        and lower(ll.artist) not like 'various%'
        
        
        -- and date_added > '2026-01-01'
    group by artist, genre
    --having count(*) > 10
    order by sum(playcount) desc
    limit 500
)
select row_number() over (order by C desc) as ID
    , cte.*
from cteMain cte
;

select * from workspace.ml.temp_artist_genre_working_list order by artist asc;

-- COMMAND ----------



-- COMMAND ----------

  WITH genre_catalog AS (
    SELECT 
      `genre_id`,
      `name`,
      `description`,
      `artists`,
      `full_path`,
      `depth`
    FROM `workspace`.`ml`.`genre`
  ),
  -- Try exact artist match first
  exact_matches AS (
    SELECT DISTINCT
      w.`artist`,
      g.`full_path` AS recommended_genre,
      'exact_match' AS match_type
    FROM `workspace`.`ml`.`temp_artist_genre_working_list` w
    JOIN genre_catalog g
      ON ARRAY_CONTAINS(g.`artists`, w.`artist`)
    WHERE w.`new_genre` IS NULL
  )

select  * from exact_matches

-- COMMAND ----------

-- DBTITLE 1,Cell 4
-- Hybrid approach with single result per artist - MERGE INTO table
MERGE INTO `workspace`.`ml`.`temp_artist_genre_working_list` AS target
USING (
  WITH genre_catalog AS (
    SELECT 
      `genre_id`,
      `name`,
      `description`,
      `match_instructions`,
      `artists`,
      `full_path`,
      `depth`
    FROM `workspace`.`ml`.`genre`
    where genre_id like '40%'
  ),
  -- Try exact artist match first
  exact_matches AS (
    SELECT DISTINCT
      w.`artist`,
      g.`full_path` AS recommended_genre,
      'exact_match' AS match_type
    FROM `workspace`.`ml`.`temp_artist_genre_working_list` w
    JOIN genre_catalog g
      ON ARRAY_CONTAINS(g.`artists`, w.`artist`)
    WHERE w.`new_genre` IS NULL
  ),
  -- Build enhanced genre list with example artists for AI
  genre_list_with_artists AS (
    SELECT 
      CONCAT_WS('\n', 
        COLLECT_LIST(
          CONCAT(
            '- ', `full_path`, 
            CASE 
              WHEN `artists` IS NOT NULL THEN 
                CONCAT(' (Example artists: ', ARRAY_JOIN(`artists`, ', '), ')')
              ELSE ''
            END,
            CASE 
              WHEN `description` IS NOT NULL AND `description` != '' THEN
                CONCAT(': ', 
                  CASE 
                    WHEN LENGTH(`description`) > 150 
                    THEN CONCAT(SUBSTRING(`description`, 1, 150), '...')
                    ELSE `description`
                  END
                )
              ELSE ''
            END
          )
        )
      ) AS all_genres
    FROM genre_catalog
    WHERE (`description` IS NOT NULL AND `description` != '') 
       OR `artists` IS NOT NULL
  ),
  -- Get list of artists that need AI classification (no exact match)
  artists_needing_ai AS (
    SELECT DISTINCT w.`artist`
    FROM `workspace`.`ml`.`temp_artist_genre_working_list` w
    WHERE w.`new_genre` IS NULL
      AND NOT EXISTS (
        SELECT 1 FROM exact_matches e WHERE e.`artist` = w.`artist`
      )
  ),
  -- Use AI only for artists without exact matches
  ai_recommendations AS (
    SELECT 
      a.`artist`,
      ai_query(
        'databricks-meta-llama-3-3-70b-instruct',
        CONCAT(
          'You are a music genre expert. Classify the artist "', a.`artist`, '" into the SINGLE BEST genre from the list below.\n\n',
          'Instructions:\n',
          '- Base your decision on the artist''s PRIMARY musical style and era\n',
          '- Use the example artists in each genre as strong indicators of fit\n',
          '- Consider the genre descriptions for additional context\n',
          '- Obey instructions in the match_instructions column\n',
          '- Do not consider genre information from ml.library_latest\n',
          '- If an artist does not seem to be a particularly good match for any of the categories, return NULL\n',
          '- Return ONLY the full_path value exactly as shown (e.g., "33.04: Jazz -> Swing")\n',
          '- Do not add any explanation or extra text\n\n',
          'Available genres:\n',
          g.all_genres
        ),
        modelParameters => named_struct('max_tokens', 150, 'temperature', 0.0)
      ) AS recommended_genre,
      'ai_match' AS match_type
    FROM artists_needing_ai a
    CROSS JOIN genre_list_with_artists g
  ),
  -- Combine both approaches (guaranteed one result per artist)
  all_recommendations AS (
    SELECT `artist`, `recommended_genre`, `match_type`
    FROM exact_matches
    UNION ALL
    SELECT `artist`, `recommended_genre`, `match_type`
    FROM ai_recommendations
  )
  SELECT 
    `artist`,
    `recommended_genre`,
    match_type
  FROM all_recommendations
) AS source
ON target.`artist` = source.`artist` AND target.`new_genre` IS NULL
WHEN MATCHED THEN
  UPDATE SET target.`new_genre` = source.`recommended_genre`, target.match_type = source.match_type;

-- COMMAND ----------

select id, artist, genre, new_genre, match_type from ml.temp_artist_genre_working_list order by id

-- COMMAND ----------

-- MAGIC %skip
-- MAGIC update ml.temp_artist_genre_working_list
-- MAGIC set match_type = 'wrong'
-- MAGIC where ID in (1,)

-- COMMAND ----------

select concat('{artistName:"',artist,'", newGenre:"',new_genre,'"}, ¬')
from ml.temp_artist_genre_working_list
where match_type != 'wrong'
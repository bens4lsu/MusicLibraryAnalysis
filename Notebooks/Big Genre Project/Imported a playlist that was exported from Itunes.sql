-- Databricks notebook source
-- DBTITLE 1,Load Music Library Data
-- MAGIC %python
-- MAGIC # Read tab-delimited UTF-16 encoded music library file
-- MAGIC df = spark.read.csv(
-- MAGIC     '/Volumes/workspace/default/s3vol/MusicLibrary/1.txt',
-- MAGIC     sep='\t',
-- MAGIC     header=True,
-- MAGIC     inferSchema=True,
-- MAGIC     encoding='UTF-16'
-- MAGIC )
-- MAGIC
-- MAGIC # Display the dataframe
-- MAGIC display(df)

-- COMMAND ----------

-- DBTITLE 1,Distinct Genre Values
-- MAGIC %python
-- MAGIC # Get distinct genre values
-- MAGIC distinct_genres = df.select("Genre").distinct().orderBy("Genre")
-- MAGIC
-- MAGIC # Display the results
-- MAGIC display(distinct_genres)

-- COMMAND ----------

-- DBTITLE 1,Find Genres Not in Genre Table
-- MAGIC %python
-- MAGIC # Get distinct genres from music library
-- MAGIC music_genres = df.select("Genre").distinct()
-- MAGIC
-- MAGIC # Read the genre table
-- MAGIC genre_table = spark.table("workspace.ml.genre")
-- MAGIC
-- MAGIC # Find genres in music library that are NOT in the genre table's full_path column
-- MAGIC missing_genres = music_genres.join(
-- MAGIC     genre_table.select("full_path"),
-- MAGIC     music_genres["Genre"] == genre_table["full_path"],
-- MAGIC     "left_anti"
-- MAGIC ).orderBy("Genre")
-- MAGIC
-- MAGIC # Display the missing genres
-- MAGIC print(f"Genres in music library not found in genre table: {missing_genres.count()}")
-- MAGIC display(missing_genres)

-- COMMAND ----------

-- DBTITLE 1,Show Genre Starting with 9
-- MAGIC %python
-- MAGIC # Filter to show entries where Genre starts with '9'
-- MAGIC df.filter(df.Genre.startswith('9')).display()
-- Databricks notebook source
select distinct artist, track_name, album
from ml.library_latest 
where lower(genre) = 'classical'

-- COMMAND ----------

-- MAGIC %python
-- MAGIC from pyspark.sql import SparkSession
-- MAGIC from pyspark.sql.types import StructType, StructField, StringType
-- MAGIC
-- MAGIC # Initialize Spark Session
-- MAGIC spark = SparkSession.builder \
-- MAGIC     .appName("ClassicalMusicTaxonomy") \
-- MAGIC     .getOrCreate()
-- MAGIC
-- MAGIC # Define explicit schema
-- MAGIC schema = StructType([
-- MAGIC     StructField("artist", StringType(), True),
-- MAGIC     StructField("classical_subgenre", StringType(), True)
-- MAGIC ])
-- MAGIC
-- MAGIC # Artist taxonomy data
-- MAGIC data = [
-- MAGIC     ("Alfred Sommer & Dieter Goldmann", "Chamber Music"),
-- MAGIC     ("Amilcare Ponchielli", "Romantic"),
-- MAGIC     ("Andrés Segovia", "Classical Guitar"),
-- MAGIC     ("Antonin Dvorak", "Romantic"),
-- MAGIC     ("Antonio Vivaldi", "Baroque"),
-- MAGIC     ("Aphex Twin", "Modern Classical / Ambient Classical"),
-- MAGIC     ("Aaron Copland", "20th Century / Modern Classical"),
-- MAGIC     ("Arto Noras, Slovak Chamber Orchestra and Bohdan Warchal", "Chamber Music"),
-- MAGIC     ("Baden-Baden Symphony Orchestra and Werner Stiefel", "Orchestral"),
-- MAGIC     ("Bangkok Guitar Society", "Classical Guitar"),
-- MAGIC     ("Barcelona Symphony Orchestra and National Orchestra of Catalonia", "Orchestral"),
-- MAGIC     ("Béla Bartók", "20th Century / Modern Classical"),
-- MAGIC     ("Benedictine Monks of Santo Domingo de Silos", "Medieval / Gregorian Chant"),
-- MAGIC     ("Benedetto Marcello", "Baroque"),
-- MAGIC     ("Bengt Ericson and Karin Langebo", "Chamber Music"),
-- MAGIC     ("Benjamin Britten", "20th Century / Modern Classical"),
-- MAGIC     ("Berlioz Debussy", "Romantic / Impressionism"),
-- MAGIC     ("Berlin Philharmonic Wind Quintet", "Chamber Music"),
-- MAGIC     ("Bedrich Smetana", "Romantic"),
-- MAGIC     ("Boris Karloff, Mario Rossi & Wiener Opernorchester", "Orchestral / Spoken Word Classical"),
-- MAGIC     ("Camille Saint-Saëns", "Romantic"),
-- MAGIC     ("Christoph Henkel and Elisabeth Westenholz", "Chamber Music"),
-- MAGIC     ("Claude Le Jeune", "Renaissance"),
-- MAGIC     ("Collegium Vocale Koln - Wolfgang Fromme", "Choral / Early Music"),
-- MAGIC     ("Dan Schultz", "Contemporary Classical"),
-- MAGIC     ("David Schittner and Zagreb Soloists", "Chamber Music"),
-- MAGIC     ("Déodat de Séverac", "Impressionism / Post-Romantic"),
-- MAGIC     ("Die 12 Cellisten Der Berliner Philharmoniker", "Cello Ensemble / Modern Classical"),
-- MAGIC     ("Dmitri Shostakovich", "20th Century / Modern Classical"),
-- MAGIC     ("Elemér Lavotha and Kerstin Åberg", "Chamber Music"),
-- MAGIC     ("Elemér Lavotha, Kalmar County Chamber Orchestra and Jan-Olav Wedin", "Chamber Music"),
-- MAGIC     ("Escolania de Nuestra Señora del Buen Retiro", "Sacred / Choral"),
-- MAGIC     ("Felix Mendelssohn", "Romantic"),
-- MAGIC     ("Françoise Groben and Alfredo Perl", "Chamber Music"),
-- MAGIC     ("Frans Helmerson", "Chamber Music"),
-- MAGIC     ("Frans Helmerson and Hans Pålsson", "Chamber Music"),
-- MAGIC     ("Frans Helmerson, Gothenburg Symphony Orchestra and Neeme Järvi", "Orchestral"),
-- MAGIC     ("Frederick Noad", "Classical Guitar"),
-- MAGIC     ("Gabriel Fauré", "Romantic"),
-- MAGIC     ("George Frideric Händel", "Baroque"),
-- MAGIC     ("George Frideric Handel", "Baroque"),
-- MAGIC     ("George Philipp Telemann", "Baroque"),
-- MAGIC     ("Georges Bizet", "Romantic"),
-- MAGIC     ("Georges Cziffra", "Romantic / Virtuoso Piano"),
-- MAGIC     ("Giacomo Puccini", "Opera / Late Romantic"),
-- MAGIC     ("Gioachino Rossini", "Operatic / Romantic"),
-- MAGIC     ("Giuseppe Verdi", "Operatic / Romantic"),
-- MAGIC     ("Glenn Gould", "Baroque / Classical Piano"),
-- MAGIC     ("Guido Schiefen", "Chamber Music"),
-- MAGIC     ("Guido Schiefen and Günter Ludwig", "Chamber Music"),
-- MAGIC     ("Gustav Mahler", "Late Romantic"),
-- MAGIC     ("Helmut Koch", "Choral / Baroque"),
-- MAGIC     ("Henry Purcell", "Baroque"),
-- MAGIC     ("Hidemi Suzuki and Bach Collegium Japan", "Early Music / Period Performance"),
-- MAGIC     ("Hidemi Suzuki, Van Wassenaer Orchestra and Makoto Akatsu", "Baroque / Period Performance"),
-- MAGIC     ("Igor Stravinsky", "20th Century / Modern Classical"),
-- MAGIC     ("Jacques Offenbach", "Romantic / Operetta"),
-- MAGIC     ("Jean-Joseph Mouret", "Baroque"),
-- MAGIC     ("Johann Fux", "Baroque"),
-- MAGIC     ("Johann Joachim Quantz", "Baroque"),
-- MAGIC     ("Johann Pachelbel", "Baroque"),
-- MAGIC     ("Johann Sebastian Bach", "Baroque"),
-- MAGIC     ("Johannes Brahms", "Romantic"),
-- MAGIC     ("John Dowland", "Renaissance"),
-- MAGIC     ("John Williams", "Film Score / Contemporary Classical"),
-- MAGIC     ("Joaquin Rodrigo", "20th Century Classical / Classical Guitar"),
-- MAGIC     ("Jörg Metzger & Dieter Goldmann", "Chamber Music"),
-- MAGIC     ("Joshua Bell", "Virtuoso Violin / Romantic & Modern"),
-- MAGIC     ("Julian Bream", "Classical Guitar / Early Music"),
-- MAGIC     ("Kaori Muraji", "Classical Guitar"),
-- MAGIC     ("Kathleen Battle & Christopher Parkening", "Vocal Classical / Classical Guitar"),
-- MAGIC     ("Kirstin von der Goltz, Ute Zimmermannn, Conrad von der Goltz Chamber Orchestra and Conrad von der Goltz", "Chamber Music"),
-- MAGIC     ("Leopold Stokowski", "Orchestral / Late Romantic"),
-- MAGIC     ("Leoš Janáček", "20th Century / Modern Classical"),
-- MAGIC     ("London Philharmonic Orchestra", "Orchestral"),
-- MAGIC     ("London Philharmonic Orchestra & David Parry", "Orchestral"),
-- MAGIC     ("L'Orchestre de la Suisse Romande and Ernest Ansermet", "Orchestral"),
-- MAGIC     ("Lorand Fenyves & L'Orchestre de la Suisse Romande & Ernest Ansermet", "Orchestral / Violin Concerto"),
-- MAGIC     ("Louis Vierne", "Late Romantic / Organ Classical"),
-- MAGIC     ("Louisiana Youth Orchestras", "Orchestral"),
-- MAGIC     ("Luciano Pavarotti", "Opera / Vocal Classical"),
-- MAGIC     ("Ludwig van Beethoven", "Classical (Era) / Romantic Transition"),
-- MAGIC     ("Luigi Boccherini", "Classical (Era)"),
-- MAGIC     ("Make a Joyful Noise", "Sacred / Choral"),
-- MAGIC     ("Markus Stocker and Viktor Yampolsky", "Chamber Music"),
-- MAGIC     ("Martin Ostertag, SWR Symphony Orchestra and Michael Boder", "Orchestral / Modern Classical"),
-- MAGIC     ("Modest Mussorgsky", "Romantic"),
-- MAGIC     ("Montserrat Figueras", "Early Music / Renaissance & Medieval"),
-- MAGIC     ("Motet de Genève & L'Orchestre de la Suisse Romande & Ernest Ansermet", "Choral / Orchestral"),
-- MAGIC     ("Naoto u. Eriko Yamamoto", "Chamber Music"),
-- MAGIC     ("Natalia Gutman, Latvian Philharmonic Orchestra and Tovijs Lifsics", "Orchestral / Cello Concerto"),
-- MAGIC     ("Nikolai Schneider, KHG Symphony Orchestra and Joel Jenny", "Orchestral"),
-- MAGIC     ("Orphei Drängar", "Choral / Male Choir"),
-- MAGIC     ("Orquesta Sinfónica de la RTV Española", "Orchestral"),
-- MAGIC     ("Pepe Romero", "Classical Guitar"),
-- MAGIC     ("Pyotr Ilyich Tchaikovsky", "Romantic"),
-- MAGIC     ("Richard Wagner", "Opera / Romantic"),
-- MAGIC     ("Robert Cohen and Roberte Mamou", "Chamber Music"),
-- MAGIC     ("Sergei Prokofiev", "20th Century / Modern Classical"),
-- MAGIC     ("Saskia Viersen, Quirine Viersen, Berliner Symphoniker and Eduardo Marturet", "Orchestral / Chamber"),
-- MAGIC     ("St. Paul's Cathedral Choir", "Sacred / Choral"),
-- MAGIC     ("Steve Smith", "Contemporary Classical / Crossover"),
-- MAGIC     ("Stockholm Chamber Duo", "Chamber Music"),
-- MAGIC     ("Tanya & Dorise", "Classical Guitar / Instrumental Crossover"),
-- MAGIC     ("The Three Tenors", "Opera / Vocal Classical"),
-- MAGIC     ("The Vocal Majority", "Choral"),
-- MAGIC     ("Torleif Thedéen and Roland Pöntinen", "Chamber Music"),
-- MAGIC     ("Torleif Thedéen, Malmö Symphony Orchestra and Lev Markiz", "Orchestral"),
-- MAGIC     ("Torleif Thedéen, Tapiola Sinfonietta and Jean-Jacques Kantorow", "Orchestral / Chamber"),
-- MAGIC     ("Valentin Feygin, Moscow Conservatory Chamber Orchestra and Mikhail Teriyan", "Chamber Music"),
-- MAGIC     ("Various Artists", "Compilation / Various"),
-- MAGIC     ("Various Artists, Strauss Orchestra Vienna, Joseph Francek", "Light Classical / Viennese Waltz"),
-- MAGIC     ("Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", "Light Classical / Viennese Waltz"),
-- MAGIC     ("Vaughan Williams", "20th Century / English Pastoral Classical"),
-- MAGIC     ("Victor Simon, Moscow Radio Symphony Orchestra and Gennady Rozhdestvensky", "Orchestral"),
-- MAGIC     ("Victor Simon, Moscow Radio Symphony Orchestra and Vladimir Fedoseyev", "Orchestral"),
-- MAGIC     ("Victor Yoran", "Chamber Music / Cello"),
-- MAGIC     ("William Bolcom", "20th Century / Modern Classical / Ragtime Classical"),
-- MAGIC     ("Wolfgang Amadeus Mozart", "Classical (Era)"),
-- MAGIC     ("Yo-Yo Ma", "Chamber Music / Virtuoso Cello")
-- MAGIC ]
-- MAGIC
-- MAGIC # Create PySpark DataFrame
-- MAGIC df = spark.createDataFrame(data, schema=schema)
-- MAGIC
-- MAGIC # Inspect the output
-- MAGIC display(df)

-- COMMAND ----------

-- MAGIC %python
-- MAGIC df.write.mode("overwrite").saveAsTable("workspace.ml.temp_classical")

-- COMMAND ----------

update workspace.ml.temp_classical
set update_genre = 'Contemporary Classical'
where artist = 'Steve Smith'
--where update_genre is null
--    and lower(classical_subgenre) like '%renaissance%'

-- COMMAND ----------

select * 
from workspace.ml.temp_classical
where update_genre is null

-- COMMAND ----------

update ml.temp_classical set update_genre = 'Classical (Era)' where update_genre = 'Classical'

-- COMMAND ----------

select artist, update_genre, full_path,
    CONCAT ('{artistName: "', artist, '", newGenre: "', full_path, '"}, ¬')
from workspace.ml.temp_classical tc
left outer join workspace.ml.genre g on tc.update_genre = g.name
where update_genre is not null
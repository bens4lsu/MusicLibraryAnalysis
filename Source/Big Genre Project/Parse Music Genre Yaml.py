# Databricks notebook source
# DBTITLE 1,Load genre.yaml to DataFrame
import yaml
import pandas as pd

# Read the YAML file
with open('/Volumes/workspace/default/s3vol/MusicLibrary/genre.yaml', 'r') as file:
    genre_data = yaml.safe_load(file)

# Convert to DataFrame
# Assuming the YAML contains a list of records or a dict that can be converted
if isinstance(genre_data, list):
    df = pd.DataFrame(genre_data)
else:
    # If it's a dict, convert to DataFrame
    df = pd.DataFrame([genre_data])

print(f"Loaded {len(df)} rows")
# display(df.head(10))

# COMMAND ----------

# DBTITLE 1,Infer parent/child relationships from genre_id
# Function to extract parent genre_id from hierarchical genre_id
def get_parent_genre_id(genre_id):
    """
    Extract parent genre_id from hierarchical genre_id.
    e.g., '10.01.01' -> '10.01', '10.01' -> '10', '10' -> None
    """
    if pd.isna(genre_id) or genre_id is None:
        return None
    
    genre_id_str = str(genre_id)
    
    # If there's a dot, the parent is everything before the last dot
    if '.' in genre_id_str:
        parent = genre_id_str.rsplit('.', 1)[0]
        return parent
    else:
        # Top-level genre has no parent
        return None

# Apply the function to populate parent_genre_id
df['parent_genre_id'] = df['genre_id'].apply(get_parent_genre_id)

# Display results showing the hierarchy with description and artists
# print("\n📊 Parent/Child Relationships:")
# print("="*80)
# display(df[['genre_id', 'name', 'parent_genre_id', 'year_emerged', 'description', 'artists']].head(20))

# Show some statistics
print(f"\n✅ Total genres: {len(df)}")
print(f"✅ Top-level genres (no parent): {df['parent_genre_id'].isna().sum()}")
print(f"✅ Child genres: {df['parent_genre_id'].notna().sum()}")

# Show hierarchy depth distribution
df['depth'] = df['genre_id'].apply(lambda x: len(str(x).split('.')) if pd.notna(x) else 0)
print("\n📈 Hierarchy Depth Distribution:")
print(df['depth'].value_counts().sort_index())

# COMMAND ----------

# DBTITLE 1,Build full hierarchical name path
# Create a lookup dictionary for fast name retrieval by genre_id
genre_lookup = df.set_index('genre_id')['name'].to_dict()

def get_full_path(genre_id, visited=None):
    """
    Recursively build the full hierarchical path from root to current genre.
    Returns a string like "Rock -> Early Rock 'N' Roll -> Skiffle (Revival)"
    """
    if visited is None:
        visited = set()
    
    # Prevent infinite loops in case of circular references
    if genre_id in visited:
        return "[Circular Reference]"
    
    if pd.isna(genre_id) or genre_id not in genre_lookup:
        return ""
    
    visited.add(genre_id)
    
    # Get current genre name
    current_name = genre_lookup[genre_id]
    
    # Get parent genre_id
    parent_id = df[df['genre_id'] == genre_id]['parent_genre_id'].iloc[0]
    
    # Base case: no parent (top-level genre)
    if pd.isna(parent_id):
        return current_name
    
    # Recursive case: get parent path and append current
    parent_path = get_full_path(parent_id, visited.copy())
    return f"{parent_path} -> {current_name}"

# Apply the function to create the full path column
df['full_path'] = df['genre_id'] + ': ' + df['genre_id'].apply(lambda x: get_full_path(x))

# Display results with year, description, and artists
print("\n🌳 Full Hierarchical Paths:")
print("="*80)
display(df[['genre_id', 'name', 'full_path', 'year_emerged', 'description', 'artists']].head(20))

# Show some examples at different depths
print("\n📍 Example Paths by Depth:")
for depth in sorted(df['depth'].unique()):
    example = df[df['depth'] == depth].iloc[0]
    print(f"\nDepth {depth}: {example['full_path']}")

# COMMAND ----------

display(df)

# COMMAND ----------

# DBTITLE 1,Enrich artists from library_Latest
from pyspark.sql import functions as F

# Read the library table
library_df = spark.table("workspace.ml.library_Latest")

# Get unique artists per genre from the library
library_artists = library_df.select("artist", "genre") \
    .filter("artist IS NOT NULL AND genre IS NOT NULL") \
    .groupBy("genre") \
    .agg(F.collect_set("artist").alias("library_artists"))

# Convert to pandas for easier manipulation
library_artists_pd = library_artists.toPandas()

# Create a lookup dictionary: genre -> list of artists from library
library_lookup = dict(zip(library_artists_pd['genre'], library_artists_pd['library_artists']))

print(f"Found {len(library_lookup)} unique genres in library_Latest")

# Function to merge artists lists, keeping unique values
def merge_artists(existing_artists, full_path):
    """
    Merge existing artists array with artists from library that match the full_path.
    Returns a unique sorted list.
    """
    # Start with existing artists (from YAML)
    if existing_artists is None:
        merged = []
    elif isinstance(existing_artists, list):
        merged = list(existing_artists)
    else:
        # Handle numpy arrays, strings, or other types
        try:
            merged = list(existing_artists)
        except:
            merged = []
    
    # Add artists from library if genre matches
    if full_path in library_lookup:
        library_artists = library_lookup[full_path]
        merged.extend(library_artists)
    
    # Return unique sorted list
    return sorted(list(set(merged))) if merged else None

# Apply the merge function
df['artists'] = df.apply(lambda row: merge_artists(row['artists'], row['full_path']), axis=1)

# Show statistics
total_genres = len(df)
genres_with_artists = df['artists'].notna().sum()
genres_enriched = df.apply(lambda row: row['full_path'] in library_lookup, axis=1).sum()

print(f"\n✅ Enrichment Statistics:")
print(f"   Total genres: {total_genres}")
print(f"   Genres with artists (after enrichment): {genres_with_artists}")
print(f"   Genres found in library_Latest: {genres_enriched}")

# Show some examples of enriched genres
print(f"\n🎵 Example Enriched Genres:")
print("="*80)
examples = df[df['artists'].notna()].head(10)
for _, row in examples.iterrows():
    artist_count = len(row['artists']) if row['artists'] else 0
    print(f"\n{row['name']} ({row['genre_id']})")
    print(f"  Artists ({artist_count}): {', '.join(row['artists'][:5]) if row['artists'] else 'None'}{'...' if artist_count > 5 else ''}")

display(df[['genre_id', 'name', 'full_path', 'artists']].head(20))

# COMMAND ----------

# DBTITLE 1,Save to workspace.ml.genre table
# Convert pandas DataFrame to Spark DataFrame
spark_df = spark.createDataFrame(df)

# Write to Unity Catalog table
table_name = "workspace.ml.genre"

print(f"💾 Writing {len(df)} records to {table_name}...")

# Write the table (overwrite mode to replace if exists)
spark_df.write \
    .mode("overwrite") \
    .option("overwriteSchema", "true") \
    .saveAsTable(table_name)

print(f"✅ Successfully saved to {table_name}")

# Verify the table was created
result = spark.sql(f"SELECT COUNT(*) as count FROM {table_name}").collect()
print(f"✅ Table contains {result[0]['count']} rows")

# Show table schema
print(f"\n📋 Table Schema:")
spark.sql(f"DESCRIBE {table_name}").show(truncate=False)

# COMMAND ----------

# MAGIC %sql
# MAGIC select genre_id, name, full_path, year_emerged, description, artists from workspace.ml.genre
# MAGIC order by genre_id
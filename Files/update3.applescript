-- Apple Music Genre Updater with Embedded Data
-- Automatically skips records where match_type = "wrong"

-- Initialize counters
set updateCount to 0
set notFoundCount to 0
set errorLog to {}

-- Artist data embedded directly
set artistData to {Â
	{artist:"Various Artists", title:"String Quartet No. 1 in D major, Op. 11: Andante", genre:"80.11: Classical -> Chamber Music"}, Â
	{artist:"John Williams", title:"Township Kwela", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Voices Of Spring Waltz, Op.410", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Boris Karloff, Mario Rossi & Wiener Opernorchester", title:"Lieutenant KijŽ Suite Symphonique, Op. 60: II. Romance", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Boris Karloff, Mario Rossi & Wiener Opernorchester", title:"Peter and the Wolf, Op. 67: XII. The Hunters Arrive", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Fanfare and Pursuit", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Echoes", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Vaughan Williams", title:"Serenade to Music", genre:"80.08: Classical -> Choral"}, Â
	{artist:"Orquesta Sinf—nica de la RTV Espa–ola", title:"Los Improperios - Popule meus", genre:"80.08: Classical -> Choral"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Cagliostro In Vienna: Overture", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Where The Lemon Trees Blossom Waltz, Op.364", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Boris Karloff, Mario Rossi & Wiener Opernorchester", title:"Peter and the Wolf, Op. 67: I. Introduction", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Boris Karloff, Mario Rossi & Wiener Opernorchester", title:"Peter and the Wolf, Op. 67: XIII. The Procession to the Zoo", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Mendelssohn Piano Concerto No 2", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Franz Schubert", title:"8th Symphony - Allegro Moderato", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Tales From The Vienna Woods Waltz, Op.325", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"Feuerfest Polka Polka, Op.269", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Torleif ThedŽen, Malmš Symphony Orchestra and Lev Markiz", title:"Concerto in E Minor for Cello and Orchestra, Op. 85: III. Adagio", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Boris Karloff, Mario Rossi & Wiener Opernorchester", title:"Peter and the Wolf, Op. 67: X. The Bird Diverts the Wolf", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Franz Schubert", title:"Welser-mšst -  1126220237", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists", title:"Berceuse for piano in D flat major, Op. 57, CT. 7", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Vaughan Williams", title:"Five Mystical Songs: I Easter", genre:"80.08: Classical -> Choral"}, Â
	{artist:"Orquesta Sinf—nica de la RTV Espa–ola", title:"De Profundis - De profundis clamavi", genre:"80.08: Classical -> Choral"}, Â
	{artist:"Orquesta Sinf—nica de la RTV Espa–ola", title:"Los Improperios - Preludio", genre:"80.08: Classical -> Choral"}, Â
	{artist:"Orquesta Sinf—nica de la RTV Espa–ola", title:"Los Improperios - Crucem tuam adoramus, domine", genre:"80.08: Classical -> Choral"}, Â
	{artist:"John Williams", title:"Masanga", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"John Williams", title:"Musha Musiki", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"John Williams", title:"Djandjon", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"John Williams", title:"Domeniconi: Koyunbaba, part 3", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"Nikolai Schneider, KHG Symphony Orchestra and Joel Jenny", title:"Concerto in B Minor for Cello and Orchestra, Op. 104: I. Allegro", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Dance of the Tumblers", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Concerto for Mirimba and Orchestra", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Okeanos", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Light Cavalry Overture", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Selections from Les Miserables", genre:"72: Musical Theater and Soundtracks"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Happy Hoedown", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Franz Schubert", title:"Welser-mšst -  1126220322", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists", title:"Canon and Gigue for 3 violins & continuo in D major: Canon in D major", genre:"80.03: Classical -> Baroque"}, Â
	{artist:"Orquesta Sinf—nica de la RTV Espa–ola", title:"Los Improperios - Hagios o Theos - Sancte Deus", genre:"80.08: Classical -> Choral"}, Â
	{artist:"John Williams", title:"Malinke Guitars", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"PlappermŠulchen, Op.245", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Victor Simon, Moscow Radio Symphony Orchestra and Vladimir Fedoseyev", title:"Concerto in A Minor for Cello and Orchestra, Op. 129: I. Nicht zu schnell (attacca)", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"Sounds Of Mary Waltz, Op.214", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Boris Karloff, Mario Rossi & Wiener Opernorchester", title:"Peter and the Wolf, Op. 67: VI. The Wolf", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Boris Karloff, Mario Rossi & Wiener Opernorchester", title:"Peter and the Wolf, Op. 67: VIII. The Wolf Stalks the Bird and Cat", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Louisiana Youth Orchestras", title:"A Cypress Prelude", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Lorand Fenyves & L'Orchestre de la Suisse Romande & Ernest Ansermet", title:"Rimsky-Korsakov: Scheherazade, Op.35 - The Young Prince and the Young Princess", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Lorand Fenyves & L'Orchestre de la Suisse Romande & Ernest Ansermet", title:"Rimsky-Korsakov: Scheherazade, Op.35 - Festival at Bagdad - The Sea - The Shipwreck against a rock surmounted by a bronze warrior (The Shipwreck)", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists", title:"Grand Jeu", genre:"80.03: Classical -> Baroque"}, Â
	{artist:"John Williams", title:"O Bia", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"John Williams", title:"Anon: Ductia", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"Egypt March, Op.335", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Treasure Waltz (from The Gypsy Baron), Op.418", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Lorand Fenyves & L'Orchestre de la Suisse Romande & Ernest Ansermet", title:"Rimsky-Korsakov: Scheherazade, Op.35 - The Sea and Sinbad's Ship", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Vaughan Williams", title:"Five Mystical Songs: II I got me flowers", genre:"80.08: Classical -> Choral"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Die Fledermaus: Overture", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Accelerations Waltz, Op. 234", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Eljen a Magyar, Op.332", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Steven Isserlis and Stephen Hough", title:"Minuet in E Major, Op. 13", genre:"80.04: Classical -> Classical (Era)"}, Â
	{artist:"Various Artists", title:"MŽditation, violin & orchestra version and various arrangements (from opera 'ThŠis'): Meditation", genre:"80.10: Classical -> Opera"}, Â
	{artist:"Various Artists", title:"Peer Gynt Suite for orchestra (or piano or piano, 4 hands) No. 2, Op. 55: Solveig's Song", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"John Williams", title:"Anon: Saltarello", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Thunder and Lightning, Polka Op.324", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Torleif ThedŽen, Malmš Symphony Orchestra and Lev Markiz", title:"Concerto in E Minor for Cello and Orchestra, Op. 85: I. Adagio - Moderato", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"L'Orchestre de la Suisse Romande and Ernest Ansermet", title:"Rimsky-Korsakov: Sadko, Op.5 - A Musical Picture", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Franz Schubert", title:"Welser-mšst -  1126215724", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Orquesta Sinf—nica de la RTV Espa–ola", title:"Lamentaci—n-Jerusalen convertere", genre:"80.08: Classical -> Choral"}, Â
	{artist:"Orquesta Sinf—nica de la RTV Espa–ola", title:"Los Improperios - Sanctus Deus", genre:"80.08: Classical -> Choral"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"Delirien Waltz, Op.212", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"Frauenherz Polka, Op.166", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Torleif ThedŽen, Malmš Symphony Orchestra and Lev Markiz", title:"Concerto in E Minor for Cello and Orchestra, Op. 85: II. Allegro molto", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Victor Simon, Moscow Radio Symphony Orchestra and Vladimir Fedoseyev", title:"Concerto in A Minor for Cello and Orchestra, Op. 129: II. Langsam (attacca)", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Boris Karloff, Mario Rossi & Wiener Opernorchester", title:"Peter and the Wolf, Op. 67: IX. Peter Prepares to Catch the Wolf", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Nutcracker Suite", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Louisiana Youth Orchestras", title:"As Summer Was Just Beginning", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Various Artists", title:"La plus que lente, waltz for piano (or orchestra), L. 121", genre:"80.06: Classical -> Modern"}, Â
	{artist:"London Philharmonic Orchestra", title:"Brain Damage", genre:"10.02.06: Rock -> Golden Age/Classic Rock -> Progressive Rock, Art Rock, & Symphonic Rock"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"The Gypsy Baron: Overture", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Victor Simon, Moscow Radio Symphony Orchestra and Gennady Rozhdestvensky", title:"Concerto in A Minor for Cello and Orchestra, Op. 22: I. Allegro moderato", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Nikolai Schneider, KHG Symphony Orchestra and Joel Jenny", title:"Concerto in B Minor for Cello and Orchestra, Op. 104: II. Adagio ma non troppo", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Orquesta Sinf—nica de la RTV Espa–ola", title:"Los Improperios - Ego propter te flagellavi", genre:"80.08: Classical -> Choral"}, Â
	{artist:"John Williams", title:"Triangular Situations", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"John Williams", title:"Domeniconi: Koyunbaba, part 1", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"John Williams", title:"Albniz (I): Mallorca, barcarola for piano in F sharp minor, Op. 202, B 41", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"London Philharmonic Orchestra", title:"Breathe in the Air", genre:"10.02.06: Rock -> Golden Age/Classic Rock -> Progressive Rock, Art Rock, & Symphonic Rock"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"Bahn frei!, Polka Op.45", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"The Gypsy Baron: March", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"My Life Is Love And Pleasure, Op.263", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Victor Simon, Moscow Radio Symphony Orchestra and Vladimir Fedoseyev", title:"Variations on a Rococo Theme for Cello and Orchestra, Op. 33: Theme and Variations", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Torleif ThedŽen, Malmš Symphony Orchestra and Lev Markiz", title:"Concerto in E Minor for Cello and Orchestra, Op. 85: IV. Allegro, ma non troppo", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Moonlight Tango", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Orquesta Sinf—nica de la RTV Espa–ola", title:"Lamentaci—n-Facti sunt hostes", genre:"80.08: Classical -> Choral"}, Â
	{artist:"Orquesta Sinf—nica de la RTV Espa–ola", title:"De Profundis - Si iniquitates", genre:"80.08: Classical -> Choral"}, Â
	{artist:"John Williams", title:"Satie: Gymnopedie #3", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"John Williams", title:"Williams: Aeolian Suite - Toccata", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"John Williams", title:"Houghton: StŽlŽ - StŽlŽ", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"Lagoon Waltz, Op.411", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Hidemi Suzuki and Bach Collegium Japan", title:"Concerto in A Minor for Cello and Strings, Wq. 170: II. Andante", genre:"80.04: Classical -> Classical (Era)"}, Â
	{artist:"Franz Schubert", title:"Welser-mšst -  1126220044", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Vaughan Williams", title:"Five Mystical Songs: V Antiphon", genre:"80.08: Classical -> Choral"}, Â
	{artist:"John Williams", title:"Williams: Aeolian Suite - Double Dance", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"John Williams", title:"Tarrega: Recuerdos de la Alhambra", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"John Williams", title:"Satie: Gnossienne #1", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"Enjoy Your Life Waltz", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Selections from Phantom fo the Opera", genre:"72: Musical Theater and Soundtracks"}, Â
	{artist:"Various Artists", title:"Servus tuus,offertory", genre:"80.08: Classical -> Choral"}, Â
	{artist:"Vaughan Williams", title:"Flos Campi", genre:"80.06: Classical -> Modern"}, Â
	{artist:"John Williams", title:"Theodorakis: Epitafios 3", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"London Philharmonic Orchestra", title:"Us and Them", genre:"10.02.06: Rock -> Golden Age/Classic Rock -> Progressive Rock, Art Rock, & Symphonic Rock"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"Sounds Of The Spheres, Waltz Op.235", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Boris Karloff, Mario Rossi & Wiener Opernorchester", title:"Lieutenant KijŽ Suite Symphonique, Op. 60: V. Burial of KijŽ", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Brazilian Myths", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Two Canons", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Lorand Fenyves & L'Orchestre de la Suisse Romande & Ernest Ansermet", title:"Rimsky-Korsakov: Scheherazade, Op.35 - The Story of the Calender Prince", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Franz Schubert", title:"Welser-mšst -  1126215905", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Vaughan Williams", title:"Fantasia on Christmas Carols", genre:"84: Christmas"}, Â
	{artist:"Orquesta Sinf—nica de la RTV Espa–ola", title:"Lamentaci—n-Incipit Lamentatio Jeremiae profhetae", genre:"80.08: Classical -> Choral"}, Â
	{artist:"John Williams", title:"Cardillo: Core 'Ngrato", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Loreley-Rhein Chimes Waltz, Op.154", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Annenpolka, Op.117", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"Carmen Quadrille, Op.134", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"Champagner Polka, Op.211", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"Jockey Polka, Op.245", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Victor Simon, Moscow Radio Symphony Orchestra and Gennady Rozhdestvensky", title:"Concerto in A Minor for Cello and Orchestra, Op. 22: III. Molto allegro e appasionata", genre:"80.06: Classical -> Modern"}, Â
	{artist:"L'Orchestre de la Suisse Romande and Ernest Ansermet", title:"Rimsky-Korsakov: The Tale of Tsar Saltan - Suite, Op.57 - 3. The Three Wonders", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Orquesta Sinf—nica de la RTV Espa–ola", title:"Lamentaci—n-Migravit Judas Propter afflictionem", genre:"80.08: Classical -> Choral"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"The Beautiful Blue Danube, Waltz Op.314", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Tritsch-Tratsch Polka, Op.214", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Steven Isserlis and Stephen Hough", title:"Song Without Words in D Major for Cello and Piano, Op. 109", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Orquesta Sinf—nica de la RTV Espa–ola", title:"De Profundis - Fiant aure tuae", genre:"80.08: Classical -> Choral"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Be United Millions Waltz, Op.364", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Hidemi Suzuki and Bach Collegium Japan", title:"Concerto in A Minor for Cello and Strings, Wq. 170: III. Allegro assai", genre:"80.04: Classical -> Classical (Era)"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Fanfare from La Perl", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Urban Hymns 1", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"L'Orchestre de la Suisse Romande and Ernest Ansermet", title:"Rimsky-Korsakov: Russian Easter Festival, Overture, Op.36", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"John Williams", title:"Guitar Makossa", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"John Williams", title:"Theodorakis: Epitafios 5", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"John Williams", title:"Houghton: StŽlŽ - Web", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"Perpetuum mobile, Op.257", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"You and you Waltz, Op.367 (from Die Fledermaus)", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Hidemi Suzuki and Bach Collegium Japan", title:"Concerto in A Major for Cello and Strings, Wq. 172: II. Largo con sordini, mesto", genre:"80.04: Classical -> Classical (Era)"}, Â
	{artist:"Boris Karloff, Mario Rossi & Wiener Opernorchester", title:"Lieutenant KijŽ Suite Symphonique, Op. 60: I. Birth of KijŽ", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Louisiana Youth Orchestras", title:"The Chair-men of the Bored", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Franz Schubert", title:"8th Symphony - Andante con moto", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"John Williams", title:"Anon: Lamento di Tristan", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Love Songs Waltz, Op. 114", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Boris Karloff, Mario Rossi & Wiener Opernorchester", title:"Peter and the Wolf, Op. 67: XI. Peter Catches the Wolf", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Variations on a Hebrew Folk Song", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"London Philharmonic Orchestra", title:"Another Brick in the Wall, Pt. 2", genre:"10.02.06: Rock -> Golden Age/Classic Rock -> Progressive Rock, Art Rock, & Symphonic Rock"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"Wine, Women and Song Waltz, Op.333", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Frans Helmerson, Gothenburg Symphony Orchestra and Neeme JŠrvi", title:"Waldesruhe (Silent Woods) for Cello and Orchestra, Op. 68: Lento e molto cantabile", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"London Philharmonic Orchestra", title:"Time [The Old Tree With Winding Roots Behind the Lake of Dreams Mix]", genre:"10.02.06: Rock -> Golden Age/Classic Rock -> Progressive Rock, Art Rock, & Symphonic Rock"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"VergnŸgungszug Polka, Op.281", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"One Night In Venice: Overture", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Village Swallows from Austria, Op.164", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Amazing Grace", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Vaughan Williams", title:"Five Mystical Songs: III Love bade me welcome", genre:"80.08: Classical -> Choral"}, Â
	{artist:"Orquesta Sinf—nica de la RTV Espa–ola", title:"Lamentaci—n-Omnes amici ejus", genre:"80.08: Classical -> Choral"}, Â
	{artist:"Orquesta Sinf—nica de la RTV Espa–ola", title:"Los Improperios - Ego te potavi", genre:"80.08: Classical -> Choral"}, Â
	{artist:"John Williams", title:"Sangara", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Emperor Waltz, Op.437", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Morning Papers, Waltz Op.279", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Victor Simon, Moscow Radio Symphony Orchestra and Gennady Rozhdestvensky", title:"Concerto in A Minor for Cello and Orchestra, Op. 22: II. Andante sostenuto", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Baden-Baden Symphony Orchestra and Werner Stiefel", title:"Symphony in One Movement, Op. 9: Allegro ma non troppo - Allegro molto - Andante tranquillo - Con moto", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Hidemi Suzuki and Bach Collegium Japan", title:"Concerto in A Major for Cello and Strings, Wq. 172: I. Allegro", genre:"80.04: Classical -> Classical (Era)"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Heart and Soul", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"L'Orchestre de la Suisse Romande and Ernest Ansermet", title:"Rimsky-Korsakov: The Tale of Tsar Saltan - Suite, Op.57 - 2. The Tsaritsa and her son afloat in the cask", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"L'Orchestre de la Suisse Romande and Ernest Ansermet", title:"Rimsky-Korsakov: Overture \"May Night\"", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists", title:"Suite for orchestra No 3 in D major, BWV 1068: Air", genre:"80.03: Classical -> Baroque"}, Â
	{artist:"Orquesta Sinf—nica de la RTV Espa–ola", title:"Los Improperios - Quia eduxi te", genre:"80.08: Classical -> Choral"}, Â
	{artist:"John Williams", title:"Nkosi Sikelel'i Afrika", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"London Philharmonic Orchestra", title:"Comfortably Numb", genre:"10.02.06: Rock -> Golden Age/Classic Rock -> Progressive Rock, Art Rock, & Symphonic Rock"}, Â
	{artist:"London Philharmonic Orchestra", title:"The Great Gig in the Sky", genre:"10.02.06: Rock -> Golden Age/Classic Rock -> Progressive Rock, Art Rock, & Symphonic Rock"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Radetzky March", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Barcelona Symphony Orchestra and National Orchestra of Catalonia", title:"Souvenirs, Ballet Suite, Op. 28: Hesitation (Tango)", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Hidemi Suzuki and Bach Collegium Japan", title:"Concerto in A Minor for Cello and Strings, Wq. 170: I. Allegro assai", genre:"80.04: Classical -> Classical (Era)"}, Â
	{artist:"Boris Karloff, Mario Rossi & Wiener Opernorchester", title:"Lieutenant KijŽ Suite Symphonique, Op. 60: IV. Troika", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Louisiana Youth Orchestras", title:"St. Anthony Chorale", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Brother James", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Festive Overture", genre:"80.06: Classical -> Modern"}, Â
	{artist:"L'Orchestre de la Suisse Romande and Ernest Ansermet", title:"Rimsky-Korsakov: The Tale of Tsar Saltan - The Flight of the Bumble-Bee", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"L'Orchestre de la Suisse Romande and Ernest Ansermet", title:"Rimsky-Korsakov: Christmas Eve - Suite", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Leichtes Blut, Polka Op.319", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"Rathausball TŠnze, Op.438", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Natalia Gutman, Latvian Philharmonic Orchestra and Tovijs Lifsics", title:"Grand Potpourri in D Major for Cello and Orchestra, Op. 20, J. 64", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Boris Karloff, Mario Rossi & Wiener Opernorchester", title:"Peter and the Wolf, Op. 67: II. The Story Begins", genre:"80.06: Classical -> Modern"}, Â
	{artist:"John Williams", title:"Theodorakis: Epitafios 4", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"John Williams", title:"Domeniconi: Koyunbaba, part 2", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"London Philharmonic Orchestra", title:"Money", genre:"10.02.06: Rock -> Golden Age/Classic Rock -> Progressive Rock, Art Rock, & Symphonic Rock"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Artist's Life Waltz, Op.316", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Vaughan Williams", title:"Five Mystical Songs: IV The call", genre:"80.08: Classical -> Choral"}, Â
	{artist:"John Williams", title:"Mitopa", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Pizzicato Polka", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"London Philharmonic Orchestra & David Parry", title:"Adagio for Strings, Op. 11a", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Hidemi Suzuki and Bach Collegium Japan", title:"Concerto in A Major for Cello and Strings, Wq. 172: III. Allegro assai", genre:"80.04: Classical -> Classical (Era)"}, Â
	{artist:"Boris Karloff, Mario Rossi & Wiener Opernorchester", title:"Peter and the Wolf, Op. 67: VII. The Duck Is Caught", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Serenade", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Roses From The South, Waltz Op.388", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"Kiss Waltz, Op.400", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"North Sea Pictures Waltz, Op.390", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Boris Karloff, Mario Rossi & Wiener Opernorchester", title:"Peter and the Wolf, Op. 67: IV. The Duck - Dialogue With the Birds - Attack of the Cat", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Boris Karloff, Mario Rossi & Wiener Opernorchester", title:"Peter and the Wolf, Op. 67: V. Grandfather", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Festive March", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Sarabande and March", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Minuet - Telemann", genre:"80.03: Classical -> Baroque"}, Â
	{artist:"Franz Schubert", title:"Welser-mšst -", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists", title:"Adagio, for violin, strings & organ in G minor (composed by Remo Giazotto; not by Albinoni), T. Mi 26", genre:"80.03: Classical -> Baroque"}, Â
	{artist:"Various Artists", title:"Peer Gynt Suite for orchestra (or piano or piano, 4 hands) No. 1, Op. 46: Morning", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"John Williams", title:"Maki", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"John Williams", title:"Omby", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Sute No 2 from the Three-Cornered Hat", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Postludes", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Concerto for Double Bass Op 3", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Theme and Variations - Feese", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"L'Orchestre de la Suisse Romande and Ernest Ansermet", title:"Rimsky-Korsakov: The Tale of Tsar Saltan - Suite, Op.57 - 1. The Tsar's departure and Farewell", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"John Williams", title:"Williams: Aeolian Suite - Aeolian Chant", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"John Williams", title:"Satie: Gnossienne #2", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Persian March, Op.289", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Celtic Dance", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Bartok Suite from \"For Children\"", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Clash and Roar", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Orquesta Sinf—nica de la RTV Espa–ola", title:"De Profundis - Et ipse redimet Israel", genre:"80.08: Classical -> Choral"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Joseph Francek", title:"Vienna Blood: Overture", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists, Strauss Orchestra Vienna, Norbert Neukamp", title:"Vienna Blood Waltz, Op.354", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Victor Simon, Moscow Radio Symphony Orchestra and Vladimir Fedoseyev", title:"Concerto in A Minor for Cello and Orchestra, Op. 129: III. Sehr lebhaft", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Various Artists", title:"Adagio for glass harmonica in C major, K. 356 (K. 617a)", genre:"80.04: Classical -> Classical (Era)"}, Â
	{artist:"Orquesta Sinf—nica de la RTV Espa–ola", title:"Lamentaci—n-Viae Sion Lugent eo", genre:"80.08: Classical -> Choral"}, Â
	{artist:"John Williams", title:"Domeniconi: Koyunbaba, part 4", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"London Philharmonic Orchestra", title:"Time", genre:"10.02.06: Rock -> Golden Age/Classic Rock -> Progressive Rock, Art Rock, & Symphonic Rock"}, Â
	{artist:"Nikolai Schneider, KHG Symphony Orchestra and Joel Jenny", title:"Concerto in B Minor for Cello and Orchestra, Op. 104: III. Finale. Allegro moderato", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Brazilian Myths", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"Various Artists", title:"Adagietto, for orchestra (from the Symphony No.5): Adagio", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"Franz Schubert", title:"Welser-mšst -  1126220141", genre:"80.05: Classical -> Romantic"}, Â
	{artist:"John Williams", title:"Engome", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"John Williams", title:"The Magic Box", genre:"80.09: Classical -> Classical Guitar"}, Â
	{artist:"London Philharmonic Orchestra", title:"Nobody Home", genre:"10.02.06: Rock -> Golden Age/Classic Rock -> Progressive Rock, Art Rock, & Symphonic Rock"}, Â
	{artist:"Boris Karloff, Mario Rossi & Wiener Opernorchester", title:"Lieutenant KijŽ Suite Symphonique, Op. 60: III. KijŽÕs Wedding", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Boris Karloff, Mario Rossi & Wiener Opernorchester", title:"Peter and the Wolf, Op. 67: III. The Bird", genre:"80.06: Classical -> Modern"}, Â
	{artist:"Louisiana Youth Orchestras", title:"Little Symphony", genre:"80.07: Classical -> Contemporary Classical"}, Â
	{artist:"L'Orchestre de la Suisse Romande and Ernest Ansermet", title:"Rimsky-Korsakov: Dubinushka, Op.62", genre:"80.05: Classical -> Romantic"} Â
		}

-- Process each artist
repeat with artistRecord in artistData
	try
		set currentArtist to artist of artistRecord
		set currentTitle to title of artistRecord
		set currentGenre to genre of artistRecord
		
		-- Update the genre in Apple Music
		tell application "Music"
			-- Find all tracks by this artist
			set matchingTracks to (every track whose artist is currentArtist and name is currentTitle)
			
			if (count of matchingTracks) > 0 then
				repeat with aTrack in matchingTracks
					set genre of aTrack to currentGenre
				end repeat
				set updateCount to updateCount + 1
				log "Updated " & currentArtist & " to genre: " & currentGenre
			else
				set notFoundCount to notFoundCount + 1
				set end of errorLog to "Artist not found: " & currentArtist
				log "Artist not found in library: " & currentArtist
			end if
		end tell
	on error errMsg
		set end of errorLog to "Error processing " & currentArtist & ": " & errMsg
		log "Error processing " & currentArtist & ": " & errMsg
	end try
end repeat

-- Display summary
set summaryMessage to "Genre Update Complete!" & return & return & Â
	"Artists updated: " & updateCount & return & Â
	"Artists not found in library: " & notFoundCount

if (count of errorLog) > 0 then
	set oldDelim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to linefeed
	set errorText to errorLog as text
	set AppleScript's text item delimiters to oldDelim
	set summaryMessage to summaryMessage & return & return & "Errors:" & return & errorText
end if

display(summaryMessage)


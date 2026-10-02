-- Apple Music Genre Updater with Embedded Data
-- Automatically skips records where match_type = "wrong"

-- Initialize counters
set updateCount to 0
set notFoundCount to 0
set errorLog to {}

-- Artist data embedded directly
set artistData to {Â
	{artist:"Camper Van Beethoven", title:"Take the Skinheads Bowling (Camper Van Beethoven)", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"Ty Segall", title:"My Lady's On Fire", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"The Postal Service", title:"The District Sleeps Alone Tonight", genre:"13.07: Pop -> Synthpop & New Romantics"}, Â
	{artist:"Foxygen", title:"San Francisco", genre:"10.02.04: Rock -> Golden Age/Classic Rock -> Psychedelic Rock"}, Â
	{artist:"Run the Jewels", title:"Close Your Eyes (And Count To Fuck)  ft Zack de la Rocha", genre:"40.09: Rap & Hip-Hop -> Trip-Hop & Abstract Hip-Hop"}, Â
	{artist:"Mudhoney", title:"Touch Me I'm Sick", genre:"10.05.04: Rock -> Alternative Rock/Indie -> Grunge"}, Â
	{artist:"Bon Iver", title:"Blood Bank", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Vampire Weekend", title:"Harmony Hall", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Yeah Yeah Yeahs", title:"Gold Lion", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Mannequin Pussy", title:"Sometimes", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"Dehd", title:"Dog Days", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Geese", title:"Taxes", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"The Drums", title:"Let's Go Surfing", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Cat Power", title:"The Greatest", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Wednesday", title:"Elderberry Wine", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Parquet Courts", title:"Stoned and Starving", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"The Shins", title:"Phantom Limb", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Modest Mouse", title:"Ocean Breathes Salty", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Wednesday", title:"Quarry", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Fleet Foxes", title:"Mykonos", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Big Thief", title:"Shark Smile", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Sharon Van Etten", title:"Seventeen", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"Neutral Milk Hotel", title:"Holland, 1945", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Of Montreal", title:"Wraith Pinned to the Mist and Other Games (Album Version)", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Wilco", title:"Heavy metal drummer", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Vampire Weekend", title:"Step", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"A Tribe Called Quest", title:"Can I Kick It?", genre:"40.05: Rap & Hip-Hop -> Conscious & Jazz Rap"}, Â
	{artist:"Mitski", title:"Your Best American Girl", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"TV on the Radio", title:"Dlz", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"The Flaming Lips", title:"She Don't Use Jelly", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"The Mountain Goats", title:"This Year", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"The Afghan Whigs", title:"Gentlemen", genre:"10.05.04: Rock -> Alternative Rock/Indie -> Grunge"}, Â
	{artist:"Interpol", title:"Slow Hands", genre:"10.03.04: Rock -> Punk Rock/New Wave -> Post-Punk"}, Â
	{artist:"MJ Lenderman", title:"She's Leaving You", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Death Cab for Cutie", title:"Title and Registration", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Parquet Courts", title:"Berlin Got Blurry", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Pixies", title:"Monkey Gone To Heaven", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Hamilton Leithauser + Rostam", title:"In a Black Out", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"The Decemberists", title:"Here I Dreamt I Was An Architect", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Future Islands", title:"Seasons (Waiting On You)", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"The Shins", title:"Caring Is Creepy", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Death Cab For Cutie", title:"Soul Meets Body", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Chairlift", title:"Bruises", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Beck", title:"E-Pro", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Kurt Vile", title:"Pretty Pimpin", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Angel Olsen", title:"Shut Up Kiss Me", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"Modest Mouse", title:"Dramamine", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Interpol", title:"Untitled", genre:"10.03.04: Rock -> Punk Rock/New Wave -> Post-Punk"}, Â
	{artist:"Best Coast", title:"Boyfriend", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Vampire Weekend", title:"Campus", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Waxahatchee", title:"Right Back to It (feat. MJ Lenderman)", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Bon Iver", title:"Skinny Love", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"The Flaming Lips", title:"Yoshimi Battles the Pink Robots, Pt. 1", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Phoebe Bridgers", title:"Motion Sickness", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"The Walkmen", title:"The Rat", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"The Shins", title:"New Slang", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Pixies", title:"Here Comes Your Man", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Cigarettes After Sex", title:"Apocalypse", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"TV On The Radio", title:"Wolf Like Me", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Car Seat Headrest", title:"Drunk Drivers/Killer Whales", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"Bright Eyes", title:"First Day of My Life", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Mazzy Star", title:"Fade Into You", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"The Flaming Lips", title:"Do You Realize??", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Sufjan Stevens", title:"Chicago", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"Wilco", title:"Jesus, Etc.", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"The White Stripes", title:"Fell in Love With a Girl", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"Death Cab For Cutie", title:"I Will Follow You into the Dark", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Yeah Yeah Yeahs", title:"Maps", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Iron & Wine", title:"Such Great Heights", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Vampire Weekend", title:"A-Punk", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Neutral Milk Hotel", title:"In the Aeroplane Over the Sea", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Interpol", title:"Evil", genre:"10.03.04: Rock -> Punk Rock/New Wave -> Post-Punk"}, Â
	{artist:"Modest Mouse", title:"Float On", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Pixies", title:"Where Is My Mind?", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"The Strokes", title:"Last Nite", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"American Football", title:"Never Meant", genre:"10.04.05: Rock -> Hardcore -> Post-Hardcore, Emo, and Screamo"}, Â
	{artist:"Animal Collective", title:"My Girls", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Animal Collective", title:"Summertime Clothes", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Archers of Loaf", title:"Web in Front", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"At the Drive-In", title:"One Armed Scissor", genre:"10.04.05: Rock -> Hardcore -> Post-Hardcore, Emo, and Screamo"}, Â
	{artist:"Band of Horses", title:"No One's Gonna Love You", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Band of Horses", title:"The Funeral", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Beach Fossils", title:"Down the Line", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Beach House", title:"Myth", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Beach House", title:"Space Song", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Beastie Boys", title:"Sabotage", genre:"40.01: Rap & Hip-Hop -> Old School & Golden Age"}, Â
	{artist:"Beat Happening", title:"Indian Summer", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Beirut", title:"Nantes", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Big Star", title:"Thirteen", genre:"13.05: Pop -> Early Pop Rock & Power Pop"}, Â
	{artist:"Bikini Kill", title:"Rebel Girl", genre:"10.03.03: Rock -> Punk Rock/New Wave -> Punk Rock"}, Â
	{artist:"Blonde Redhead", title:"23", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Bon Iver", title:"Holocene", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"boygenius", title:"Not Strong Enough", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"Bratmobile", title:"Panik", genre:"10.03.03: Rock -> Punk Rock/New Wave -> Punk Rock"}, Â
	{artist:"The Breeders", title:"Cannonball", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"The Brian Jonestown Massacre", title:"Anemone", genre:"10.02.04: Rock -> Golden Age/Classic Rock -> Psychedelic Rock"}, Â
	{artist:"Bright Eyes", title:"Lover I Don't Have to Love", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Broken Bells", title:"The High Road", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Built to Spill", title:"Carry the Zero", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"Car Seat Headrest", title:"Can't Cool Me Down", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"Caroline Polachek", title:"So Hot You're Hurting My Feelings", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Clairo", title:"Bags", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Clap Your Hands Say Yeah", title:"The Skin of My Yellow Country Teeth", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Cults", title:"Always Forever", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"The Dandy Warhols", title:"Bohemian Like You", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Danger Mouse & Karen O", title:"Turn the Light", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Daniel Johnston", title:"True Love Will Find You In the End", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Das Racist & Heems", title:"Combination Pizza Hut and Taco Bell", genre:"40.09: Rap & Hip-Hop -> Trip-Hop & Abstract Hip-Hop"}, Â
	{artist:"Day Wave", title:"Drag", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Death Cab for Cutie", title:"I Will Possess Your Heart", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"The Decemberists", title:"We Both Go Down Together", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Descendents", title:"Suburban Home", genre:"10.03.09: Rock -> Punk Rock/New Wave -> Skate Punk & Pop Punk"}, Â
	{artist:"DIIV", title:"Doused", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Dinosaur Jr.", title:"Freak Scene", genre:"10.05.02: Rock -> Alternative Rock/Indie -> Noise Rock"}, Â
	{artist:"Dinosaur Jr.", title:"Feel the Pain", genre:"10.05.02: Rock -> Alternative Rock/Indie -> Noise Rock"}, Â
	{artist:"Dirty Projectors", title:"Stillness Is the Move", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"DJ Shadow", title:"Midnight In a Perfect World", genre:"40.09: Rap & Hip-Hop -> Trip-Hop & Abstract Hip-Hop"}, Â
	{artist:"Dr. Dog", title:"Where'd All the Time Go?", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Dum Dum Girls", title:"Coming Down", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Electric Six", title:"Danger! High Voltage!", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"Elliott Smith", title:"Between the Bars", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"Elliott Smith", title:"Say Yes", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"Father John Misty", title:"Chateau Lobby #4 (In C for Two Virgins) - Live from the Hamburg Elbphilharmonie on August 8, 2019", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"Father John Misty", title:"Real Love Baby", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"Faye Webster", title:"But Not Kiss", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"Fiona Apple", title:"Paper Bag", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"Fleet Foxes", title:"Ragged Wood", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Fugazi", title:"Waiting Room", genre:"10.04.05: Rock -> Hardcore -> Post-Hardcore, Emo, and Screamo"}, Â
	{artist:"Future Islands", title:"A Dream of You and Me", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Galaxie 500", title:"Tugboat", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Gossip", title:"Standing In the Way of Control", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"Grizzly Bear", title:"Two Weeks", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Guided By Voices", title:"Game of Pricks", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"HAIM", title:"The Wire", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Heatmiser", title:"Plainclothes Man", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"The Hold Steady", title:"Your Little Hoodrat Friend", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"Hovvdy", title:"True Love", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Hum", title:"Stars", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"HŸsker DŸ", title:"Don't Want to Know If You Are Lonely", genre:"10.04.05: Rock -> Hardcore -> Post-Hardcore, Emo, and Screamo"}, Â
	{artist:"Interpol", title:"Obstacle 1", genre:"10.03.04: Rock -> Punk Rock/New Wave -> Post-Punk"}, Â
	{artist:"Interpol", title:"PDA", genre:"10.03.04: Rock -> Punk Rock/New Wave -> Post-Punk"}, Â
	{artist:"Iron & Wine", title:"Naked As We Came", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Japanese Breakfast", title:"Be Sweet", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Japanese Breakfast", title:"Road Head", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Jawbreaker", title:"Accident Prone", genre:"10.04.05: Rock -> Hardcore -> Post-Hardcore, Emo, and Screamo"}, Â
	{artist:"Jay Reatard", title:"My Shadow", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"Jenny Lewis", title:"Just One of the Guys", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"Jonathan Fire Eater", title:"Give Me Daughters", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"Jonathan Richman & The Modern Lovers", title:"Roadrunner", genre:"10.03.02: Rock -> Punk Rock/New Wave -> Pub Rock & Proto Punk"}, Â
	{artist:"Julian Casablancas", title:"11th Dimension", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"King Tuff", title:"Sun Medallion", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"Kurt Vile", title:"Jesus Fever", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"LCD Soundsystem", title:"Daft Punk Is Playing at My House", genre:"13.07: Pop -> Synthpop & New Romantics"}, Â
	{artist:"LCD Soundsystem", title:"All My Friends", genre:"13.07: Pop -> Synthpop & New Romantics"}, Â
	{artist:"LCD Soundsystem", title:"Dance Yrself Clean", genre:"13.07: Pop -> Synthpop & New Romantics"}, Â
	{artist:"Le Tigre", title:"Deceptacon", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"The Lemonheads", title:"Into Your Arms", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"Local Natives", title:"When Am I Gonna Lose You", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Low", title:"Words", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Lucy Dacus", title:"Night Shift", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Luna", title:"California (All the Way)", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Luscious Jackson", title:"Naked Eye", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Magdalena Bay", title:"Image", genre:"13.07: Pop -> Synthpop & New Romantics"}, Â
	{artist:"The Magnetic Fields", title:"The Book of Love", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Meshell Ndegeocello & Cat Power", title:"DonÕt You Want Me", genre:"30.12: R&B -> Neo Soul/Nu Soul"}, Â
	{artist:"MGMT", title:"Electric Feel", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"MGMT", title:"Kids", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Minutemen", title:"Corona", genre:"10.03.03: Rock -> Punk Rock/New Wave -> Punk Rock"}, Â
	{artist:"Mission of Burma", title:"Academy Fight Song", genre:"10.03.04: Rock -> Punk Rock/New Wave -> Post-Punk"}, Â
	{artist:"Mitski", title:"My Love Mine All Mine", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"Modest Mouse", title:"Convenient Parking", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"The Moldy Peaches", title:"Anyone Else But You", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"My Morning Jacket", title:"Wordless Chorus (2025 Remaster)", genre:"10.05.12: Rock -> Alternative Rock/Indie -> Jam Bands"}, Â
	{artist:"Nada Surf", title:"Inside of Love", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Nation of Language", title:"Sole Obsession", genre:"13.07: Pop -> Synthpop & New Romantics"}, Â
	{artist:"The National", title:"Fake Empire", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"The National", title:"Bloodbuzz Ohio", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"The National", title:"I Need My Girl", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Neon Indian", title:"Polish Girl", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Orville Peck", title:"Turn to Hate", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Panda Bear", title:"Comfy in Nautica", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Pavement", title:"Harness Your Hopes (B-side)", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Pavement", title:"Cut Your Hair", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Pavement", title:"Gold Soundz", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Pavement", title:"Major Leagues", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Perfume Genius", title:"Queen", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"Phantogram", title:"Black Out Days", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Phoebe Bridgers", title:"Kyoto", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"Phosphorescent", title:"Song For Zula", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Pinback", title:"Good to Sea", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Pinegrove", title:"Old Friends", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Porches", title:"Be Apart", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"The Promise Ring", title:"Nothing Feels Good (Remastered)", genre:"10.04.05: Rock -> Hardcore -> Post-Hardcore, Emo, and Screamo"}, Â
	{artist:"The Rapture", title:"House of Jealous Lovers", genre:"10.03.04: Rock -> Punk Rock/New Wave -> Post-Punk"}, Â
	{artist:"Real Estate", title:"Talking Backwards", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Real Estate", title:"Beach Comber", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"The Replacements", title:"Can't Hardly Wait", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Richard Swift", title:"Lady Luck", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"Rilo Kiley", title:"Portions for Foxes", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Santigold", title:"L.E.S. Artistes", genre:"40.07: Rap & Hip-Hop -> Pop Rap & R&B Crossovers"}, Â
	{artist:"Silver Jews", title:"Random Rules", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Sky Ferreira", title:"Everything Is Embarrassing", genre:"13.07: Pop -> Synthpop & New Romantics"}, Â
	{artist:"Sleater-Kinney", title:"Modern Girl", genre:"10.03.03: Rock -> Punk Rock/New Wave -> Punk Rock"}, Â
	{artist:"Sleigh Bells", title:"Rill Rill", genre:"10.05.02: Rock -> Alternative Rock/Indie -> Noise Rock"}, Â
	{artist:"Slint", title:"Good Morning, Captain", genre:"10.03.04: Rock -> Punk Rock/New Wave -> Post-Punk"}, Â
	{artist:"Smog", title:"Cold Blooded Old Times", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"Soccer Mommy", title:"Your Dog", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"Sonic Youth", title:"Teen Age Riot", genre:"10.05.02: Rock -> Alternative Rock/Indie -> Noise Rock"}, Â
	{artist:"Sonic Youth", title:"Kool Thing", genre:"10.05.02: Rock -> Alternative Rock/Indie -> Noise Rock"}, Â
	{artist:"Sonic Youth", title:"Incinerate", genre:"10.05.02: Rock -> Alternative Rock/Indie -> Noise Rock"}, Â
	{artist:"The Sonics", title:"Strychnine", genre:"10.03.02: Rock -> Punk Rock/New Wave -> Pub Rock & Proto Punk"}, Â
	{artist:"Spoon", title:"The Underdog", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Spoon", title:"I Summon You", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Spoon", title:"Inside Out", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Spoon", title:"Do You", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"St. Vincent", title:"Los Ageless", genre:"10.03.10: Rock -> Punk Rock/New Wave -> Modern Art Punk"}, Â
	{artist:"St. Vincent", title:"Digital Witness", genre:"10.03.10: Rock -> Punk Rock/New Wave -> Modern Art Punk"}, Â
	{artist:"The Strokes", title:"Under Cover of Darkness", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"The Strokes", title:"Reptilia", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"The Strokes", title:"12:51", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"Sufjan Stevens", title:"Should Have Known Better", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"Sufjan Stevens", title:"Mystery of Love (From ÒCall Me By Your NameÓ)", genre:"13.04: Pop -> Singer/Songwriter"}, Â
	{artist:"Sugar", title:"If I Can't Change Your Mind", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Suicide", title:"Dream Baby Dream", genre:"10.03.03: Rock -> Punk Rock/New Wave -> Punk Rock"}, Â
	{artist:"Sunny Day Real Estate", title:"In Circles (2009 Remastered Version)", genre:"10.04.05: Rock -> Hardcore -> Post-Hardcore, Emo, and Screamo"}, Â
	{artist:"Superchunk", title:"Driveway to Driveway", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"Sylvan Esso", title:"Coffee", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Television", title:"See No Evil", genre:"10.03.02: Rock -> Punk Rock/New Wave -> Pub Rock & Proto Punk"}, Â
	{artist:"Tennis", title:"Origins", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Thundercat", title:"Them Changes", genre:"30.12: R&B -> Neo Soul/Nu Soul"}, Â
	{artist:"Toro y Moi", title:"Blessa", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Toro y Moi", title:"Ordinary Pleasure", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"TV Girl", title:"Lovers Rock", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"TV Girl", title:"Cigarettes out the Window", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"TV on the Radio", title:"Happy Idiot", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"The War on Drugs", title:"Under the Pressure", genre:"10.02.02: Rock -> Golden Age/Classic Rock -> Folk Rock"}, Â
	{artist:"Warpaint", title:"Common Blue", genre:"13.10: Pop -> Indie Pop"}, Â
	{artist:"Washed Out", title:"Feel It All Around", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Washed Out", title:"It All Feels Right", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"The White Stripes", title:"Icky Thump", genre:"10.03.12: Rock -> Punk Rock/New Wave -> Indie Punk/Modern Garage Rock"}, Â
	{artist:"Whitney", title:"No Woman", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Wilco", title:"Impossible Germany", genre:"10.05.13: Rock -> Alternative Rock/Indie -> Folk Rock/Alt Country"}, Â
	{artist:"Wild Nothing", title:"Chinatown", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"X", title:"Los Angeles", genre:"10.03.03: Rock -> Punk Rock/New Wave -> Punk Rock"}, Â
	{artist:"Yeah Yeah Yeahs", title:"Zero", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Yeah Yeah Yeahs", title:"Heads Will Roll", genre:"10.05.10: Rock -> Alternative Rock/Indie -> Post-Grunge Alt Rock"}, Â
	{artist:"Yo La Tengo", title:"Sugarcube", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"}, Â
	{artist:"Yo La Tengo", title:"Autumn Sweater", genre:"10.05.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Dream Pop"} Â
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


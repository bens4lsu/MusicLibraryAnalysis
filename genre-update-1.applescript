-- Apple Music Genre Updater
-- Updates genre tags for artists based on database classifications

tell application "Music"
	
	-- Counter for tracking progress
	set updateCount to 0
	set errorList to {}
	
	-- Artist and genre mappings from workspace.ml.temp_artist_genre_working_list
	set artistGenreList to {Â
		{"AJJ", "10.05.07: Rock -> Contemporary Rock -> Indie Folk & Freakfolk/New Weird America"}, Â
		{"Aimee Mann", "10.04.08: Rock -> Alternative Rock/Indie -> Alternative/Indie Rock II"}, Â
		{"Arcade Fire", "10.05.07: Rock -> Contemporary Rock -> Garage Rock & Post-Punk Revivals"}, Â
		{"Arctic Monkeys", "10.05.03: Rock -> Contemporary Rock -> Garage Rock & Post-Punk Revivals"}, Â
		{"Beck", "10.04.08: Rock -> Alternative Rock/Indie -> Alternative/Indie Rock II"}, Â
		{"Better Than Ezra", "10.04.10: Rock -> Alternative Rock/Indie -> Post-Grunge"}, Â
		{"Bjšrk", "10.04.08: Rock -> Alternative Rock/Indie -> Alternative/Indie Rock II"}, Â
		{"Blink-182", "10.04.06: Rock -> Alternative Rock/Indie -> Skate Punk and Pop Punk"}, Â
		{"Blues Traveler", "10.04.10: Rock -> Alternative Rock/Indie -> Post-Grunge"}, Â
		{"Blur", "10.04.09: Rock -> Alternative Rock/Indie -> Britpop"}, Â
		{"Bob Dylan", "10.02.02: Rock -> Golden Age/Classic Rock -> Folk Rock"}, Â
		{"Bruce Springsteen", "10.02.10: Rock -> Golden Age/Classic Rock -> Heartland Rock & Adult Oriented Rock"}, Â
		{"Cake", "10.04.08: Rock -> Alternative Rock/Indie -> Alternative/Indie Rock II"}, Â
		{"Cat Power", "10.04.08: Rock -> Alternative Rock/Indie -> Alternative/Indie Rock II"}, Â
		{"Coldplay", "10.05.01: Rock -> Contemporary Rock -> Post-Britpop"}, Â
		{"David Bowie", "10.02.08: Rock -> Golden Age/Classic Rock -> Glam Rock/Glitter Rock/Shock Rock"}, Â
		{"Eels", "10.04.08: Rock -> Alternative Rock/Indie -> Alternative/Indie Rock II"}, Â
		{"Elvis Presley", "10.01.02: Rock -> Early Rock N Roll -> Rock N Roll & Rockabilly"}, Â
		{"Eric Clapton", "10.02.03: Rock -> Golden Age/Classic Rock -> British Blues & Blues Rock"}, Â
		{"Fats Domino", "10.01.02: Rock -> Early Rock N Roll -> Rock N Roll & Rockabilly"}, Â
		{"Fleetwood Mac", "10.02.05: Rock -> Golden Age/Classic Rock -> Heartland Rock & Adult Oriented Rock"}, Â
		{"Foo Fighters", "10.04.10: Rock -> Alternative Rock/Indie -> Post-Grunge"}, Â
		{"Green Day", "10.04.10: Rock -> Alternative Rock/Indie -> Post-Grunge"}, Â
		{"IDLES", "10.05.03: Rock -> Contemporary Rock -> Garage Rock & Post-Punk Revivals"}, Â
		{"INXS", "10.02.04: Rock -> Golden Age/Classic Rock -> New Wave"}, Â
		{"Jack Johnson", "10.05.07: Rock -> Contemporary Rock -> Indie Folk & Freakfolk/New Weird America"}, Â
		{"Jimi Hendrix", "10.02.04: Rock -> Golden Age/Classic Rock -> Psychodelic Rock"}, Â
		{"Led Zeppelin", "10.02.05: Rock -> Golden Age/Classic Rock -> Hard Rock"}, Â
		{"Limp Bizkit", "10.04.05: Rock -> Alternative Rock/Indie -> Rap Rock/Rapcore/Funk Metal"}, Â
		{"Lynyrd Skynyrd", "10.02.09: Rock -> Golden Age/Classic Rock -> Southern Rock"}, Â
		{"Mazzy Star", "10.04.03: Rock -> Alternative Rock/Indie -> Dream Pop & Shoegaze"}, Â
		{"Modest Mouse", "10.04.08: Rock -> Alternative Rock/Indie -> Alternative/Indie Rock II"}, Â
		{"Morrissey", "10.04.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Indie Rock"}, Â
		{"Mt. Joy", "10.05.07: Rock -> Contemporary Rock -> Indie Folk & Freakfolk/New Weird America"}, Â
		{"Neil Diamond", "10.02.10: Rock -> Golden Age/Classic Rock -> Heartland Rock & Adult Oriented Rock"}, Â
		{"Nirvana", "10.04.04: Rock -> Alternative Rock/Indie -> Grunge"}, Â
		{"No Doubt", "10.04.06: Rock -> Alternative Rock/Indie -> Skate Punk and Pop Punk"}, Â
		{"PJ Harvey", "10.04.08: Rock -> Alternative Rock/Indie -> Alternative/Indie Rock II"}, Â
		{"Parquet Courts", "10.05.03: Rock -> Contemporary Rock -> Garage Rock & Post-Punk Revivals"}, Â
		{"Peter Gabriel", "10.02.06: Rock -> Golden Age/Classic Rock -> Progressive Rock, Art Rock, & Symphonic Rock"}, Â
		{"Pink Floyd", "10.02.06: Rock -> Golden Age/Classic Rock -> Progressive Rock, Art Rock, & Symphonic Rock"}, Â
		{"Pixies", "10.04.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Indie Rock"}, Â
		{"Primus", "10.04.02: Rock -> Alternative Rock/Indie -> Noise Rock"}, Â
		{"Queen", "10.02.08: Rock -> Golden Age/Classic Rock -> Glam Rock/Glitter Rock/Shock Rock"}, Â
		{"R.E.M.", "10.04.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Indie Rock"}, Â
		{"Radiohead", "10.05.01: Rock -> Contemporary Rock -> Post-Britpop"}, Â
		{"Randy Newman", "10.02.10: Rock -> Golden Age/Classic Rock -> Heartland Rock & Adult Oriented Rock"}, Â
		{"Red Hot Chili Peppers", "10.04.05: Rock -> Alternative Rock/Indie -> Rap Rock/Rapcore/Funk Metal"}, Â
		{"Reverend Horton Heat", "10.02.06: Rock -> Golden Age/Classic Rock -> Horror Punk & Psychobilly"}, Â
		{"Rod Stewart", "10.02.10: Rock -> Golden Age/Classic Rock -> Heartland Rock & Adult Oriented Rock"}, Â
		{"Slothrust", "10.05.03: Rock -> Contemporary Rock -> Garage Rock & Post-Punk Revivals"}, Â
		{"Spoon", "10.05.03: Rock -> Contemporary Rock -> Garage Rock & Post-Punk Revivals"}, Â
		{"Steely Dan", "10.02.10: Rock -> Golden Age/Classic Rock -> Heartland Rock & Adult Oriented Rock"}, Â
		{"The Allman Brothers Band", "10.02.09: Rock -> Golden Age/Classic Rock -> Southern Rock"}, Â
		{"The Avett Brothers", "10.05.07: Rock -> Contemporary Rock -> Indie Folk & Freakfolk/New Weird America"}, Â
		{"The Beach Boys", "10.01.04: Rock -> Early Rock N Roll -> Surf Rock/Instrumental"}, Â
		{"The Beatles", "10.02.01: Rock -> Golden Age/Classic Rock -> Beat/British Invasion"}, Â
		{"The Clash", "10.02.02: Rock -> Golden Age/Classic Rock -> Punk Rock"}, Â
		{"The Eagles", "10.02.10: Rock -> Golden Age/Classic Rock -> Heartland Rock & Adult Oriented Rock"}, Â
		{"The Everly Brothers", "10.01.02: Rock -> Early Rock N Roll -> Rock N Roll & Rockabilly"}, Â
		{"The Flaming Lips", "10.04.08: Rock -> Alternative Rock/Indie -> Alternative/Indie Rock II"}, Â
		{"The Hives", "10.05.03: Rock -> Contemporary Rock -> Garage Rock & Post-Punk Revivals"}, Â
		{"The Killers", "10.05.03: Rock -> Contemporary Rock -> Garage Rock & Post-Punk Revivals"}, Â
		{"The Kinks", "10.02.01: Rock -> Golden Age/Classic Rock -> Beat/British Invasion"}, Â
		{"The Kooks", "10.05.03: Rock -> Contemporary Rock -> Garage Rock & Post-Punk Revivals"}, Â
		{"The Ramones", "10.02.02: Rock -> Golden Age/Classic Rock -> Punk Rock"}, Â
		{"The Rolling Stones", "10.02.03: Rock -> Golden Age/Classic Rock -> British Blues & Blues Rock"}, Â
		{"The Shins", "10.04.08: Rock -> Alternative Rock/Indie -> Alternative/Indie Rock II"}, Â
		{"The Smashing Pumpkins", "10.04.08: Rock -> Alternative Rock/Indie -> Alternative/Indie Rock II"}, Â
		{"The Smiths", "10.04.01: Rock -> Alternative Rock/Indie -> Jangle Pop/Indie Rock"}, Â
		{"The Stooges", "10.02.01: Rock -> Golden Age/Classic Rock -> Pub Rock & Proto Punk"}, Â
		{"The Vaccines", "10.05.03: Rock -> Contemporary Rock -> Garage Rock & Post-Punk Revivals"}, Â
		{"The Who", "10.02.05: Rock -> Golden Age/Classic Rock -> Hard Rock"}, Â
		{"They Might Be Giants", "10.04.08: Rock -> Alternative Rock/Indie -> Alternative/Indie Rock II"}, Â
		{"Ty Segall", "10.05.03: Rock -> Contemporary Rock -> Garage Rock & Post-Punk Revivals"}, Â
		{"U2", "10.05.01: Rock -> Contemporary Rock -> Post-Britpop"} Â
			}
	
	-- Display initial dialog
	display dialog "This script will update genre tags for " & (count of artistGenreList) & " artists in Apple Music." & return & return & "This may take several minutes. Continue?" buttons {"Cancel", "Update Genres"} default button "Update Genres"
	
	-- Process each artist
	repeat with artistGenre in artistGenreList
		set artistName to item 1 of artistGenre
		set newGenre to item 2 of artistGenre
		
		try
			-- Search for tracks by this artist
			set foundTracks to (search library playlist 1 for artistName only artists)
			
			if (count of foundTracks) > 0 then
				-- Update genre for all tracks by this artist
				repeat with aTrack in foundTracks
					try
						set genre of aTrack to newGenre
						set updateCount to updateCount + 1
					on error errMsg
						set end of errorList to "Error updating track: " & errMsg
					end try
				end repeat
			else
				set end of errorList to "No tracks found for: " & artistName
			end if
			
		on error errMsg
			set end of errorList to "Error processing " & artistName & ": " & errMsg
		end try
		
	end repeat
	
	-- Display completion message
	set resultMessage to "Genre update complete!" & return & return & "Tracks updated: " & updateCount
	
	if (count of errorList) > 0 then
		set resultMessage to resultMessage & return & return & "Errors encountered: " & (count of errorList)
	end if
	
	display dialog resultMessage buttons {"OK"} default button "OK"
	
end tell
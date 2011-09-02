(* Begin user defined settings ************)
property campfire_token : "1234567" (* Your Campfire API authentication token *)
property airplay_device : "Apple TV" (* The name of your AirPlay device *)
property campfire_room : "https://yourname.campfirenow.com/room/123456/speak.xml" (* The Campfire room you’d like to post to *)

(* End user defined settings *************)

global current_track, last_track, current_device

on run
	(* init at runtime*)
	set current_track to ""
	set current_device to ""
	set last_track to ""
end run

on idle
	if application "iTunes" is not running then return 10
	tell application "iTunes"
		if (player state is not playing) or (current track is equal to last_track) then return 5
		
		set last_track to current track
		
		set minimized of front browser window to false
		set visible of front browser window to true
		set current_device to my getDevice()
		if current_device as string is not equal to airplay_device & " AirPlay" then return 5
		
		set track_info to my mungeText({name, artist, album} of last_track, "", " :: ")
		set track_info to track_info as string
		set track_info to my mungeText(track_info, "&", "&amp;") (* Replace ampersands *)
		set track_info to my mungeText(track_info, "\"", "&#34;") (* Replace quotation marks *)
		set track_info to my mungeText(track_info, "’", "&#39;") (* Replace apostrophes *)
		
		set shellCommand to ("curl -u " & campfire_token & ":X -H ‘Content-Type: application/xml’ -d ‘<message><type>TextMessage</type><body>" & track_info & "</body></message>’ " & campfire_room)
		set shellCommand to shellCommand as string
		do shell script shellCommand
		(*display dialog shellCommand*)
		(*log "Posting to Campfire:" & shellCommand*)
		return 5
	end tell
end idle

on getDevice()
	tell application "System Events"
		tell process "iTunes"
			return description of button 8 of window "iTunes"
		end tell
	end tell
end getDevice

on mungeText(itxt, stxt, rtxt)
	set tid to AppleScript's text item delimiters
	if class of itxt is text then
		set AppleScript's text item delimiters to stxt
		set itxt to text items of itxt
	end if
	set AppleScript's text item delimiters to rtxt
	set otxt to itxt as text
	set AppleScript's text item delimiters to tid
	return otxt
end mungeText
-------------------------------------------------------------------------
--T and G Apps Ltd.
--Created by Joseph Stevens
--www.tandgapps.co.uk
--joe@tandgapps.co.uk

--CoronaSDK version 2013.1179 was used for this template.

--You are not allowed to publish this template to the Appstore as it is. 
--You need to work on it, improve it and replace the graphics. 

--For questions and/or bugs found, please contact me using our contact
--form on http://www.tandgapps.co.uk/contact-us/
-------------------------------------------------------------------------



--Initial Settings
display.setStatusBar(display.HiddenStatusBar) --Hide status bar from the beginning



--Global score vars
_G.overallScore = 0
_G.target = 1

-- Global tileIconSheet, made global to save us loading and removing it each game!
_G.tileIconSheet = graphics.newImageSheet("images/tiles.png", {height = 30, width = 30, numFrames = 8, sheetContentWidth = 240, sheetContentHeight = 30})


--------This block of code is for creating and storing the playerId----------------



local json = require "json"

local BACKEND_BASE_URL = "https://teloquat.appspot.com/_ah/api"
local TOKEN = "43mfsdfl98342klsdf"

local function networkListener( event )
        if ( event.isError ) then
                print( "Network error!")
        else
                print ( "RESPONSE: " .. event.response )
                local decode = json.decode( event.response )
                native.showAlert( "Player_id",  decode.player_id , { "OK" } )   -- for testing purposes only, remove for final build
                print("Got new user ID: " .. decode.player_id )
        end
end

-- Set the HTTP headers.
local headers = {}
headers["Content-Type"] = "application/json"

-- All calls to the backend need to send the security token.
local data = { ["token"] = TOKEN}
local body = json.encode(data)

-- Build the HTTP request.
local params = {}
params.headers = headers
params.body = body
local url = BACKEND_BASE_URL .. "/twarp_engine_api/v1/first_time"

-- Contact the server.
network.request(url, "POST", networkListener, params)


-----------------------------------------------------------------------------------

--Import storyboard etc
local storyboard = require "storyboard"
storyboard.purgeOnSceneChange = true --So it automatically purges for us.
local sqlite3 = require("sqlite3")  --For loading and saving into our database



--Loads sounds. Done here so that we don't have to keep on creating and disposing of them!
local sounds = {}
sounds["select"] = audio.loadSound("sounds/select.mp3")
sounds["pop"] = audio.loadSound("sounds/pop.mp3")

function playSound(name) --Just pass a name to it. e.g. "select"
    audio.play(sounds[name])
end

--Create a database for holding the top score.
--You could easily edit this to add more levels and more highscores.
local dbPath = system.pathForFile("fruit_scores.db3", system.DocumentsDirectory)
local db = sqlite3.open(dbPath)
local tablesetup = [[ 
		CREATE TABLE scores (id INTEGER PRIMARY KEY, score INTEGER, level INTEGER);
		CREATE TABLE levels (id INTEGER PRIMARY KEY, score INTEGER, level INTEGER);
		INSERT INTO scores VALUES (NULL, 0, 0);
		INSERT INTO levels VALUES (NULL, 0, 0);
	]]
db:exec(tablesetup) --Create it now.
db:close() --Then close the database

function doesFileExist( fname, path )

    local results = false

    local filePath = system.pathForFile( fname, path )

    --filePath will be 'nil' if file doesn't exist and the path is 'system.ResourceDirectory'
    if ( filePath ) then
        filePath = io.open( filePath, "r" )
    end

    if ( filePath ) then
        print( "File found: " .. fname )
        --clean up file handles
        filePath:close()
        results = true
    else
        print( "File does not exist: " .. fname )
    end

    return results
end

local function copyFile(srcName, srcPath, dstName, dstPath, overwrite )
        local results = false

    local srcPath = doesFileExist( srcName, srcPath )

    if ( srcPath == false ) then
        return nil  -- nil = source file not found
    end

    --check to see if destination file already exists
    if not ( overwrite ) then
        if ( fileLib.doesFileExist( dstName, dstPath ) ) then
            return 2  -- 1 = file already exists (don't overwrite)
        end
    end

    --copy the source file to the destination file
    local rfilePath = system.pathForFile( srcName, srcPath )
    local wfilePath = system.pathForFile( dstName, dstPath )

    local rfh = io.open( rfilePath, "rb" )
    local wfh = io.open( wfilePath, "wb" )

    if not ( wfh ) then
        print( "writeFileName open error!" )
        return false
    else
        --read the file from 'system.ResourceDirectory' and write to the destination directory
        local data = rfh:read( "*a" )
        if not ( data ) then
            print( "read error!" )
            return false
        else
            if not ( wfh:write( data ) ) then
                print( "write error!" )
                return false
            end
        end
    end

    results = 2  -- 2 = file copied successfully!

    --clean up file handles
    rfh:close()
    wfh:close()

    return results
end

local function copyLevelFiles()
    for i=1,10 do
        if copyFile( "levels/chapter1level"..i, nil, "chapter1level"..i..".json", system.DocumentsDirectory, true ) ~= 2 then
            break
        end
    end
end

copyLevelFiles()

--Now change scene to go to the menu.
storyboard.gotoScene( "menu", "fade", 400 )
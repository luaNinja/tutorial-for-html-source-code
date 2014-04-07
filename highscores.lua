-------------------------------------------------------------------------
--Mobieos Pvt. Ltd.
--Created by Anirban Mookherjee

--CoronaSDK version used 2013.2100

-------------------------------------------------------------------------


--Start off by requiring storyboard and creating a scene.
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()


-- Set up our variables
local xMin = display.screenOriginX 
local yMin = display.screenOriginY
local xMax = display.contentWidth - display.screenOriginX
local yMax = display.contentHeight - display.screenOriginY
local xWidth = xMax-xMin --The total width
local yHeight = yMax-yMin --The total height
local _W = display.contentWidth
local _H = display.contentHeight

local showLevels = false;




-----------------------------------------------
-- *** STORYBOARD SCENE EVENT FUNCTIONS ***
------------------------------------------------
-- Called when the scene's view does not exist:
-- Create all your display objects here.
function scene:createScene( event )
    print( "Higscores: createScene event")
    local screenGroup = self.view

    --Now make our display groups and insert them into the screengroup.
    local bgGroup = display.newGroup()
    local tabGroup = display.newGroup()
    local scoreTableGroup = display.newGroup()
   	screenGroup:insert(bgGroup)
    screenGroup:insert(tabGroup)
    screenGroup:insert(scoreTableGroup)

    
    ------------
    -- DISPLAY OBJECTS
    ------------
    --Create the main UI
	local backgroundImage = display.newImageRect("images/menu_bg.png", 360, 570)
	local scoresButtonText = display.newText("Scores", 0, 0, native.systemFontBold, 16)
	local scoresButton = display.newRoundedRect(0, 0, 125, 40, 3)
	local levelsButtonText = display.newText("Levels", 0, 0, native.systemFontBold, 16)
	local levelsButton = display.newRoundedRect(0, 0, 125, 40, 3)
	local chartBackground = display.newRoundedRect (0, 0, 280, 320, 3)
	local menuButtonText = display.newImageRect("images/mainmenu.png", 228, 36)
	local tableColumnScore = display.newText("Score", 0, 0, native.systemFontBold, 16)
	local tableColumnLevel = display.newText("Level", 0, 0, native.systemFontBold, 16)
	local highscoreTitle = display.newImageRect("images/highscores.png", 256, 36)


    -- Go back to the menu when the main menu button is pressed
	local function backToMenu (event)
		if event.phase == "ended" then
			playSound("select")
			storyboard.gotoScene( "menu", "fade", 400 )
		end
		return true
	end

	-- Update the table of scores
	local function updateUI ()
		-- Open the SQLite database
		local dbPath = system.pathForFile("fruit_scores.db3", system.DocumentsDirectory)
		local db = sqlite3.open(dbPath)

		-- Clear the table
		for i = 1, 20, 2 do
			scoreTableGroup[i].text = "0"
			scoreTableGroup[i].x = 33 + scoreTableGroup[i].width / 2
			scoreTableGroup[i + 1].text = "0"
			scoreTableGroup[i + 1].x = 290 - scoreTableGroup[i + 1].width / 2
		end

		-- Display the scores for the currently selected tab
		if showLevels then
			scoresButton.alpha = 0.3
			scoresButtonText.alpha = 0.3
			levelsButton.alpha = 1
			levelsButtonText.alpha = 1

			-- Get the scores from the database
			local scoreIndex = 1
			for row in db:nrows("SELECT * FROM levels ORDER BY level DESC") do
				scoreTableGroup[scoreIndex].text = row.score
				scoreTableGroup[scoreIndex].x = 33 + scoreTableGroup[scoreIndex].width / 2
				scoreTableGroup[scoreIndex + 1].text = row.level
				scoreTableGroup[scoreIndex + 1].x = 290 - scoreTableGroup[scoreIndex + 1].width / 2
				scoreIndex = scoreIndex + 2
		    end
		else
			scoresButton.alpha = 1
			scoresButtonText.alpha = 1
			levelsButton.alpha = 0.3
			levelsButtonText.alpha = 0.3

			-- Get the scores from the database
			local scoreIndex = 1
			for row in db:nrows("SELECT * FROM scores ORDER BY score DESC") do
				scoreTableGroup[scoreIndex].text = row.score
				scoreTableGroup[scoreIndex].x = 33 + scoreTableGroup[scoreIndex].width / 2
				scoreTableGroup[scoreIndex + 1].text = row.level
				scoreTableGroup[scoreIndex + 1].x = 290 - scoreTableGroup[scoreIndex + 1].width / 2
				scoreIndex = scoreIndex + 2
		    end
		end
		db:close()
	end

	-- Change the score table to show highest scores
	local function scoresOnTouch(event)
		if event.phase == "ended" then
			playSound("select")
			showLevels = false
			updateUI()
		end
		return true
	end

	-- Change the score table to show the highest levels
	local function levelsOnTouch(event)
		if event.phase == "ended" then
			playSound("select")
			showLevels = true
			updateUI()
		end
		return true
	end

	-----------------------------------------------
	--*** Init ***
	-----------------------------------------------
	-- Set up the UI
	backgroundImage.x = _W*0.5
	backgroundImage.y = _H*0.5

	scoresButtonText:setTextColor(0, 0, 0)
	scoresButtonText.x = 90
	scoresButtonText.y = yMin + 80
	scoresButtonText.alpha = 0.3

	scoresButton.strokeWidth = 1;
	scoresButton:setFillColor (255, 255, 255)
	scoresButton:setStrokeColor (0, 0, 0)
	scoresButton.x = 90
	scoresButton.y = yMin + 85
	scoresButton.alpha = 0.3

	levelsButtonText:setTextColor(0, 0, 0)
	levelsButtonText.x = 230
	levelsButtonText.y = scoresButtonText.y
	levelsButtonText.alpha = 0.3

	levelsButton.strokeWidth = 1;
	levelsButton:setFillColor (255, 255, 255)
	levelsButton:setStrokeColor (0, 0, 0)
	levelsButton.x = 230
	levelsButton.y = scoresButton.y
	levelsButton.alpha = 0.3

	chartBackground.strokeWidth = 1;
	chartBackground:setFillColor (255, 255, 255)
	chartBackground:setStrokeColor (0, 0, 0)
	chartBackground.x = _W / 2
	chartBackground.y = yMin + 255

	menuButtonText.x = _W / 2
	menuButtonText.y = yMax - 30

	highscoreTitle.x = _W / 2
	highscoreTitle.y = yMin + 30


	-- Add the UI to the local group
	bgGroup:insert(backgroundImage)
	tabGroup:insert(scoresButton)
	tabGroup:insert(levelsButton)
	tabGroup:insert(chartBackground)
	tabGroup:insert(scoresButtonText)
	tabGroup:insert(levelsButtonText)
	screenGroup:insert(menuButtonText)
	screenGroup:insert(highscoreTitle)


	-- Create the table of scores
	tableColumnScore.x = 33 + tableColumnScore.width / 2
	tableColumnScore.y = yMin + 115
	tableColumnScore:setTextColor(0, 0, 0)
	tableColumnLevel.x = 290 - tableColumnLevel.width / 2
	tableColumnLevel.y = tableColumnScore.y
	tableColumnLevel:setTextColor(0, 0, 0)
	screenGroup:insert(tableColumnScore)
	screenGroup:insert(tableColumnLevel)

	for i = 1, 10 do 
		local tableRowScore = display.newText("0", 0, 0, native.systemFontBold, 16)
		tableRowScore.x = 33 + tableRowScore.width / 2
		tableRowScore.y = i * 28 + 115 + yMin
		tableRowScore:setTextColor(0, 0, 0)
		local tableRowLevel = display.newText("0", 0, 0, native.systemFontBold, 16)
		tableRowLevel.x = 290 - tableRowLevel.width / 2
		tableRowLevel.y = tableRowScore.y
		tableRowLevel:setTextColor(0, 0, 0)
		scoreTableGroup:insert(tableRowScore)
		scoreTableGroup:insert(tableRowLevel)
	end


	-- Add event listeners and timers
	menuButtonText:addEventListener("touch", backToMenu)
	levelsButton:addEventListener("touch", levelsOnTouch)
	scoresButton:addEventListener("touch", scoresOnTouch)


	-- Populate the high score table for the first time
	updateUI()
end



-- Called immediately after scene has moved onscreen:
-- Start timers/transitions etc.
function scene:enterScene( event )
    print( "Higscores: enterScene event" )

    -- Completely remove the previous scene/all scenes.
    -- Handy in this case where we want to keep everything simple.
    storyboard.removeAll()
end



-- Called when scene is about to move offscreen:
-- Cancel Timers/Transitions and Runtime Listeners etc.
function scene:exitScene( event )
    print( "Higscores: exitScene event" )
end



--Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
    print( "Higscores: destroying view" )
end




-----------------------------------------------
-- Add the story board event listeners
-----------------------------------------------
scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )



--Return the scene to storyboard.
return scene




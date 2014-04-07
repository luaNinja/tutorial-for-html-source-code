-------------------------------------------------------------------------
--Mobieos Pvt. Ltd.
--Created by Anirban Mookherjee

--CoronaSDK version used 2013.2100

-------------------------------------------------------------------------


--Start off by requiring storyboard and creating a scene.
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()


-- Set up our variables and groups
local sqlite3 = require("sqlite3")  --For loading and saving into our database
local dbPath = system.pathForFile("fruit_scores.db3", system.DocumentsDirectory)
local db = sqlite3.open(dbPath)
local lowestScore = 0
local lowestLevel = 0
local isHighscore = false
local isLevelHighscore = false
local addTouchEventTimer
local highscoreFlashTimer
local gameOverAnimationTimer

local xMin = display.screenOriginX 
local yMin = display.screenOriginY
local xMax = display.contentWidth - display.screenOriginX
local yMax = display.contentHeight - display.screenOriginY
local xWidth = xMax-xMin --The total width
local yHeight = yMax-yMin --The total height
local _W = display.contentWidth
local _H = display.contentHeight


--Predeclare so we can access them from enterScene as well
local targetHighscoreText 
local highscoreText
local mainMenuButtonText 
local mainBackground 
local gameOverIcon 
local scoreText 
local levelText 



-----------------------------------------------
-- *** STORYBOARD SCENE EVENT FUNCTIONS ***
------------------------------------------------
-- Called when the scene's view does not exist:
-- Create all your display objects here.
function scene:createScene( event )
    print( "GameOver: createScene event")
    local screenGroup = self.view


   	------------
    -- DISPLAY OBJECTS
    ------------
    --Create the main UI
    targetHighscoreText = display.newText("New Highscore!", 0, 0, native.systemFontBold, 16)
	highscoreText = display.newText("New Highscore!", 0, 0, native.systemFontBold, 16)
	mainMenuButtonText = display.newImageRect("images/mainmenu.png", 228, 36)
	mainBackground = display.newImageRect("images/menu_bg.png", 360, 570)
	gameOverIcon = display.newImageRect("images/game_over.png", 108, 68)
	scoreText = display.newText("Final Score: " .. overallScore, 0, 0, native.systemFontBold, 16)
	levelText = display.newText("Level: " .. target - 2, 0, 0, native.systemFontBold, 16)


	------------
	--Now load the scores and display them etc!
  	------------
	-- Check if the score is higher than the lowest value in the database
	--We run a nil check because the first time you play there won't be any rows!
	for row in db:nrows("SELECT min(score) AS 'min' FROM scores") do
		if row.min ~= nil then 
			lowestScore = row.min
		end
    end
    if lowestScore < overallScore then isHighscore = true end


    -- Check if the score is higher than the lowest value in the database
	for row in db:nrows("SELECT min(level) AS 'min' FROM levels") do
		if row.min ~= nil then 
			lowestLevel = row.min
		end
    end
    if lowestLevel < target - 2 then isLevelHighscore = true end --we minus 2 because the 1st level has a target of 3.


    -- Add highscores to the database
    if isHighscore then
		local addScoreQuery = "INSERT INTO scores VALUES (NULL, " .. overallScore .. ", " .. (target - 2) .. ");\
		DELETE FROM scores WHERE score = (SELECT min(score) FROM scores) AND (SELECT count(*) FROM scores) > 10;"
		db:exec(addScoreQuery)
	end

	if isLevelHighscore then
		local addScoreQuery = "INSERT INTO levels VALUES (NULL, " .. overallScore .. ", " .. (target - 2) .. ");\
		DELETE FROM levels WHERE level = (SELECT min(level) FROM levels) AND (SELECT count(*) FROM levels) > 10;"
		db:exec(addScoreQuery)
	end

	db:close() -- Close the database


	-- Set up the UI
	mainBackground.x = xMin + 360 / 2
	mainBackground.y = yMin + 570 / 2

	gameOverIcon.x = _W / 2
	gameOverIcon.y = yMin + 100

	scoreText:setTextColor(0, 0, 0)
	scoreText.x = _W / 2
	scoreText.y = 200

	highscoreText:setTextColor(0, 0, 0)
	highscoreText.x = _W / 2
	highscoreText.y = 220
	if isHighscore then
		highscoreText.isVisible = true
	else
		highscoreText.isVisible = false
	end

	levelText:setTextColor(0, 0, 0)
	levelText.x = _W / 2
	levelText.y = 270

	targetHighscoreText:setTextColor(0, 0, 0)
	targetHighscoreText.x = _W / 2
	targetHighscoreText.y = 290
	if isLevelHighscore then
		targetHighscoreText.isVisible = true
	else
		targetHighscoreText.isVisible = false
	end

	mainMenuButtonText.x = _W / 2
	mainMenuButtonText.y = yMax - 40


	-- Add UI to screenGroup
	screenGroup:insert(mainBackground)
	screenGroup:insert(gameOverIcon)
	screenGroup:insert(scoreText)
	screenGroup:insert(highscoreText)
	screenGroup:insert(levelText)
	screenGroup:insert(targetHighscoreText)
	screenGroup:insert(mainMenuButtonText)
end



-- Called immediately after scene has moved onscreen:
-- Start timers/transitions etc.
function scene:enterScene( event )
    print( "GameOver: enterScene event" )

    -- Completely remove the previous scene/all scenes.
    -- Handy in this case where we want to keep everything simple.
    storyboard.removeAll()


  	------------
    --Functions and timers.
     ------------
    -- Move back to the main menu when the user presses the main menu button
	local function mainMenuOnTouch(event)
		if event.phase == "ended" then
			playSound("select")
			storyboard.gotoScene( "menu", "fade", 400 )
		end
		return true
	end

	-- Prevents the player from accidentally pressing the main menu button as soon as they enter the screen
	local function addTouchEvent(event)
		mainMenuButtonText:addEventListener("touch", mainMenuOnTouch)
	end

	-- Flashes the high score labels if they're visible
	local function flashHighscores(event)
		if isHighscore then
			highscoreText.isVisible = not highscoreText.isVisible
		end
		if isLevelHighscore then
			targetHighscoreText.isVisible = not targetHighscoreText.isVisible
		end
	end

	-- Animate the game over icon
	local function gameOverAnimate(event)
		gameOverIcon.y = math.sin(event.count / 10) * 10 + yMin + 100
	end


	-- Add event listeners and timers
	addTouchEventTimer = timer.performWithDelay(2000, addTouchEvent, 1)
	highscoreFlashTimer = timer.performWithDelay(500, flashHighscores, 0)
	gameOverAnimationTimer = timer.performWithDelay(20, gameOverAnimate, 0)
end



-- Called when scene is about to move offscreen:
-- Cancel Timers/Transitions and Runtime Listeners etc.
function scene:exitScene( event )
    print( "GameOver: exitScene event" )
    timer.cancel(addTouchEventTimer); addTouchEventTimer = nil
	timer.cancel(highscoreFlashTimer); highscoreFlashTimer = nil
	timer.cancel(gameOverAnimationTimer); gameOverAnimationTimer = nil
end



--Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
    print( "GameOver: destroying view" )
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


	

	




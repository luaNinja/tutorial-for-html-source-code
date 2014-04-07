-------------------------------------------------------------------------
--Mobieos Pvt. Ltd.
--Created by Anirban Mookherjee

--CoronaSDK version used 2013.2100

-------------------------------------------------------------------------


--Start off by requiring storyboard and creating a scene.
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()


-- Set up our variables and groups ***
local menuTouchGroup --Made in the storyboard functions.
local menuBackgroundGroup

local xMin = display.screenOriginX 
local yMin = display.screenOriginY
local xMax = display.contentWidth - display.screenOriginX
local yMax = display.contentHeight - display.screenOriginY
local xWidth = xMax-xMin --The total width
local yHeight = yMax-yMin --The total height
local _W = display.contentWidth
local _H = display.contentHeight
local menuTouchGroupTimer
local menuLogoTransition


--Predecalre the images etc
local menuLogo
local menuBackground
local playText
local highscoreText



-----------------------------------------------
-- *** STORYBOARD SCENE EVENT FUNCTIONS ***
------------------------------------------------
-- Called when the scene's view does not exist:
-- Create all your display objects here.
function scene:createScene( event )
    print( "Menu: createScene event")
    local screenGroup = self.view

    --Now make our display groups and insert them into the screengroup.
    menuTouchGroup = display.newGroup()
    menuBackgroundGroup = display.newGroup()
    screenGroup:insert(menuBackgroundGroup)
    screenGroup:insert(menuTouchGroup)
    
    ------------
    -- DISPLAY OBJECTS
    ------------
    menuLogo = display.newImageRect("images/logo.png", 304, 104)
	menuBackground = display.newImageRect("images/menu_bg.png", 360, 570)
	playText = display.newImageRect("images/start.png", 240, 36)
	highscoreText = display.newImageRect("images/highscores.png", 256, 36)

	--
	menuBackground.x = xMin + 360 * 0.5
	menuBackground.y = yMin + 570 * 0.5
	menuBackgroundGroup:insert(menuBackground);
	
	playText.x = _W / 2
	playText.y = yMax - 160
	
	highscoreText.x = _W / 2
	highscoreText.y = yMax - 80

	menuLogo.x = _W / 2
	menuLogo.y = yMin - 100

	menuTouchGroup:insert(menuLogo)
	menuTouchGroup:insert(playText)
	menuTouchGroup:insert(highscoreText)


	-- Add create enough tiles to fill the screen
	for i = 1, 126 do
		local newTile = display.newImageRect(tileIconSheet, math.random(1, 8), 30, 30)
		newTile.x = xMin + (i - 1) % 9 * 40 + 20
		newTile.y = yMin + math.floor((i - 1) / 9) * 40 + 20
		newTile.alpha = 0.3
		menuBackgroundGroup:insert(newTile)
	end
end



-- Called immediately after scene has moved onscreen:
-- Start timers/transitions etc.
function scene:enterScene( event )
    print( "Menu: enterScene event" )

    -- Completely remove the previous scene/all scenes.
    -- Handy in this case where we want to keep everything simple.
    storyboard.removeAll()


    -- Slide the logo into the screen
	-- Animate the logo
	local function menuTick (event)
		menuLogo.y = math.sin(event.count / 10) * 10 + yMin + 100
	end
	local function animateLogo ()
		menuTouchGroupTimer = timer.performWithDelay(20, menuTick, 0)
	end
	menuLogoTransition = transition.to(menuLogo, {time=1000, y=yMin + 100, transition=easing.outQuad, onComplete=animateLogo})
	


	-- Set up touch events
	-- When the user presses start game
	local function onStartGameTouch (event)
		if event.phase == "ended" then
			playSound("select")
			storyboard.gotoScene( "game", "fade", 400 )
		end
		return true
	end

	-- When the user presses highscore
	local function onHighscoreGameTouch (event)
		if event.phase == "ended" then
			playSound("select")
			storyboard.gotoScene( "highscores", "fade", 400 )
		end
		return true
	end
	playText:addEventListener("touch", onStartGameTouch)
	highscoreText:addEventListener("touch", onHighscoreGameTouch)
end



-- Called when scene is about to move offscreen:
-- Cancel Timers/Transitions and Runtime Listeners etc.
function scene:exitScene( event )
    print( "Menu: exitScene event" )
    if menuTouchGroupTimer ~= nil then 
   	 	timer.cancel(menuTouchGroupTimer); menuTouchGroupTimer = nil
   	end
   	if menuLogoTransition ~= nil then 
   		transition.cancel(menuLogoTransition); menuLogoTransition = nil
   	end
end



--Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
    print( "Menu: destroying view" )
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

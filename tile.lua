-------------------------------------------------------------------------
--Mobieos Pvt. Ltd.
--Created by Anirban Mookherjee

--CoronaSDK version used 2013.2100

-------------------------------------------------------------------------

local tile = {}
local tile_mt = { __index = tile }

-- Constructor
function tile.new(tileType, tileIndex, isHidden)
    local newTile = {
        tileType = tileType,
        tileIndex = tileIndex,
        tileImage = display.newImageRect(tileIconSheet, tileType, 30, 30),
        hasBeenCheckedH = false,
        hasBeenCheckedV = false,
        willBePopped = false,
        fallingHeight = 2200,
        tileOffsetY = 0,
        tileOffsetX = 0,
        shouldMoveBack = false,
        moveBackDirection = 0,
        isHidden = isHidden
    }

    -- Update the tile position
    newTile.tileImage.x = (newTile.tileIndex - 1) % 8 * 40 + 20 - newTile.tileOffsetX
    newTile.tileImage.y = math.floor((newTile.tileIndex - 1) / 8) * 40 + 120 - newTile.tileOffsetY - newTile.fallingHeight

    -- Hide the tiles which have been matched
    if newTile.willBePopped then
        newTile.tileImage.isVisible = 0

    else
        newTile.tileImage.isVisible = 1
    end

    if newTile.isHidden then
        tileType = -1
    end

    return setmetatable(newTile, tile_mt)
end

-- Update this tile
function tile:update()
    -- Update fall distance
    if self.isHidden and self.tileImage.isVisible == true then
        print("tarun.. is hidden update:".. self.tileIndex)

            self.tileImage.isVisible = false
            self.tileType = -1
        return
    end
    if self.fallingHeight > 0 then
        self.fallingHeight = self.fallingHeight - 20
        if self.fallingHeight < 0 then
            self.fallingHeight = 0
        end
    end

    -- Move tileOffsets closer to 0
    if self.tileOffsetX > 0 then
        self.tileOffsetX = self.tileOffsetX - 10
        if self.tileOffsetX < 0 then
            self.tileOffsetX = 0
        end
    elseif self.tileOffsetX < 0 then
        self.tileOffsetX = self.tileOffsetX + 10
        if self.tileOffsetX > 0 then
            self.tileOffsetX = 0
        end
    end

    if self.tileOffsetY > 0 then
        self.tileOffsetY = self.tileOffsetY - 10
        if self.tileOffsetY < 0 then
            self.tileOffsetY = 0
        end
    elseif self.tileOffsetY < 0 then
        self.tileOffsetY = self.tileOffsetY + 10
        if self.tileOffsetY > 0 then
            self.tileOffsetY = 0
        end
    end

    -- Reposition tile
    self.tileImage.y = math.floor((self.tileIndex - 1) / 8) * 40 + 120 - self.tileOffsetY - self.fallingHeight
    self.tileImage.x = (self.tileIndex - 1) % 8 * 40 + 20 - self.tileOffsetX
    if self.willBePopped  then
        self.tileImage.isVisible = 0
    elseif self.isHidden ~= true then
        self.tileImage.isVisible = 1
    end
    
end

-- Update a tile type and its image and position
function tile:setTileType(tileType)

    if self.isHidden  then
        --self.tileImage.isVisible = 0
        --tileImage:removeSelf()
        print("tarun.. is hidden:".. self.tileIndex )
        self.tileType = -1
        return
    end

    self.tileType = tileType
    self.tileImage:removeSelf()
    
    self.tileImage = display.newImageRect(tileIconSheet, self.tileType, 30, 30)

    self.tileImage.y = math.floor((self.tileIndex - 1) / 8) * 40 + 120 - self.tileOffsetY - self.fallingHeight
    self.tileImage.x = (self.tileIndex - 1) % 8 * 40 + 20 - self.tileOffsetX
    if self.willBePopped then
        self.tileImage.isVisible = 0
    elseif self.isHidden ~= false then
        self.tileImage.isVisible = 1
    end
    
end

return tile

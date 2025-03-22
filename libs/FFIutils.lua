local FFIutils = {}
local ffi = require("ffi")

-- Define all your C structs
ffi.cdef[[
typedef struct {
    double x, y;
} Vec2;

typedef struct {
    Vec2 pos;
    double angle;
    int number;
    int type;
} Entity;

typedef struct {
    Vec2 start;
    Vec2 end;
} Wall;

typedef struct {
    Entity* entities;
    size_t entityCount;
    Wall* walls;
    size_t wallCount;
} GameState;
]]

function FFIutils.CreateSharedState(maxEntities, maxWalls)
    -- Allocate arrays
    local Entities = ffi.new("Entity[?]", maxEntities)
    local Walls = ffi.new("Wall[?]", maxWalls)
    -- Allocate the GameState struct
    local gameState = ffi.new("GameState")
    
    -- Assign entity and wall pointers
    gameState.entities = Entities
    gameState.entityCount = maxEntities
    gameState.walls = Walls
    gameState.wallCount = maxWalls
    
    return ffi.cast("GameState*", gameState)
end


return FFIutils
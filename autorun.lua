---@diagnostic disable: undefined-global

local stnt = elements.allocate("MOD", "STNT")
elements.element(stnt, elements.element(elements.DEFAULT_PT_TNT))
elements.property(stnt, "Name", "STNT")
elements.property(stnt, "Description", "Super TNT. More destructive than normal TNT.")
elements.property(stnt, "Colour", 0xFF5500)
elements.property(stnt, "Flammable", 100000)
elements.property(stnt, "Explosive", 1)

local function stntUpdate(i,x,y,s,nt)  
    for r in sim.neighbors(x,y,1,1) do
        local nearPart = sim.partProperty(r, "type")
        if nearPart == elem.DEFAULT_PT_FIRE or nearPart == elem.DEFAULT_PT_PLSM or sim.partProperty(i, "temp") >= 1000 then
            for _ = 1, 50 do
                sim.partCreate(-1, x, y, elem.DEFAULT_PT_PLSM)
                
                sim.partProperty(r, "temp", 10000)
                sim.pressure(x/4, y/4, 2147483647)
                
            end
            if math.random(1, 10000) <= 200 then
                sim.partCreate(0, x, y, elem.MOD_PT_STNT)
            end
        end
    end
end

elements.property(stnt, "Update", stntUpdate)


local meat = elements.allocate("MOD", "MEAT")
elements.element(meat, elements.element(elements.DEFAULT_PT_CLST))
elements.property(meat, "Name", "MEAT")
elements.property(meat, "Description", "Meat. Can be cooked.")
elements.property(meat, "Colour", 0xDE332F)
elements.property(meat, "HighTemperature", 120)
elements.property(meat, "HighTemperatureTransition", -1)

local function meatUpdate(i,x,y,s,nt)  
    local currentTemp = sim.partProperty(i, "temp")
    if currentTemp > 80+273.15 and math.random(1, 10000) <= currentTemp * currentTemp then
        sim.partChangeType(i, elem.MOD_PT_CMET)
    end
end

elements.property(meat, "Update", meatUpdate)


local cmet = elements.allocate("MOD", "CMET")
elements.element(cmet, elements.element(elements.DEFAULT_PT_CLST))
elements.property(cmet, "Name", "CMET")
elements.property(cmet, "Description", "Cooked Meat.")
elements.property(cmet, "Colour", 0x4B2D12)
elements.property(cmet, "HighTemperature", 300)
elements.property(cmet, "HighTemperatureTransition", -1)

local function cmetUpdate(i,x,y,s,nt)  
    local currentTemp = sim.partProperty(i, "temp")
    if currentTemp > 200+273.15 and math.random(1, 10000) <= currentTemp * currentTemp / 100 then
        sim.partChangeType(i, elem.DEFAULT_PT_BCOL)
    end
end

elements.property(cmet, "Update", cmetUpdate)


local nuke = elements.allocate("MOD", "NUKE")
elements.element(nuke, elements.element(elements.DEFAULT_PT_SAND))
elements.property(nuke, "Name", "NUKE")
elements.property(nuke, "Description", "Nuclear Bomb. Extremely destructive.")
elements.property(nuke, "Colour", 0x00FF00)
elements.property(nuke, "Temperature", 0)
elements.property(nuke, "MenuSection", elements.SC_NUCLEAR)
elements.property(nuke, "HighTemperature", 10000)
elements.property(nuke, "HighTemperatureTransition", elements.MOD_PT_NUKE)

local function nukeUpdate(i,x,y,s,nt)  
    if sim.partProperty(i, "temp") >= 273.15 then
        local radius = 12
    for r in sim.neighbors(x,y,4,4) do
        for rep = 1, 50, 1 do
            sim.partCreate(0, x + math.random(-radius, radius), y + math.random(-radius, radius), elem.MOD_PT_UTHT)
            sim.partCreate(0, x + math.random(-radius, radius), y + math.random(-radius, radius), elem.DEFAULT_PT_PLSM)
            sim.partCreate(0, x + math.random(-radius, radius), y + math.random(-radius, radius), elem.DEFAULT_PT_WARP)
            sim.partCreate(0, x + math.random(-radius, radius), y + math.random(-radius, radius), elem.MOD_PT_NUKE)
        end
        sim.partProperty(r, "tmp", 2147483647)
        sim.partProperty(r, "life", 0)
        sim.partProperty(r, "type", elem.DEFAULT_PT_SING)
        sim.partProperty(i, "tmp", 2147483647)
        sim.partProperty(i, "life", 0)
        sim.partProperty(i, "type", elem.DEFAULT_PT_SING)
    end
    end
end

elements.property(nuke, "Update", nukeUpdate)

local utht = elements.allocate("MOD", "UTHT")
elements.element(utht, elements.element(elements.DEFAULT_PT_ANAR))
elements.property(utht, "Name", "UTHT")
elements.property(utht, "Description", "Ultra Heat. Heats nearby particles to max temperature.")
elements.property(utht, "Colour", 0xFF0000)
elements.property(utht, "Temperature", 10000)
elements.property(utht, "MenuSection", elements.SC_EXPLOSIVE)

local function uthtUpdate(i,x,y,s,nt)
    for r in sim.neighbors(x,y,4,4) do
        sim.partProperty(r, "temp", 10000)
    end
    if math.random(1, 100) <= 4 then
        sim.partProperty(i, "life", sim.partProperty(i, "life") + 1)
    end
    if sim.partProperty(i, "life") >= 20 then
        sim.partKill(i)
    end
end

elements.property(utht, "Update", uthtUpdate)
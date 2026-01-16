function Sleep(ms)
    local t = os.clock()
    local ms = ms / 1000
    while os.clock() - t <= ms do
    end
end

local UC4 = elements.allocate("MOD", "UC4")
elements.element(UC4, elements.element(elements["DEFAULT_PT_C-4"]))
elements.property(UC4, "Name", "UC4")
elements.property(UC4, "Description", "Ultra C-4. Highly unstable explosive that can be triggered by fire or high temperatures.")
elements.property(UC4, "Colour", 0xb24ffd)
elements.property(UC4, "Flammable", 100000)
elements.property(UC4, "Explosive", 2)

local function UC4Update(i,x,y,s,nt)  
    local myTemp = sim.partProperty(i, "temp") or 0
    for r in sim.neighbors(x,y,1,1) do
        local nearPart = sim.partProperty(r, "type")
        if nearPart == elem.DEFAULT_PT_FIRE or nearPart == elem.DEFAULT_PT_PLSM or myTemp >= 1000 then
            -- reduce number of creations and avoid repeated expensive calls
            for _ = 1, 4 do
                sim.partCreate(-1, x + math.random(-1,1), y + math.random(-1,1), elem.DEFAULT_PT_PLSM)
            end
            sim.partProperty(r, "temp", 10000)
            sim.pressure(x/4, y/4, 256)
            if math.random(1, 10000) <= 200 then
                sim.partCreate(0, x, y, elem.MOD_PT_UC4)
            end
        end
    end
end

elements.property(UC4, "Update", UC4Update)


local meat = elements.allocate("MOD", "MEAT")
elements.element(meat, elements.element(elements.DEFAULT_PT_CLST))
elements.property(meat, "Name", "MEAT")
elements.property(meat, "Description", "Meat. Can be cooked.")
elements.property(meat, "Colour", 0xDE332F)
elements.property(meat, "HighTemperature", 120)
elements.property(meat, "HighTemperatureTransition", -1)

local function meatUpdate(i,x,y,s,nt)  
    local currentTemp = sim.partProperty(i, "temp")
    if currentTemp > 80+273.15 and math.random(1, 10000) <= currentTemp * currentTemp / 10 then
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
        sim.partChangeType(i, elem.MOD_PT_ASH)
    end
end

elements.property(cmet, "Update", cmetUpdate)


local ash = elements.allocate("MOD", "ASH")
elements.element(ash, elements.element(elements.DEFAULT_PT_SAWD))
elements.property(ash, "Name", "ASH")
elements.property(ash, "Colour", 0xA0A0A0)
elements.property(ash, "Flammable", 0)
elements.property(ash, "Description", "Ash. Created from burnt element.")
elements.property(ash, "Properties", elem.TYPE_PART)
elements.property(ash, "Advection", 0.5)

local function ashGraphics(i,colr,colg,colb)
    local t = (sim.partProperty(i, "temp") or 0) - 273.15
    if t > 1000 then
        return 0, ren.PMODE_FLAT, 255, 226, 58, 58, 0, 0, 0, 0
    elseif t > 550 then
        return 0, ren.PMODE_FLAT, 255, 209, 95, 95, 0, 0, 0, 0
    elseif t > 200 then
        return 0, ren.PMODE_FLAT, 255, 174, 142, 142, 0, 0, 0, 0
    else
        return 0, ren.PMODE_FLAT, 255, 160, 160, 160, 0, 0, 0, 0
    end
end

elements.property(ash, "Graphics", ashGraphics)

local nuke = elements.allocate("MOD", "NUKE")
elements.element(nuke, elements.element(elements.DEFAULT_PT_CNCT))
elements.property(nuke, "Name", "NUKE")
elements.property(nuke, "Description", "Nuclear Bomb. Extremely destructive.")
elements.property(nuke, "Colour", 0x00FF00)
elements.property(nuke, "Temperature", 0)
elements.property(nuke, "MenuSection", elements.SC_NUCLEAR)
elements.property(nuke, "Properties", elem.TYPE_PART + elem.PROP_RADIOACTIVE)
elements.property(nuke, "HighTemperature", 10000)
elements.property(nuke, "HighTemperatureTransition", elements.MOD_PT_NUKE)
elements.property(nuke, "Gravity", 0.01)
elements.property(nuke, "Advection", 0.0001)

local function nukeUpdate(i,x,y,s,nt)
    local myTemp = sim.partProperty(i, "temp") or 0
    local myPressure = sim.pressure(x/4, y/4) or 0
    if myTemp >= 273.15 or math.abs(myPressure) >= 3 then
        sim.pressure(x/4, y/4, 2147483647)
        sim.createBox(x-3, y-3, x+3, y+3, elem.DEFAULT_PT_SING)
        for r in sim.neighbors(x, y, 3, 3) do
            sim.partChangeType(r, elem.DEFAULT_PT_SING)
            sim.partProperty(r, "tmp", 2147483647)
            sim.partProperty(r, "life", 0)
        end
        sim.partKill(i)
    end
end

elements.property(nuke, "Update", nukeUpdate)

local uth = elements.allocate("MOD", "UHT")
elements.element(uth, elements.element(elements.DEFAULT_PT_ANAR))
elements.property(uth, "Name", "UHT")
elements.property(uth, "Description", "Ultra Heat. Heats nearby particles to max temperature.")
elements.property(uth, "Colour", 0xFF0000)
elements.property(uth, "Temperature", 10000)
elements.property(uth, "MenuSection", elements.SC_EXPLOSIVE)
local function uhtUpdate(i,x,y,s,nt)
    local life = sim.partProperty(i, "life") or 0
    -- throttle neighbor heating: only run every 3 life ticks and reduce radius
    if (life % 3) == 0 then
        for r in sim.neighbors(x,y,2,2) do
            sim.partProperty(r, "temp", 10000)
        end
    end
    if math.random(1, 100) <= 4 then
        sim.partProperty(i, "life", life + 1)
    end
    if sim.partProperty(i, "life") >= 20 then
        sim.partKill(i)
    end
end
elements.property(uth, "Update", uhtUpdate)


local pirn = elements.allocate("MOD", "PIRN")
elements.element(pirn, elements.element(elements.DEFAULT_PT_IRON))
elements.property(pirn, "Name", "PIRN")
elements.property(pirn, "Description", "Pig Iron. Created when COKE and BRMT(iron ore) are heated together.")
elements.property(pirn, "Colour", 0x805757)
elements.property(pirn, "HighTemperature", 1000+273.15)
elements.property(pirn, "HighPressure", 1)
elements.property(pirn, "HighPressureTransition", elem.DEFAULT_PT_BRMT)

local stel = elements.allocate("MOD", "STEL")
elements.element(stel, elements.element(elements.DEFAULT_PT_METL))
elements.property(stel, "Name", "STEL")
elements.property(stel, "Description", "Steel. Created when molten PIRN touches OXYG")
elements.property(stel, "Colour", 0x979797)
elements.property(stel, "HighTemperature", 1420+273.15)
elements.property(stel, "MenuSection", elem.SC_SOLIDS)

local co = elements.allocate("MOD", "CO")
elements.element(co, elements.element(elements.DEFAULT_PT_CO2))
elements.property(co, "Name", "CO")
elements.property(co, "Description", "Carbon Monoxide.")
elements.property(co, "Colour", 0x3c3c3c)
elements.property(co, "Properties", elem.TYPE_GAS + elem.PROP_DEADLY)

local coke = elements.allocate("MOD", "COKE")
elements.element(coke, elements.element(elements.DEFAULT_PT_BCOL))
elements.property(coke, "Name", "COKE")
elements.property(coke, "Description", "Coke (fuel). Created when bcol is heated.")
elements.property(coke, "Colour", 0x4F4F4F)

local function cokeUpdate(i, x, y, s, nt)
    -- 자신의 속성을 미리 변수에 저장 (API 호출 횟수 감소)
    local myTemp = sim.partProperty(i, "temp")
    if myTemp == nil then return end -- 안전 장치

    -- 온도가 낮으면 이웃 검사조차 하지 않음 (조기 종료로 성능 향상)
    local firePoint = 400 + ((8 - s) * 25) + 273.15 -- 막힘 정도에 따른 발화점 조정
    if myTemp < firePoint then return end

    -- 주변 입자 검사
    local ignited = false
    for r in sim.neighbors(x, y, 1, 1) do
        local rType = sim.partProperty(r, "type")
        if rType == elements.DEFAULT_PT_FIRE or rType == elements.DEFAULT_PT_PLSM or rType == elem.DEFAULT_PT_LAVA or rType == elem.DEFAULT_PT_LIGH then
            ignited = true
            break -- 불을 찾았으면 더 이상 루프를 돌 필요 없음
        end
    end

    -- 발화 로직
    if ignited then
        local chance = math.max(100, 1200+273.15 - (myTemp - firePoint) * 3)  -- 온도가 높아지면 연소가 더 잘 됨.
        if math.random(1, chance) <= 100 then
            for _ = 1, 2 do
                if s < 1 then  -- 주변이 막혀있으면 불완전연소로 일산화탄소(SMKE) 생성
                    if math.random(1, 2) == 1 then
                        sim.partCreate(-1, x + math.random(-1, 1), y + math.random(-1, 1), elements.DEFAULT_PT_FIRE)
                    else
                        sim.partCreate(-1, x + math.random(-1, 1), y + math.random(-1, 1), elements.MOD_PT_CO)
                    end
                    if myTemp < 1600+273.15 then
                    local nextTemp = myTemp + math.random(30+273.15, 45+273.15)
                    sim.partProperty(i, "temp", nextTemp)
                    end
                else  -- 충분한 공간이 있으면 불 생성
                sim.partCreate(-1, x + math.random(-1, 1), y + math.random(-1, 1), elements.DEFAULT_PT_FIRE)
                if myTemp < 2100+273.15 then
                    local nextTemp = myTemp + math.random(50+273.15, 70+273.15)
                    sim.partProperty(i, "temp", nextTemp)
                end
                
                end
                if math.random(1, 600) == 1 then
                    sim.partKill(i)
                end
            end
        end
    end
end
elements.property(coke, "Update", cokeUpdate)

local function cokeGraphics(i,colr,colg,colb)
    local temp = (sim.partProperty(i, "temp") or 0) - 273.15
    local r
    local g
    local b

    if temp < 500 then
        r = 40
        g = 40
        b = 40
    elseif temp < 1250 then
        r = 40 + (temp - 500) * 0.25
        g = 40
        b = 40
    elseif temp < 2000 then
        r = 230
        g = 40 + (temp - 1300) * 0.21
        b = 40
    else
        r = 230
        g = 200
        b = 150
    end
    
    return 0, ren.PMODE_FLAT, 255, r, g, b, 0, 0, 0, 0

end

elements.property(coke, "Graphics", cokeGraphics)


local irno = elements.allocate("MOD", "IRNO")
elements.element(irno, elements.element(elements.DEFAULT_PT_BRMT))
elements.property(irno, "Name", "IRNO")
elements.property(irno, "Description", "Iron Ore.")
elements.property(irno, "Colour", 0x8B4513)
elements.property(irno, "HighTemperature", 1000+273.15)
elements.property(irno, "HighTemperatureTransition", elem.DEFAULT_PT_LAVA)

local ch4 = elements.allocate("MOD", "CH4")
elements.element(ch4, elements.element(elements.DEFAULT_PT_GAS))
elements.property(ch4, "Name", "CH4")
elements.property(ch4, "Description", "Methane.")
elements.property(ch4, "Colour", 0x00B0CF)
elements.property(ch4, "Flammable", 1500)
elements.property(ch4, "HighTemperature", 10000)
elements.property(ch4, "HighPressureTransition", -1)


local function ch4Update(i,x,y,s,nt)
    local rType
    local myTemp
    for r in sim.neighbors(x,y,1,1) do
        rType = sim.partProperty(r, "type")
        myTemp = sim.partProperty(i, "temp")
        if rType == elements.DEFAULT_PT_FIRE or rType == elements.DEFAULT_PT_PLSM or rType == elem.DEFAULT_PT_LAVA or rType == elem.DEFAULT_PT_LIGH then
            if myTemp < 1950+273.15 then
                local nextTemp = myTemp + math.random(55+273.15, 75+273.15)
                sim.partProperty(i, "temp", nextTemp)
                sim.pressure(x/4, y/4, math.random(0.2, 0.3))
                end
            sim.partChangeType(i, elements.DEFAULT_PT_FIRE)
        elseif rType == elem.DEFAULT_PT_OXYG and myTemp >= 537+273.15 then
            if myTemp < 2800+273.15 then
                local nextTemp = myTemp + math.random(100+273.15, 125+273.15)
                sim.partProperty(i, "temp", nextTemp)
                sim.pressure(x/4, y/4, math.random(0.3, 0.5))
                end
            sim.partChangeType(i, elements.DEFAULT_PT_FIRE)
        end
    end
end

elements.property(ch4, "Update", ch4Update)


local function createAsh(i,x,y,s,nt)
    local myTemp = sim.partProperty(i, "temp") or 0
    if myTemp < 100 then return end
    -- throttle: only run chance calculation occasionally to reduce load
    if math.random(1,4) ~= 1 then return end

    local myType = sim.partProperty(i, "type")
    for r in sim.neighbors(x,y,1,1) do
        local rType = sim.partProperty(r, "type")
        local base = 10 + math.max(0, (myTemp - 200) * 2)
        local chanceVal = math.random(1, math.max(2, base))
        if myType == elem.DEFAULT_PT_WOOD then
            chanceVal = math.random(1, 5 + math.max(0, (myTemp - 200) * 1))
        end
        if rType == elements.DEFAULT_PT_FIRE and chanceVal <= 10 then
            sim.partCreate(-1, x + math.random(-1, 1), y + math.random(-1,1), elem.MOD_PT_ASH)
        end
    end
end

--BCOL을 고온에서 COKE로 변환하는 코드
local function bcolUpdate(i, x, y, s, nt)
    if sim.partProperty(i, "temp") > 1000+273.15 then
        for r in sim.neighbors(x,y,1,1) do
            if sim.partProperty(r, "type") ~= elem.DEFAULT_PT_OXYG then
                if math.random(1, 100) < 1 + math.min(9, 0.003 * (sim.partProperty(i, "temp") - 1000-273.15)) then
                    sim.partChangeType(i, elem.MOD_PT_COKE)  -- 1000도 이상에서만 코크스로 변환
                    local rand = math.random(1,100)
                    if rand <= 2 then
                        sim.partCreate(-1, x + math.random(-1,1), y + math.random(-1,1), elem.DEFAULT_PT_CO2)
                    elseif rand <= 10 then
                        sim.partCreate(-1, x + math.random(-1,1), y + math.random(-1,1), elem.MOD_PT_CO)
                    elseif rand <= 40 then
                        sim.partCreate(-1, x + math.random(-1,1), y + math.random(-1,1), elem.MOD_PT_CH4)
                    else
                        sim.partCreate(-1, x + math.random(-1,1), y + math.random(-1,1), elem.DEFAULT_PT_HYGN)
                    end
                end
                return
            else 
                if math.random(1, 100) <= 2 then
                    sim.partChangeType(r, elem.DEFAULT_PT_FIRE)
                    return
                end
            end
        end
    end
    createAsh(i,x,y,s,nt)
end

elements.property(elements.DEFAULT_PT_BCOL, "Update", bcolUpdate)
elements.property(elements.DEFAULT_PT_WOOD, "Update", createAsh)
elements.property(elements.DEFAULT_PT_COAL, "Update", createAsh)
elements.property(elements.DEFAULT_PT_SAWD, "Update", createAsh)
elements.property(elements.DEFAULT_PT_PLNT, "Update", createAsh)

local function lavaUpdate(i, x, y, s, nt)
    local iCtype = sim.partProperty(i, "ctype")
    if not iCtype then return end  -- ctype이 없으면 종료
    
    for r in sim.neighbors(x, y, 2, 2) do
        local rType = sim.partProperty(r, "type")
        if not rType then return end  -- type이 없으면 건너뛰기

        if iCtype == elem.MOD_PT_IRNO and rType == elem.MOD_PT_CO then  -- COKE로 생성한 CO(일산화탄소)와 용융된 BRMT(철 광석)을 반응시켜 선철(PIRN) 제련
            sim.partProperty(i, "ctype", elem.MOD_PT_PIRN)
            sim.partChangeType(r, elem.DEFAULT_PT_CO2)  -- CO를 CO2(이산화탄소)로 변환
        end

        if iCtype == elem.MOD_PT_PIRN and rType == elem.DEFAULT_PT_OXYG then -- 선철을 산소와 반응시켜 강철(METL) 생성
            sim.partProperty(i, "ctype", elem.MOD_PT_STEL)
            if sim.pressure(x/4, y/4) <= 5 then
            sim.pressure(x/4, y/4, math.random(0.4, 1.6))
            end
            sim.createBox(x-1, y-1, x+1, y+1, elem.DEFAULT_PT_FIRE)
        end
    end
end

elements.property(elements.DEFAULT_PT_LAVA, "Update", lavaUpdate)


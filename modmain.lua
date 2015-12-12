-- V1.0 Release version

-- Created by Soilworker
--------------------------------------------------------------------------------------------

Assets = {
	Asset("ATLAS", "images/circlesegment_2.xml"),
	Asset("ATLAS", "images/circlesegment_3.xml"),
	Asset("ATLAS", "images/circlesegment_4.xml"),
	Asset("ATLAS", "images/circlesegment_5.xml"),
	Asset("ATLAS", "images/circlesegment_6.xml"),
	Asset("ATLAS", "images/circlesegment_7.xml"),
	Asset("ATLAS", "images/circlesegment_8.xml"),
	Asset("ATLAS", "images/circlesegment_9.xml"),
	Asset("ATLAS", "images/circlesegment_10.xml"),
	Asset("ATLAS", "images/circlesegment_11.xml"),
	Asset("ATLAS", "images/circlesegment_12.xml"),
	Asset("ATLAS", "images/circlesegment_13.xml"),
	Asset("ATLAS", "images/circlesegment_14.xml"),
	Asset("ATLAS", "images/circlesegment_16.xml"),
	Asset("ATLAS", "images/circlesegment_18.xml"),
	Asset("ATLAS", "images/circlesegment_21.xml"),
	Asset("ATLAS", "images/circlesegment_24.xml"),
	Asset("ATLAS", "images/circlesegment_30.xml"),
	Asset("ATLAS", "images/circlesegment_36.xml"),
	Asset("ATLAS", "images/circlesegment_45.xml"),
	Asset("ATLAS", "images/circlesegment_72.xml"),
}

local SeasonClock = GLOBAL.require("widgets/seasonclock")
local Vector3 = GLOBAL.require("vector3")

function AddSeasonClock( inst )
	local controls = inst.HUD.controls
	local seasonClock = SeasonClock(GetModConfigData("autumn_color"), GetModConfigData("winter_color"), GetModConfigData("spring_color"), GetModConfigData("summer_color"), GetModConfigData("hovertextoption"), GetModConfigData("hoverfontsize"), GetModConfigData("seasonfontsize"), GetModConfigData("texttodisplay"))
	local userClockPosition = GetModConfigData("clockposition")

	controls.sidepanel:AddChild(seasonClock)
	SetPositioning(controls, seasonClock)
	seasonClock:SetClockPosition(userClockPosition, controls.clock)	-- This will allow moving of the clock if its nighttime whenthe game loads...hacky but work for now
end

function SetPositioning(controls, seasonClock)
	local userClockPosition = GetModConfigData("clockposition")
	local clockPosition = seasonClock:GetPosition()
	local brainAdjustment = {x=0, y=0}
	local heartAdjustment = {x=0, y=0}
	local stomachAdjustment = {x=0, y=0}
	local rainAdjustment = {x=0, y=0}
	local naughtyAdjustment = {x=0, y=0}
	local temperatureAdjustment = {x=0, y=0}

	local inCaves = false

	-- Adjust for caves
	if GLOBAL.GetWorld() and GLOBAL.GetWorld():IsCave() and not GetModConfigData("showincave") then
		seasonClock:Hide()
		return
	elseif GLOBAL.GetWorld() and GLOBAL.GetWorld():IsCave() and GetModConfigData("showincave") then
		inCaves = true
	end

	if(userClockPosition == "leftofday" or userClockPosition == "rightofday") and not inCaves then
		clockPosition.x = -120
		brainAdjustment = {x=-60, y=-20}
		heartAdjustment = {x=-60, y=-20}
		stomachAdjustment = {x=-60, y=-20}
		rainAdjustment = {x=-60, y=-20}
		naughtyAdjustment = {x=-60, y=-20}
		temperatureAdjustment = {x=-60, y=-20}
		controls.sidepanel:SetPosition(-70,-70,0)	-- Paritally needed for Minimap HUD mod. Also for just looking good.

	elseif(userClockPosition == "belowday" or userClockPosition == "aboveday") and not inCaves then
		clockPosition.x = 0
		clockPosition.y = -130
		brainAdjustment.y = -140
		heartAdjustment.y = -140
		stomachAdjustment.y = -140
		rainAdjustment.y = -140
		naughtyAdjustment.y = -140
		temperatureAdjustment.y = -140
		
	elseif(inCaves) then
		clockPosition.x = -10
		brainAdjustment.y = -90
		heartAdjustment.y = -90
		stomachAdjustment.y = -90
		rainAdjustment.y = -90
		naughtyAdjustment.y = -90
		temperatureAdjustment.y = -90
	end

	if(userClockPosition == "rightofday" or userClockPosition == "aboveday") and not inCaves then
		dayClockPosition = controls.clock:GetPosition()
    	controls.clock:SetPosition(clockPosition.x, clockPosition.y, clockPosition.z)
		seasonClock:SetPosition(dayClockPosition.x, dayClockPosition.y, 0)
	else
		-- The day clock fits much better if we do this.
		dayClockPosition = controls.clock:GetPosition()
		controls.clock:SetPosition(dayClockPosition.x, dayClockPosition.y, dayClockPosition.z)
		seasonClock:SetPosition(clockPosition.x, clockPosition.y, 0)
	end

	-- Shift the other widgets down so ours fits nicely
	AdjustRoGControlsPositions(controls, seasonClock, brainAdjustment, heartAdjustment, stomachAdjustment, rainAdjustment, naughtyAdjustment, temperatureAdjustment)
	
end

function AdjustRoGControlsPositions(controls, seasonClock, brainAdjustment, heartAdjustment, stomachAdjustment, rainAdjustment, naughtyAdjustment, temperatureAdjustment)
	heartCurrentPosition = controls.status.heart:GetPosition()
	stomachCurrentPosition = controls.status.stomach:GetPosition()
	brainCurrentPosition = controls.status.brain:GetPosition()

	-- Move the Sanity, Hunger, and Health icons down
	controls.status.brain:SetPosition(brainCurrentPosition.x + brainAdjustment.x, brainCurrentPosition.y + brainAdjustment.y, brainCurrentPosition.z);
	controls.status.stomach:SetPosition(stomachCurrentPosition.x + stomachAdjustment.x, stomachCurrentPosition.y + stomachAdjustment.y, stomachCurrentPosition.z);
	controls.status.heart:SetPosition(heartCurrentPosition.x + heartAdjustment.x, heartCurrentPosition.y + heartAdjustment.y, heartCurrentPosition.z);

	-- Shift moisture meter
	if GLOBAL.IsDLCEnabled(GLOBAL.REIGN_OF_GIANTS) then
		moistureCurrentPosition = controls.status.moisturemeter:GetPosition()
		controls.status.moisturemeter:SetPosition(moistureCurrentPosition.x + rainAdjustment.x, moistureCurrentPosition.y + rainAdjustment.y, moistureCurrentPosition.z);
	end

	-- Accomodate for the "Always On Status" mod.
	for _, moddir in ipairs(GLOBAL.KnownModIndex:GetModsToLoad()) do
	    if GLOBAL.KnownModIndex:GetModInfo(moddir).name == "Always On Status" then
	    	naughtyCurrentPosition = controls.status.naughty:GetPosition()
			controls.status.naughty:SetPosition(naughtyCurrentPosition.x + naughtyAdjustment.x, naughtyCurrentPosition.y + naughtyAdjustment.y, naughtyCurrentPosition.z);

			temperatureCurrentPosition = controls.status.temperature:GetPosition()
			controls.status.temperature:SetPosition(temperatureCurrentPosition.x + temperatureAdjustment.x, temperatureCurrentPosition.y + temperatureAdjustment.y, temperatureCurrentPosition.z);
	    end
	end
end

function AdjustControlsForMods()

	naughtyCurrentPosition = controls.status.naughty:GetPosition()
			controls.status.naughty:SetPosition(naughtyCurrentPosition.x + naughtyAdjustment.x, naughtyCurrentPosition.y + naughtyAdjustment.y, naughtyCurrentPosition.z);

			temperatureCurrentPosition = controls.status.temperature:GetPosition()
			controls.status.temperature:SetPosition(temperatureCurrentPosition.x + temperatureAdjustment.x, temperatureCurrentPosition.y + temperatureAdjustment.y, temperatureCurrentPosition.z);

end

function DetermineModsEnabledToAccomodate()
	local alwaysOnStatus, miniMapHud, rpgHud = false, false, false

	-- Accomodate for the "Always On Status" mod.
	for _, moddir in ipairs(GLOBAL.KnownModIndex:GetModsToLoad()) do
	    if GLOBAL.KnownModIndex:GetModInfo(moddir).name == "Always On Status" then
	    	alwaysOnStatus = true
	    elseif (GLOBAL.KnownModIndex:GetModInfo(moddir).name == "Minimap HUD") then
	    	miniMapHud = true
	    elseif (GLOBAL.KnownModIndex:GetModInfo(moddir).name == "") then
	    end
	end

	return alwaysOnStatus, miniMapHud, rpgHud
end

--
AddSimPostInit(AddSeasonClock)
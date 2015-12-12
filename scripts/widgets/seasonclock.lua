local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"

-- We need to check if this is enabled, the vanilla season manager doesn't have the necessary methods and causes the loading of a 
-- saved game to hang. 
local reignOfGiantsEnabled = false
local isFocused = false

local SeasonClock = Class(Widget, function(self, autumn_color_option, winter_color_option, spring_color_option, summer_color_option, hover_text_option, hover_font_size, season_font_size, text_to_display)
	Widget._ctor(self, "SeasonClock")

	reignOfGiantsEnabled = IsDLCEnabled(REIGN_OF_GIANTS)

	-- Colors for the segments for the different seasons
	self.SUMMER_COLOR = self:GetColorForUserOption(summer_color_option)
	self.AUTUMN_COLOR = self:GetColorForUserOption(autumn_color_option)
	self.WINTER_COLOR = self:GetColorForUserOption(winter_color_option)
	self.SPRING_COLOR = self:GetColorForUserOption(spring_color_option)
	self.hoverTextOption = hover_text_option
	self.hoverFontSize = self:GetHoverFontSizeForUserOption(hover_font_size)
	self.seasonFontSize = self:GetSeasonFontSizeForUserOption(season_font_size)
	self.defaultTextToDisplay = text_to_display
	self.DARKEN_PERCENT = .90	
	self.adjustedForNight = false
	self.adjustedForDay = false

	local totalDaysInYear, summerLength, autumnLength, winterLength, springLength = self:GetSeasonSegments()

	-- DEBUG
	print(string.format("Total Days in Year: [%s]. Summer Length: [%s]. Autumn Length: [%s]. Winter Length [%s]. Spring Length: [%s].", tostring(totalDaysInYear), tostring(summerLength), tostring(autumnLength), tostring(winterLength), tostring(springLength)))

	-- Setup Scaling
    self.base_scale = 1
    self:SetScale(self.base_scale,self.base_scale,self.base_scale)

	-- Setup the clock animations (FIXME: May not be needed for the season clock. Need to re-evaluate later.)
	self.anim = self:AddChild(UIAnim())
    local sc = 1
    self.anim:SetScale(sc,sc,sc)
    self.anim:GetAnimState():SetBank("clock01")
    self.anim:GetAnimState():SetBuild("clock_transitions")
    self.anim:GetAnimState():PlayAnimation("idle_day",true)


    -- Determine the sized circle segment we need (360 / number of days in a year). We use the circle generated circle segments and place them around the face of the clock in a circle.
    self.segs = {}
	local segscale = .3
    local numsegs = totalDaysInYear
    local segmentDegree = math.floor(360/totalDaysInYear)
    for i = 1, numsegs do
		local seg = self:AddChild(Image("images/circlesegment_"..segmentDegree..".xml", "circlesegment_"..segmentDegree..".tex"))
        seg:SetScale(segscale,segscale,segscale)
        seg:SetHRegPoint(ANCHOR_LEFT)
        seg:SetVRegPoint(ANCHOR_BOTTOM)
        seg:SetRotation((i-1)*(360/numsegs))
        seg:SetClickable(false)
        table.insert(self.segs, seg)
    end
    -- Clock rims, hands, and text
    self.rim = self:AddChild(Image("images/hud.xml", "clock_rim.tex"))
    self.hands = self:AddChild(Image("images/hud.xml", "clock_hand.tex"))
    self.text = self:AddChild(Text(BODYTEXTFONT, self.seasonFontSize/self.base_scale))
    self.text:SetPosition(5, 0/self.base_scale, 0)
    self.rim:SetClickable(false)
    self.hands:SetClickable(false)

    -- Listen for day complete to update the hand positiion
    self.inst:ListenForEvent( "daycomplete", function(inst, data) self:SetClockHand() end, GetWorld())
    self.inst:ListenForEvent( "daycomplete", function(inst, data) self:UpdateSeasonString() end, GetWorld())
    self.inst:ListenForEvent( "nighttime", function() self:ShiftForMoonNighttime() end, GetWorld())
    self.inst:ListenForEvent( "daytime", function() self:ShiftForMoonDaytime() end, GetWorld())

	-- Register as a listener for the daycomplete event. Update season info string when this happens.
	self.inst:ListenForEvent( "seasonChange", function() self:UpdateSeasonString() end, GetWorld())

	self:CalcSegs()
	self:UpdateSeasonString()
	self:SetClockHand()
	self:Show()
end)

function SeasonClock:SetClockPosition(position, dayClock)
	self.position = position
	if(GetClock():IsNight()) then
		self:ShiftForMoonNighttime()
	end
end

-- Sets the clock hand to the proper rotation based on the current day into the "year"
function SeasonClock:SetClockHand()
	local seasonManager = GetSeasonManager()
	local totalDaysInYear, summerLength, autumnLength, winterLength, springLength = self:GetSeasonSegments()
	local daysIntoSeason = seasonManager:GetDaysIntoSeason()
	daysIntoSeason = self:RoundNumber(daysIntoSeason)
	local currentSeason = seasonManager:GetSeasonString()
	local daysIntoYear = 0

	if daysIntoSeason == 0 then
		daysIntoSeason = daysIntoSeason
	end

	if currentSeason == "summer" then
		daysIntoYear = daysIntoSeason  -- Since the clock starts at summer, probably a better more extensible way to do this later.
	elseif currentSeason == "autumn" then
		daysIntoYear = summerLength + daysIntoSeason
	elseif currentSeason == "winter" then
		daysIntoYear = summerLength + autumnLength + daysIntoSeason
	elseif currentSeason == "spring" then
		daysIntoYear = summerLength + autumnLength + winterLength + daysIntoSeason
	end

	local rotation = daysIntoYear * (360/totalDaysInYear)

	self.hands:SetRotation(rotation)
end

function SeasonClock:ShiftForMoonDaytime()
	if(self.position == "leftofday") then
		local currentPosition = self:GetPosition()
		self:SetPosition(currentPosition.x - -47, currentPosition.y, currentPosition.z)
	end
end

function SeasonClock:ShiftForMoonNighttime()
	if(self.position == "leftofday") then
		local currentPosition = self:GetPosition()
		self:SetPosition(currentPosition.x + -47, currentPosition.y, currentPosition.z)
	end
end

-- Determines what string to update depending on whether or not the user is currently focused (ie: in the case the user is hovering on the clock and the day complete event fires)
function SeasonClock:UpdateSeasonString()
	local hoverMethod, defaultMethod

	if (self.defaultTextToDisplay == "currentseason") then
		hoverMethod = self.UpdateNextSeasonString;
		defaultMethod = self.UpdateSeasonNameString;
	elseif (self.defaultTextToDisplay == "seasonprogress") then
		hoverMethod = self.UpdateSeasonNameString;
		defaultMethod = self.UpdateNextSeasonString
	else
		return -- Don't display anything.
	end

	if isFocused then
		hoverMethod(self)
	else
		defaultMethod(self)
	end
end

function SeasonClock:UpdateSeasonNameString()
	local currentSeason = self:GetPrettySeasonName()
	self.text:SetString(currentSeason)
	self.text:SetSize(self.seasonFontSize/self.base_scale)
end

function SeasonClock:UpdateNextSeasonString()
	SeasonClock._base.OnGainFocus(self)
	local clock_str = self:GenerateCurrentSeasonClockString()
	self.text:SetString(clock_str)
	self.text:SetSize(self.hoverFontSize/self.base_scale)
end

-- Get the total number of segments...multireturn:
-- total days of all enabled seasons, days in summer, days in autumn, days in winter, days in spring.
function SeasonClock:GetSeasonSegments()
	local seasonManager = GetSeasonManager()
	local summerLength = 0
	local autumnLength = 0
	local winterLength = 0
	local springLength = 0
	local totalDaysInYear = 0

	if(reignOfGiantsEnabled) then
		summerLength = seasonManager.summerenabled and seasonManager:GetSeasonLength(SEASONS.SUMMER) or 0
		autumnLength = seasonManager.autumnenabled and seasonManager:GetSeasonLength(SEASONS.AUTUMN) or 0
		winterLength = seasonManager.winterenabled and seasonManager:GetSeasonLength(SEASONS.WINTER) or 0
		springLength = seasonManager.springenabled and seasonManager:GetSeasonLength(SEASONS.SPRING) or 0
	else
		if(seasonManager.seasonmode == "endlesssummer") then
			summerLength = seasonManager.summerlength
		elseif(seasonManager.seasonmode == "endlesswinter") then
			winterLength = seasonManager.winterlength
		else
			summerLength = seasonManager.summerlength
			winterLength = seasonManager.winterlength
		end
	end

	totalDaysInYear = summerLength + autumnLength + winterLength + springLength
	return totalDaysInYear, summerLength, autumnLength, winterLength, springLength
end

local firstSummer, firstAutumn, firstWinter, firstSpring = true, true, true, true

-- Sets the colors of all segments in the clock.
function SeasonClock:CalcSegs()
    local dark = false

    local totalDaysInYear, summerLength, autumnLength, winterLength, springLength = self:GetSeasonSegments()

    for k,seg in pairs(self.segs) do
        local color = nil
        seg:Show()
        
        if k >= 0 and k <= summerLength then
        	color = self.SUMMER_COLOR
        elseif k > summerLength and k <= (summerLength + autumnLength) then
        	color = self.AUTUMN_COLOR
        elseif k > (summerLength + autumnLength) and k <= (summerLength + autumnLength + winterLength) then
        	color = self.WINTER_COLOR
        elseif k > (summerLength + autumnLength + winterLength) and k <= (summerLength + autumnLength + winterLength + springLength) then
        	color = self.SPRING_COLOR
        end

        if dark then
			color = color * self.DARKEN_PERCENT
		end

		seg:SetTint(color.x, color.y, color.z, 1)
		dark = not dark
    end
end

-- Gets the properly cased string representation of the current season.
-- Season param should be the season string.
function SeasonClock:GetPrettySeasonName(season)
	local seasonManager = GetSeasonManager()
	local prettyName = "ERROR"
	local seasonToCheck

	if season then
		seasonToCheck = season
	else
		seasonToCheck = seasonManager:GetSeasonString()
	end

	if seasonToCheck == "summer" then
		prettyName = STRINGS.UI.SANDBOXMENU.SUMMER
	elseif seasonToCheck == "autumn" then
		prettyName = STRINGS.UI.SANDBOXMENU.AUTUMN
	elseif seasonToCheck == "winter" then
		prettyName = STRINGS.UI.SANDBOXMENU.WINTER
	elseif seasonToCheck == "spring" then
		prettyName = STRINGS.UI.SANDBOXMENU.SPRING
	end

	return prettyName
end

-- Retrieves the season string we display on hover
function SeasonClock:GenerateCurrentSeasonClockString()
	local seasonManager = GetSeasonManager()
	local daysIn = seasonManager:GetDaysIntoSeason()
	local currentSeason = self:GetPrettySeasonName()
	local nextSeason = self:GetNextSeason()

	-- We have to potentially round the days remaining and days in. Otherwise we sometimes get values like 0.99999 or 1.88888787e-15
	local daysLeft = seasonManager:GetDaysLeftInSeason()
	daysLeft = self:RoundNumber(daysLeft)
	daysIn = self:RoundNumber(daysIn)

	local seasonString = ""
	if (self.hoverTextOption == "detailed") then 
		seasonString = string.format("%s days into %s.\r%s days until %s.", daysIn, currentSeason, daysLeft, self:GetNextSeason())
	else
		seasonString = string.format("%s/%s\r%s", daysIn, seasonManager:GetSeasonLength(), self:GetNextSeason())
	end

	return seasonString
end

-- If the fractional part of the value is less than 0.5 we return the floor of the value, otherwise we return the ceiling of the value.
function SeasonClock:RoundNumber(value)
	local integral, fractional = math.modf(value)
	
	if(fractional < 0.5) then
		value = math.floor(value)
	else
		value = math.ceil(value)
	end
	
	return value
end

function SeasonClock:GetColorForUserOption(useroption)
	local colors = { ["lightred"] = Vector3(255/255,99/255,71/255), ["red"] = Vector3(220/255,20/255,60/255), ["yellow"] = Vector3(238/255,238/255,0/255), ["lightyellow"] = Vector3(255/255,255/255,0/255), ["lightblue"] = Vector3(152/255,245/255,255/255), ["blue"] = Vector3(98/255,184/255,255/255), ["lightgreen"] = Vector3(180/255,238/255,180/255), ["green"] = Vector3(50/255,198/255,166/255) }

	return colors[useroption]
end

function SeasonClock:GetSeasonFontSizeForUserOption(useroption)
	local fontsizes = { ["verysmall"] = 20, ["small"] = 25, ["default"] = 33, ["large"] = 38, ["verylarge"] = 43}

	return fontsizes[useroption]
end

function SeasonClock:GetHoverFontSizeForUserOption(useroption)
	local detailedFontsizes = { ["verysmall"] = 11, ["small"] = 16, ["default"] = 25, ["large"] = 30, ["verylarge"] = 35}
	local briefFontsizes = { ["verysmall"] = 20, ["small"] = 24, ["default"] = 33, ["large"] = 40, ["verylarge"] = 47}

	if(self.hoverTextOption == "detailed") then
		return detailedFontsizes[useroption]
	else
		return briefFontsizes[useroption]
	end
end

function SeasonClock:OnGainFocus()
	isFocused = true
	self:UpdateSeasonString()
	return true
end

function SeasonClock:OnLoseFocus()
	isFocused = false
	self:UpdateSeasonString()
	return true
end

function SeasonClock:GetNextSeason()
	local seasonManager = GetSeasonManager()
	local currentSeason = seasonManager:GetSeason()
	local nextSeason = "ERROR"

	-- Vanilla Game
	if(not reignOfGiantsEnabled) then 
		if(seasonManager.seasonmode == "endlesssummer") then
			nextSeason = SEASONS.SUMMER
		elseif(seasonManager.seasonmode == "endlesswinter") then
			nextSeason = SEASONS.WINTER
		elseif(seasonManager.seasonmode == "cycle" and seasonManager:IsSummer()) then
			nextSeason = SEASONS.WINTER
		elseif(seasonManager.seasonmode == "cycle" and seasonManager:IsWinter()) then
			nextSeason = SEASONS.SUMMER
		end
	-- Reign of Giants
	else
		if(seasonManager.seasonmode == "endlesssummer") then
			nextSeason = SEASONS.SUMMER
		elseif(seasonManager.seasonmode == "endlesswinter") then
			nextSeason = SEASONS.WINTER
		elseif(seasonManager.seasonmode == "endlessautumn") then
			nextSeason = SEASONS.AUTUMN
		elseif(seasonManager.seasonmode == "endlesswinter") then
			nextSeason = SEASONS.WINTER
		else
			-- Cycle mode, we need to determine what seasons are enabled to properly do this.
			local nextSeasonFound = false;
			local nextSeasons = { [SEASONS.SPRING] = SEASONS.SUMMER, [SEASONS.SUMMER] = SEASONS.AUTUMN, [SEASONS.AUTUMN] = SEASONS.WINTER, [SEASONS.WINTER] = SEASONS.SPRING }
			nextSeason = nextSeasons[currentSeason]

			-- Loop thru the next seasons until we find the next one that is enabled.
			while(not nextSeasonFound) do
				if(seasonManager:GetSeasonIsEnabled(nextSeason)) then
					nextSeasonFound = true
				else
					nextSeason = nextSeasons[nextSeason]
				end
			end
		end
	end
	
	return self:GetPrettySeasonName(nextSeason)
end

return SeasonClock
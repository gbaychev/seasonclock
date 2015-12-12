-- This information tells other players more about the mod
name = "Season Clock"
description = "A clock that indicates the progression through the seasons."
version = "Public preview version"
author = "Soilworker"

forumthread = "nuttinyet"

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 6

-- Compatibility
dont_starve_compatible = true
reign_of_giants_compatible = true

-- Can specify a custom icon for this mod!
icon_atlas = "seasonclock_icon.xml"
icon = "seasonclock_icon.tex"

-- Specify the priority	(needs to be at 2, or basically higher priority than 2.5, due to the mod priority of the "Always On Status" mod.)
-- This is compatiable with that mod.
priority=2

configuration_options =
{
	{
		name = "autumn_color",
		label = "Autumn Color",
		options = {
						{description = "Light Yellow", data = "lightyellow"},
						{description = "Yellow", data = "yellow"},
						{description = "Light Green", data = "lightgreen"},
						{description = "Green", data = "green"},
						{description = "Light Red", data = "lightred"},
						{description = "Red", data = "red"},
						{description = "Light Blue", data = "lightblue"},
						{description = "Blue", data = "blue"},
					},

		default = "lightred",
	
	},
	{
		name = "winter_color",
		label = "Winter Color",
		options = {
						{description = "Light Yellow", data = "lightyellow"},
						{description = "Yellow", data = "yellow"},
						{description = "Light Green", data = "lightgreen"},
						{description = "Green", data = "green"},
						{description = "Light Red", data = "lightred"},
						{description = "Red", data = "red"},
						{description = "Light Blue", data = "lightblue"},
						{description = "Blue", data = "blue"},
					},

		default = "lightblue",
	
	},
	{
		name = "spring_color",
		label = "Spring Color",
		options = {
						{description = "Light Yellow", data = "lightyellow"},
						{description = "Yellow", data = "yellow"},
						{description = "Light Green", data = "lightgreen"},
						{description = "Green", data = "green"},
						{description = "Light Red", data = "lightred"},
						{description = "Red", data = "red"},
						{description = "Light Blue", data = "lightblue"},
						{description = "Blue", data = "blue"},
					},

		default = "green",
	
	},
	{
		name = "summer_color",
		label = "Summer Color",
		options = {
						{description = "Light Yellow", data = "lightyellow"},
						{description = "Yellow", data = "yellow"},
						{description = "Light Green", data = "lightgreen"},
						{description = "Green", data = "green"},
						{description = "Light Red", data = "lightred"},
						{description = "Red", data = "red"},
						{description = "Light Blue", data = "lightblue"},
						{description = "Blue", data = "blue"},
					},

		default = "yellow",
	
	},
	{
		name = "hovertextoption",
		label = "Hover Text",
		options = {
						{description = "Detailed", data = "detailed"},
						{description = "Brief", data = "brief"},
						{description = "Off", data = "off"},
					},

		default = "detailed",
	},
	{
		name = "hoverfontsize",
		label = "Hover Font Size",
		options = {
						{description = "Very Small", data = "verysmall"},
						{description = "Small", data = "small"},
						{description = "Default", data = "default"},
						{description = "Large", data = "large"},
						{description = "Very Large", data = "verylarge"},
					},

		default = "default",
	},

	{
		name = "seasonfontsize",
		label = "Season Font Size",
		options = {
						{description = "Very Small", data = "verysmall"},
						{description = "Small", data = "small"},
						{description = "Default", data = "default"},
						{description = "Large", data = "large"},
						{description = "Very Large", data = "verylarge"},
					},
		default = "default",
	},

	{
		name = "showincave",
		label = "Visible in Caves",
		options = {
						{description = "True", data = true},
						{description = "False", data = false},
					},
		default = true,
	},

	{
		name = "texttodisplay",
		label = "Default Text to Display",
		options = {
						{description = "Current Season", data = "currentseason"},
						{description = "Season Progress", data = "seasonprogress"},
						{description = "Off", data = "off"},
					},
		default = "currentseason",
	},

	{
		name = "clockposition",
		label = "Clock Position",
		options = {
						{description = "Above Day Clock", data = "aboveday"},
						{description = "Below Day Clock", data = "belowday"},
						{description = "Left of Day Clock", data = "leftofday"},
						{description = "Right of Day Clock", data = "rightofday"},
					},
		default = "rightofday",
	},
}
--- ************************************************************************************************************************************************************************
---
---				Name : 		main.lua
---				Purpose :	Demonstration app for the fontmanager library
---				Created:	7 May 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	MIT
---
--- ************************************************************************************************************************************************************************

display.setStatusBar(display.HiddenStatusBar)

FM = require("system.fontmanager")																-- get the instance of the font manager.
SM = require("system.scenemanager")																-- get the instance of the scene manager

--- ************************************************************************************************************************************************************************
--//					This scene class is the menu scene. It keeps a table of names of effects (e.g. wobble) to scene instances.
--- ************************************************************************************************************************************************************************

local MainScene = SM.Scene:new()

function MainScene:initialise()
	SM.Scene.initialise(self) 																	-- call superclass constructor.
	self.sceneTable = {} 																		-- table of scenes. 
	self.count = 0 																				-- number of scenes
end

--//	Add a scene name and instance to the table held for this scene
--//	@sceneName [string] 	Name of scene to add
--//	@sceneInstance [Scene]	Instance of scene

function MainScene:add(sceneName,sceneInstance)
	self.sceneTable[sceneName] = sceneInstance 													-- store it.
	SM.SceneManager:append(sceneName,sceneInstance)												-- add the instance
	self.count = self.count + 1 																-- bump the count.
	return self
end

--//	Called to create the menu.

function MainScene:create()
	local y = display.contentHeight/2 - (self.count-1) * 30										-- centre the menu
	self.stringTable = {} 																		-- table of strings that make up the menu
	self.instanceToStringTable = {} 															-- map string display object to scene name
	for name,_ in pairs(self.sceneTable) do 													-- work through the scenes we know about
		self.stringTable[name]=display.newBitmapText(name,display.contentWidth/2,y,"font1",50)	-- create the menu items
		self.stringTable[name]:setModifier("jagged"):setSpacing(4) 								-- make them jagged and slightly spaced out
		self.stringTable[name]:addEventListener("tap",self) 									-- tapping on them calls the tap method.
		self.instanceToStringTable[self.stringTable[name]:getView()] = name 					-- save mapping from view object to name (used in tap)
		self:insert(self.stringTable[name]:getView()) 											-- insert into view
		y = y + 60 																				-- next row down.
	end
	local url = "https://github.com/autismuk/Font-Manager" 										-- add our URL at the bottom.
	local txt = display.newText(url,display.contentWidth/2,display.contentHeight-5,native.systemFont,12)
	txt.anchorY = 1
	self:insert(txt)
end

--//	Called when one of the menu items is tapped.
--//	@e 	[tap event]		Information about the event.
function MainScene:tap(e)
	local scene = self.instanceToStringTable[e.target]											-- use the table to convert the view group object to a name.
	self:gotoScene(scene) 																		-- and go to that scene.
end

--//	This template override means that entering here we will slide right.

function MainScene:getTransitionType()
	return "slideright"
end

--- ************************************************************************************************************************************************************************
--//		This is a little sneaky, we use the class as a template and provide the modifier in the constructor. So we can reuse this class for all the scenes.
--- ************************************************************************************************************************************************************************

local DisplayScene = SM.Scene:new()

--//	Construct the scene
--//	@modifier 	[String/Function/Class]		The modifier used to animate or shape the scene.

function DisplayScene:initialise(modifier)
	SM.Scene.initialise(self) 																	-- call the superclass constructor
	self.modifier = modifier 																	-- save the modifier
end

--//	Called when scene created

function DisplayScene:create()
	self.background = display.newRect(0,0,display.contentWidth,display.contentHeight) 			-- set up the blue background
	self.background.anchorX,self.background.anchorY = 0,0
	self.background:setFillColor(0,0,0.3)
	self:insert(self.background)
end

--//	Pre-open, create and perhaps animate the fonts.

function DisplayScene:preOpen()
	self.text = {} 																				-- array of three bitmap objects to create
	self.text[1] = display.newBitmapText("This is text",display.contentWidth/2,display.contentHeight/4,"font1",64)
	self.text[2] = display.newBitmapText("This is text",display.contentWidth/2,display.contentHeight/2,"font3",64):setScale(0.5,1)
	self.text[3] = display.newBitmapText("This is text",display.contentWidth/2,display.contentHeight*3/4,"font2",64)

	for i = 1,3 do 																				-- iterate through all three
		self:insert(self.text[i]:getView()) 													-- put them in the scene view
		if i > 1 then self.text[i]:setModifier(self.modifier) end 								-- set the modifier for the 2nd and 3rd text object
	end
	self.text[3]:animate(3) 																	-- but only animate the 3rd - so we have, normal, shaped, animated.
end

--//	We use the slideleft transition type into this scene

function DisplayScene:getTransitionType()
	return "slideleft"
end

--//	When the scene is open we add the tap event listener on the background

function DisplayScene:postOpen()
	self.background:addEventListener( "tap",self)
end

--//	Just before the scene closes we remove the tap event listener on the background

function DisplayScene:preClose()
	self.background:removeEventListener( "tap",self)
end

--//	On close, remove the texts back to the system.

function DisplayScene:postClose()
	for i = 1,3 do self.text[i]:remove() end
	self.text = {}
end

--//	Handle the tap

function DisplayScene:tap(e)
	self:gotoScene("main")																		-- by going back to the main scene e.g. the menu.
end

--//	A modifier that does the pulser - this and spinner are code types.

function pulser(modifier, cPos, elapsed, index, length)
	local w = math.floor(elapsed/250) % length + 1 												-- every 180ms change character, creates a number 1 .. length
	if index == w then  																		-- are we scaling this character
		local newScale = 1 + (elapsed % 250) / 250 												-- calculate the scale zoom - make it 2- rather than 1+, it goes backwards
		modifier.xScale,modifier.yScale = newScale,newScale 									-- scale it up
	end
end

--//	A modifier that rotates the characters at various rates

function spinner(modifier, cPos, elapsed, index, length)
	local r =  elapsed / (3 + index) 															-- elapsed is elapsed time in ms, index is character position in the string
	modifier.rotation = r  																		-- rotate the character.
end

local main = MainScene:new() 																	-- create the main scene instance
SM.SceneManager:append("main",main)																-- tell the scene manager about it

main:add("wobble",DisplayScene:new("wobble")) 													-- add new display scene instances 
main:add("curve",DisplayScene:new("curve")) 													-- note, the add method tells the scene manager about them.
main:add("jagged",DisplayScene:new("jagged"))
main:add("scale",DisplayScene:new("scale"))
main:add("pulser",DisplayScene:new(pulser))
main:add("spinner",DisplayScene:new(spinner))

SM.SceneManager:gotoScene("main") 																-- and go to the main scene, e.g. the menu.

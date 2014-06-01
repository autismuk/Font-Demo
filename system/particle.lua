--- ************************************************************************************************************************************************************************
---
---				Name : 		particle.lua
---				Purpose :	Particle Class
---				Created:	26 May 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	MIT
---
--- ************************************************************************************************************************************************************************

-- Standard OOP (with Constructor parameters added.)
_G.Base =  _G.Base or { new = function(s,...) local o = { } setmetatable(o,s) s.__index = s o:initialise(...) return o end, initialise = function() end }

--- ************************************************************************************************************************************************************************
--																						Basic Emitter Class
--- ************************************************************************************************************************************************************************

local Emitter = Base:new()

Emitter.JSONInstance = require("json") 														-- instance of json required to decode effects
Emitter.effectsFolder = "effects" 															-- effects folder

--//	Create a new emitter using the emitter file given
--//	@emitterFile [string] 		Name of emitter file in folder, without .json suffix

function Emitter:initialise(emitterFile)
	self.emitterFile = emitterFile  														-- save emitter file name
	if self.emitterFile ~= nil then  														-- if one provided, load it.
		self:loadParameters(emitterFile)
	end
end

--//	Start an emitter 
--//	@x 	[number] 				Where to start it
--//	@y 	[number]				Where to start it
--//	@return [Emitter]			Chaining option

function Emitter:start(x,y)
	assert(self.emitter == nil,"Emitter started twice")
	self.emitter = display.newEmitter(self.emitterParams) 									-- create a new emitter
	self.emitter.x,self.emitter.y = x,y  													-- move it
	return self
end 

--//	Destroy an emitter

function Emitter:removeSelf() 
	self.emitter:removeSelf() 																-- remove it
	self.emitter = nil 																		-- clean up
	self.emitterFile = nil self.emitterParams = nil
end

Emitter.remove = Emitter.removeSelf

--//%	Load a parameter file

function Emitter:loadParameters()
	local filePath = system.pathForFile(Emitter.effectsFolder .. "/" .. 					-- the file to load with the parameters
															self.emitterFile .. ".json")
	local handle = io.open(filePath,"r") 													-- read it in.
	local fileData = handle:read("*a")
	handle:close()
	self.emitterParams = Emitter.JSONInstance.decode(fileData) 								-- convert from JSON to LUA
	self:fixParameter("textureFileName") 													-- update files used with full path.
end 

--//%	Fix an effects parameter parameter (er..) by giving it the full effects folder path
--//	@paramName [string] 	parameter to fix 

function Emitter:fixParameter(paramName)
	if self.emitterParams[paramName] ~= nil then  											-- if present
		self.emitterParams[paramName] = Emitter.effectsFolder .. "/" .. 					-- fix it
																self.emitterParams[paramName]	
	end
end

--- ************************************************************************************************************************************************************************
--													This emitter class self-destructs after a given time period
--- ************************************************************************************************************************************************************************

local ShortEmitter = Emitter:new()

--//	Create a new emitter using the emitter file given
--//	@emitterFile [string] 		Name of emitter file in folder, without .json suffix
--//	@timeFrame [number]			Period of emitter life, if you don't want to use the duration parameter

function ShortEmitter:initialise(emitterFile,timeFrame)
	Emitter.initialise(self,emitterFile) 													-- super constructor
	if timeFrame == nil then timeFrame = self.emitterParams.duration * 1000 end  			-- if no time frame given, use the one in "duration"
	timer.performWithDelay( timeFrame, function() self:destroy() end) 						-- tell it to self destruct after that time.
end 

return { Emitter = Emitter, ShortEmitter = ShortEmitter }
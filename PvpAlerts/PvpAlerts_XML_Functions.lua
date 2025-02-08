---@class (partial) PvpAlerts
local PVP = PVP_Alerts_Main_Table

function PVP_Alerts_SavePosition()
	local coordX, coordY=PVP_Main:GetCenter()
	PVP.SV.offsetX=coordX-(GuiRoot:GetWidth()/2)
	PVP.SV.offsetY=coordY-(GuiRoot:GetHeight()/2)
	PVP_Main:ClearAnchors()
	PVP_Main:SetAnchor(CENTER, GuiRoot, CENTER, PVP.SV.offsetX, PVP.SV.offsetY)
end

function PVP_Counter_SavePosition()
	local coordX, coordY=PVP_Counter:GetCenter()
	PVP.SV.counterOffsetX=coordX-(GuiRoot:GetWidth()/2)
	PVP.SV.counterOffsetY=coordY-(GuiRoot:GetHeight()/2)
	PVP_Counter:ClearAnchors()
	PVP_Counter:SetAnchor(CENTER, GuiRoot, CENTER, PVP.SV.counterOffsetX, PVP.SV.counterOffsetY)
end

function PVP_Tug_SavePosition()
	local coordX, coordY=PVP_TUG:GetCenter()
	PVP.SV.tugOffsetX=coordX-(GuiRoot:GetWidth()/2)
	PVP.SV.tugOffsetY=coordY-(GuiRoot:GetHeight()/2)
	PVP_TUG:ClearAnchors()
	PVP_TUG:SetAnchor(CENTER, GuiRoot, CENTER, PVP.SV.tugOffsetX, PVP.SV.tugOffsetY)
end

function PVP_Feed_SavePosition()
	local coordX, coordY=PVP_KillFeed:GetCenter()
	PVP.SV.feedOffsetX=coordX-(GuiRoot:GetWidth()/2)
	PVP.SV.feedOffsetY=coordY-(GuiRoot:GetHeight()/2)
	PVP_KillFeed:ClearAnchors()
	PVP_KillFeed:SetAnchor(CENTER, GuiRoot, CENTER, PVP.SV.feedOffsetX, PVP.SV.feedOffsetY)
end

function PVP_Names_SavePosition()
	local coordX, coordY=PVP_Names:GetCenter()
	PVP.SV.namesOffsetX=coordX-(GuiRoot:GetWidth()/2)
	PVP.SV.namesOffsetY=coordY-(GuiRoot:GetHeight()/2)
	PVP_Names:ClearAnchors()
	PVP_Names:SetAnchor(CENTER, GuiRoot, CENTER, PVP.SV.namesOffsetX, PVP.SV.namesOffsetY)
end

function PVP_KOS_SavePosition()
	local coordX, coordY=PVP_KOS:GetCenter()
	PVP.SV.KOSOffsetX=coordX-(GuiRoot:GetWidth()/2)
	PVP.SV.KOSOffsetY=coordY-(GuiRoot:GetHeight()/2)
	PVP_KOS:ClearAnchors()
	PVP_KOS:SetAnchor(CENTER, GuiRoot, CENTER, PVP.SV.KOSOffsetX, PVP.SV.KOSOffsetY)
end

function PVP_Camp_SavePosition()
	local coordX, coordY=PVP_ForwardCamp:GetCenter()
	PVP.SV.campOffsetX=coordX-(GuiRoot:GetWidth()/2)
	PVP.SV.campOffsetY=coordY-(GuiRoot:GetHeight()/2)
	PVP_ForwardCamp:ClearAnchors()
	PVP_ForwardCamp:SetAnchor(CENTER, GuiRoot, CENTER, PVP.SV.campOffsetX, PVP.SV.campOffsetY)
end

function PVP_Capture_SavePosition()
	local coordX, coordY=PVP_Capture:GetCenter()
	PVP.SV.captureOffsetX=coordX-(GuiRoot:GetWidth()/2)
	PVP.SV.captureOffsetY=coordY-(GuiRoot:GetHeight()/2)
	PVP_Capture:ClearAnchors()
	PVP_Capture:SetAnchor(CENTER, GuiRoot, CENTER, PVP.SV.captureOffsetX, PVP.SV.captureOffsetY)
end

function PVP_TargetName_SavePosition()
	local coordX, coordY=PVP_TargetName:GetCenter()
	PVP.SV.targetOffsetX=coordX-(GuiRoot:GetWidth()/2)
	PVP.SV.targetOffsetY=coordY-(GuiRoot:GetHeight()/2)
	PVP_TargetName:ClearAnchors()
	PVP_TargetName:SetAnchor(CENTER, GuiRoot, CENTER, PVP.SV.targetOffsetX, PVP.SV.targetOffsetY)
end

function PVP_NewAttacker_SavePosition()
	local coordX, coordY=PVP_NewAttacker:GetCenter()
	PVP.SV.newAttackerOffsetX=coordX-(GuiRoot:GetWidth()/2)
	PVP.SV.newAttackerOffsetY=coordY-(GuiRoot:GetHeight()/2)
	PVP_NewAttacker:ClearAnchors()
	PVP_NewAttacker:SetAnchor(CENTER, GuiRoot, CENTER, PVP.SV.newAttackerOffsetX, PVP.SV.newAttackerOffsetY)
end

function PVP_OnScreen_SavePosition()
	local coordX, coordY=PVP_OnScreen:GetCenter()
	PVP.SV.onScreenOffsetX=coordX-(GuiRoot:GetWidth()/2)
	PVP.SV.onScreenOffsetY=coordY-(GuiRoot:GetHeight()/2)
	PVP_OnScreen:ClearAnchors()
	PVP_OnScreen:SetAnchor(CENTER, GuiRoot, CENTER, PVP.SV.onScreenOffsetX, PVP.SV.onScreenOffsetY)
end

function PVP_Medals_SavePosition()
	local coordX, coordY=PVP_Medals:GetCenter()
	PVP.SV.medalsOffsetX=coordX-(GuiRoot:GetWidth()/2)
	PVP.SV.medalsOffsetY=coordY-(GuiRoot:GetHeight()/2)
	PVP_Medals:ClearAnchors()
	PVP_Medals:SetAnchor(CENTER, GuiRoot, CENTER, PVP.SV.medalsOffsetX, PVP.SV.medalsOffsetY)
end

function PVP.KOS_Control_Movement()
	local button = PVP_KOS_ControlFrame_Button
	local centerNewX, centerNewY = button:GetCenter()
	local offsetXMove=centerNewX-PVP.moveInfo.centerX

	PVP.moveInfo.offsetX=PVP.moveInfo.offsetX+offsetXMove

	local width = PVP.moveInfo.effectiveWidth

	if PVP.moveInfo.offsetX<zo_round(-width/2) then PVP.moveInfo.offsetX=zo_round(-width/2)
	elseif PVP.moveInfo.offsetX>zo_round(width/2) then PVP.moveInfo.offsetX=zo_round(width/2) end


	if PVP.moveInfo.offsetX<=zo_round(-width/3) then
		button:SetText("All")
		PVP.SV.KOSmode=1
	elseif PVP.moveInfo.offsetX<=0 then
		button:SetText("Allies")
		PVP.SV.KOSmode=2
	elseif PVP.moveInfo.offsetX<=zo_round(width/3) then
		button:SetText("Enemies")
		PVP.SV.KOSmode=3
	else
		button:SetText("Setup")
		PVP.SV.KOSmode=4
	end

	local currentTime = GetFrameTimeMilliseconds()
	if currentTime-PVP.moveInfo.timeStamp>=100 then
		PVP:RefreshLocalPlayers()
		PVP.moveInfo.timeStamp = currentTime
	end

	button:ClearAnchors()
	button:SetAnchor(PVP.moveInfo.point, PVP.moveInfo.relativeTo, PVP.moveInfo.relativePoint, PVP.moveInfo.offsetX, PVP.moveInfo.offsetY)
	PVP.moveInfo.centerX=button:GetCenter()
end

function PVP_KOS_Control_MoveStart(self)
	PVP.moveInfo={}
	local control = PVP_KOS_ControlFrame
	local _, point, relativeTo, relativePoint, offsetX, offsetY = self:GetAnchor()
	local centerX, centerY = self:GetCenter()
	local offsetXleft, offsetXright = (control:GetLeft()-self:GetLeft()+5)+offsetX, (control:GetRight()-self:GetRight()-5)+offsetX
	if offsetX>offsetXright then offsetX=offsetXright end
	if offsetX<offsetXleft then offsetX=offsetXleft end

	local controlWidth = control:GetWidth()-10
	local selfWidth = self:GetWidth()
	local effectiveWidth = controlWidth-selfWidth

	local currentTime = GetFrameTimeMilliseconds()

	PVP.moveInfo={point=point, relativeTo=relativeTo, relativePoint=relativePoint, offsetX=offsetX, offsetY=offsetY, centerX=centerX, centerY=centerY, effectiveWidth=effectiveWidth, timeStamp=currentTime}
	self:SetHandler("OnUpdate", PVP.KOS_Control_Movement)
end

function PVP_KOS_Control_MoveStop(self)
	self:SetHandler("OnUpdate", nil)

	local width = PVP.moveInfo.effectiveWidth

	if PVP.moveInfo.offsetX<=zo_round(-width/3) then
		PVP.moveInfo.offsetX=zo_round(-width/2)
		self:SetText("All")
		PVP.SV.KOSmode=1
	elseif PVP.moveInfo.offsetX<=0 then
		PVP.moveInfo.offsetX=zo_round(-width/6)
		self:SetText("Allies")
		PVP.SV.KOSmode=2
	elseif PVP.moveInfo.offsetX<=zo_round(width/3) then
		PVP.moveInfo.offsetX=zo_round(width/6)
		self:SetText("Enemies")
		PVP.SV.KOSmode=3
	else
		PVP.moveInfo.offsetX=zo_round(width/2)
		self:SetText("Setup")
		PVP.SV.KOSmode=4
	end

	PVP:RefreshLocalPlayers()

	self:ClearAnchors()
	self:SetAnchor(PVP.moveInfo.point, PVP.moveInfo.relativeTo, PVP.moveInfo.relativePoint, PVP.moveInfo.offsetX, PVP.moveInfo.offsetY)
end

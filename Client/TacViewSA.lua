--Script works with moonloader v.026.5-beta, tested on SAMP versions 0.3.7-R3 and 0.3DL.
--!AVIONICS speed = TacView speed/1.98!
--BydloCode_start()
--{
require 'moonloader'
require 'sampfuncs'

local keys = require "vkeys"
local switch = require 'switch'

samp = require "samp.events"

if getMoonloaderVersion() >= 27 then
	require 'deps'
	{
		'luasocket',--(?)or do with smthng like: https://www.blast.hk/threads/13380/post-272601
	}
else
	local socket = require 'socket'
end

local IsRecording = false
local TDStatus
local TVRec
local STime
local Ver = "0.1.0-b25.10.2023"
local FontMain
----------------------Database
local IsInited

local dbVeh
local dbObject

local ActiveGunShots
-----------------------Script nfo
script_name("TacViewSA")
script_author("d7.KrEoL")
script_version(Ver)
script_url("https://vk.com/d7kreol")
script_description("Сохранение телеметрии полёта SAMP в формате ACMI.")
----------------------
function OnTVRSaCmd(arg)
	OnTVStatus()
end
function main()
	IsInited = false
	
	repeat wait(0) until isSampLoaded()
	repeat wait(0) until isSampAvailable()
	
	ActiveGunShots = {X, Y, Z, tX, tY, tZ, Time, Object}
	
	local TVRec
	local FileName
	Screen = {x, y}
	Screen.x, Screen.y =  getScreenResolution()
	RenderPos = {x = Screen.x - (0.2 * Screen.x), y = Screen.y - (0.77 * Screen.y)}
	
	LoadTextFont()
	lua_thread.create(RenderInfoText)
	DBInit()
	
	sampRegisterChatCommand("tvrec", OnTVStatus)
	sampRegisterChatCommand("tvreload", ReloadCFG)
	sampRegisterChatCommand("tvcfg", ReloadCFG)
	sampRegisterChatCommand("tvdb", ReloadCFG)
	sampRegisterChatCommand("tvver", 
	function()
			print("[TVRec] Script version is ",Ver," Author: d7.KrEoL");
			sampAddChatMessage(string.format("{FFFFFF}Version: {11B8FF}%s {FFFFFF}Author: {11B8FF}d7.KrEoL", Ver), 0xFF11B8FF)
    	end)
	
	print("TVRec script is active, type /tvrec into T-chat or press num3 to start/stop recording ")
	sampAddChatMessage("{11B8FF}TVRec {FFFFFF}script is active, type {11B8FF}/tvrec {FFFFFF}or press {11B8FF}num3 {FFFFFF}to start/stop recording", 0xFF11B8FF)
	sampAddChatMessage(string.format("{FFFFFF}Version: {11B8FF}%s {FFFFFF}Author: {11B8FF}d7.KrEoL", Ver), 0xFF11B8FF)
	
	OnUpdateF()
	
end
function DBInit()
	print("Database Init");
	dbVeh = { ID, Name }
	dbObject = { ID, Name }
	
	print("Loading vehicle database");
	local OpenDir = string.format("%s\\moonloader\\resource\\tvsa\\VehDB.txt", getGameDirectory())
	local linesVeh = ReadDBFromTXT(OpenDir)
	print("Loading object database");
	OpenDir = string.format("%s\\moonloader\\resource\\tvsa\\ObjDB.txt", getGameDirectory())
	local linesObjs = ReadDBFromTXT(OpenDir)
	for i = 1,#linesVeh do
		local args={}
		for str in string.gmatch(linesVeh[i], "([^".."=".."]+)") do
			table.insert(args, str)
			if #args > 1 then
				table.insert(dbVeh, {ID = tonumber(args[1]), Name = args[2]})
			end
		end
	end
	for i = 1, #linesObjs do
		local args={}
		for str in string.gmatch(linesObjs[i], "([^".."=".."]+)") do
			table.insert(args, str)
			if #args > 1 then
				table.insert(dbObject, {ID = tonumber(args[1]), Name = args[2]})
			end
		end
	end
	print("Looking for vehicles in database")
	for i = 1, #dbVeh do
		print("+{FFFFFF}vehicle info added from database: {11B8FF}[", i, "] {FFFFFF}", "Model ID = {11B8FF}",  dbVeh[i].ID, "{FFFFFF}Name = {11B8FF}", dbVeh[i].Name)
	end
	print("Looking for objects in database")
	for i = 1, #dbObject do
		print("+{FFFFFF}object info added from database: {11B8FF}[", i, "] {FFFFFF}", "Model ID = {11B8FF}",  dbObject[i].ID, "{FFFFFF}Name = {11B8FF}", dbObject[i].Name)
	end
end
function ReloadCFG()
	print("Reloading script database");
	if IsRecording then OnTVStatus() end
	
	print("Vehicles database cleared")
	for i = 1, #dbVeh do
		dbVeh[i].ID = nil
		dbVeh[i].Name = nil
	end
	print("Objects database cleared")
	for i = 1, #dbObject do 
		dbObject[i].ID = nil
		dbObject[i].Name = nil
	end
	
	DBInit()
	
	print("Script database files reloaded");
	sampAddChatMessage(string.format("{11B8FF}[TVRec]: {FFFFFF}script objects and vehicles database reloaded!"), 0xFF11B8FF)
end
function OnUpdateF()
	while true do
		if isKeyJustPressed(VK_NUMPAD3) then OnTVStatus() end
		wait(0)
		if (IsRecording and TVRec) then
			wait(154)
			strr = string.format("\n#%f\n",socket.gettime()-STime)
			WriteFileStr(strr)
			GetAllPlayersPos()
			GetAllObjectsPos()
			UpdateGunShots()
		end
	end
end 
function OnTVStatus()
	IsRecording = not IsRecording;
	if IsRecording then
		OpenFile()
		WriteFileHeader()
		STime = socket.gettime()
		sampAddChatMessage("{11B8FF}[TVRec]: {FFFFFF}Recording started!", 0xFF11B8FF)
	else
		ClearGunShots()
		CloseFile()
		sampAddChatMessage(string.format("{11B8FF}[TVRec]: {FFFFFF}Recording saved into {11B8FF}%s", FileName), 0xFF11B8FF)
	end
	print("TVRecorder: ",IsRecording);
end
function GetAllPlayersPos()
	local peds = getAllChars()
	local CharCar
	local pName
	local PosX, PosY, PosZ, RotX, RotY, RotZ, tmpx
	local strr
	for i, v in ipairs(peds) do
		if doesCharExist(v) then
			local result, playerid = sampGetPlayerIdByCharHandle(v)
			if result then --?ifnot continue?
				pName = sampGetPlayerNickname(playerid)
				if isCharInAnyCar(v) then
					CharCar = getCarCharIsUsing(v)
					vName = GetVehName(getCarModel(CharCar))
					PosX,PosY,PosZ = getCarCoordinates(CharCar)
					PosX = PosX/100000
					PosY = PosY/100000
					
					RotX = getCarRoll(CharCar)*-1
					RotY = getCarPitch(CharCar)
					RotZ = getCarHeading(CharCar)*-1
					
					if math.abs(RotX) > 80 then
						if RotY > 180 then
							RotY = 360 - RotY
						else
							RotY = (180 - RotY)
						end
						if RotY > 100 and RotX < 177 then RotY = (180 - RotY)*-1 end
					end
					CH = getCarHealth(CharCar)*0.01
					CS = getCarSpeed(CharCar)*0.2777778
					playerid = playerid + 100
					if CH == 0 then 
						strr = string.format("\n-a%i\n", playerid)
					else 
						strr = string.format("\na%i, T=%.6f|%.6f|%.6f|%.2f|%.2f|%.2f,CAS=%.2f,HDG=%.2f,Type=Aircraft,Color=Red,Coalition=Allies,Name=%s,Pilot=%s,Health=%.2f,Group=GTASA,Country=ru\n",playerid,PosX,PosY,PosZ,RotX,RotY,RotZ,CS,RotZ,vName,pName,CH/1000)
					end
					WriteFileStr(strr)
				else
					PosX, PosY, PosZ = getCharCoordinates(v)
					PosX = PosX/100000
					PosY = PosY/100000
					RotX = 0
					RotY = 0
					RotZ = getCharHeading(v)--?
					PH=getCharHealth(v)*0.1
					playerid = playerid + 100
					if PH == 0 then 
						strr = string.format("\n-a%i\n", playerid)
					else 
						strr = string.format("\na%i, T=%.6f|%.6f|%.6f|%.2f|%.2f|%.2f,Type=Type=Ground+Light+Human+Infantry,Color=Red,Coalition=Allies,Name=AK-47 Infantry,Pilot=%s,Health=%.2f,Group=GTASA,Country=ru\n",playerid,PosX,PosY,PosZ,RotX,RotY,RotZ,pName,PH/100)
					end
					WriteFileStr(strr)
				end
			end
		end
	end
end
function GetAllVehiclesPos()
	
end
function GetAllObjectsPos()
	local objs = getAllObjects()
	local PosX, PosY, PosZ, RotX, RotY, RotZ, tmpx
	local qx, qy, qz, qw 
	local res
	local objName
	local strr
	local Type
	for i, v in ipairs(objs) do
		objName = GetObjName(getObjectModel(v))
		if not (objName == "Trash") then
			res, PosX,PosY,PosZ = getObjectCoordinates(v)
			PosX = PosX/100000
			PosY = PosY/100000
			qx, qy, qz, qw = getObjectQuaternion(v)
			RotX, RotY, RotZ = GetMissileRotation(qx, qy, qz, qw)
			RotX = RotX*100
			RotY = RotY*100
			RotZ = RotZ*100
			local hX, hY, hZ
			if (objName == "Flare") then
				Type = "Flare"
			else
				if (objName == "weapons.shells.5_45x39_NOtr") then
					Type = "Projectile+Shell"
				else
					Type = "Weapon + Missile"
				end
			end
			if (getObjectHealth(v) < 1) then 
				strr = string.format("\n-b%i, T=%.6f|%.6f|%.6f|%.2f|%.2f|%f,Type=%s,Color=Red,Coalition=Allies,Name=%s,Pilot=MISSLE,Group=GTASA,Country=ru\n",v,PosX,PosY,PosZ,RotY,RotX,RotZ,Type,objName)
			else
				strr = string.format("\nb%i, T=%.6f|%.6f|%.6f|%.2f|%.2f|%.2f,Type=%s,Color=Red,Coalition=Allies,Name=%s,Pilot=MISSLE,Group=GTASA,Country=ru\n",v,PosX,PosY,PosZ,RotY,RotX,RotZ,Type,objName)
				WriteFileStr(strr)
			end
		end
		
	end
end
function OpenFile()
	local Dir = string.format("%s\\moonloader\\resource\\tvsa\\TVRec-%s.acmi", getGameDirectory(), os.date("%y.%m.%d-%H.%M.%S"))
	TVRec = io.open(Dir, "w+")--???
	FileName = GetFileName(Dir)
	print("Recording into: ", FileName)
	print(getGameDirectory() .. "\\moonloader\\resource\\tvsa\\TVRec-" .. os.date("%x-%H.%M") .. ".acmi")
end
function CloseFile()
	TVRec:close()
	TVRec = nil
	print("File Saved!")
end
function WriteFileStr(strr)
	if TVRec
	then
		TVRec:write(strr)
	end
end
function WriteFileHeader()
	WriteFileStr("FileType=text/acmi/tacview\nFileVersion=2.1\n")
	WriteFileStr("0,Category=SAMP Server TacView Recorder\n")
	WriteFileStr(string.format("0,ReferenceTime=%s-%s-%sT%s:%s:%sZ\n", os.date('%Y'), os.date('%m'), os.date('%d'), os.date('%H'),os.date('%M'), os.date('%S')))
	WriteFileStr("0,RecordingTime=2023-10-24T14:40:00.00Z\n")
	WriteFileStr("0,Title=San Andreas TacView Recording\n")
	WriteFileStr("0,DataRecorder=SALUAACMI 0.0.0.6-b25102023BT\n")
	WriteFileStr("0,Author=Kirill Desmov\n")
	WriteFileStr("0,Comments=Contacts - vk.com/d7kreol\n")
	WriteFileStr("40000001,T=0|0|100,Type=Navaid+Static+Bullseye,Color=Blue,Coalition=Enemies\n")
	WriteFileStr("40000002,T=0|0|100,Type=Navaid+Static+Bullseye,Color=Grey,Coalition=Neutrals\n")
	WriteFileStr("40000003,T=0|0|100,Type=Navaid+Static+Bullseye,Color=Red,Coalition=Allies\n")
end
function GetObjName(objID)
	for i = 1, #dbObject do
		if dbObject[i].ID == objID then
			return dbObject[i].Name
		end
	end
	return "Trash"
end
function GetVehName(vehID)
	for i = 1, #dbVeh do
		if dbVeh[i].ID == vehID then
			return dbVeh[i].Name
		end
	end
	return "Humvee"
end
function RenderInfoText()
	while true do
		if IsRecording then
			render_text(Text_FontMain, "TVRec", RenderPos.x, RenderPos.y, 0xFF11B8FF, 1, 0xFF000000)
		else
			render_text(Text_FontMain, "TVRec", RenderPos.x, RenderPos.y, 0xFFAAAA00, 1, 0xFF000000)
		end
		wait(0)
	end
	if IsInited then
		render_text(Text_FontMain, (string.format("{11B8FF}TVRec{FFFFFF}: id: %i", id)), 0, 300, 0xFFFFCC00, 1, 0xFF000000, false)
	end
end
function LoadTextFont()
	Text_FontMain = renderCreateFont("Arial Rounded MT", 14, 1, 1)
end
function render_text(font, text, x, y, color, outline, outline_color, ignore_colortags)
	if outline > 0 then
		renderFontDrawText(font, text, x, y + outline, outline_color, ignore_colortags)
		renderFontDrawText(font, text, x + outline, y + outline, outline_color, ignore_colortags)
		renderFontDrawText(font, text, x + outline, y, outline_color, ignore_colortags)
		renderFontDrawText(font, text, x + outline, y - outline, outline_color, ignore_colortags)
		renderFontDrawText(font, text, x, y - outline, outline_color, ignore_colortags)
		renderFontDrawText(font, text, x - outline, y - outline, outline_color, ignore_colortags)
		renderFontDrawText(font, text, x - outline, y, outline_color, ignore_colortags)
		renderFontDrawText(font, text, x - outline, y + outline, outline_color, ignore_colortags)
	end
	renderFontDrawText(font, text, x, y, color, ignore_colortags)
end
function GetFileName(str)
	return str:match("^.+\\(.+)$")
end
function samp.onBulletSync(playerid, data)
	if not(IsRecording) then return true end
	if data.target.x == -1 or data.target.y == -1 or data.target.z == -1 then return true end
	if data.target.x == nil or data.target.y == nil or data.target.z == nil then return true end
	AddGunShot(data.origin.x, data.origin.y, data.origin.z, data.target.x, data.target.y, data.target.z)
end
function GetPlayerVehData()
	local vehData = InCarData()
end
function InCarData()
	local buffer
	sampStorePlayerIncarData(sampGetPlayerIdByCharHandle(PLAYER_PED), buffer)
	return buffer
end
function samp.onVehicleSync(playerId, vehicleId, data)
	if saPacket_IsPlaneFiring(data.upDownKeys) then
		local vehid = sampGetCarHandleBySampVehicleId(vehicleId)
		if saPacket_IsPlaneCanFire(vehid) then
			local oX, oY, oZ = getCarCoordinates(vehid)
			local tX, tY, tZ = getOffsetFromCarInWorldCoords(vehid, 0, 5, 0)
			AddGunShot(oX, oY, oZ, tX, tY, tZ)
		end
	end
end
function onSendPacket(id, bitStream, priority, reliability, orderingChannel)
	if id == 200 and IsRecording then
		local fulldata = parseVehicleSyncData(bitStream)
		local pid = fulldata[1]
		local vid = fulldata[2]
		local data = fulldata[3]
		if saPacket_IsPlaneFiring(data.upDownKeys) then
			local vehid = storeCarCharIsInNoSave(PLAYER_PED) 
			local oX, oY, oZ = getCarCoordinates(vehid)
			local tX, tY, tZ = getOffsetFromCarInWorldCoords(vehid, 0, 5, 0)
			AddGunShot(oX, oY, oZ, tX, tY, tZ)
		end
	end
end
function tmpres()
	if id == 200 and IsRecording then
		local fulldata = parseVehicleSyncData(bitStream)
		local pid = fulldata[1]
		local vid = fulldata[2]
		local data = fulldata[3]
		if saPacket_IsPlaneFiring(data.upDownKeys) then
			local pchar = sampGetCharHandleBySampPlayerId(pid)
			local vehid = storeCarCharIsInNoSave(pchar) 
			if saPacket_IsPlaneCanFire(vehid) then
				local oX, oY, oZ = getCarCoordinates(vehid)
				local tX, tY, tZ = getOffsetFromCarInWorldCoords(vehid, 0, 5, 0)
				AddGunShot(oX, oY, oZ, tX, tY, tZ)
			end
		end
	end
end
function saPacket_IsPlaneFiring(upDownKeys)
	if upDownKeys == 256 or upDownKeys == 511 or upDownKeys == 2304 or upDownKeys == 2559 or upDownKeys == 8448 or upDownKeys == 8703 or upDownKeys == 16640 or upDownKeys == 16895 or upDownKeys == 18688 or upDownKeys == 18943 or upDownKeys == 25087 then 	return true
	else 
		return false
	end
end
function IsPlaneCanFire(veh)
	local model = getCarModel(veh)
	if model == 476 or model == 447 or model == 425 then
		return true
	else
		return false
	end
end
function AddGunShot(x, y, z, tx, ty, tz)
	local obj = createObject(18643, x, y, z)
	setObjectVisible(obj, false)
	table.insert(ActiveGunShots, {X = x, Y = y, Z = z, tX = tx, tY = ty, tZ = tz, Time = socket.gettime(), Object = obj})
end
function ClearGunShots()
	for i = 1, #ActiveGunShots do
		if not(ActiveGunShots[i] == nil) then
			if  doesObjectExist(ActiveGunShots[i].Object) then deleteObject(ActiveGunShots[i].Object) end
			ActiveGunShots[i] = nil 
		end
	end
end
function UpdateGunShots()
	if not(IsRecording) then return false end
	local pos
	local LTime = socket.gettime()
	for i = 1, #ActiveGunShots do
		if not(ActiveGunShots[i] == nil) then
			pos = SliceLine3D(ActiveGunShots[i].X, ActiveGunShots[i].Y, ActiveGunShots[i].Z, ActiveGunShots[i].tX, ActiveGunShots[i].tY, ActiveGunShots[i].tZ , 25)
			local dst = getDistanceBetweenCoords3d(pos.x, pos.y, pos.z, ActiveGunShots[i].tX, ActiveGunShots[i].tY, ActiveGunShots[i].tZ)
			
			local isSet = setObjectCoordinates(ActiveGunShots[i].Object, pos.x, pos.y, pos.z)
			
			GunFire_SingleShot(i, pos.x, pos.y, pos.z)
			if dst < 10 then 
				if  doesObjectExist(ActiveGunShots[i].Object) then deleteObject(ActiveGunShots[i].Object) end
				ActiveGunShots[i] = nil 
			elseif (LTime - ActiveGunShots[i].Time) > 1 then 
				if  doesObjectExist(ActiveGunShots[i].Object) then deleteObject(ActiveGunShots[i].Object) end
				ActiveGunShots[i] = nil 
			end
		end
	end
end
function parseVehicleSyncData(bs)
	local hnd = require 'samp.events.handlers'
	
	return hnd.packet_vehicle_sync_reader(bs)
end
function GunFire_Interpolate(id, X1, Y1, Z1, X2, Y2, Z2)
	local pos
	local RotX, RotY, RotZ = 0, 0, 0
	X1 = X1/100000
	X2 = X2/100000
	Y1 = Y1/100000
	Y2 = Y2/100000
	for i = 0, 100 do
		wait(10)
		pos = SliceLine3D(X1, Y1, Z1, X2, Y2, Z2, i)
		strr = string.format("\n#%f\n",socket.gettime()-STime)
		WriteFileStr(strr)
		strr = string.format("\nc303%i, T=%.6f|%.6f|%.6f|%.2f|%.2f|%.2f,Type=Projectile + Shell,Color=Red,Coalition=Allies,Name=weapons.shells.5_45x39_NOtr,Pilot=GUNSHOT,Group=GTASA,Country=ru\n",id,pos.x,pos.y,pos.z,RotX,RotY,RotZ)

		WriteFileStr(strr)
	end
end
function SliceLine3D(x1, y1, z1, x2, y2, z2, percentSize)
	local dX = x2 - x1
	local dY = y2 - y1
	local dZ = z2 - z1
	local preX = dX * percentSize
	local preY = dY * percentSize
	local preZ = dZ * percentSize
	local res = { x = x1 + preX, y = y1 + preY, z = z1 + preZ }
	return res
end
function GetMissileRotation(qx, qy, qz, qw)--QuantToFloat, but working not right, why?
	local rx, ry, rz
	rx = math.asin(2*qy*qz-2*qx*qw);
	ry = -math.atan2(qx*qz+qy*qw, 0.5-qx*qx-qy*qy);
	rz = -math.atan2(qx*qy+qz*qw, 0.5-qx*qx-qz*qz);
	return rx, ry, rz
end
function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end
function ReadDBFromTXT(file)
  if not file_exists(file) then return {} end
  local lines = {}
  for line in io.lines(file) do 
	if string.sub(line, 1, string.len('#')) == '#' then
	else
		lines[#lines + 1] = line
	end
  end
  print("{FFFFFF}Loaded {11B8FF}[", #lines, "] {FFFFFF}lines")
  return lines
end
--}-_-

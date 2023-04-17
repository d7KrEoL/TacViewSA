--Script works with moonloader v.026.5-beta, tested on SAMP version 0.3DL.
--BydloCode_start()
--{
require 'moonloader'

local IsRecording = false
local Iteration = 0 --TODO вместо итераций перейти на сверку с системным временем, в миллисекундах
local TVRec

script_name("TacViewSA")
script_author("d7.KrEoL")
script_version("0.0.2-b18.04.2023")
script_url("https://vk.com/d7kreol")
script_description("Сохранение телеметрии GTASA:MP в ACMI формате. (Адаптация для SAMP WARS).")

function main()

	local TVRec
	
		
	repeat wait(0) until isSampLoaded()
	repeat wait(0) until isSampAvailable()
	
	print("TVRec script is active, type /tvrec into T-chat to start/stop recording")

	sampRegisterChatCommand("tvrec",
          function()
            IsRecording = not IsRecording;
			if IsRecording then
				OpenFile()
				WriteFileHeader()
				Iteration = 0
			else
				CloseFile()
			end
			print("TVRecorder: ",IsRecording);
          end)

	function GetAllPlayersPos()
		local peds = getAllChars()
		local CharCar
		local pName
		local PosX, PosY, PosZ, RotX, RotY, RotZ, tmpx
		local strr
		for i, v in ipairs(peds) do
			if doesCharExist(v) then
				local result, playerid = sampGetPlayerIdByCharHandle(v)
				
				if result then
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
						CH = getCarHealth(CharCar)
						CS = getCarSpeed(CharCar)*0.2777778
						playerid = playerid + 100
						if CH == 0 then 
							strr = string.format("\n-a%i\n", playerid)
						else 
							strr = string.format("\na%i, T=%f|%f|%f|%f|%f|%f,CAS=%f,HDG=%f,Type=Aircraft,Color=Red,Coalition=Allies,Name=%s,Pilot=%s,Health=%f,Group=GTASA,Country=ru\n",playerid,PosX,PosY,PosZ,RotX,RotY,RotZ,CS,RotZ,vName,pName,CH/1000)
						end
						
						WriteFileStr(strr)
					else
						PosX, PosY, PosZ = getCharCoordinates(v)
						PosX = PosX/100000
						PosY = PosY/100000
						RotX = 0
						RotY = 0
						RotZ = getCharHeading(v)+180*-1
						PH=getCharHealth(v)
						playerid = playerid + 100
						if PH == 0 then 
							strr = string.format("\n-a%i\n", playerid)
						else 
							strr = string.format("\na%i, T=%f|%f|%f|%f|%f|%f,Type=Type=Ground+Light+Human+Infantry,Color=Red,Coalition=Allies,Name=AK-47 Infantry,Pilot=%s,Health=%f,Group=GTASA,Country=ru\n",playerid,PosX,PosY,PosZ,RotX,RotY,RotZ,pName,PH/100)
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
		local res
		local objName
		local strr
		for i, v in ipairs(objs) do
			objName = GetObjName(getObjectModel(v))
			
			
			if not (objName == "Trash") then
				res, PosX,PosY,PosZ = getObjectCoordinates(v)
				PosX = PosX/100000
				PosY = PosY/100000

				RotX = 0
				RotY = 0
				RotZ = (getObjectHeading(v)*-1)-90

				strr = string.format("\nb%i, T=%f|%f|%f|%f|%f|%f,Type=Weapon + Missile,Color=Red,Coalition=Allies,Name=%s,Pilot=MISSLE,Group=GTASA,Country=ru\n",v,PosX,PosY,PosZ,RotX,RotY,RotZ,objName)
				WriteFileStr(strr)
			end
			
		end
	end
	
	function OpenFile()
		TVRec = io.open(getGameDirectory() .. "\\moonloader\\resource\\tvsa\\TVRec.acmi", "w+")
		print (TVRec)
		print(getGameDirectory() .. "\\moonloader\\resource\\tvsa\\TVRec.acmi")
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
		WriteFileStr("FileType=text/acmi/tacview\n")
		WriteFileStr("FileVersion=2.1\n")
		WriteFileStr("0,ReferenceLongitude=0\n")
		WriteFileStr("0,ReferenceLatitude=0\n")
		WriteFileStr("0,Category=SAMP Server TacView Recorder\n")
		WriteFileStr("0,ReferenceTime=2016-06-23T09:50:00Z\n")
		WriteFileStr("0,RecordingTime=2023-03-30T15:49:19.09Z\n")
		WriteFileStr("0,Title=San Andreas TacView Recording\n")
		WriteFileStr("0,DataRecorder=SALUAACMI 0.0.0.2-pa180423\n")
		WriteFileStr("0,Author=Kirill Desmov\n")
		WriteFileStr("0,Comments=Contacts - vk.com/d7kreol\n")
		WriteFileStr("40000001,T=0|0|100,Type=Navaid+Static+Bullseye,Color=Blue,Coalition=Enemies\n")
		WriteFileStr("40000002,T=0|0|100,Type=Navaid+Static+Bullseye,Color=Grey,Coalition=Neutrals\n")
		WriteFileStr("40000003,T=0|0|100,Type=Navaid+Static+Bullseye,Color=Red,Coalition=Allies\n")
	end
	
	function GetObjName(objID)
		local switch = require 'switch'
		local tmp
		local oNM = switch()
			:case(-1225, function() 
					tmp = "AIM-9L Sidewinder"--AGM-64
				end)
			:case(-1226, function() 
					tmp = "AGM-65 Maverick"--AGM-64
				end)
			:case(-1227, function() 
					tmp = "AGM-65A Maverick"--AGM 114 Hellfire
				end)
			:case(-1229, function() 
					tmp = "X_58"--X-31П
				end)
			:case(-1230, function() 
					tmp = "R-27ER (AA-10 Alamo-C)"--SW
				end)
			:case(-1231, function() 
					tmp = "Kh-29 Kedge"--SW
				end)
			:case(-1232, function() 
					tmp = "R-60 (AA-8 Aphid-A)"--SW
				end)
			:case(-1233, function() 
					tmp = "9M330"--9М31М
				end)
			:case(-1234, function() 
					tmp = "AGM-88 HARM"--SW
				end)
			:case(-1236, function() 
					tmp = "S-8"--SW
				end)
			:case(-1238, function() 
					tmp = "R-73 (AA-11 Archer)"--SW
				end)
			:case(-1240, function() 
					tmp = "AT_6"--SW
				end)
			:case(1241, function() 
					tmp = "9M113 Konkurs"--SW
				end)
			:case(-1242, function() 
					tmp = "MIM-72G Chaparral"--MIM-146
				end)
			:case(-1283, function() 
					tmp = "S-25"--SW
				end)
			:case(-1328, function() 
					tmp = "AIM-120 AMRAAM"--SW
				end)
			:case(-1355, function() 
					tmp = "X_25MP"--SW
				end)
			:default(function()
					tmp =  "Trash"
				end)
		oNM(objID)
		return tmp
	end
	function GetVehName(vehID)
		local switch = require 'switch'
		local tmp
	
		local vNM = switch()
			:case(401, function() 
				tmp = "M1 Abrams"--Leopard
			end)
			:case(404, function() 
				tmp = "MIM-23 Hawk (M192 LN)"--SW Bradley
			end)
			:case(405, function() 
				tmp = "MIM-23 Hawk (M192 LN)"
			end)
			:case(405, function() 
				tmp = "Eurocopter Tiger"
			end)
			:case(408, function() 
				tmp = "AV-8B Harrier II"
			end)
			:case(409, function() 
				tmp = "Su-27 Flanker"
			end)
			:case(410, function() 
				tmp = "EF2000 Typhoon"--EF2000
			end)
			:case(411, function() 
				tmp = "GAZ-66"--Typhoon
			end)
			:case(413, function() 
				tmp = "GAZ-66"--Tiger
			end)
			:case(417, function() 
				tmp = "CH-53 Sea Stallion"
			end)
			:case(418, function() 
				tmp = "A400M Atlas"
			end)
			:case(420, function()
				tmp = "Kamaz"
			end)
			:case(422, function()
				tmp = "Roland ADS"
			end)
			:case(423, function()
				tmp = "An-30M Clank"
			end)
			:case(424, function()
				tmp = "BRDM-2"--SW BRDM
			end)
			:case(425, function() 
				tmp = "AH-64A Apache"
			end)
			:case(428, function() 
				tmp = "Ka-50 Black Shark"
			end)
			:case(431, function()
				tmp = "Kamaz"
			end)
			:case(432, function() 
				tmp = "M1 Abrams"
			end)
			:case(438, function()
				tmp = "A-10A Thunderbolt II"
			end)
			:case(439, function()
				tmp = "Su-25 Frogfoot"
			end)
			:case(440, function()
				tmp = "Mi-8 Hip"--Ka-60
			end)
			:case(443, function()
				tmp = "F-15E Strike Eagle"
			end)
			:case(444, function() 
				tmp = "M113"
			end)
			:case(447, function() 
				tmp = "SA 341 Gazelle"
			end)
			:case(476, function() 
				tmp =  "P-51D Mustang"
			end)
			:case(511, function()
				tmp =  "An-26"
			end)
			:case(512, function() 
				tmp =  "Yak-1"
			end)
			:case(513, function() 
				tmp =  "Eagle II"
			end)
			:case(519, function() 
				tmp =  "Learjet 45"
			end)
			:case(520, function() 
				tmp =  "AV-8B Harrier II" 
			end)
			:case(553, function() 
				tmp =  "C-130 Hercules"
			end)
			:case(563, function() 
				tmp = "AH-64D Apache Longbow"
			end)
			:case(577, function() 
				tmp =  "Boeing 737-800" 
			end)
			:case(592, function() 
				tmp =  "C-135 Stratolifter"
			end)
			:case(593, function() 
				tmp =  "Cessna 402"
			end)
			:default(function()
				tmp =  "Humvee"
			end)
		vNM(vehID)
		return tmp
	end
	
	function OnUpdateF()
		while true do
			wait(0)
			if (IsRecording and TVRec) then
				wait(154)
				strr = string.format("\n#%f\n",Iteration)
				WriteFileStr(strr)
				wait(0)
				GetAllPlayersPos()
				wait(0)
				GetAllObjectsPos()
				wait(0)
				Iteration = Iteration + 0.2
			end
		end
	end
	
	OnUpdateF()
	
end
--}-_-

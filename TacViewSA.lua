--Script works with moonloader v.026.5-beta, tested on SAMP version 0.3DL.
--BydloCode_start()
--{
require 'moonloader'

local IsRecording = false
local Iteration = 0 --TODO вместо итераций перейти на сверку с системным временем, в миллисекундах
local TVRec
--local STime --TODO вместо итераций перейти на сверку с системным временем, в миллисекундах

script_name("TacViewSA")
script_author("d7.KrEoL")
script_version("0.0.1-b13.04.2023")
script_url("https://vk.com/d7kreol")
script_description("Сохранение телеметрии GTASA:MP в ACMI формате. (Адаптация для SAMP WARS).")

function main()
	
		
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
			print(IsRecording);
          end)

	function GetAllPlayersPos()
		local peds = getAllChars()
		local ids = {}
		local CharCar
		local pName
		local PosX, PosY, PosZ, RotX, RotY, RotZ, tmpx
		local strr
		for i, v in ipairs(peds) do
			if doesCharExist(v) then
				local result, playerid = sampGetPlayerIdByCharHandle(v)

				if result then
					pName = sampGetPlayerNickname(playerid)
					print("-----\nPlayer: ", pName)
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
						playerid = playerid + 100

						strr = string.format("\n%i, T=%f|%f|%f|%f|%f|%f,Type=Aircraft,Color=Red,Coalition=Allies,Name=%s,Pilot=%s,Health=%i,Group=GTASA,Country=ru\n",playerid,PosX,PosY,PosZ,RotX,RotY,RotZ,vName,pName,CH)
            TVRec:write(strr)
					else
						PosX, PosY, PosZ = getCharCoordinates(v)
						PosX = PosX/100000
						PosY = PosY/100000
						RotX = 0
						RotY = 0
						RotZ = getCharHeading(v)

						PH=getCharHealth(v)
						playerid = playerid+100

						strr = string.format("\n%i, T=%f|%f|%f|%f|%f|%f,Type=Type=Ground+Light+Human+Infantry,Color=Red,Coalition=Allies,Name=AK-47 Infantry,Pilot=%s,Health=%i,Group=GTASA,Country=ru\n",playerid,PosX,PosY,PosZ,RotX,RotY,RotZ,pName,PH)
						TVRec:write(strr)
					end
					print("\n-----")
				end
			end
		end
	end
	
	function OpenFile()
		TVRec = io.open(getGameDirectory() .. "\\moonloader\\resource\\tvsa\\TVRec.acmi", "w+")
	end
	
	function CloseFile()
		TVRec:close()
		TVRec = nil
		print("File Saved!")
	end
	
	function WriteFileHeader()
		TVRec:write("FileType=text/acmi/tacview\n")
		TVRec:write("FileVersion=2.1\n")
		TVRec:write("0,ReferenceLongitude=0\n")
		TVRec:write("0,ReferenceLatitude=0\n")
		TVRec:write("0,Category=SAMP Server TacView Recorder\n")
		TVRec:write("0,ReferenceTime=2016-06-23T09:50:00Z\n")
		TVRec:write("0,RecordingTime=2023-03-30T15:49:19.09Z\n")
		TVRec:write("0,Title=San Andreas TacView Recording\n")
		TVRec:write("0,DataRecorder=SALUAACMI 0.0.0.1-pa130423\n")
		TVRec:write("0,Author=Kirill Desmov\n")
		TVRec:write("0,Comments=Contacts - vk.com/d7kreol\n")
		TVRec:write("40000001,T=0|0|100,Type=Navaid+Static+Bullseye,Color=Blue,Coalition=Enemies\n")
		TVRec:write("40000002,T=0|0|100,Type=Navaid+Static+Bullseye,Color=Grey,Coalition=Neutrals\n")
		TVRec:write("40000003,T=0|0|100,Type=Navaid+Static+Bullseye,Color=Red,Coalition=Allies\n")
	end

	function GetVehName(vehID)
		local switch = require 'switch'
		local sresult
	
		local vNM = switch()--Пришлось, ради default, к тому же удобно
			:case(405, function() 
				sresult = "MIM-23 Hawk (M192 LN)"--SAMP WARS
			end)
			:case(408, function() 
				sresult = "AV-8B Harrier II"--SAMP WARS
			end)
			:case(409, function() 
				sresult = "Su-27 Flanker"--SAMP WARS
			end)
			:case(417, function() 
				sresult = "CH-53 Sea Stallion"
			end)
			:case(418, function() 
				sresult = "A400M Atlas"--SAMP WARS
			end)
			:case(420, function()
				sresult = "Kamaz"--SAMP WARS
			end)
			:case(425, function() 
				sresult = "AH-64A Apache"
			end)
			:case(432, function() 
				sresult = "M1 Abrams"
			end)
			:case(438, function()
				sresult = "A-10C Thunderbolt II"
			end)
			:case(439, function()
				sresult = "Su-25 Frogfoot"--SAMP WARS
			end)
			:case(443, function()
				sresult = "F-15E Strike Eagle"--SAMP WARS
			end)
			:case(444, function() 
				sresult = "M113"--SAMP WARS
			end)
			:case(447, function() 
				sresult = "SA 341 Gazelle"
			end)
			:case(476, function() 
				sresult =  "P-51D Mustang"
			end)
			:case(511, function() 
				sresult =  "An-26"
			end)
			:case(512, function() 
				sresult =  "Yak-1"
			end)
			:case(513, function() 
				sresult =  "Eagle II"
			end)
			:case(519, function() 
				sresult =  "Learjet 45"
			end)
			:case(520, function() 
				sresult =  "AV-8B Harrier II" 
			end)
			:case(553, function() 
				sresult =  "C-130 Hercules"
			end)
			:case(563, function() 
				sresult = "AH-64D Apache Longbow"--SAMP WARS
			end)
			:case(577, function() 
				sresult =  "Boeing 737-800" 
			end)
			:case(592, function() 
				sresult =  "C-135 Stratolifter"
			end)
			:case(593, function() 
				sresult =  "Cessna 402"
			end)
			:default(function()
				sresult =  "Humvee"
			end)
		vNM(vehID)
		return tmp
	end
	
	function OnUpdateF()
		while true do
			wait(0)
			if (IsRecording and TVRec) then
				wait(137)
				strr = string.format("\n#%f,\n",Iteration)
				TVRec:write(strr)
				wait(0)
				GetAllPlayersPos()
				wait(0)
				Iteration = Iteration + 0.2--Не всегда будет работать корректно, перейти на сверку с системным временем
			end
		end
	end
	
	OnUpdateF()
	
end
--}-_-

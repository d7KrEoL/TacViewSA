# TacViewSA

Saving samp game telemetry and exporting into tacview. There will be a **client-side (_Moonloader/Lua_)** and **server-side (_Pawn_)** scripts. Both will record **_.acmi_**-formated telemetry data from GTASA to load into TacView (https://www.tacview.net/).

# [Client-Side](Client/) tacview recorder:

Works with moonloader _v.026.5-beta_. You will also need SAMP client version _0.3DL_ installed on your GTA San Andreas.

##Installation

1. [Download](https://www.blast.hk/moonloader/download.php) and install moonloader from [official website](https://www.blast.hk/)

     _to get extra informatiom you can visit_ [forum thread page](https://www.blast.hk/threads/13305/)

2. Download Client-side script. You can find it in [Client](Client/) folder of repository or in [Releases](https://github.com/d7KrEoL/TacViewSA/releases) section;

3. Unzip all files to GTASA/moonloader folder; 

      _TacViewSA.lua should be in 'modloader' root folder (RF), 
      switch.lua in RF/lib, 
      TVRec.lua in RF/resources/tvsa_

4. After entering the server type /tvrec to start/stop recording. Your recorded files will be in RF/resources/tvsa folder.



#Server-Side tacview recorder:

Not yet ready.

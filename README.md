# TacViewSA - ENG

Saving samp game telemetry and exporting into tacview. There will be a **client-side (_Moonloader/Lua_)** and **server-side (_Pawn_)** scripts. Both will record **_.acmi_**-formated telemetry data from GTASA to load into [TacView](https://www.tacview.net/).

# [Client-Side](Client/) tacview recorder:

Recording a data on client-side. Don't need server-side script, using only player's resources, output files can be modified by player, script can also be modified to record a wrong data. Works fine with moonloader _v.026.5-beta_. You will also need SAMP client version _0.3DL_ installed on your GTA San Andreas.

## Installation

1. [Download](https://sampforum.blast.hk/files/03DL/sa-mp-0.3.DL-R1-install.exe) and install samp 0.3 DL client from samp forums archive;

2. [Download](https://www.blast.hk/moonloader/download.php) and install moonloader from [official website](https://www.blast.hk/);

     _to get extra informatiom you can visit_ [forum thread page](https://www.blast.hk/threads/13305/)

3. Download Client-side script. You can find it in [Client](Client/) folder of repository or in [Releases](https://github.com/d7KrEoL/TacViewSA/releases) section;

4. Unzip all files to GTASA/moonloader folder; 

      _TacViewSA.lua should be in 'modloader' root folder (RF), 
      switch.lua in RF/lib, 
      TVRec.lua in RF/resources/tvsa_

5. After entering the server type /tvrec to start/stop recording. Your recorded files will be in RF/resources/tvsa folder. Default filename is TVRec.acmi.



# Server-Side tacview recorder:

Recording a data on server side. Don't need client-side script to be installed on GTASA of players. Using server resources, files are saving on server, so cannot be modified by players, script can't be modified as well. Will be versions for SAMP 0.3.7-R2 and 0.3DL servers.

## Installation

Script is only avaliable for private beta-access now, going into a public release later.



# TacViewSA - RU

Скрипт, позволяющий сохранять данные формата _.acmi_ телеметрии в процессе игры для выгрузки их в программу [TacView](https://www.tacview.net/). Планируется создать **клиентский (_Moonloader/Lua_)** и **серверный (_Pawn_)** скрипты (независимые друг от друга).

# [Клиентский](Client/) скрипт:

Записывает информацию на стороне клиента. Работает автономно от серверного скрипта (независимо от того поддерживает ли сервер запись или нет), использует при работе ресурсы клиента (игрока). Работает на версии moonloader _v.026.5-beta_ и клиента samp _0.3DL_.

## Установка

1. [Скачайте](https://sampforum.blast.hk/files/03DL/sa-mp-0.3.DL-R1-install.exe) и установите клиент 0.3 DL с архива самп форума;

2. [Скачайте](https://www.blast.hk/moonloader/download.php) и установите moonloader с [официального сайта](https://www.blast.hk/);

     _дополнительную информацию можно получить в_ [теме на форуме](https://www.blast.hk/threads/13305/)

3. Скачайте клиентский скрипт архивом из [репозитория](Client/), или на странице с [релизами](https://github.com/d7KrEoL/TacViewSA/releases);

4. Разархивируйте содержимое в папку с игрой/moonloader; 

      _TacViewSA.lua должен лежать в папке 'modloader' (далее КП), 
      switch.lua в КП/lib, 
      TVRec.lua в КП/resources/tvsa,
      при отсутствии какой-либо из папок просто создайте её_

5. Далее можете заходить в игру, после присоединения к серверу и спавна введите /tvrec для начала/окончания записи. записанные файлы будут храниться в папке с игрой/moonloader/resources/tvsa/(название файла).acmi. По умолчанию файл называется TVRec.acmi.



# Серверный скрипт:

Записывает телеметрию на стороне сервера. Работает независимо от наличия либо отсутствия установленного клиентского скрипта у игроков. Задействует ресурсы сервера, не влияет на загруженность клиентских машин. Записи сохраняются на стороне сервера и могут быть модифицированы только администратором, либо людьми, имеющими доступ к файловой системе машины. Серверный скрипт не может быть модифицирован на стороне клиента либо сервера без дополнительных инструментов и скачивается в скомпилированном виде.

## Установка
На данный момент проходит закрытое тестирование, публичный релиз запланирован на более поздний срок.

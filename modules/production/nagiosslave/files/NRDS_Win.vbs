'# Developed by: Yancy Ribbens (yribbens@nagios.com)
'# Copyright (c) 2010-2011 Nagios Enterprises, LLC.

'# Fixed inability to run multiple checks using the same plugin
'# Ver R2.1

'# Ver R2.2
'Changed regular expression matching to match service name to be 
'anything except `~!$%^&*|'"<>?,()=

'# Ver R2.3
'moved XML header creation outside of host logic so if no __host__ exists
'XML header will still be created

'# Ver R2.4
'improved log messaging and added log size limits

'branched to R3.0

'# Ver R3.1
'changed regular expression matching when parsing for plugins to match
'extension names of any size and no spaces in file name

'# Ver R3.2
'add diag mode to pass static check to nagios for testing
'invoke from cmd line:
'cscript NRDS_win.vbs -diag

'# Ver R4.0
'Ignore certificate errors

'#Branch to Version 1.0 stable

'# Ver 1.01
'add RegEx test before parsing for filename to protect against bad command definitions

'# Ver 1.1
'add [extensions] settings for wrapping command definitions

'# Ver 1.11
'handel error if no output returned by plugin

current_version = "NRDS_Win 1.11"

On Error Resume Next

Const ForReading = 1
Const ForWriting = 2
Const ForAppending = 8

Set objShell = CreateObject("Wscript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

hostState = "0"

max_log_size = 500

'Creates Dictionary for each [section] in .ini file
Function IniToDict(ByVal iniFile)
	'Declare our comment RegEx
    Dim commentRegEx
    Dim headerRegEx
    Dim valueRegEx
    Dim regExMatch
    
    ' Shows current header that is currently being processed
    Dim currHeader
    
    ' Key value that is currently being processed
    Dim currKey
    Dim currValue
    
    Set commentRegEx = New RegExp
    Set headerRegEX  = New RegExp
    Set valueRegEx   = New RegExp
	Set CheckRegEx   = New RegExp
    
    headerRegEx.pattern  = "^\s*\[\s*([a-zA-Z]*)\s*\].*$"
	valueRegEx.pattern   = "^(\w*)\s*=\s*(.*)\s*$"
	CheckRegEx.pattern   = "^command\[([^`~!$%^&*|'""<>?,()=]*)]\s*=\s*(.*)\s*$"
    
    'Create a File System Object
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    Set readIniFile   = CreateObject("Scripting.Dictionary")
	
	GetTheParent = objFSO.GetParentFolderName(wscript.ScriptFullName)
	iniFile = GetTheParent & "\" & iniFile
	
    'Open the text file - strData now contains the whole file
    strData = objFSO.OpenTextFile(iniFile,ForReading).ReadAll
    
    'Split the text file into lines
    arrLines = Split(strData,vbCrLf)
    'Step through the lines
	
    For Each strLine in arrLines
        If headerRegEx.Test(strLine) Then
            currHeader  = headerRegEx.Execute(strLine)(0).SubMatches(0)
            readIniFile.Add currHeader, CreateObject("Scripting.Dictionary")
        ElseIf valueRegEx.Test(strLine) Then
            currKey     = valueRegEx.Execute(strLine)(0).SubMatches(0)
            currValue   = valueRegEx.Execute(strLine)(0).SubMatches(1)
            readIniFile(currHeader).Add currKey , currValue
        ElseIf CheckRegEx.Test(strLine) Then
			currKey     = CheckRegEx.Execute(strLine)(0).SubMatches(0)
            currValue   = CheckRegEx.Execute(strLine)(0).SubMatches(1)
			readIniFile(currHeader).Add currKey , currValue
		End If
	Next
	
	Set IniToDict = readIniFile

End Function

Function URLEncode(ByVal str)
 Dim strTemp, strChar
 Dim intPos, intASCII
 strTemp = ""
 strChar = ""
 For intPos = 1 To Len(str)
  intASCII = Asc(Mid(str, intPos, 1))
  If intASCII = 32 Then
   strTemp = strTemp & "+"
  ElseIf ((intASCII < 123) And (intASCII > 96)) Then
   strTemp = strTemp & Chr(intASCII)
  ElseIf ((intASCII < 91) And (intASCII > 64)) Then
   strTemp = strTemp & Chr(intASCII)
  ElseIf ((intASCII < 58) And (intASCII > 47)) Then
   strTemp = strTemp & Chr(intASCII)
  Else
   strChar = Trim(Hex(intASCII))
   If intASCII < 16 Then
    strTemp = strTemp & "%0" & strChar
   Else
    strTemp = strTemp & "%" & strChar
   End If
  End If
 Next
 URLEncode = strTemp
End Function

Function GetOSVer()
	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
	Set oss = objWMIService.ExecQuery ("Select * from Win32_OperatingSystem")

	For Each os in oss
		GetOSVer = os.Version
	Next
End Function

'Creates Log file of debug information
Function WriteLog(Galactic_Guide, message, LogData )
	Const ForReading = 1
	Const ForWriting = 2
	Const ForAppending = 8
	
	LOG_FILE = Galactic_Guide.item("LOG_FILE")
	
    Set objLogFile = objFSO.OpenTextFile( LOG_FILE, ForAppending, True )
	
	WriteLog = Date
	WriteLog = WriteLog & " "
	WriteLog = WriteLog & Time
	WriteLog = WriteLog & " "
	WriteLog = WriteLog & message
	WriteLog = WriteLog & " : "
	WriteLog = WriteLog & LogData
	
    objLogFile.WriteLine ( WriteLog )

    objLogFile.Close

End Function

'Posts Data
Function PostData(Data, nrdp_address, Galactic_Guide )
		log_message = "running Post routine.."
		WriteLog Galactic_Guide, log_message, ""
		
		SSL_OPTION = 13056
		IGNORE_SSL = Galactic_Guide.item("IGNORE_SSL_CERTIFICATE_ERRORS")
		
		if IGNORE_SSL = "0" then
			SSL_OPTION = 0
			log_message = "Honor certificate errors"
			WriteLog Galactic_Guide, log_message, SSL_OPTION
		else
			log_message = "ignoring certificate errors"
			WriteLog Galactic_Guide, log_message, SSL_OPTION
		end if
		
		log_message = "Post Data...."
		WriteLog Galactic_Guide, log_message, Data
		
		log_message = "address....."
		WriteLog Galactic_Guide, log_message, nrdp_address
		
		submit = nrdp_address & Data
		
		Err.Clear
		Set objXmlHttp = CreateObject("Msxml2.ServerXMLHTTP")
		REM oXMLHTTP.setProxy 2, “http=dc-proxy-resolvable-hostname:9090″, “”
		objXmlHttp.setOption 2, SSL_OPTION
		objXmlHttp.open "POST", submit, False
		objXmlHttp.send
		
		REM If Err.Number <> 0 Then
			REM log_message = "Error while submitting to Nagios"
			REM WriteLog Galactic_Guide, log_message, ""
			REM WriteLog Galactic_Guide, "Error: ", Err.Number
			REM WriteLog Galactic_Guide, "Error (Hex): ", Err.Number
			REM WriteLog Galactic_Guide, "Source: ", Err.Number
			REM WriteLog Galactic_Guide, "Description: ", Err.Number
			REM Err.Clear
		REM End If
		REM On Error Goto 0

		Set PostData = objXmlHttp
		Set objXmlHttp = Nothing
		
End Function

'Process each check in [services] and formats as XML
Function ProcessChecks( checks, Galactic_Guide, diag )
	PLUGIN_DIR  = Galactic_Guide.item("PLUGIN_DIR")
	TOKEN	    = Galactic_Guide.item("TOKEN")
	HOSTNAME    = Galactic_Guide.item("HOSTNAME")
	set folder  = objFSO.GetFolder( PLUGIN_DIR )
	plugin_path = folder.ShortPath
	
	xmlData = "token=" & TOKEN & "&cmd=submitcheck&XMLDATA=<?xml version='1.0'?>" _
				& "<checkresults>"

	For Each servicename in checks.Keys
	
		'split the line into two parts, the service name and the check
		chkCmd = checks(servicename)
		
		LOG_FILE = Galactic_Guide.item("LOG_FILE")
		
		if diag Then
			output = servicename
			state = "1"
		else
			result_array = run_check( chkCmd , Galactic_Guide )
			output = result_array(0)
			state  = result_array(1)
		end if

		if servicename = "__HOST__" then
			xmlData = xmlData & "<checkresult type='host' checktype='1'>" _
						& "<hostname>" & HOSTNAME & "</hostname>" _
						& "<state>" & state & "</state>" _
						& "<output>" & output & "</output>" _
					& "</checkresult>"
		else
		'xmlData = xmlData & "<checkresult type='service' checktype='1'><hostname>" & host & "</hostname><servicename>" & servicename & "</servicename><state>" & state & "</state><output>" & output & "</output></checkresult> "
			xmlData = xmlData & "<checkresult type='service' checktype='1'>" _
						& "<hostname>" & HOSTNAME & "</hostname>" _
						& "<servicename>" & servicename & "</servicename>" _
						& "<state>" & state & "</state>" _
						& "<output>" & output & "</output>" _
					& "</checkresult>"
		end if

	Next
	
	xmlData = xmlData & "</checkresults>"
	
	log_message = "XML to be posted to NRDP"
	WriteLog Galactic_Guide, log_message, xmlData
	
	ProcessChecks = xmlData
	
End Function
				
				
Function run_check( chkCmd, Galactic_Guide )
	Set retDict = IniToDict( "Config.ini" )
	
	if retDict.Exists( "extensions" ) Then
		Set extensions  = retDict.Item( "extensions" )
	
		Set file_ext = New RegExp
		file_ext.pattern = "\$PLUGIN_DIR\$\\[^\\/:\*\ ?""<>\|]+\.([\w]*)"
	
		Set file_name = New RegExp
		file_name.pattern = "\$PLUGIN_DIR\$\\([^\\/:\*\ ?""<>\|]+\.[\w]*)"
	
		if file_ext.test(chkCmd) then
			ext = file_ext.execute(chkCmd)(0).SubMatches(0)
		end if
	
		For Each ext_type in extensions.keys
			if ext_type = ext then
				Set check_command = New RegExp
				check_command.pattern = "\$CHECK_COMMAND\$"
				chkCmd = check_command.replace( extensions(ext_type), chkCmd )
			end if
		Next
	end if
	
	PLUGIN_DIR = Galactic_Guide.item("PLUGIN_DIR")
	
	Set file_cmd = New RegExp
	file_cmd.pattern = "\$PLUGIN_DIR\$"
	
	chkCmd = file_cmd.replace( chkCmd , PLUGIN_DIR )
	
	'creates the commad line argument to run
	cmdLine = "cmd /c "
	'cmdLine = cmdLine & """"
	cmdLine = cmdLine & chkCmd
	'cmdLine = cmdLine & """"
	cmdLine = cmdLine & " > %temp%\output.txt"
	
	log_message = "command to be run"
	WriteLog Galactic_Guide, log_message, chkCmd

	log_message = "command line executing"
	WriteLog Galactic_Guide, log_message, cmdLine
	'determine return code of check
	state = objShell.Run(cmdLine,0,True)
	
	'set location of output file created by check and collects parses that file
	tempd = objShell.ExpandEnvironmentStrings( "%TEMP%" )
	outputLoc = tempd & "\output.txt"
	
	Set f = objFSO.OpenTextFile(outputLoc)

	output = ""
	Do Until f.AtEndOfStream
	  output = output + f.ReadLine
	Loop
		
	output = replace(output, "<" , "&lt;")
	output = replace(output, ">" , "&gt;")
	output = URLEncode( output )
		
	check_output_debug = output
	log_message = "return results from plugin"
	WriteLog Galactic_Guide, log_message, output
		
	check_return_debug = state
	log_message = "return code from plugin"
	WriteLog Galactic_Guide, log_message, state
		
	result_array = array( output, state )
	run_check = result_array

End Function

'''''''''''''''''''''''checks for updates''''''''''''''''''''''
'function to download plugins

Function RetriveURL( Galactic_Guide, URL, save_file )
	
	log_message = "downloading new file"
	WriteLog Galactic_Guide, log_message, URL
	
	set objXMLHTTP = PostData ("", URL, Galactic_Guide)
	
	Set objADOStream = CreateObject("ADODB.Stream")
	if objXMLHTTP.Status = 200 then
		
		objADOStream.Open
		objADOStream.Type = 1 'adTypeBinary

		objADOStream.Write objXMLHTTP.ResponseBody
		objADOStream.Position = 0    'Set the stream
	End if

	set objFSO = Createobject("Scripting.FileSystemObject")
	if objFSO.Fileexists( save_file ) then
		objFSO.DeleteFile save_file
	End if
	
	objADOStream.SaveToFile save_file
	objADOStream.Close
	
	Set objXmlHttp = Nothing
End Function

Function NRDP_fetch_plugin( Galactic_Guide, ByVal plugin_url, filename )
	
	plugin_url = plugin_url & "getplugin&plugin="
	plugin_url = plugin_url & filename
	plugin_url = plugin_url & "&os=Windows"
	plugin_url = plugin_url & "&os_ver="
	plugin_url = plugin_url & os_ver
	plugin_url = plugin_url & "&arch="
	plugin_url = plugin_url & CPU_architecture
	
	log_message = "downloading new plugin"
	WriteLog Galactic_Guide, log_message, filename
	
	log_message = "new plugin URL"
	WriteLog Galactic_Guide, log_message, plugin_url
	
	NRDP_fetch_plugin = plugin_url
	
End Function

Function NRDP_fetch_config( Galactic_Guide, ByVal config_url )

	CONFIG_NAME = Galactic_Guide.item( "CONFIG_NAME" )
	
	config_url = config_url & "getconfig&configname="
	config_url = config_url & CONFIG_NAME
	config_url = config_url & "&os=Windows"
	config_url = config_url & "&os_ver="
	config_url = config_url & os_ver
	config_url = config_url & "&arch="
	config_url = config_url & CPU_architecture
	
	log_message = "downloading new config"
	WriteLog Galactic_Guide, log_message, config_url
	
	NRDP_fetch_config = config_url
	
End Function

'returns true if new config is available, otherwise return false
Function NRDP_Check( Galactic_Guide, ByVal config_check_url )
	
	CONFIG_NAME    = Galactic_Guide.item("CONFIG_NAME")
	CONFIG_VERSION = Galactic_Guide.item("CONFIG_VERSION")

	xml = "<?xml version='1.0' ?>" _
			& "<configs>" _
				& "<config>" _
					& "<name>" & CONFIG_NAME & "</name>" _
					& "<version>" & CONFIG_VERSION & "</version>" _
				& "</config>" _
			& "</configs>"
	
	config_check_url = config_check_url & "updatenrds&XMLDATA="
	config_check_url = config_check_url & xml
	
	log_message = "XML being passed to check for updates"
	WriteLog Galactic_Guide, log_message, config_check_url
	
	Set XMLStatus = PostData( "", config_check_url, Galactic_Guide )
	
	log_message = "NRDP response to update query"
	WriteLog Galactic_Guide, log_message, XMLStatus.responseText
	
	Set objXMLDoc = CreateObject( "Microsoft.XMLDOM" ) 
	objXMLDoc.async = False 
	objXMLDoc.loadXML( XMLStatus.responseText )

	Set Root = objXMLDoc.documentElement 
	
	Set colNodes = objXMLDoc.selectNodes( "/result/status" )
		for each objNode in colNodes
			item = objNode.text
			if item = "1" Then
				update_available = True
			else update_available = False
			end if
		log_message = "Config update availability"
		WriteLog Galactic_Guide, log_message, update_available
		Next
		
	NRDP_Check = update_available
	
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function filecount( LOG )

	set txtinput = objFSO.OpenTextFile( LOG,ForReading )

	'Skip lines one by one 
	Do While txtinput.AtEndOfStream <> True
		strTemp = txtinput.SkipLine ' or .ReadLine
	Loop

	filecount = txtinput.Line-1 ' Returns the number of lines
	
End Function


Function trimlog( LOG )

	set txtinput = objFSO.OpenTextFile( LOG,ForReading )
	NewFile = ""
	trim_file = false
	trimmed   = false
	
	Do until txtinput.AtEndOfStream
		strLine = txtinput.Readline
		
		if InStr(strLine, "---Starting NRDS Transaction---") <> 0 then
			if trimmed = false then
				trim_file = true
				trimmed   = true
			end if
		end if
		
		if trim_file = false then
			NewFile = NewFile & strLine & vbcrlf
		end if
		
		if InStr(strLine, "---NRDS Transaction Finished---") then 
			trim_file = false
		end if
		
	Loop
	txtinput.Close
	
	Set LOG_FILE = objFSO.OpenTextFile( LOG,ForWriting )
	LOG_FILE.Write NewFile
	LOG_FILE.Close
	
	filesize = filecount( LOG )
	
	if filesize > max_log_size then
		trimlog( LOG )
	end if
	
End function

Function diag_mode(Galactic_Guide)
	Set args = Wscript.arguments
	diag_mode = False
	
	For Each arg in args
		log_message = "Argument passed"
		WriteLog Galactic_Guide, log_message, arg
		if arg = "-diag" then
			diag_mode = True
		end if
	Next
	
	log_message = "Diagnostic mode"
	WriteLog Galactic_Guide, log_message, diag_mode
	
End Function
		

Function main()
	Set Galactic_Guide = CreateGalacticGuide()
	
	LOG_FILE = Galactic_Guide.item("LOG_FILE")
	
	
	log_message = "---Starting NRDS Transaction---"
	WriteLog Galactic_Guide, log_message, ""
	
	log_size = filecount( LOG_FILE )
	diag = diag_mode(Galactic_Guide)
	
	if log_size > max_log_size Then
		trimlog LOG_FILE
	end if
	
	'create prefix url
	URL = Galactic_Guide.item( "URL" )
	TOKEN = Galactic_Guide.item( "TOKEN" )
	
	nrdp_url = URL
	nrdp_url = nrdp_url & "/"
	nrdp_url = nrdp_url & "?token="
	nrdp_url = nrdp_url & TOKEN
	nrdp_url = nrdp_url & "&cmd="
	
	log_message = "base NRDP address locked and loaded"
	WriteLog Galactic_Guide, log_message, nrdp_url
	
	UPDATE_CONFIG = Galactic_Guide.item( "UPDATE_CONFIG" )
	
	if UPDATE_CONFIG = "1" Then
		
		'new_config_available will be true or false
		new_config_available = NRDP_Check( Galactic_Guide, nrdp_url )
		
		'grab new config if available
		if new_config_available then
			NRDP_fetch_config_url = NRDP_fetch_config( Galactic_Guide, nrdp_url )
			CONFIG = Galactic_Guide.item("CONFIG")
			RetriveURL Galactic_Guide, NRDP_fetch_config_url, CONFIG
			Set Galactic_Guide = Nothing
			Set Galactic_Guide = CreateGalacticGuide()
		end if
	End if

	''''''''''''''run checks'''''''''''''''''''''''''''''''
	'new config loaded should exist now
	Set retDict = IniToDict( "Config.ini" )
	Set checks  = retDict.Item( "services" )
	'plugin_path = retDict.Item("settings").Item("PLUGIN_DIR")

	'if updates plugins are enabled
	UPDATE_PLUGINS = Galactic_Guide.item("UPDATE_PLUGINS")
	
	if UPDATE_PLUGINS = "1" then
		'Set CheckDict = ParseChecks(nrdp_url, checks, Galactic_Guide)
		
		Set file_name = New RegExp
		file_name.pattern = "\$PLUGIN_DIR\$\\([^\\/:\*\ ?""<>\|]+\.[\w]*)"
		PLUGIN_DIR = Galactic_Guide("PLUGIN_DIR")
		
		For Each check in checks.keys
			chk_cmd = checks(check)
			
			if file_name.test(chk_cmd) then
				file	  = file_name.execute(chk_cmd)(0).SubMatches(0)
				FullPath = PLUGIN_DIR + "\" + file
				
				if not objFSO.FileExists( FullPath ) Then
					log_message = "new plugins available"
					WriteLog Galactic_Guide, log_message, file
					
					log_message = "downloading plugin to"
					WriteLog Galactic_Guide, log_message, FullPath
					
					Plugin_Fetch_URL = NRDP_fetch_plugin(Galactic_Guide, nrdp_url, file)
					RetriveURL Galactic_Guide, Plugin_Fetch_URL, FullPath
				end if
			end if
		Next
	End if

	if diag Then
		log_message = "create test check"
		WriteLog Galactic_Guide, log_message, diag
		Set checks = CreateObject("Scripting.Dictionary")
		checks.Add current_version, "bogus data"
	else
		Set checks  = retDict.Item("services")
	end if
	
	postXML = ProcessChecks( checks, Galactic_Guide, diag )
	Set postResult = PostData( postXML, nrdp_url, Galactic_Guide )
	
	log_message = "post response from NRDP"
	WriteLog Galactic_Guide, log_message, postResult.responseText
	
	log_message = "---NRDS Transaction Finished---"
	WriteLog Galactic_Guide, log_message, ""
End Function

Function CreateGalacticGuide()
	
	'Create dictionary item from .ini file
	Set retDict = IniToDict( "Config.ini" )
	Set hostDict = IniToDict( "Host.ini" )
	
	Set Galactic_Guide = CreateObject( "Scripting.Dictionary" )
	
	Galactic_Guide.add "CONFIG_VERSION", retDict.Item( "settings" ).Item( "CONFIG_VERSION" )
	Galactic_Guide.add "CONFIG_NAME", retDict.Item( "settings" ).Item( "CONFIG_NAME" )
	Galactic_Guide.add "URL", retDict.Item( "settings" ).Item( "URL" )
	Galactic_Guide.add "TOKEN", retDict.Item( "settings" ).Item( "TOKEN" )
	Galactic_Guide.add "IGNORE_SSL_CERTIFICATE_ERRORS", retDict.Item( "settings" ).Item( "IGNORE_SSL_CERTIFICATE_ERRORS" )
	
	PLUGIN_DIR = retDict.Item( "settings" ).Item( "PLUGIN_DIR" )
	SET PLUGIN_DIR_SHORT = objFSO.GetFolder( PLUGIN_DIR )
	PLUGIN_DIR = PLUGIN_DIR_SHORT.ShortPath

	Galactic_Guide.add "PLUGIN_DIR", PLUGIN_DIR
	Galactic_Guide.add "UPDATE_CONFIG", retDict.Item( "settings" ).Item( "UPDATE_CONFIG" )
	Galactic_Guide.add "UPDATE_PLUGINS", retDict.Item( "settings" ).Item( "UPDATE_PLUGINS" )
	Galactic_Guide.add "LOG_FILE", retDict.Item( "settings" ).Item( "LOG_FILE" )
	Galactic_Guide.add "CONFIG", hostDict.Item( "settings" ).Item( "CONFIG" )
	
	HOSTNAME = hostDict.Item( "settings" ).Item( "HOSTNAME" )
	
	if HOSTNAME = "localhost" Then
		set wshnetwork = createobject("wscript.network")
		HOSTNAME = wshnetwork.computername
	End If
	Galactic_Guide.add "HOSTNAME", HOSTNAME
	
	Set CreateGalacticGuide = Galactic_Guide
	
End Function

CPU_architecture = objShell.ExpandEnvironmentStrings( "%PROCESSOR_ARCHITECTURE%" )
os_ver = GetOSVer()

main()

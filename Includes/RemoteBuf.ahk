;---------------------------------------------
; Open remote buffer
;
; ARGUMENTS: p_handle	- HWND of buffer host
;			 p_size		- Size of the buffer
;
; Returns	buffer handle (>0)
;			-1 if unable to open process
;			-2 if unable to get memory
;--------------------------------------------
RemoteBuf_Open(p_handle, p_size)
{
	global
	local proc_hwnd, bufAdr, pid

	
	WinGet, pid, PID, ahk_id %p_handle%
	proc_hwnd := DllCall( "OpenProcess"
                         , "uint", 0x38				; PROCESS_VM_OPERATION | PROCESS_VM_READ | PROCESS_VM_WRITE (0x0020)
                         , "int", false 
                         , "uint", pid ) 

	if proc_hwnd = 0
		return -1
		
	bufAdr	:= DllCall( "VirtualAllocEx" 
                        , "uint", proc_hwnd
                        , "uint", 0 
                        , "uint", p_size			; SIZE
                        , "uint", 0x1000            ; MEM_COMMIT 
                        , "uint", 0x4 )				; PAGE_READWRITE 
	
	if bufAdr = 
		return -2

	RemoteBuf_idx += 1
	RemoteBuf_%RemoteBuf_idx%_handle  := proc_hwnd
	RemoteBuf_%RemoteBuf_idx%_size	  := p_size
	RemoteBuf_%RemoteBuf_idx%_adr	  := bufAdr

	return RemoteBuf_idx
}

;----------------------------------------------------
; Close remote buffer.
;----------------------------------------------------
RemoteBuf_Close(p_bufHandle)
{
	global
	local handle, adr

	handle	:= RemoteBuf_%p_bufHandle%_handle
	adr		:= RemoteBuf_%p_bufHandle%_adr

	if handle = 0
		return 0

    result := DllCall( "VirtualFreeEx" 
                     , "uint", handle
                     , "uint", adr
                     , "uint", 0 
                     , "uint", 0x8000 )				; MEM_RELEASE 
	

	DllCall( "CloseHandle", "uint", handle )

	RemoteBuf_%p_bufHandle%_adr		 = 
	RemoteBuf_%RemoteBuf_idx%_size	 =
	RemoteBuf_%RemoteBuf_idx%_handle =

	return result
}
;----------------------------------------------------
; Read remote buffer and return buffer
;----------------------------------------------------
RemoteBuf_Read(p_bufHandle, byref p_localBuf, p_size, p_offset = 0)
{
	global
	local handle, adr, size, localBuf

	handle	:= RemoteBuf_%p_bufHandle%_handle
	adr		:= RemoteBuf_%p_bufHandle%_adr
	size	:= RemoteBuf_%p_bufHandle%_size


	if (handle = 0) or (adr = 0) or (offset >= size)
		return -1

    result := DllCall( "ReadProcessMemory" 
                  , "uint", handle
                  , "uint", adr + p_offset
                  , "uint", &p_localBuf
                  , "uint", p_size
                  , "uint", 0 ) 
	
	return result
}

;----------------------------------------------------
; Write to remote buffer, local buffer p_local.
;----------------------------------------------------
RemoteBuf_Write(p_bufHandle, byref p_local, p_size, p_offset=0)
{
	global
	local handle, adr, size

	handle	:= RemoteBuf_%p_bufHandle%_handle
	adr		:= RemoteBuf_%p_bufHandle%_adr
	size	:= RemoteBuf_%p_bufHandle%_size
	

	if (handle = 0) or (adr = 0) or (offset >= size)
		return -1

	result  := DllCall( "WriteProcessMemory"
						,"uint", handle
						,"uint", adr + p_offset
						,"uint", &p_local
						,"uint", p_size
						,"uint", 0 )

	return result
}


RemoteBuf_GetAdr(p_handle) 
{
	global
	return 	RemoteBuf_%p_handle%_adr
}

RemoteBuf_GetSize(p_handle) 
{
	global
	return 	RemoteBuf_%p_handle%_size
}
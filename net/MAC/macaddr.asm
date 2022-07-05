; CQX96 networking
; Based on https://github.com/CosmosOS/Cosmos/blob/Userkit_20220209/source/Cosmos.HAL2/Network/MACAddress.cs

; MAC Address NONE
macaddr_none:
    times 6 db 0     ; Broadcast array

; MAC Address Broadcast
macaddr_none:
    times 6 db 0xFF  ; Broadcast array

; MAC Address Current
macaddr_current:
    times 6 db 0     ; Broadcast array
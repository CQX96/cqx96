cqx                   EQU  0000h
printstring           EQU  0003h
commandline           EQU  0006h
newline               EQU  0009h
os_create_file        EQU  000Ch
os_remove_file        EQU  000Fh
getinput              EQU  0012h
os_write_file         EQU  0015h
os_string_chomp       EQU  001Bh
os_int_to_string      EQU  001Eh
os_load_file          EQU  0021h
os_string_copy        EQU  0024h
os_string_tokenize    EQU  0027h
os_string_length      EQU  002Ah
os_print_2hex         EQU  002Dh
os_print_4hex         EQU  0030h
os_string_compare     EQU  0033h
os_string_to_int      EQU  0036h
os_get_file_size      EQU  0039h
program_file          EQU  003Ch

login		  EQU  003Fh
get_username	  EQU  0042h

os_string_uppercase   EQU  0045h

graphics_init	  EQU  0048h
graphprint	    	  EQU  004Bh
graphics_uninit	  EQU  004Eh

get_uname		  EQU  0051h
not_implemented	  EQU  0054h
os_get_file_list      EQU  0057h
change_device         EQU  005Ah
get_device            EQU  005Dh
os_string_parse       EQU  0060h

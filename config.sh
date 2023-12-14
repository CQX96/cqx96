echo "CQX96 Kernel Configuration"
echo "Graphics Support (y/n):"
read graphics_support
echo "Login System (y/n):"
read login_system
echo "Ignore Panics (y/n):"
read ignore_panics
echo "Load Screen (y/n):"
read load_screen
echo "MD5 Hash (y/n):"
read md5_hash
echo "Multi Device (y/n):"
read multi_device
echo "graphics_support=$graphics_support" > config.txt
echo "login_system=$login_system" >> config.txt
echo "ignore_panics=$ignore_panics" >> config.txt
echo "load_screen=$load_screen" >> config.txt
echo "md5_hash=$md5_hash" >> config.txt
echo "multi_device=$multi_device" >> config.txt
echo "Done!"
 #! /bin/bash
 make clean
 make
 if [ ! -e "upscaled" ];then mkdir -p "upscaled"; fi

 for i in $(ls ./downscaled); 
    do 
        ./upscale ./downscaled/$i 3840 2160 ./upscaled/$i; 
        echo $i; 
    done
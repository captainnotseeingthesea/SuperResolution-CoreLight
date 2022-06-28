/*************************************************

 Copyright: NUDT_CoreLight

 File name: bmp.svh

 Author: NUDT_CoreLight

 Date: 2021-04-14


 Description:

  BMP file manipulate

 **************************************************/

class BMP;

    extern static function void bmp2bin(string src="", string dst="");
    extern static function void bin2bmp(string src="", string dst="", int height=0, int width=0);

endclass


// Methods
function void BMP::bmp2bin(string src="", string dst="");
    if(src == "" || dst == "") begin
        $display("bmp2bin: invalid file name");
        $finish;
    end

    $system({utils_path, $sformatf("/bmp_bin.py bmp2bin %s %s", src, dst)});
endfunction


function void BMP::bin2bmp(string src="", string dst="", int height=0, int width=0);
    if(src == "" || dst == "" || height == 0 || width == 0) begin
        $display("bin2bmp: invalid arguments");
        $finish;
    end

    $system({utils_path, $sformatf("/bmp_bin.py bin2bmp %s %s %d %d", src, dst, height, width)});
endfunction
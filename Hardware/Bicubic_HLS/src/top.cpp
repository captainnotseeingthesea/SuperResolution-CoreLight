#include "top.h"

void my_hls_resize(AXI_STREAM& src_axi, AXI_STREAM& dst_axi)
{
#pragma HLS INTERFACE axis port=src_axi
#pragma HLS INTERFACE axis port=dst_axi

#pragma HLS INTERFACE ap_ctrl_none port=return

        int interpolation;
		SRC_IMAGE       imag_0;
		DST_IMAGE       imag_1;
		#pragma HLS dataflow
		hls::AXIvideo2Mat(src_axi, imag_0);
		hls::Resize(imag_0,imag_1,interpolation=HLS_INTER_CUBIC);
		hls::Mat2AXIvideo(imag_1, dst_axi);
}

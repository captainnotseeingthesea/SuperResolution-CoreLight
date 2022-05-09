#ifndef _TOP_H_
#define _TOP_H_
#include "hls_video.h"
#include "ap_int.h"

#define SRC_WIDTH  960
#define SRC_HEIGHT 540

#define DST_WIDTH  3840
#define DST_HEIGHT 2160

typedef hls::stream<ap_axiu<24,1,1,1> >               AXI_STREAM;

typedef hls::Mat<SRC_HEIGHT, SRC_WIDTH, HLS_8UC3>     SRC_IMAGE;
typedef hls::Mat<DST_HEIGHT, DST_WIDTH, HLS_8UC3>     DST_IMAGE;

void my_hls_resize(AXI_STREAM& src_axi, AXI_STREAM& dst_axi);

#endif

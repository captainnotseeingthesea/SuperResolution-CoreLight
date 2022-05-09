#include "top.h"
#include "hls_opencv.h"
#include "iostream"
#include <time.h>

using namespace std;
using namespace cv;

#define INPUT_IMAGE         "0.bmp"
int main (int argc, char** argv)
{

	Mat src = imread(INPUT_IMAGE);

	Mat dst(DST_HEIGHT,DST_WIDTH, CV_8UC3);

	if(src.empty())
	{
		printf("load jpg fail\r\n");
		return -1;
	}
	if(src.elemSize() != 3)
	{
		printf("jpg d len not fit\r\n");
		return -1;
	}

	AXI_STREAM src_axi, dst_axi;

	cvMat2AXIvideo(src, src_axi);

	my_hls_resize(src_axi,dst_axi);

	AXIvideo2cvMat(dst_axi, dst);

	imshow("src",src);

	imshow( "dst",dst);

	imwrite("upscaled.bmp", dst);

	waitKey(0);
}

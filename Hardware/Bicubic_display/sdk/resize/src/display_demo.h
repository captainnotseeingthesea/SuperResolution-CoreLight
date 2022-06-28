/************************************************************************/
/*																		*/
/*	display_demo.h	--	ZYBO display demonstration 						*/
/*																		*/
/************************************************************************/
/*	Author: Sam Bobrowicz												*/
/*	Copyright 2016, Digilent Inc.										*/
/************************************************************************/
/*  Module Description: 												*/
/*																		*/
/*		This file contains code for running a demonstration of the		*/
/*		HDMI output capabilities on the ZYBO. It is a good	            */
/*		example of how to properly use the display_ctrl drivers.	    */
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/* 																		*/
/*		2/5/2016(SamB): Created											*/
/*																		*/
/************************************************************************/

#ifndef DISPLAY_DEMO_H_
#define DISPLAY_DEMO_H_

/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */

#include "xil_types.h"

/* ------------------------------------------------------------ */
/*					Miscellaneous Declarations					*/
/* ------------------------------------------------------------ */

#define DEMO_PATTERN_0 0
#define DEMO_PATTERN_1 1
#define DEMO_PATTERN_2 2
#define DEMO_PATTERN_3 3



#define BYTES_PIXEL 3

#define READ_FRAME_HEIGHT 540
#define READ_FRAME_WIDTH 960
#define WRITE_FRAME_HEIGHT (READ_FRAME_HEIGHT * 4)
#define WRITE_FRAME_WIDTH (READ_FRAME_WIDTH * 4)

#define READ_MAX_FRAME (READ_FRAME_HEIGHT * READ_FRAME_WIDTH * BYTES_PIXEL)
#define READ_STRIDE (READ_FRAME_WIDTH * BYTES_PIXEL)

#define WRITE_MAX_FRAME (WRITE_FRAME_WIDTH * WRITE_FRAME_HEIGHT * BYTES_PIXEL)
#define WRITE_STRIDE (WRITE_FRAME_WIDTH * BYTES_PIXEL)

/* ------------------------------------------------------------ */
/*					Procedure Declarations						*/
/* ------------------------------------------------------------ */

void DemoInitialize();
void DemoPrintTest(u8 *frame, u32 width, u32 height, u32 stride, int pattern);

/* ------------------------------------------------------------ */

/************************************************************************/

#endif /* DISPLAY_DEMO_H_ */

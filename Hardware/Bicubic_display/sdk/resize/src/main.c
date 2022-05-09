/************************************************************************/
/*																		*/
/*	display_demo.c	--	ALINX AX7021 HDMI Display demonstration 						*/
/*																		*/
/************************************************************************/

/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */

#include "display_demo.h"
#include "display_ctrl/display_ctrl.h"
#include <stdio.h>
#include "math.h"
#include <ctype.h>
#include <stdlib.h>
#include "xil_types.h"
#include "xil_cache.h"
#include "xparameters.h"
#include "pic_800_600.h"
#include "i2c/PS_i2c.h"
#include "sleep.h"
#include "ff.h"
#include "bmp.h"
#include "xscugic.h"
#include "xil_exception.h"
#include "xuartps.h"
#include "sleep.h"
//#include "xmy_hls_resize.h"
/*
 * XPAR redefines
 */
#define DYNCLK_BASEADDR XPAR_AXI_DYNCLK_0_BASEADDR
#define VGA_VDMA_ID XPAR_AXIVDMA_0_DEVICE_ID
#define DISP_VTC_ID XPAR_VTC_0_DEVICE_ID
#define VID_VTC_IRPT_ID XPS_FPGA3_INT_ID
#define VID_GPIO_IRPT_ID XPS_FPGA4_INT_ID
#define SCU_TIMER_ID XPAR_SCUTIMER_DEVICE_ID
#define UART_BASEADDR XPAR_PS7_UART_1_BASEADDR

#define READ_WRITE_VDMA_ID XPAR_AXI_VDMA_1_DEVICE_ID

#define INTC_DEVICE_ID	XPAR_SCUGIC_SINGLE_DEVICE_ID

#define READ_INTR_ID XPAR_FABRIC_AXIVDMA_1_MM2S_INTROUT_VEC_ID
#define WRITE_INTR_ID XPAR_FABRIC_AXIVDMA_1_S2MM_INTROUT_VEC_ID

#define UART_DEV_ID	XPAR_PS7_UART_1_DEVICE_ID
#define UART_INTR_ID XPAR_PS7_UART_1_INTR

/* ------------------------------------------------------------ */
/*				Global Variables								*/
/* ------------------------------------------------------------ */

/*
 * Display Driver structs
 */
DisplayCtrl dispCtrl;
XAxiVdma vdma0; // Used to display the picture via HDMI
XAxiVdma vdma1; // Used to tranfer the picture to Bicubic IP
//XMy_hls_resize ResizeInstance;
XScuGic IntcInstance;		/* Interrupt Controller Instance */

static FIL fil;		/* File object */
static FATFS fatfs;
static int write_complete;

/*
 * Framebuffers for source video data
 */
u8 ReadframeBuf[DISPLAY_NUM_FRAMES][READ_MAX_FRAME] __attribute__ ((aligned(64)));
u8 *pReadFrames[DISPLAY_NUM_FRAMES]; //array of pointers to the frame buffers

/*
 * Framebuffers for destination video data
 */
u8 WriteframeBuf[DISPLAY_NUM_FRAMES][WRITE_MAX_FRAME] __attribute__ ((aligned(64)));
u8 *pWriteFrames[DISPLAY_NUM_FRAMES]; //array of pointers to the frame buffers

XIicPs IicInstance;

/* 
*	UART Object
*/
XUartPs	uartInst;
u8 rxBuf[32];
u8 txBuf[32];

/* ------------------------------------------------------------ */
/*				Procedure Definitions							*/
/* ------------------------------------------------------------ */

unsigned char read_line_buf[1920 * 3];
unsigned char Write_line_buf[3840 * 3];
void bmp_read(char * bmp,u8 *frame,u32 stride)
{
	short y,x;
	short Ximage;
	short Yimage;
	u32 iPixelAddr = 0;
	FRESULT res;
	unsigned char TMPBUF[64];
	unsigned int br;         // File R/W count

	res = f_open(&fil, bmp, FA_OPEN_EXISTING | FA_READ);
	if(res != FR_OK)
	{
		f_close(&fil);
		xil_printf("Failed to Read!\r\n") ;
		return ;
	}
	res = f_read(&fil, TMPBUF, 54, &br);
	if(res != FR_OK)
	{
		f_close(&fil);
		xil_printf("Failed to Read!\r\n") ;
		return ;
	}
	Ximage=(unsigned short int)TMPBUF[19]*256+TMPBUF[18];
	Yimage=(unsigned short int)TMPBUF[23]*256+TMPBUF[22];
	iPixelAddr = (Yimage-1)*stride ;

	for(y = 0; y < Yimage ; y++)
	{
		f_read(&fil, read_line_buf, Ximage * 3, &br);
		for(x = 0; x < Ximage; x++)
		{
			frame[x * BYTES_PIXEL + iPixelAddr + 0] = read_line_buf[x * 3 + 0];
			frame[x * BYTES_PIXEL + iPixelAddr + 1] = read_line_buf[x * 3 + 1];
			frame[x * BYTES_PIXEL + iPixelAddr + 2] = read_line_buf[x * 3 + 2];
		}
		iPixelAddr -= stride;
	}
	f_close(&fil);
}


void bmp_write(char * name, char *head_buf, char *data_buf)
{
	short y,x;
	short Ximage;
	short Yimage;
	u32 iPixelAddr = 0;
	FRESULT res;
	unsigned int br;         // File R/W count

	memset(&Write_line_buf, 0, 3840*3) ;

	res = f_open(&fil, name, FA_CREATE_ALWAYS | FA_WRITE);
	if(res != FR_OK)
	{
		return ;
	}
	res = f_write(&fil, head_buf, 54, &br) ;
	if(res != FR_OK)
	{
		return ;
	}
	Ximage=(unsigned short)head_buf[19]*256+head_buf[18];
	Yimage=(unsigned short)head_buf[23]*256+head_buf[22];
	iPixelAddr = (Yimage-1)*Ximage*3 ;
	for(y = 0; y < Yimage ; y++)
	{
		for(x = 0; x < Ximage; x++)
		{
			Write_line_buf[x*3 + 0] = data_buf[x*3 + iPixelAddr + 0] ;
			Write_line_buf[x*3 + 1] = data_buf[x*3 + iPixelAddr + 1] ;
			Write_line_buf[x*3 + 2] = data_buf[x*3 + iPixelAddr + 2] ;
		}
		res = f_write(&fil, Write_line_buf, Ximage*3, &br) ;
		if(res != FR_OK)
		{
			f_close(&fil);
			xil_printf("Failed to Write!\r\n") ;
			return ;
		}
		iPixelAddr -= Ximage*3;
	}

	f_close(&fil);
}

int initUart()
{
	int status;
	XUartPs_Config	* uartCfg_Ptr;
	uartCfg_Ptr = XUartPs_LookupConfig(UART_DEV_ID);
	status = XUartPs_CfgInitialize(&uartInst, uartCfg_Ptr, uartCfg_Ptr->BaseAddress);
	if(status != XST_SUCCESS)
	{
		xil_printf("initialize uart1 failed\n");
		return XST_FAILURE;
	}
	//设置波特率, 115200
	XUartPs_SetBaudRate(&uartInst, 115200);
	if(status != XST_SUCCESS)
	{
		xil_printf("set Buad Rate failed\n");
		return XST_FAILURE;
	}
	//设置操作模式, 默认模式
	XUartPs_SetOperMode(&uartInst, XUARTPS_OPER_MODE_NORMAL);
	/*
	 * * @param	InstancePtr is a pointer to the XUartPs instance.
	 * 	 @param	RecvTimeout setting allows the UART to detect an idle connection
	 *			on the reciever data line.
	 *			Timeout duration = RecvTimeout x 4 x Bit Period. 0 disables the
	 *			timeout function.
	 */
	XUartPs_SetRecvTimeout(&uartInst, 8);
	XUartPs_Recv(&uartInst, rxBuf, 32);
	return XST_SUCCESS;
}

void uartIntrHandler(void *CallBackRef, u32 Event, u32 EventData)
{
	//接收超时时间发生
	if(Event == XUARTPS_EVENT_RECV_TOUT)
	{
		//重新启动监听
		XUartPs_Recv(&uartInst, rxBuf, 32);
		int Status;
		if(rxBuf[0] == (u8)'q')
		{
			Status = DisplayStop(&dispCtrl);
			if (Status != XST_SUCCESS)
			{
				xil_printf("Couldn't start display during demo initialization%d\r\n", Status);

			}
			else
			{
				xil_printf("Stop image display!\r\n");
			}
		}
		else if(rxBuf[0] == (u8)'p')
		{
			Status = DisplayStart(&dispCtrl);
			if (Status != XST_SUCCESS)
			{
				xil_printf("Couldn't start display during demo initialization%d\r\n", Status);

			}
			else
			{
				xil_printf("Start image display!\r\n");
			}
		}
		else if (rxBuf[0] == (u8)'w')
		{
			DisplayChangePos(&dispCtrl, 0);
			xil_printf("Shift up the image!\r\n");
		}
		else if(rxBuf[0] == (u8)'s')
		{
			DisplayChangePos(&dispCtrl, 1);
			xil_printf("Shift down the image!\r\n");
		}
		else if(rxBuf[0] == (u8)'a')
		{
			DisplayChangePos(&dispCtrl, 2);
			xil_printf("Shift left the image!\r\n");
		}
		else if(rxBuf[0] == (u8)'d')
		{
			DisplayChangePos(&dispCtrl, 3);
			xil_printf("Shift right the image!\r\n");
		}
	}
}

/* 
* Initialize the Bicubic processor
*/
int BicubicInit(u32 interpolation_parameter)
{
	int status;
//	status = XMy_hls_resize_Initialize(&ResizeInstance, XPAR_MY_HLS_RESIZE_0_DEVICE_ID);
//	if(status != XST_SUCCESS)
//	{
//		xil_printf("Resize ip Initialization failed %d\r\n", status);
//		return status;
//	}
	// config
//	XMy_hls_resize_Set_src_rows(&ResizeInstance, READ_FRAME_HEIGHT);
//	XMy_hls_resize_Set_src_cols(&ResizeInstance, READ_FRAME_WIDTH);
//	XMy_hls_resize_Set_dst_rows(&ResizeInstance, WRITE_FRAME_HEIGHT);
//	XMy_hls_resize_Set_dst_cols(&ResizeInstance, WRITE_FRAME_WIDTH);
	xil_printf("\nInit resize ip Success\r\n");
	return status;
}

/*
* Write callback function of VDMA1
*/
void WriteCallBack(void * CallBackRef, u32 Mask)
{
	xil_printf("Write interrupt!\r\n");
	if (Mask & XAXIVDMA_IXR_FRMCNT_MASK)
	{
		write_complete = 1;
		xil_printf("Write Transfer complete!\r\n");
	}
}
/* 
* Write error callback function of VDMA1
*/
void WriteErrorCallBack(void * CallBackRef, u32 Mask)
{
	xil_printf("Write error interrupt!\r\n");
	if (Mask & XAXIVDMA_IXR_ERROR_MASK) {
		xil_printf("Write Transfer failed!\r\n");
	}
}
/* 
* Write callback function of VDMA2
*/

void ReadCallBack(void * CallBackRef, u32 Mask)
{
	xil_printf("Read interrupt!\r\n");
	if (Mask & XAXIVDMA_IXR_FRMCNT_MASK)
	{
		xil_printf("Read Transfer complete!\r\n");
	}
}

/* 
* Write error callback function of VDMA2
*/
void ReadErrorCallBack(void * CallBackRef, u32 Mask)
{
	xil_printf("Read error interrupt!\r\n");
	if (Mask & XAXIVDMA_IXR_ERROR_MASK) {
		xil_printf("Read Transfer failed!\r\n");
	}
}

/* 
* Configure the external interrupt handler
*/
int bicubicSetupIntr(XScuGic *IntcInstancePtr)
{
	int status;
	XScuGic_Config *IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
	if (NULL == IntcConfig) {
		xil_printf("No interrupt controller found for ID %d\r\n", INTC_DEVICE_ID);
		return XST_FAILURE;
	}
	status = XScuGic_CfgInitialize(IntcInstancePtr, IntcConfig,
					IntcConfig->CpuBaseAddress);
	if (status != XST_SUCCESS) {
		xil_printf("Interrupt controller Configuration Initialization failed %d\r\n", status);
		return XST_FAILURE;
	}
	Xil_ExceptionInit();

	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT,
				(Xil_ExceptionHandler)XScuGic_InterruptHandler,
				IntcInstancePtr);
	/*
	 * Connect the device driver handler that will be called when an
	 * interrupt for the device occurs, the handler defined above performs
	 * the specific interrupt processing for the device.
	 */
	status = XScuGic_Connect(IntcInstancePtr, READ_INTR_ID,
				(Xil_InterruptHandler)XAxiVdma_ReadIntrHandler,
				&vdma1);
	if (status != XST_SUCCESS) {
		xil_printf("Read interrupt controller Configuration Initialization failed %d\r\n", status);
		return status;
	}

	status = XScuGic_Connect(IntcInstancePtr, WRITE_INTR_ID,
				(Xil_InterruptHandler)XAxiVdma_WriteIntrHandler,
				&vdma1);
	if (status != XST_SUCCESS) {
		xil_printf("Write interrupt controller Configuration Initialization failed %d\r\n", status);
		return status;
	}

	status = XScuGic_Connect(IntcInstancePtr, UART_INTR_ID, (Xil_InterruptHandler)XUartPs_InterruptHandler, &uartInst);
	if (status != XST_SUCCESS) {
		xil_printf("UART interrupt controller Configuration Initialization failed %d\r\n", status);
		return status;
	}
	/*
	* Enable the interrupt for the device.
	*/
	XScuGic_SetPriorityTriggerType(IntcInstancePtr, READ_INTR_ID, 0xA0, 0x3);
	XScuGic_SetPriorityTriggerType(IntcInstancePtr, WRITE_INTR_ID, 0xA0, 0x3);
	XScuGic_Enable(IntcInstancePtr, READ_INTR_ID);
	XScuGic_Enable(IntcInstancePtr, WRITE_INTR_ID);
	XScuGic_Enable(IntcInstancePtr, UART_INTR_ID);

	/* 
	*	Register callback functions
	*/
	XAxiVdma_SetCallBack(&vdma1, XAXIVDMA_HANDLER_GENERAL, WriteCallBack, (void *)&vdma1, XAXIVDMA_WRITE);
	XAxiVdma_SetCallBack(&vdma1, XAXIVDMA_HANDLER_ERROR, WriteErrorCallBack, (void *)&vdma1, XAXIVDMA_WRITE);
	XAxiVdma_SetCallBack(&vdma1, XAXIVDMA_HANDLER_GENERAL, ReadCallBack, (void *)&vdma1, XAXIVDMA_READ);
	XAxiVdma_SetCallBack(&vdma1, XAXIVDMA_HANDLER_ERROR, ReadErrorCallBack, (void *)&vdma1, XAXIVDMA_READ);
	
	XUartPs_SetHandler(&uartInst, (XUartPs_Handler)uartIntrHandler, &uartInst);
	XUartPs_SetInterruptMask(&uartInst, XUARTPS_IXR_TOUT);

	XAxiVdma_IntrEnable(&vdma1, XAXIVDMA_IXR_ALL_MASK, XAXIVDMA_WRITE);
	XAxiVdma_IntrEnable(&vdma1, XAXIVDMA_IXR_ALL_MASK, XAXIVDMA_READ);
	
	/*
	 * Enable interrupts in the Processor.
	 */
	Xil_ExceptionEnable();
	return XST_SUCCESS;
}

/* 
* Start Bicubic process
*/
int BicubicStart()
{
	XAxiVdma_DmaSetup ReadConfig; /*VDMA channel configuration*/
	XAxiVdma_DmaSetup WriteConfig; /*VDMA channel configuration*/
	int ReadStatus, WriteStatus;
	XAxiVdma_FrameCounter vdma1_FrameCounter;
	/* 
		Configure the vmda used to write the picture
	*/
	WriteConfig.FrameDelay = 0;
	WriteConfig.EnableCircularBuf = 0;
	WriteConfig.EnableSync = 0;
	WriteConfig.PointNum = 0;
	WriteConfig.EnableFrameCounter = 1;
	WriteConfig.VertSizeInput = WRITE_FRAME_HEIGHT;
	WriteConfig.HoriSizeInput = WRITE_STRIDE;
	WriteConfig.FixedFrameStoreAddr = 0;
	WriteConfig.Stride = WRITE_STRIDE;

	for (int i = 0; i < DISPLAY_NUM_FRAMES; i++)
	{
		WriteConfig.FrameStoreStartAddr[i] = pWriteFrames[i];
	}
	WriteStatus = XAxiVdma_DmaConfig(&vdma1, XAXIVDMA_WRITE, &(WriteConfig));
	if (WriteStatus != XST_SUCCESS)
	{
		xdbg_printf(XDBG_DEBUG_GENERAL, "VDMA1 write channel config failed %d\r\n", WriteStatus);
		return XST_FAILURE;
	}

	WriteStatus = XAxiVdma_DmaSetBufferAddr(&vdma1, XAXIVDMA_WRITE, WriteConfig.FrameStoreStartAddr);
	if (WriteStatus != XST_SUCCESS)
	{
		xdbg_printf(XDBG_DEBUG_GENERAL, "VDMA1 write channel set buffer address failed %d\r\n", WriteStatus);
		return XST_FAILURE;
	}

	/* 
		Configure the vmda used to read the picture
	*/
	ReadConfig.FrameDelay = 0;
	ReadConfig.EnableCircularBuf = 0;
	ReadConfig.EnableSync = 0;
	ReadConfig.PointNum = 0;
	ReadConfig.EnableFrameCounter = 1;
	ReadConfig.VertSizeInput = READ_FRAME_HEIGHT;
	ReadConfig.HoriSizeInput = READ_STRIDE;
	ReadConfig.FixedFrameStoreAddr = 0;
	ReadConfig.Stride = READ_STRIDE;
	vdma1_FrameCounter.ReadFrameCount = 1;
	vdma1_FrameCounter.WriteFrameCount = 1;
	for (int i = 0; i < DISPLAY_NUM_FRAMES; i++)
	{
		ReadConfig.FrameStoreStartAddr[i] = ReadframeBuf[i];
	}
		ReadStatus = XAxiVdma_DmaConfig(&vdma1, XAXIVDMA_READ, &(ReadConfig));
	if (ReadStatus != XST_SUCCESS)
	{
		xdbg_printf(XDBG_DEBUG_GENERAL, "VDMA1 Read channel config failed %d\r\n", ReadStatus);
		return XST_FAILURE;
	}
	ReadStatus = XAxiVdma_SetFrameCounter(&vdma1, &vdma1_FrameCounter);
	if (ReadStatus != XST_SUCCESS)
	{
		xdbg_printf(XDBG_DEBUG_GENERAL, "VDMA1 write channel set frame counter failed %d\r\n", ReadStatus);
		return XST_FAILURE;
	}
	
	ReadStatus = XAxiVdma_DmaSetBufferAddr(&vdma1, XAXIVDMA_READ, ReadConfig.FrameStoreStartAddr);
	if (ReadStatus != XST_SUCCESS)
	{
		xdbg_printf(XDBG_DEBUG_GENERAL, "VDMA1 Read channel set buffer address failed %d\r\n", ReadStatus);
		return XST_FAILURE;
	}

	/* 
	* Start these two VDAMs to transfer image
	*/
	 WriteStatus = XAxiVdma_DmaStart(&vdma1, XAXIVDMA_WRITE);
	 if (WriteStatus != XST_SUCCESS)
	 {
	 	xdbg_printf(XDBG_DEBUG_GENERAL, "VDMA1 Start write transfer failed %d\r\n", WriteStatus);
	 	return XST_FAILURE;
	 }

	ReadStatus = XAxiVdma_DmaStart(&vdma1, XAXIVDMA_READ);
	if (ReadStatus != XST_SUCCESS)
	{
		xdbg_printf(XDBG_DEBUG_GENERAL, "VDMA2 Start read transfer failed %d\r\n", ReadStatus);
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

int main(void)
{
	Xil_DCacheDisable(); // Disable the cache

	int Status;
	XAxiVdma_Config *vdmaConfig0;
	XAxiVdma_Config *vdmaConfig1;
	int i;
	FRESULT rc;
	write_complete = 0;

	/*
	 * Initialize an array of pointers to the 3 frame buffers
	 */
	for (i = 0; i < DISPLAY_NUM_FRAMES; i++)
	{
		pReadFrames[i] = ReadframeBuf[i];
	}

	for(i = 0; i < DISPLAY_NUM_FRAMES; i++)
	{
		pWriteFrames[i] = WriteframeBuf[i];
	}

	/*
	 * Initialize vdma0 driver
	 */
	vdmaConfig0 = XAxiVdma_LookupConfig(VGA_VDMA_ID);
	if (!vdmaConfig0)
	{
		xil_printf("No video DMA found for ID %d\r\n", VGA_VDMA_ID);

	}

	Status = XAxiVdma_CfgInitialize(&vdma0, vdmaConfig0, vdmaConfig0->BaseAddress);
	if (Status != XST_SUCCESS)
	{
		xil_printf("vdma0 Configuration Initialization failed %d\r\n", Status);

	}

	/*
	 * Initialize vdma1 driver
	 */
	vdmaConfig1 = XAxiVdma_LookupConfig(READ_WRITE_VDMA_ID);
	if(!vdmaConfig1)
	{
		xil_printf("No video DMA found for ID %d\r\n", READ_WRITE_VDMA_ID);
	}

	Status = XAxiVdma_CfgInitialize(&vdma1, vdmaConfig1, vdmaConfig1->BaseAddress);
	if (Status != XST_SUCCESS)
	{
		xil_printf("vdma1 Configuration Initialization failed %d\r\n", Status);

	}

	/*
	 * Initialize UART driver
	*/
	
	Status = initUart();
	if(Status != XST_SUCCESS)
	{
		xil_printf("initialize Uart1 failed\n");
		return XST_FAILURE;
	}

	/* 
	* Initialize the Bicubic processor
	*/
//	BicubicInit(5);
	bicubicSetupIntr(&IntcInstance);
	/* 
	* Read the picture from SD to the FrameBuffer
	*/
	rc = f_mount(&fatfs, "0:/", 0);
	if (rc != FR_OK)
	{
		return 0 ;
	}

	bmp_read("3.bmp", pReadFrames[0], READ_STRIDE);

//	for(int i = 0; i < READ_MAX_FRAME; i++)
//	{
//		pReadFrames[0][i] = 255;
//	}
	
	 BicubicStart();

	while (1)
	{
		if(write_complete)
		{
//			bmp_write("cat.bmp", (char *)&BMODE_3840x2160, (char *)pWriteFrames[0]);
			xil_printf("Write bicubic img to the SD card successfully!!\r\n");
			/*
			 * Initialize the Display controller and start it
			 */
		 	Status = DisplayInitialize(&dispCtrl, &vdma0, DISP_VTC_ID, DYNCLK_BASEADDR, pWriteFrames, WRITE_STRIDE, WRITE_FRAME_WIDTH, WRITE_FRAME_HEIGHT);
			if (Status != XST_SUCCESS)
			{
				xil_printf("Display Ctrl initialization failed during demo initialization%d\r\n", Status);

			}
			Status = DisplayStart(&dispCtrl);
			if (Status != XST_SUCCESS)
			{
				xil_printf("Couldn't start display during demo initialization%d\r\n", Status);

			}
			write_complete = 0;
		}
	}
	return 0;

}

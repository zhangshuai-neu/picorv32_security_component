#include <stdio.h>
#include "platform.h"
#include "xcopia_mem.h"
#include "xparameters.h"

#define DIM_IMG (320*240)
#define MEM_BASE_ADDR 0x00100000
#define TX_BUFFER_BASE (MEM_BASE_ADDR + 0x00010000)
#define RX_BUFFER_BASE (MEM_BASE_ADDR + 0x00030000)

XCopia_mem copiaMem;

int initialize_ip()
{
	XCopia_mem_Config *CfgPtr = XCopia_mem_LookupConfig(XPAR_COPIA_MEM_0_DEVICE_ID);
	if (!CfgPtr) {
		xil_printf("No config found for copia_mem\n");
		return XST_FAILURE;
	}

	int Status = XCopia_mem_CfgInitialize(&copiaMem, CfgPtr);
	if (Status != XST_SUCCESS) {
		xil_printf("Initialization failed for copia_mem\n");
		return XST_FAILURE;
	}

	return 0;
}


void check_matr(unsigned char *a, unsigned char *b)
{
	int success = 0;
	int i = 0;

	for(i=0; i<DIM_IMG; i++)
	{
		if(a[i] != b[i])
			success = 1;
	}

	if(success == 0)
		xil_printf("successo\n");
	else
		xil_printf("errore\n");
}


int main()
{
	init_platform();

	unsigned char a[DIM_IMG];
	unsigned char *b = 0xC0000000;

	xil_printf("generating array\n");
	int i = 0;
	for(i=0; i<DIM_IMG; i++)
			a[i] = '1';
	xil_printf("array generated\n");

	if(initialize_ip() == XST_FAILURE)
		return -1;

	xil_printf("IP configuration done\n");

	XCopia_mem_Set_source(&copiaMem, a);
	XCopia_mem_Set_dest(&copiaMem, b);
	XCopia_mem_Set_start(&copiaMem, 1);

	xil_printf("transfer started\n");
	XCopia_mem_Start(&copiaMem);
	while(!XCopia_mem_IsDone(&copiaMem))
		;
	xil_printf("transfer ended\n");

	//check_matr(a,b);

	return 0;
}



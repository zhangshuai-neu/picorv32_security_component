#include "copia_mem.h"
const int max_depth = DIM_IMG;

int copia_mem(volatile unsigned char *source, volatile unsigned char *dest, int start)
{
#pragma HLS INTERFACE m_axi depth=max_depth port=dest offset=slave bundle=DEST_BUS
#pragma HLS INTERFACE m_axi depth=max_depth port=source offset=slave bundle=SOURCE_BUS
#pragma HLS INTERFACE s_axilite port=return
#pragma HLS INTERFACE s_axilite port=start bundle=START_BUS

	if(start == 1){
		for(int i=0; i<DIM_IMG; i++){
			char a = '1';
			dest[i] = a;
		}
		return 0;
	}
	else {
		return -1;
	}
}

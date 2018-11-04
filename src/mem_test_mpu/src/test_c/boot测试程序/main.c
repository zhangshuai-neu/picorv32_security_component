// 字节编址
#define mpu_start_addr 3072 

void main(){
    // test base_mpu
    int a=0;
    int b=0;
    int c=2;
    a=a+1;
    b=b+1;
    c=a+b;
    
    // test mpu_cache update ================================
    int * addr= (int*)mpu_start_addr;
    // 跳过原来的两个条目 2*5 word
    addr = addr+11;                     
    
    // 按照 mem_mpu.v 中给出的方式进行更新 
    // 访问权限
    addr = addr+4;
    *addr = 0x0000000f; 
    // 数据范围
    addr = addr-2;
    *addr = 0x00000000;
    *(addr+1) = 0x00000100;
    // 代码范围
    addr = addr-2;
    *addr = 0x00000000;
    *(addr+1) = 0x00000100;
    
    // test mpu_interrupt  ===================================
    // 这是一个非法的写操作
    addr = (int*)1536;
    *addr = 0x55aa;
}

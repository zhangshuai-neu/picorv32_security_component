void main(){
    // test base_mpu
    int a=0;
    int b=0;
    int c=2;
    a=a+1;
    b=b+1;
    c=a+b;
    
    // test mpu_interrupt
    // 这是一个非法的写操作
    int *addr = (int*)1536;
    *addr = 0x55aa;
}

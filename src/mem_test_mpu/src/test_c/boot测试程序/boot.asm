
main.o:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <main>:
   0:	fe010113          	addi	sp,sp,-32
   4:	00812e23          	sw	s0,28(sp)
   8:	02010413          	addi	s0,sp,32
   c:	fe042623          	sw	zero,-20(s0)
  10:	fe042423          	sw	zero,-24(s0)
  14:	00200793          	li	a5,2
  18:	fef42223          	sw	a5,-28(s0)
  1c:	fec42783          	lw	a5,-20(s0)
  20:	00178793          	addi	a5,a5,1
  24:	fef42623          	sw	a5,-20(s0)
  28:	fe842783          	lw	a5,-24(s0)
  2c:	00178793          	addi	a5,a5,1
  30:	fef42423          	sw	a5,-24(s0)
  34:	fec42703          	lw	a4,-20(s0)
  38:	fe842783          	lw	a5,-24(s0)
  3c:	00f707b3          	add	a5,a4,a5
  40:	fef42223          	sw	a5,-28(s0)
  44:	60000793          	li	a5,1536
  48:	fef42023          	sw	a5,-32(s0)
  4c:	fe042783          	lw	a5,-32(s0)
  50:	00005737          	lui	a4,0x5
  54:	5aa70713          	addi	a4,a4,1450 # 55aa <main+0x55aa>
  58:	00e7a023          	sw	a4,0(a5)
  5c:	00000013          	nop
  60:	01c12403          	lw	s0,28(sp)
  64:	02010113          	addi	sp,sp,32
  68:	00008067          	ret

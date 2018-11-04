
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
  44:	000017b7          	lui	a5,0x1
  48:	c0078793          	addi	a5,a5,-1024 # c00 <main+0xc00>
  4c:	fef42023          	sw	a5,-32(s0)
  50:	fe042783          	lw	a5,-32(s0)
  54:	02c78793          	addi	a5,a5,44
  58:	fef42023          	sw	a5,-32(s0)
  5c:	fe042783          	lw	a5,-32(s0)
  60:	01078793          	addi	a5,a5,16
  64:	fef42023          	sw	a5,-32(s0)
  68:	fe042783          	lw	a5,-32(s0)
  6c:	00f00713          	li	a4,15
  70:	00e7a023          	sw	a4,0(a5)
  74:	fe042783          	lw	a5,-32(s0)
  78:	ff878793          	addi	a5,a5,-8
  7c:	fef42023          	sw	a5,-32(s0)
  80:	fe042783          	lw	a5,-32(s0)
  84:	0007a023          	sw	zero,0(a5)
  88:	fe042783          	lw	a5,-32(s0)
  8c:	00478793          	addi	a5,a5,4
  90:	10000713          	li	a4,256
  94:	00e7a023          	sw	a4,0(a5)
  98:	fe042783          	lw	a5,-32(s0)
  9c:	ff878793          	addi	a5,a5,-8
  a0:	fef42023          	sw	a5,-32(s0)
  a4:	fe042783          	lw	a5,-32(s0)
  a8:	0007a023          	sw	zero,0(a5)
  ac:	fe042783          	lw	a5,-32(s0)
  b0:	00478793          	addi	a5,a5,4
  b4:	10000713          	li	a4,256
  b8:	00e7a023          	sw	a4,0(a5)
  bc:	60000793          	li	a5,1536
  c0:	fef42023          	sw	a5,-32(s0)
  c4:	fe042783          	lw	a5,-32(s0)
  c8:	00005737          	lui	a4,0x5
  cc:	5aa70713          	addi	a4,a4,1450 # 55aa <main+0x55aa>
  d0:	00e7a023          	sw	a4,0(a5)
  d4:	00000013          	nop
  d8:	01c12403          	lw	s0,28(sp)
  dc:	02010113          	addi	sp,sp,32
  e0:	00008067          	ret

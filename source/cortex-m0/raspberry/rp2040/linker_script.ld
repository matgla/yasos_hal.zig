MEMORY {
  FLASH(rx) : ORIGIN = 0x10000000, LENGTH = 128K
  SRAM(rwx) : ORIGIN = 0x20041f00, LENGTH = 20K
}

__heap_size__ = 0x1000;

SECTIONS
{
  .boot2 : {
    __boot2_start = .;
    KEEP(*(.boot2))
    __boot2_end = .;
  } > FLASH

  ASSERT(__boot2_end - __boot2_start == 256, 
    "Pico second stage bootloader must be 256 bytes in size")

  .vector_table : 
  {
    . = ALIGN(4);
    KEEP(*(.vector_table))
    . = ALIGN(4);
  } > FLASH 

  .text : 
  {
    . = ALIGN(4); 
    /* some of text sections would be better in RAM */ 
    *(.text) 
    *(.text*)
    *(.glue_7)
    *(.glue_7t)
    *(.eh_frame)

    *(.init)
    *(.fini)
    . = ALIGN(4);
  } > FLASH

  .rodata : 
  {
    . = ALIGN(4);
    *(.rodata)
    *(.rodata*)
    . = ALIGN(4); 
  } > FLASH 
 
  /* ARM exception handling */ 
  .ARM.extab : 
  {
    *(.ARM.extab* .gnu.linkonce.armextab.*) 
  } > FLASH
  .ARM.exidx : 
  {
    __exidx_start = .;
    *(.ARM.exidx*)
    __exidx_end = .; 
  } > FLASH 

  .preinit_array :
  {
    PROVIDE_HIDDEN(__preinit_array_start = .);
    KEEP(*(.preinit_array*))
    PROVIDE_HIDDEN(__preinit_array_end = .);
  } > FLASH

  .init_array :
  {
    PROVIDE_HIDDEN(__init_array_start = .);
    KEEP(*(SORT(.init_array.*)))
    KEEP(*(.init_array*))
    PROVIDE_HIDDEN(__init_array_end = .);
  } > FLASH

  .fini_array : 
  {
    PROVIDE_HIDDEN(__fini_array_start = .);
    KEEP(*(SORT(.fini_array.*)))
    KEEP(*(.fini_array*))
    PROVIDE_HIDDEN(__fini_array_end = .);
  } > FLASH
 
  __data_start_flash__ = LOADADDR(.data);
  .data : 
  {
    . = ALIGN(4);
    __data_start__ = .;
    *(vtable)
    *(.ram_function*)
    *(.data) 
    *(.data*)
    __data_end__ = .;
    . = ALIGN(4);

  } > SRAM AT> FLASH 

  .bss : 
  {
    . = ALIGN(4);
    __bss_start__ = .;
    *(.bss)
    *(.bss*)
    __bss_end__ = .;
    . = ALIGN(4);
  } > SRAM

  .heap : 
  {
    . = ALIGN(4);
    __heap_start__ = .;
    . = . + __heap_size__;
    __heap_end__ = .;
    . = ALIGN(4);
  } > SRAM 
 
  _stack_top = ORIGIN(SRAM) + LENGTH(SRAM);

  /DISCARD/ :
  {
    libc.a ( * )
    libm.a ( * )
    libgcc.a ( * )
  }
}

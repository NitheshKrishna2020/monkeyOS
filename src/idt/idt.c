#include "idt.h"
#include "config.h"
#include "memory/memory.h"
#include "kernel.h"

extern void idt_load(struct idtr_desc* ptr);

struct idt_desc idt_descriptors[MYOS_TOTAL_INTERRUPTS];
struct idtr_desc idtr_descriptor;

void idt_zero() {
    print("\n");
    print("You hit divided by one error\n");
}

void idt_set(int interrupt_no, void* address) {
    print("set up idt numbers and methods\n");

    struct idt_desc* desc = &idt_descriptors[interrupt_no];

    desc->offset_1 = (uint32_t) address & 0x0000ffff;
    desc->selector = KERNEL_CODE_SELECTOR;
    desc->zero = 0;
    desc->type_attr = 0xEE;
    desc->offset_2 = (uint32_t) address >> 16;

}

void idt_init() {
    print("init idt\n");

    memset(idt_descriptors, 0, sizeof(idt_descriptors));
    idtr_descriptor.limit = sizeof(idt_descriptors) - 1;
    idtr_descriptor.base = (uint32_t) idt_descriptors;

    idt_set(0, idt_zero);
    idt_load(&idtr_descriptor);

}
`timescale 1ns / 1ps

module Mux(
    input a, b, sel,
    output out
    );
    
    //native version
    //assign out = (sel) ? b:a;
    wire nsel;
    wire oa;
    wire ob;
    //gate level implementation
    nand gate1(nsel, sel, sel);
    nand gate2(oa, a, nsel);
    nand gate3(ob, b, sel);
    nand gate4(out, oa, ob);
    
endmodule

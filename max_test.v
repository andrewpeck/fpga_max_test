`timescale 1ns / 1ps

module max_test
  (
   input      clk,
   output reg outp
   );

   //------------------------------------------------------------------------------------------------------------------
   // Heater FFs + LUTs
   //------------------------------------------------------------------------------------------------------------------

   parameter  R = 11000; // number of shift registers
   parameter  SN = 144; // length of each shift register

   reg [R-1:0] flp = 0;

   integer     i, j;

   genvar      gi, gj;
   wire [R-1:0] q;
   generate
      for (gi = 0; gi < R; gi = gi+1)
        begin
           shreg #(.N(SN)) s (.d(flp[gi]), .q(q[gi]), .clk(clk));
        end
   endgenerate

   always @(posedge clk)
     begin
        outp = ^q;

        flp = ~flp;
     end

   //------------------------------------------------------------------------------------------------------------------
   // Heater rams
   //------------------------------------------------------------------------------------------------------------------

   parameter BRAMS = 1500;

   (* max_fanout = 8 *) reg [9:0] addra=0;
   (* max_fanout = 8 *) reg [9:0] addrb=0;
   wire [15:0] dob [BRAMS-1:0];
   reg [15:0]  dobr [BRAMS-1:0];

   always @(posedge clk) begin
      addra=addra+1'b1;
      addrb=addrb+1'b1;
   end

   genvar gb;
   generate
      for (gb = 0; gb < BRAMS; gb = gb+1)
        begin
           simple_dual_one_clock bram (clk,1'b1,1'b1,1'b1,addra,addrb,~dobr[gb],dob[gb]);

           always @(posedge clk)
             dobr[gb] <= dob[gb];
        end
   endgenerate

endmodule


module shreg 
  # (
     parameter INST=0, 
     parameter N = 100
     )
   (
    input  d,
    output q,
    input  clk
    );

   wire [N:0] qw;
   wire [N:0] qn;

   assign qw[0] = d;
   assign q = qw[N];

   genvar     i;
   generate
      for (i = 0; i < N; i = i+1)
        begin

           // invert every 4th stage of the sr to better balance LUT to FF
           if (i[1:0]==2'b00)
             assign qn[i+1] = ~qw[i];
           else
             assign qn[i+1] = qw[i];

           FDCE shf
             (
              .D  (qn[i]),
              .CE (1'b1),
              .Q  (qw[i+1]),
              .CLR(1'b0),
              .C  (clk)
              );
        end
   endgenerate

endmodule

// Simple Dual-Port Block RAM with One Clock
// File: simple_dual_one_clock.v
module simple_dual_one_clock
  (
   input             clk,
   input             ena,
   input             enb,
   input             wea,
   input [9:0]       addra,addrb,
   input [15:0]      dia,
   output reg [15:0] dob
   );
   reg [15:0]        ram [1023:0];

   always @(posedge clk) begin
      if (ena) begin
         if (wea)
           ram[addra] <= dia;
      end
   end

   always @(posedge clk) begin
      if (enb)
        dob <= ram[addrb];
   end
endmodule

module tb();

  reg clk, reset;
  wire [63:0] e5,e4,e3,e2,e1;
//  wire [63:0] r1,r2,r3,r4,r5;

  RISC_V_Processor t1 (
    .clk(clk),
    .reset(reset),
    .ele1(e5),
    .ele2(e4),
    .ele3(e3),
    .ele4(e2),
    .ele5(e1)
//    .r1(r1),
//    .r2(r2),
//    .r3(r3),
//    .r4(r4),
//    .r5(r5)

  );
  
  initial begin
    clk = 1'b0;                      // Initialize clk signal to 0
    reset = 1'b1;                    // Set reset signal to active state
    #10;                             // Wait for 10 time units
    reset = 1'b0;                    // Deassert reset signal
  end
  
  always begin
    #5;                              // Toggle the clock signal every 5 time units
    clk = ~clk;                      // Negate the value of clk signal
  end
  
  initial begin
    $dumpfile("dump.vcd");           // Specify the waveform dump file
    $dumpvars();                     // Dump all variables for waveform visualization
    $monitor("Time = %d --> clk = %b, reset = %b", $time, clk, reset);  // Display time, clk, and reset values in the console
                          
  end
  
endmodule

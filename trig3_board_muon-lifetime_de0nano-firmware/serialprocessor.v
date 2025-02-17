// from http://www.sparxeng.com/blog/software/communicating-with-your-cyclone-ii-fpga-over-serial-port-part-3-number-crunching

module processor(clk, rxReady, rxData, txBusy, txStart, txData, readdata);
  input clk;
  input[7:0] rxData;
  input rxReady;
  input txBusy;
  output reg txStart;
  output reg[7:0] txData;
  output reg[7:0] readdata;//first byte we got

  localparam READ=0, SOLVING=1, WRITE1=2, WRITE2=3;
  localparam LEN = 1;
  localparam LENMAX = LEN - 1;

  integer ioCount;
  reg[7:0] data[0:LENMAX];
  integer state;

  initial begin
    txStart = 0;
    state = READ;
  end

  always @(posedge clk) begin
    case (state)
      READ: begin
        if (rxReady) begin
          data[ioCount] = rxData;
			 readdata = rxData;          
        end
      end      

      WRITE1: begin
        if (!txBusy) begin
          txData = data[ioCount];
          txStart = 1;
          state = WRITE2;
        end
      end

      WRITE2: begin
        txStart = 0;
        if (ioCount != LENMAX) begin
          ioCount = ioCount + 1;
          state = WRITE1;
        end else begin
          ioCount = 0;
          state = READ;
        end
      end
    endcase
  end
endmodule

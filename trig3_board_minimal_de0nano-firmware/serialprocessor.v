module processor(clk, rxReady, rxData, txBusy, txStart, txData, readdata,
	deadticks, firingticks, enable_outputs, 
	phasecounterselect,phaseupdown,phasestep,scanclk, clkswitch,
	histos, resethist
	);
	
	input clk;
	input[7:0] rxData;
	input rxReady;
	input txBusy;
	output reg txStart;
	output reg[7:0] txData;
	output reg[7:0] readdata;//first byte we got
	output reg enable_outputs=0;//set low to enable outputs
	reg [7:0] extradata[10];//to store command extra data, like arguemnts (up to 10 bytes)
	localparam READ=0, SOLVING=1, WRITE1=3, WRITE2=4, READMORE=5, PLLCLOCK=6, CLKSWITCH=7;
	integer state=READ;
	integer bytesread, byteswanted;
	
	integer pllclock_counter=0;
	integer scanclk_cycles=0;
	output reg[2:0] phasecounterselect; // Dynamic phase shift counter Select. 000:all 001:M 010:C0 011:C1 100:C2 101:C3 110:C4. Registered in the rising edge of scanclk.
	output reg phaseupdown=1; // Dynamic phase shift direction; 1:UP, 0:DOWN. Registered in the PLL on the rising edge of scanclk.
	output reg phasestep=0;
	output reg scanclk=0;
	output reg clkswitch=0; // No matter what, inclk0 is the default clock
		
	integer ioCount, ioCountToSend;
	reg[7:0] data[16]; // for writing out data in WRITE1,2
	
	output reg[7:0] deadticks=10; // 
	output reg[7:0] firingticks=9; // 
	
	input integer histos[4];
	output reg resethist;

	always @(posedge clk) begin
	case (state)
	READ: begin		  
		txStart<=0;
		bytesread<=0;
		byteswanted<=0;
      ioCount = 0;
      if (rxReady) begin
			readdata = rxData;
         state = SOLVING;
      end
	end
	READMORE: begin
		if (rxReady) begin
			extradata[bytesread] = rxData;
			bytesread = bytesread+1;
			if (bytesread>=byteswanted) state=SOLVING;
		end
	end
   SOLVING: begin
		if (readdata==0) begin		
			ioCountToSend = 1;
			data[0]=1; // this is the firmware version
			state=WRITE1;				
		end
		else if (readdata==1) begin //wait for next byte: some useful byte
			byteswanted=1; if (bytesread<byteswanted) state=READMORE;
			else begin
				deadticks=extradata[0];
				state=READ;
			end
		end
		else if (readdata==2) begin //wait for next byte: some useful byte
			byteswanted=1; if (bytesread<byteswanted) state=READMORE;
			else begin
				firingticks=extradata[0];
				state=READ;
			end
		end
		else if (readdata==3) begin //toggle output enable
			enable_outputs = ~enable_outputs;
			state=READ;
		end
		else if (readdata==4) begin //toggle clk inputs
			pllclock_counter=0;
			
			clkswitch = 1;
			state=CLKSWITCH;
		end
		else if (readdata==5) begin //adjust clock phases
			phasecounterselect=3'b000; // all clocks - see https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/hb/cyc3/cyc3_ciii51006.pdf table 5-10
			//phaseupdown=1'b1; // up
			scanclk=1'b0; // start low
			phasestep=1'b1; // assert!
			pllclock_counter=0;
			scanclk_cycles=0;
			state=PLLCLOCK;
		end
		else if (readdata==6) begin //
			state=READ;
		end
		else if (readdata==7) begin //
			state=READ;
		end
		else if (readdata==8) begin //
			state=READ;
		end
		else if (readdata==9) begin //toggle phaseupdown up (default) or down
			phaseupdown = ~phaseupdown;
			state=READ;
		end
		else if (readdata==10) begin //send out histo
			ioCountToSend = 16;
			data[0]=histos[0][7:0];
			data[1]=histos[0][15:8];
			data[2]=histos[0][23:16];
			data[3]=histos[0][31:24];
			data[4]=histos[1][7:0];
			data[5]=histos[1][15:8];
			data[6]=histos[1][23:16];
			data[7]=histos[1][31:24];
			data[8]=histos[2][7:0];
			data[9]=histos[2][15:8];
			data[10]=histos[2][23:16];
			data[11]=histos[2][31:24];
			data[12]=histos[3][7:0];
			data[13]=histos[3][15:8];
			data[14]=histos[3][23:16];
			data[15]=histos[3][31:24];
			state=WRITE1;	
			resethist=1;
		end
		else if (readdata==11) begin //
			state=READ;
		end
		else if (readdata==12) begin //adjust phase of clock c1
			phasecounterselect=3'b011; // clock c1 - see https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/hb/cyc3/cyc3_ciii51006.pdf table 5-10
			//phaseupdown=1'b1; // up
			scanclk=1'b0; // start low
			phasestep=1'b1; // assert!
			pllclock_counter=0;
			scanclk_cycles=0;
			state=PLLCLOCK;
		end
		else state=READ; // if we got some other command, just ignore it
	end
	
	CLKSWITCH: begin // to switch between clock inputs, put clkswitch high for a few cycles, then back down low
		pllclock_counter=pllclock_counter+1;
		if (pllclock_counter[3]) begin
			clkswitch = 0;
			state=READ;
		end
	end
	
	PLLCLOCK: begin // to step the clock phase, you have to toggle scanclk a few times
		pllclock_counter=pllclock_counter+1;
		if (pllclock_counter[4]) begin
			scanclk = ~scanclk;
			pllclock_counter=0;
			scanclk_cycles=scanclk_cycles+1;
			if (scanclk_cycles>5) phasestep=1'b0; // deassert!
			if (scanclk_cycles>7) state=READ;
		end
	end
	
	//just writng out some data bytes over serial
	WRITE1: begin
		if (!txBusy) begin
			txData = data[ioCount];
         txStart = 1;
         state = WRITE2;
		end
	end
   WRITE2: begin
		txStart = 0;
      if (ioCount < ioCountToSend-1) begin
			ioCount = ioCount + 1;
         state = WRITE1;
      end
		else state = READ;
	end

	endcase
	end  
	
endmodule

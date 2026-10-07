// tb_picorv32_xsim.v — MY file (not upstream).
//
// Self-checking, no-toolchain testbench for PicoRV32 in Vivado xsim.
// Select program with +prog_fact | +prog_multrap (default: sum).
//
// Programs (hand-assembled; every word verified in two ways — see docs):
//   sum:     loop 1+2+3+4+5, expect mailbox[0x100] = 15
//   fact:    5! via M-free repeated addition, expect mailbox[0x100] = 120
//   multrap: single `mul` with default params (ENABLE_MUL=0) — expect trap=1
// Mailbox: 0x100 result, 0x108 done flag. Watchdog aborts hangs.
//
// Uses only Verilog-2001 + $display/$finish (safe on Vivado 2019.2 xsim).
`timescale 1 ns / 1 ps

module tb_picorv32_xsim;
	reg clk = 1;
	reg resetn = 0;
	wire trap;

	always #5 clk = ~clk; // 100 MHz

	// 0=sum (default), 1=fact, 2=multrap
	reg [1:0] prog;
	reg [31:0] memory [0:255];
	integer i;
	integer cycles = 0;
	reg done = 0;

	initial begin
		repeat (100) @(posedge clk);
		resetn <= 1;
	end

	// Watchdog: any hang (e.g. unconnected-PCPI mul) ends as FAIL, not silence.
	always @(posedge clk) begin
		if (resetn && !done) begin
			cycles <= cycles + 1;
			if (cycles > 50000) begin
				$display("XSIM_RESULT: FAIL timeout after 50000 cycles (prog=%0d)", prog);
				$finish;
			end
		end
	end

	// A trap during sum/fact is a real failure. For multrap it IS the verdict.
	always @(posedge clk) begin
		if (resetn && !done && trap) begin
			if (prog == 2) begin
				$display("XSIM_RESULT: PASS multrap (mul trapped as expected, ENABLE_MUL=0)");
				done <= 1;
				$finish;
			end else begin
				$display("XSIM_RESULT: FAIL unexpected trap (prog=%0d)", prog);
				done <= 1;
				$finish;
			end
		end
	end

	wire mem_valid;
	wire mem_instr;
	reg mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	reg  [31:0] mem_rdata;

	// Transaction trace (same style as upstream testbench_ez.v) — evidence.
	always @(posedge clk) begin
		if (resetn && mem_valid && mem_ready) begin
			if (mem_instr)
				$display("TRACE ifetch 0x%08x: 0x%08x", mem_addr, mem_rdata);
			else if (mem_wstrb)
				$display("TRACE write  0x%08x: 0x%08x (wstrb=%b)", mem_addr, mem_wdata, mem_wstrb);
			else
				$display("TRACE read   0x%08x: 0x%08x", mem_addr, mem_rdata);
		end
	end

	picorv32 uut (
		.clk       (clk      ),
		.resetn    (resetn   ),
		.trap      (trap     ),
		.mem_valid (mem_valid),
		.mem_instr (mem_instr),
		.mem_ready (mem_ready),
		.mem_addr  (mem_addr ),
		.mem_wdata (mem_wdata),
		.mem_wstrb (mem_wstrb),
		.mem_rdata (mem_rdata),
		.irq       (32'h0    ),
		.pcpi_wr   (1'b0     ),
		.pcpi_rd   (32'h0    ),
		.pcpi_wait (1'b0     ),
		.pcpi_ready(1'b0     )
	);

	// Selector + image load in ONE initial block (deterministic order —
	// two racing initial blocks once caused prog to be read before set).
	initial begin
		prog = 0;
		$display("DBG plusargs: fact=%0d multrap=%0d",
			$test$plusargs("prog_fact"), $test$plusargs("prog_multrap"));
		if ($test$plusargs("prog_fact")) prog = 1;
		if ($test$plusargs("prog_multrap")) prog = 2;
		for (i = 0; i < 256; i = i + 1)
			memory[i] = 32'h00000013; // nop (addi x0,x0,0) default fill
		if (prog == 0) begin
			// x1=0; x2=1; x3=6; loop{ x1+=x2; x2++; }while(x2<6); MEM[0x100]=x1; done
			memory[0] = 32'h00000093; // addi x1,x0,0
			memory[1] = 32'h00100113; // addi x2,x0,1
			memory[2] = 32'h00600193; // addi x3,x0,6
			memory[3] = 32'h002080b3; // add  x1,x1,x2
			memory[4] = 32'h00110113; // addi x2,x2,1
			memory[5] = 32'hfe314ce3; // blt  x2,x3,-8
			memory[6] = 32'h00100213; // addi x4,x0,1
			memory[7] = 32'h10102023; // sw   x1,256(x0)
			memory[8] = 32'h10402423; // sw   x4,264(x0)  -> done
			memory[9] = 32'h0000006f; // jal  x0,0 (park)
		end else if (prog == 1) begin
			// 5! = 120 via repeated addition (no M extension):
			// x1 = 5+5+5+5 (=20); x1 = 20+20+20 (=60); x1 = 60+60 (=120)
			memory[0]  = 32'h00500293; // addi x5,x0,5
			memory[1]  = 32'h00000093; // addi x1,x0,0
			memory[2]  = 32'h00508093; // addi x1,x1,5
			memory[3]  = 32'h00508093; // (x1=10)
			memory[4]  = 32'h00508093; // (x1=15)
			memory[5]  = 32'h00508093; // (x1=20)
			memory[6]  = 32'h00008333; // add  x6,x1,x0   (x6=20)
			memory[7]  = 32'h00000093; // addi x1,x0,0
			memory[8]  = 32'h006080b3; // add  x1,x1,x6   (R-type, NOT addi)
			memory[9]  = 32'h006080b3; // (x1=40)
			memory[10] = 32'h006080b3; // (x1=60)
			memory[11] = 32'h001080b3; // add  x1,x1,x1   (x1=120)
			memory[12] = 32'h10102023; // sw   x1,256(x0)
			memory[13] = 32'h00100213; // addi x4,x0,1
			memory[14] = 32'h10402423; // sw   x4,264(x0)  -> done
			memory[15] = 32'h0000006f; // jal  x0,0 (park)
		end else if (prog == 2) begin
			memory[0] = 32'h027302b3; // mul  x5,x6,x7 (M ext, disabled by default)
			memory[1] = 32'h0000006f; // jal  x0,0 (park, never reached)
		end else begin
			$display("XSIM_RESULT: FAIL unknown prog=%0d", prog);
			$finish;
		end
	end

	// Memory model (same single-cycle discipline as upstream testbench_ez.v).
	// The done-flag write at 0x108 triggers the verdict check.
	always @(posedge clk) begin
		mem_ready <= 0;
		if (mem_valid && !mem_ready) begin
			if (mem_addr < 1024) begin
				mem_ready <= 1;
				mem_rdata <= memory[mem_addr >> 2];
				if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
				if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
				if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
				if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
				if (!mem_instr && mem_wstrb != 0 && mem_addr == 264 && !done) begin
					done <= 1;
					if (prog == 0 && memory[64] == 15)
						$display("XSIM_RESULT: PASS sum (1+2+3+4+5=15)");
					else if (prog == 1 && memory[64] == 120)
						$display("XSIM_RESULT: PASS fact (5!=120 via repeated addition)");
					else
						$display("XSIM_RESULT: FAIL wrong result mem[0x100]=%0d (prog=%0d)",
							memory[64], prog);
					$finish;
				end
			end
		end
	end
endmodule

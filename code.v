`timescale 1ns / 1ps

module fp_multiplier (
    input  [31:0] a,
    input  [31:0] b,
    output        exception,
    output        overflow,
    output        underflow,
    output [31:0] result
);
    wire temp;
    wire sign;
    wire [7:0] exp_a, exp_b;
    wire [23:0] mant_a, mant_b;
    wire [47:0] mant_mult;
    wire [7:0] exp_sum, exp_final;
    wire [22:0] mantissa_out;
    wire [47:0] mant_norm;
    wire guard, round, sticky;
    wire [24:0] rounded_mantissa;
    wire exp_carry;
    assign temp = (a == 0 | b == 0);
    assign sign = a[31] ^ b[31];
    assign exp_a = a[30:23];
    assign exp_b = b[30:23];
    assign mant_a = (exp_a == 8'd0) ? {1'b0, a[22:0]} : {1'b1, a[22:0]};
    assign mant_b = (exp_b == 8'd0) ? {1'b0, b[22:0]} : {1'b1, b[22:0]};
    assign mant_mult = mant_a * mant_b;
    assign exp_sum = exp_a + exp_b - 8'd127;
    assign mant_norm = mant_mult[47] ? mant_mult : mant_mult << 1;
    wire [7:0] exp_adjust = mant_mult[47] ? 8'd1 : 8'd0;
    assign exp_final = exp_sum + exp_adjust;
    assign guard  = mant_norm[23];
    assign round  = mant_norm[22];
    assign sticky = |mant_norm[21:0];
    wire round_bit = guard & (round | sticky | mant_norm[24]);
    assign rounded_mantissa = {1'b0, mant_norm[46:24]} + round_bit;
    assign mantissa_out = rounded_mantissa[24] ? rounded_mantissa[23:1] : rounded_mantissa[22:0];
    assign exp_carry = rounded_mantissa[24];
    wire [7:0] final_exponent = exp_final + exp_carry;
    assign exception = (&exp_a) | (&exp_b) | temp ; 
    assign overflow  = (final_exponent >= 8'hFF);
    assign underflow = (final_exponent <= 8'd0);
    assign result = exception ? 32'h00000000 :
                    overflow  ? {sign, 8'hFF, 23'd0} :
                    underflow ? {sign, 31'd0} :
                    {sign, final_exponent, mantissa_out};
endmodule
module priority_encoder(
			input [24:0] significand,
			input [7:0] Exponent_a,
			output reg [24:0] Significand,
			output [7:0] Exponent_sub
			);

reg [4:0] shift;
always @(significand)
begin
casex (significand)
25'b1_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx :	begin
Significand = significand;
shift = 5'd0;
end
25'b1_01xx_xxxx_xxxx_xxxx_xxxx_xxxx : 	begin
Significand = significand << 1;
shift = 5'd1;
end
25'b1_001x_xxxx_xxxx_xxxx_xxxx_xxxx : 	begin
Significand = significand << 2;
shift = 5'd2;
end
25'b1_0001_xxxx_xxxx_xxxx_xxxx_xxxx : 	begin
Significand = significand << 3;
shift = 5'd3;
end
25'b1_0000_1xxx_xxxx_xxxx_xxxx_xxxx : 	begin
Significand = significand << 4;
shift = 5'd4;
end

25'b1_0000_01xx_xxxx_xxxx_xxxx_xxxx : 	begin
Significand = significand << 5;
shift = 5'd5;
end
25'b1_0000_001x_xxxx_xxxx_xxxx_xxxx : 	begin// 24'h020000
Significand = significand << 6;
shift = 5'd6;
end
25'b1_0000_0001_xxxx_xxxx_xxxx_xxxx : 	begin//24'h010000
Significand = significand << 7;
shift = 5'd7;
end
25'b1_0000_0000_1xxx_xxxx_xxxx_xxxx : 	begin// 24'h008000
Significand = significand << 8;
shift = 5'd8;
end
25'b1_0000_0000_01xx_xxxx_xxxx_xxxx : 	begin// 24'h004000
Significand = significand << 9;
shift = 5'd9;
end
25'b1_0000_0000_001x_xxxx_xxxx_xxxx : 	begin	// 24'h002000
Significand = significand << 10;
shift = 5'd10;
end
25'b1_0000_0000_0001_xxxx_xxxx_xxxx : 	begin// 24'h001000
Significand = significand << 11;
shift = 5'd11;
end
25'b1_0000_0000_0000_1xxx_xxxx_xxxx : 	begin// 24'h000800
Significand = significand << 12;
shift = 5'd12;
end
25'b1_0000_0000_0000_01xx_xxxx_xxxx : 	begin// 24'h000400
Significand = significand << 13;
shift = 5'd13;
end
25'b1_0000_0000_0000_001x_xxxx_xxxx : 	begin// 24'h000200
Significand = significand << 14;
shift = 5'd14;
end
25'b1_0000_0000_0000_0001_xxxx_xxxx  : 	begin
Significand = significand << 15; shift = 5'd15;
end
25'b1_0000_0000_0000_0000_1xxx_xxxx : 	begin// 24'h000080
Significand = significand << 16;
shift = 5'd16;
end
25'b1_0000_0000_0000_0000_01xx_xxxx : 	begin// 24'h000040
Significand = significand << 17;
shift = 5'd17;
end
25'b1_0000_0000_0000_0000_001x_xxxx : 	begin// 24'h000020
Significand = significand << 18;
shift = 5'd18;
end
25'b1_0000_0000_0000_0000_0001_xxxx : 	begin// 24'h000010
Significand = significand << 19;
shift = 5'd19;
end
25'b1_0000_0000_0000_0000_0000_1xxx :	begin// 24'h000008
Significand = significand << 20;
shift = 5'd20;
end
25'b1_0000_0000_0000_0000_0000_01xx : 	begin// 24'h000004
Significand = significand << 21;
shift = 5'd21;
end
25'b1_0000_0000_0000_0000_0000_001x : 	begin// 24'h000002
Significand = significand << 22;
shift = 5'd22;
end
25'b1_0000_0000_0000_0000_0000_0001 : 	begin// 24'h000001
Significand = significand << 23;
shift = 5'd23;
end
25'b1_0000_0000_0000_0000_0000_0000 : 	begin// 24'h000000
Significand = significand << 24;
shift = 5'd24;
end
default : 	begin
Significand = (~significand) + 1'b1;
shift = 8'd0;
end
endcase
end
assign Exponent_sub = Exponent_a - shift;
endmodule

module Addition_Subtraction(
input [31:0] a_operand,b_operand, 
input AddBar_Sub,	
output Exception,
output [31:0] result 
);
wire operation_sub_addBar;
wire Comp_enable;
wire output_sign;
wire [31:0] operand_a,operand_b;
wire [23:0] significand_a,significand_b;
wire [7:0] exponent_diff;
wire [23:0] significand_b_add_sub;
wire [7:0] exponent_b_add_sub;
wire [24:0] significand_add;
wire [30:0] add_sum;
wire [23:0] significand_sub_complement;
wire [24:0] significand_sub;
wire [30:0] sub_diff;
wire [24:0] subtraction_diff; 
wire [7:0] exponent_sub;
assign {Comp_enable,operand_a,operand_b} = (a_operand[30:0] < b_operand[30:0]) ? {1'b1,b_operand,a_operand} : {1'b0,a_operand,b_operand};
assign exp_a = operand_a[30:23];
assign exp_b = operand_b[30:23];
assign Exception = (&operand_a[30:23]) | (&operand_b[30:23]);
assign output_sign = AddBar_Sub ? Comp_enable ? !operand_a[31] : operand_a[31] : operand_a[31] ;
assign operation_sub_addBar = AddBar_Sub ? operand_a[31] ^ operand_b[31] : ~(operand_a[31] ^ operand_b[31]);
assign significand_a = (|operand_a[30:23]) ? {1'b1,operand_a[22:0]} : {1'b0,operand_a[22:0]};
assign significand_b = (|operand_b[30:23]) ? {1'b1,operand_b[22:0]} : {1'b0,operand_b[22:0]};
assign exponent_diff = operand_a[30:23] - operand_b[30:23];
assign significand_b_add_sub = significand_b >> exponent_diff;
assign exponent_b_add_sub = operand_b[30:23] + exponent_diff; 
assign perform = (operand_a[30:23] == exponent_b_add_sub);
assign significand_add = (perform & operation_sub_addBar) ? (significand_a + significand_b_add_sub) : 25'd0; 
assign add_sum[22:0] = significand_add[24] ? significand_add[23:1] : significand_add[22:0];
assign add_sum[30:23] = significand_add[24] ? (1'b1 + operand_a[30:23]) : operand_a[30:23];
assign significand_sub_complement = (perform & !operation_sub_addBar) ? ~(significand_b_add_sub) + 24'd1 : 24'd0 ; 
assign significand_sub = perform ? (significand_a + significand_sub_complement) : 25'd0;
priority_encoder pe(significand_sub,operand_a[30:23],subtraction_diff,exponent_sub);
assign sub_diff[30:23] = exponent_sub;
assign sub_diff[22:0] = subtraction_diff[22:0];
assign result = Exception ? 32'b0 : ((!operation_sub_addBar) ? {output_sign,sub_diff} : {output_sign,add_sum});
endmodule
module fft_2pt(
input [31:0]a1, b1, a0, b0, wr, wi,
output [31:0]z1r, z1i, z0r, z0i
    );
wire [31:0]xr, xi;
wire exc1,exc2,exc3,exc4,exc5,exc6;
Addition_Subtraction fa1(a0,a1,1'b0,exc1,z0r);
Addition_Subtraction fa2(b0,b1,1'b0,exc2,z0i);
Addition_Subtraction fs1(a0,a1,1'b1,exc3,xr);
Addition_Subtraction fs2(b0,b1,1'b1,exc4,xi);
wire [4:1]e, u, o;
wire [31:0] y [4:1]; 
fp_multiplier m1(xr, wr, e[1], u[1], o[1], y[1]);
fp_multiplier m2(xr, wi, e[2], u[2], o[2], y[2]);
fp_multiplier m3(xi, wr, e[3], u[3], o[3], y[3]);
fp_multiplier m4(xi, wi, e[4], u[4], o[4], y[4]);
Addition_Subtraction fs3(y[1],y[4],1,exc5,z1r);
Addition_Subtraction fs4(y[2],y[3],0,exc6,z1i);
endmodule
module fft_4pt(
input [31:0]pr1, pi1, pr0, pi0,pr2, pi2, pr3, pi3, wr1, wi1, wr0, wi0,
output [31:0]z1r, z1i, z0r, z0i, z2r, z2i, z3r, z3i);
wire [31:0] q0r, q0i, q1r, q1i, q2r, q2i, q3r, q3i;
fft_2pt f2_1(pr2, pi2, pr0, pi0, wr0, wi0, q2r, q2i, q0r, q0i);
fft_2pt f2_2(pr3, pi3, pr1, pi1, wr1, wi1, q3r, q3i, q1r, q1i);
fft_2pt f2_3(q1r, q1i, q0r, q0i, wr0, wi0, z0r, z0i, z1r, z1i);
fft_2pt f2_4(q3r, q3i, q2r, q2i, wr0, wi0, z2r, z2i, z3r, z3i);
endmodule
module fft_4pt_tb;
reg [31:0]pr1, pi1, pr0, pi0,pr2, pi2, pr3, pi3, wr1, wi1, wr0, wi0;
wire [31:0]z1r, z1i, z0r, z0i, z2r, z2i, z3r, z3i;
fft_4pt f41(pr1, pi1, pr0, pi0, pr2, pi2, pr3, pi3, wr1, wi1, wr0, wi0, z1r, z1i, z0r, z0i, z2r, z2i, z3r, z3i);
initial
begin
pr0 = 32'b00111111100000000000000000000000;
pi0 = 32'b0;
pr1 = 32'b0;
pi1 = 32'b0;
pr2 = 32'b10111111100000000000000000000000;
pi2 = 32'b0;
pr3 = 32'b0;
pi3 = 32'b0;
wr0 = 32'b00111111100000000000000000000000;
wi0 = 32'b0;
wr1 = 32'b0;
wi1 = 32'b10111111100000000000000000000000;
end
endmodule
module fft_2pt_tb;
reg [31:0]pr1, pi1, pr0, pi0,wr0,wi0;
wire [31:0]z1r, z1i, z0r, z0i,something;
wire exc;
fft_2pt f2_tb(pr1, pi1, pr0, pi0, wr0, wi0, z1r, z1i, z0r, z0i);
Addition_Subtraction a1(pr0,pr1,1'b1,exc,something); 
initial
begin
pr0 = 32'b00111111100000000000000000000000;
pi0 = 32'b0;
pr1 = 32'b00111111100000000000000000000000;
pi1 = 32'b00111111100000000000000000000000;
wr0 = 32'b00111111100000000000000000000000;
wi0 = 32'b0;
end
endmodule

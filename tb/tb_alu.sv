`timescale 1ns / 1ps

module tb_alu;
logic [7:0] a;
logic [7:0] b;
logic [2:0] op;
logic [7:0] result;
logic carry_out;
logic zero;
logic overflow;

alu dut (
.a(a),
.b(b),
.op(op),
.result (result),
.carry_out(carry_out),
.zero(zero),
.overflow(overflow)
);

task apply_and_check (input [2:0] t_op,
                      input [7:0] t_a,
                      input [7:0] t_b            
);

logic [8:0] expected;
logic [7:0] expected_logic;

begin 
op=t_op;
a=t_a;
b=t_b;

expected=9'd0;
expected_logic=8'd0;

#1;

if (t_op==3'b000) begin //ADD 
expected = {1'b0,t_a} + {1'b0, t_b};
end else if (t_op==3'b001) begin //SUB
expected= {1'b0,t_a} +{1'b0,~t_b} + 9'd1;
end else if (t_op==3'b010) begin //AND
expected_logic=t_a&t_b;
end else if (t_op==3'b011) begin //OR
expected_logic=t_a|t_b;
end else if (t_op==3'b100) begin //XOR
expected_logic=t_a^t_b;
end

assert (zero== (result==8'd0))
else $fatal ("ZERO FLAG ERROR : op=%b a=%h b=%h result=%h zero=%b ", t_op, t_a, t_b, result,zero);

if ( (t_op==3'b000) || (t_op==3'b001)) begin //ADD or SUB
assert (result == expected[7:0])
else $fatal ("Mismatch! op=%b a=%h b=%h | expected=%h got=%h ", t_op, t_a, t_b, expected[7:0], result) ;
assert(carry_out == expected[8])  
else $fatal ("CARRY_OUT WRONG : op=%b a=%h b=%h | expected=%b got=%b ",t_op, t_a, t_b, expected[8], carry_out );
     if (t_op==3'b000) begin //ADD
     assert (overflow == (~(t_a[7]^t_b[7]))&(t_a[7]^result[7])) 
     else $fatal ("OVERFLOW ERROR: op=%b a=%h b=%h result=%h",t_op, t_a, t_b ,result);
     end else if (t_op==3'b001) begin //SUB
     assert (overflow ==( (t_a[7]^t_b[7]) & (t_a[7]^result[7])))
     else $fatal ("OVERFLOW ERROR: op=%b a=%h b=%h result=%h",t_op, t_a, t_b ,result);     
     end
end else begin // lgic operation
assert (result== expected_logic)
else $fatal ("Mismatch! op=%b a=%h b=%h | expected_logic=%h got=%h ", t_op, t_a, t_b, expected_logic, result);
assert (carry_out == 1'b0)
else $fatal ("CARRY_OUT ERROR : op=%b a=%h b=%h  | Carry must be zero in logic ops, got=%b", t_op, t_a, t_b, carry_out);
assert (overflow == 1'b0)
else $fatal ("OVERFLOW ERROR : op=%b a=%h b=%h overflow=%b | Overflow must be zero in logic operations", t_op, t_a, t_b, overflow);

end
end
endtask

initial begin 
$display ("===Starting check the ALU===");

apply_and_check(3'b000, 8'h7f, 8'h02); //ADD (signed overflow)
apply_and_check(3'b000, 8'hff, 8'h01); //ADD (carry + zero)
apply_and_check(3'b000, 8'h80, 8'h80); //ADD (carry + signed overflow)
apply_and_check(3'b001, 8'h00, 8'h01); //SUB (borrow)
apply_and_check(3'b001, 8'h7F, 8'hFF); //SUB (signed overflow)
apply_and_check(3'b010, 8'h11, 8'h88); //AND
apply_and_check(3'b011, 8'h11, 8'h88); //OR 
apply_and_check(3'b100, 8'h25, 8'h62); //XOR

$display ("ALL TESTS PASS");
$finish;
end


endmodule

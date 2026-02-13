`timescale 1ns / 1ps

module alu(
input logic [7:0] a,
input logic [7:0] b,
input logic [2:0] op,
output logic [7:0] result,
output logic zero,
output logic carry_out,
output logic overflow
    );
logic [8:0] temp;

always_comb begin 
temp=9'd0;
result=8'd0;
zero=1'b1;
carry_out=1'b0;
overflow=1'b0;

case (op) 
3'b000: begin //ADD 
temp = {1'b0,a} + {1'b0,b};
end
3'b001: begin //SUB
temp= {1'b0,a} + {1'b0,~b} + 9'd1;   
end    
3'b010: begin //AND
temp=a&b;
end
3'b011: begin //OR
temp= a|b;
end
3'b100: begin //XOR 
temp=a^b;
end
default: begin
temp=9'd0;
carry_out=1'b0;
overflow=1'b0;
zero=1'b1;
end
endcase

result=temp[7:0];
zero= (result== '0);

if((op==3'b000) || (op==3'b001) ) begin //ADD or SUB
carry_out=temp[8];
end else begin
carry_out= 1'b0;
end

if(op==3'b000) begin //ADD
overflow = ( ~(a[7]^b[7]) & (a[7]^result[7]) );
end else if (op==3'b001) begin 
overflow = ( (a[7]^b[7])  & (a[7]^result[7]) );
end

end
endmodule

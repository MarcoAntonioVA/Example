`timescale 1ns / 1ps
module PWM2 (
  input clk,
  input [8:0] duty,
  output pwm_out
);

reg [31:0] q_reg, q_next;  // Registro para el contador del preescalado
reg [7:0] d_reg, d_next;   // Registro para el contador del ciclo de trabajo
reg [8:0] d_ext;           // Extensi�n del contador del ciclo de trabajo
reg pwm_reg, pwm_next;     // Registro y pr�ximo valor de la se�al de PWM
wire tick;                 // Se�al para indicar el inicio de un ciclo PWM
wire [31:0] dvsr = 32'b00000000000000000001010000111000; // Valor fijo de dvsr

always @(posedge clk) begin
  q_reg <= q_next;
  d_reg <= d_next;
  pwm_reg <= pwm_next;
end

// "prescaler" counter (Contador de preescalado)
always @(posedge clk) begin
  if (q_reg == dvsr) begin
    q_next <= 32'b0;
  end else begin
    q_next <= q_reg + 1;
  end
end

assign tick = (q_reg == 32'b0);

// duty cycle counter (Contador del ciclo de trabajo)
always @(posedge clk) begin
  if (tick) begin
    d_next <= d_reg + 1;
  end else begin
    d_next <= d_reg;
  end
end

always @(*) begin
  d_ext = {1'b0, d_reg};
end

// comparison circuit (Circuito de comparaci�n para generar PWM)
always @(*) begin
  if (d_ext < duty) begin
    pwm_next = 1'b1;
  end else begin
    pwm_next = 1'b0;
  end
end

assign pwm_out = pwm_reg;

endmodule

// Code your design here


module leftshift1(
  input logic [15:0] data_in,
  output logic [15:0] shifted_data
  );
  assign shifted_data = {data_in[14:0], data_in[15]};
endmodule

module leftshift8(
  input logic [15:0] data_in,
  output logic [15:0] shifted_data
  );
  assign shifted_data = {data_in[7:0], data_in[15:8]};
endmodule

module leftshift2(
  input logic [15:0] data_in,
  output logic [15:0] shifted_data
  );
  assign shifted_data = {data_in[13:0], data_in[15:14]};
endmodule

module round(clk, reset, plaintext, round_key, ciphertext);
    input clk, reset;
    input [31:0] plaintext;
    input [63:0] round_key;
    output [31:0] ciphertext;
    
    logic [15:0] xi, xi1;
    logic [15:0] temp3, temp4, temp5, temp6, temp7;

  
    assign xi = plaintext[15:0];
    assign xi1 = plaintext[31:16];
    logic [15:0] ls1o, ls8o, ls2o;

    leftshift1 #2 lfs1(xi1, ls1o);
    leftshift8 #2 lfs8(xi1, ls8o);
    leftshift2 #2 lfs2(xi1, ls2o);

    assign temp3 = ls1o & ls8o;
    assign temp4 = xi ^ temp3;
    assign temp6 = temp4 ^ ls2o;
    assign temp7 = temp6 ^ round_key[15:0];

  assign ciphertext = {temp7, xi1};
endmodule

module rightshift3(
  input logic [15:0] data_in,
  output logic [15:0] shifted_data
  );
  assign shifted_data = {data_in[2:0], data_in[15:3]};
endmodule

module rightshift1(
  input logic [15:0] data_in,
  output logic [15:0] shifted_data
  );
  assign shifted_data = {data_in[0], data_in[15:1]};
endmodule


module key_expansion(clk, reset, c, z, key0, key1, key2, key3, expanded_key);
  input clk, reset;
  input [15:0] key0, key1, key2, key3;

  input [15:0] c;
  input[15:0] z;
  logic [15:0] temp1, temp2, temp3, temp4, temp5, ekout;
  output [63:0] expanded_key;
  
  wire [15:0] rso1;
  rightshift3 rs3(key3, rso1);
  assign temp1 = (rso1) ^ key1;

  assign temp2 = temp1 ^ key0;

  wire [15:0] rso2;
  rightshift1 rs1(temp1, rso2);
  assign temp3 = temp2 ^ (rso2);

  
  assign temp5 = temp3 ^ z;

  assign ekout = c ^ temp5;
  assign expanded_key = {ekout, key3, key2, key1};

endmodule


module sub_simon32 (clk, reset, z_i, key, plaintext, ciphertext, new_keys);
  input clk, reset;
  input [63:0] key;
  input [15:0] z_i;
  input [31:0] plaintext;
  output [31:0] ciphertext;
  output [63:0] new_keys;

  logic [63:0] new_keys_int, new_keys_;
  
  logic [15:0] int_z;
  logic [63:0] round_key;
  logic [63:0] round_key_;
  logic [31:0] plt;
  logic [31:0] ciphertext_out;

  logic [15:0] c;
  assign c = 'hfffc;
  
  
  round round_4(clk, reset, plaintext, key, ciphertext_out);
  key_expansion ke_1(clk, reset, c, z_i, key[15:0], key[31:16], key[47:32], key[63:48], new_keys_);
  
  
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      plt<=0;
      new_keys_int<=0;
      round_key_<=0;
    end else begin
      plt<=plaintext;
      new_keys_int<=new_keys_;
      round_key_<=ciphertext_out;
    end
  end
  assign new_keys = new_keys_int;
  assign ciphertext = round_key_;
endmodule

// Notes on optimization:
// take out z values
// try variations on two flip flops vs one between key expansion and round
// should try to do a triangle of inputs 

  
module simon32_64 (clk, reset, plaintext, key, ciphertext);
  input clk, reset;
  input [31:0] plaintext;
  input [63:0] key;
  output [31:0] ciphertext;
  
  logic [31:0] temp_cipher;
  

  // generate output at each clock cycle.
  // impliment as shift register
  logic [31:0] pt0, pt4ff;
  logic [63:0] key_ff;
  
  logic [31:0] sub_texts [33];
  logic [63:0] nk [33];
  logic [15:0] z_[28];

  assign z_[0]='h0001;
  sub_simon32 ss0(clk, reset,  z_[0], key_ff, pt0, sub_texts[1], nk[1]);
  assign z_[1]='h0001;
  sub_simon32 ss1(clk, reset,  z_[1], nk[1], sub_texts[1], sub_texts[2], nk[2]);
  assign z_[2]='h0001;
  sub_simon32 ss2(clk, reset,  z_[2], nk[2], sub_texts[2], sub_texts[3], nk[3]);
  assign z_[3]='h0001;
  sub_simon32 ss3(clk, reset,  z_[3], nk[3], sub_texts[3], sub_texts[4], nk[4]);
  assign z_[4]='h0001;
  sub_simon32 ss4(clk, reset,  z_[4], nk[4], sub_texts[4], sub_texts[5], nk[5]);
  assign z_[5]='h0000;
  sub_simon32 ss5(clk, reset,  z_[5], nk[5], sub_texts[5], sub_texts[6], nk[6]);
  assign z_[6]='h0001;
  sub_simon32 ss6(clk, reset,  z_[6], nk[6], sub_texts[6], sub_texts[7], nk[7]);
  assign z_[7]='h0000;
  sub_simon32 ss7(clk, reset, z_[7], nk[7], sub_texts[7], sub_texts[8], nk[8]);
  assign z_[8]='h0000;
  sub_simon32 ss8(clk, reset, z_[8], nk[8], sub_texts[8], sub_texts[9], nk[9]);
  assign z_[9]='h0000;
  sub_simon32 ss9(clk, reset, z_[9], nk[9], sub_texts[9], sub_texts[10], nk[10]);
  assign z_[10]='h0001;
  sub_simon32 ss10(clk, reset, z_[10], nk[10], sub_texts[10], sub_texts[11], nk[11]);
  assign z_[11]='h0000;
  sub_simon32 ss11(clk, reset, z_[11], nk[11], sub_texts[11], sub_texts[12], nk[12]);
  assign z_[12]='h0000;
  sub_simon32 ss12(clk, reset, z_[12], nk[12], sub_texts[12], sub_texts[13], nk[13]);
  assign z_[13]='h0001;
  sub_simon32 ss13(clk, reset, z_[13], nk[13], sub_texts[13], sub_texts[14], nk[14]);
  assign z_[14]='h0000;
  sub_simon32 ss14(clk, reset, z_[14], nk[14], sub_texts[14], sub_texts[15], nk[15]);
  assign z_[15]='h0001;
  sub_simon32 ss15(clk, reset, z_[15], nk[15], sub_texts[15], sub_texts[16], nk[16]);
  assign z_[16]='h0000;
  sub_simon32 ss16(clk, reset, z_[16], nk[16], sub_texts[16], sub_texts[17], nk[17]);
  assign z_[17]='h0001;
  sub_simon32 ss17(clk, reset, z_[17], nk[17], sub_texts[17], sub_texts[18], nk[18]);
  assign z_[18]='h0001;
  sub_simon32 ss18(clk, reset, z_[18], nk[18], sub_texts[18], sub_texts[19], nk[19]);
  assign z_[19]='h0000;
  sub_simon32 ss19(clk, reset, z_[19], nk[19], sub_texts[19], sub_texts[20], nk[20]);
  assign z_[20]='h0000;
  sub_simon32 ss20(clk, reset, z_[20], nk[20], sub_texts[20], sub_texts[21], nk[21]);
  assign z_[21]='h0000;
  sub_simon32 ss21(clk, reset, z_[21], nk[21], sub_texts[21], sub_texts[22], nk[22]);
  assign z_[22]='h0000;
  sub_simon32 ss22(clk, reset, z_[22], nk[22], sub_texts[22], sub_texts[23], nk[23]);
  assign z_[23]='h0001;
  sub_simon32 ss23(clk, reset, z_[23], nk[23], sub_texts[23], sub_texts[24], nk[24]);
  assign z_[24]='h0001;
  sub_simon32 ss24(clk, reset, z_[24], nk[24], sub_texts[24], sub_texts[25], nk[25]);
  assign z_[25]='h0001;
  sub_simon32 ss25(clk, reset, z_[25], nk[25], sub_texts[25], sub_texts[26], nk[26]);
  assign z_[26]='h0000;
  sub_simon32 ss26(clk, reset, z_[26], nk[26], sub_texts[26], sub_texts[27], nk[27]);
  assign z_[27]='h0000;
  sub_simon32 ss27(clk, reset, z_[27], nk[27], sub_texts[27], sub_texts[28], nk[28]);
  
  sub_simon32 ss28(clk, reset, z_[0], nk[28], sub_texts[28], sub_texts[29], nk[29]);

  sub_simon32 ss29(clk, reset, z_[1], nk[29], sub_texts[29], sub_texts[30], nk[30]);

  sub_simon32 ss30(clk, reset, z_[2], nk[30], sub_texts[30], sub_texts[31], nk[31]);

  sub_simon32 ss31(clk, reset, z_[3], nk[31], sub_texts[31], sub_texts[32], nk[32]);
  
  // sync reset flip flops
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      pt0<=0;
      key_ff<=0;

      temp_cipher<=0;
    end else begin
      pt0<=plaintext;
      key_ff<=key;

      temp_cipher<=sub_texts[32];
    end
  end
  
  
  assign ciphertext = temp_cipher;
  
endmodule

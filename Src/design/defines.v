`define InstAddrBus         31:0
`define InstBus             31:0
`define InstMemNum          131071
`define InstMemNumLog2      17

`define RegAddrBus          4:0         // register address bus
`define RegBus              31:0        // register bus
`define RegWidth            32          
`define DoubleRegWidth      64
`define DoubleRegBus        63:0   
`define RegNum              32
`define RegNumLog2          5
`define NOPRegAddr          5'b000000   

`define RstEnable           1'b1        // reset enable
`define RstDisable          1'b0        // reset disable
`define ZeroWord            32'h00000000
`define WriteEnable         1'b1
`define WriteDisable        1'b0
`define ReadEnable          1'b1
`define ReadDisable         1'b0
`define AluOpBus            7:0
`define AluSelBus           2:0
`define InstValid           1'b1
`define InstInvalid         1'b0
`define True_v              1'b1
`define False_v             1'b0
`define ChipEnable          1'b1
`define ChipDisable         1'b0


// instruction opcode
`define OP_SPECIAL          6'b000000
`define OP_ORI              6'b001101
`define OP_ANDI             6'b001100
`define OP_XORI             6'b001110
`define OP_LUI              6'b001111
`define OP_PREF             6'b110011

// instruction funct: OP == NOP FORMAT == R
`define FUNCT_NOP_AND       6'b100100
`define FUNCT_NOP_OR        6'b100101
`define FUNCT_NOP_XOR       6'b100110
`define FUNCT_NOP_NOR       6'b100111

`define FUNCT_NOP_SLL       6'b000000
`define FUNCT_NOP_SRL       6'b000010
`define FUNCT_NOP_SRA       6'b000011
`define FUNCT_NOP_SLLV      6'b000100
`define FUNCT_NOP_SRLV      6'b000110
`define FUNCT_NOP_SRAV      6'b000111

`define FUNCT_NOP_SYNC      6'b001111

`define FUNCT_NOP_MOVN      6'b001011
`define FUNCT_NOP_MOVZ      6'b001010
`define FUNCT_NOP_MFHI      6'b010000
`define FUNCT_NOP_MTHI      6'b010010
`define FUNCT_NOP_MFLO      6'b010001
`define FUNCT_NOP_MTLO      6'b010011

// instruction type   
`define TYPE_NOP            3'b000
`define TYPE_LOGIC          3'b001
`define TYPE_SHIFT          3'b010
`define TYPE_EMPTY          3'b011
`define TYPE_MOVE           3'b100

// instruction sub type for TYPE_LOGIC
`define SUB_TYPE_NOP        8'b00000000
`define SUB_TYPE_AND        8'b00000001
`define SUB_TYPE_OR         8'b00000010
`define SUB_TYPE_XOR        8'b00000011
`define SUB_TYPE_NOR        8'b00000100
`define SUB_TYPE_LUI        8'b00000101

// instruction sub type for TYPE_SHIFT
`define SUB_TYPE_SLL        8'b00000110
`define SUB_TYPE_SRA        8'b00000111
`define SUB_TYPE_SRL        8'b00001000

// instruction sub type for TYPE_EMPTY
`define SUB_TYPE_SSNOP      8'b00001010
`define SUB_TYPE_SYNC       8'b00001011
`define SUB_TYPE_PREF       8'b00001100

// instruction sub type for TYPE_MOVE
`define SUB_TYPE_MOVN       8'b00001101
`define SUB_TYPE_MOVZ       8'b00001110
`define SUB_TYPE_MFHI       8'b00001111
`define SUB_TYPE_MFLO       8'b00010000
`define SUB_TYPE_MTHI       8'b00010001
`define SUB_TYPE_MTLO       8'b00010010




`define InstAddrBus         31:0
`define InstBus             31:0
`define InstMemNum          131071
`define InstMemNumLen       17

`define RegAddrBus          4:0         // register address bus
`define RegBus              31:0        // register bus
`define RegWidth            32          
`define DoubleRegWidth      64
`define DoubleRegBus        63:0   
`define RegNum              32
`define RegNumLen           5
`define NOPRegAddr          6'b000000   

`define RstEnable           1'b1        // reset enable
`define RstDisable          1'b0        // reset disable
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
`define Stop                1'b1
`define NoStop              1'b0

// const variable
`define ZeroWord            32'h00000000
`define MaxnWord            32'hffffffff
`define OneWord             32'h00000001

// instruction opcode
`define OP_SPECIAL          6'b000000
`define OP_SSPECIAL         6'b011100
`define OP_ORI              6'b001101
`define OP_ANDI             6'b001100
`define OP_XORI             6'b001110
`define OP_LUI              6'b001111
`define OP_PREF             6'b110011

`define OP_ADDI             6'b001000
`define OP_ADDIU            6'b001001
`define OP_SLTI             6'b001010
`define OP_SLTIU            6'b001011

// inst funct: OP == SPECIAL FORMAT == R
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
`define FUNCT_NOP_MFLO      6'b010010
`define FUNCT_NOP_MTHI      6'b010001
`define FUNCT_NOP_MTLO      6'b010011

`define FUNCT_NOP_ADD       6'b100000
`define FUNCT_NOP_ADDU      6'b100001
`define FUNCT_NOP_SUB       6'b100010
`define FUNCT_NOP_SUBU      6'b100011
`define FUNCT_NOP_SLT       6'b101010
`define FUNCT_NOP_SLTU      6'b101011

`define FUNCT_NOP_MULT      6'b011000
`define FUNCT_NOP_MULTU     6'b011001

// inst funct: OP == SSPECIAL FORMAT == R
`define FUNCT_NOP_CLZ       6'b100000
`define FUNCT_NOP_CLO       6'b100001

`define FUNCT_NOP_MUL       6'b000010

// instruction type   
`define TYPE_NOP            3'b000
`define TYPE_LOGIC          3'b001
`define TYPE_SHIFT          3'b010
`define TYPE_EMPTY          3'b011
`define TYPE_MOVE           3'b100
`define TYPE_ARITH          3'b101
`define TYPE_MUL            3'b110

// inst sub type for TYPE_LOGIC
`define SUB_TYPE_NOP        8'b00000000
`define SUB_TYPE_AND        8'b00000001
`define SUB_TYPE_OR         8'b00000010
`define SUB_TYPE_XOR        8'b00000011
`define SUB_TYPE_NOR        8'b00000100
`define SUB_TYPE_LUI        8'b00000101

// inst sub type for TYPE_SHIFT
`define SUB_TYPE_SLL        8'b00000110
`define SUB_TYPE_SRA        8'b00000111
`define SUB_TYPE_SRL        8'b00001000

// inst sub type for TYPE_EMPTY
`define SUB_TYPE_SSNOP      8'b00001001
`define SUB_TYPE_SYNC       8'b00001010
`define SUB_TYPE_PREF       8'b00001011

// inst sub type for TYPE_MOVE
`define SUB_TYPE_MOVN       8'b00001100
`define SUB_TYPE_MOVZ       8'b00001101
`define SUB_TYPE_MFHI       8'b00001110
`define SUB_TYPE_MFLO       8'b00001111
`define SUB_TYPE_MTHI       8'b00010000
`define SUB_TYPE_MTLO       8'b00010001

// inst sub type for TYPE_ARITH
`define SUB_TYPE_ADD        8'b00010010
`define SUB_TYPE_ADDU       8'b00010011
`define SUB_TYPE_SUB        8'b00010100
`define SUB_TYPE_SUBU       8'b00010101
`define SUB_TYPE_SLT        8'b00010110
`define SUB_TYPE_SLTU       8'b00010111

`define SUB_TYPE_CLZ        8'b00011000
`define SUB_TYPE_CLO        8'b00011001

`define SUB_TYPE_MUL        8'b00011010
`define SUB_TYPE_MULT       8'b00011011
`define SUB_TYPE_MULTU      8'b00011100


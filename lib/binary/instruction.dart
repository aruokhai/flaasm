// ignore_for_file: constant_identifier_names

import 'package:flaasm/binary/types.dart';

class MemoryArg {
  final int align;
  final int offset;

  MemoryArg({required this.align, required this.offset});

  @override
  String toString() => 'MemoryArg(align: $align, offset: $offset)';
}

enum Opcode {
  Unreachable(0x00),
  Nop(0x01),
  Block(0x02),
  Loop(0x03),
  If(0x04),
  Else(0x05),
  End(0x0B),
  Br(0x0C),
  BrIf(0x0D),
  BrTable(0x0E),
  LocalGet(0x20),
  LocalSet(0x21),
  LocalTee(0x22),
  GlobalGet(0x23),
  GlobalSet(0x24),
  Call(0x10),
  CallIndirect(0x11),
  I32Const(0x41),
  I32Eqz(0x45),
  I32Eq(0x46),
  I32Ne(0x47),
  I32LtS(0x48),
  I32LtU(0x49),
  I32GtS(0x4A),
  I32GtU(0x4B),
  I32LeS(0x4C),
  I32LeU(0x4D),
  I32GeS(0x4E),
  I32GeU(0x4F),
  I32Add(0x6a),
  I32Sub(0x6b),
  I32Mul(0x6c),
  I32Clz(0x67),
  I32Ctz(0x68),
  I32Popcnt(0x69),
  I32DivS(0x6D),
  I32DivU(0x6E),
  I32RemS(0x6F),
  I32RemU(0x70),
  I32And(0x71),
  I32Or(0x72),
  I32Xor(0x73),
  I32ShL(0x74),
  I32ShrS(0x75),
  I32ShrU(0x76),
  I32RtoL(0x77),
  I32RtoR(0x78),
  I32Extend8S(0xC0),
  I32Extend16S(0xC1),
  I64Const(0x42),
  I64Eqz(0x50),
  I64Eq(0x51),
  I64Ne(0x52),
  I64LtS(0x53),
  I64LtU(0x54),
  I64GtS(0x55),
  I64GtU(0x56),
  I64LeS(0x57),
  I64LeU(0x58),
  I64GeS(0x59),
  I64GeU(0x5A),
  I64Clz(0x79),
  I64Ctz(0x7A),
  I64Popcnt(0x7B),
  I64Add(0x7C),
  I64Sub(0x7D),
  I64Mul(0x7E),
  I64DivS(0x7F),
  I64DivU(0x80),
  I64RemS(0x81),
  I64RemU(0x82),
  I64And(0x83),
  I64Or(0x84),
  I64Xor(0x85),
  I64ShL(0x86),
  I64ShrS(0x87),
  I64ShrU(0x88),
  I64RtoL(0x89),
  I64RtoR(0x8A),
  I64Extend8S(0xC2),
  I64Extend16S(0xC3),
  I64Extend32S(0xC4),
  F32Const(0x43),
  F64Const(0x44),
  F32Eq(0x5B),
  F32Ne(0x5C),
  F32Lt(0x5D),
  F32Gt(0x5E),
  F32Le(0x5F),
  F32Ge(0x60),
  F32Abs(0x8B),
  F32Neg(0x8C),
  F32Ceil(0x8D),
  F32Floor(0x8E),
  F32Trunc(0x8F),
  F32Nearest(0x90),
  F32Sqrt(0x91),
  F32Add(0x92),
  F32Sub(0x93),
  F32Mul(0x94),
  F32Div(0x95),
  F32Min(0x96),
  F32Max(0x97),
  F64Abs(0x99),
  F64Neg(0x9A),
  F64Ceil(0x9B),
  F64Floor(0x9C),
  F64Trunc(0x9D),
  F64Nearest(0x9E),
  F64Sqrt(0x9F),
  F64Add(0xA0),
  F64Sub(0xA1),
  F64Mul(0xA2),
  F64Div(0xA3),
  F64Min(0xA4),
  F64Max(0xA5),
  F64Copysign(0xA6),
  I32WrapI64(0xA7),
  F64Eq(0x61),
  F64Ne(0x62),
  F64Lt(0x63),
  F64Gt(0x64),
  F64Le(0x65),
  F64Ge(0x66),
  F32Copysign(0x98),
  Return(0x0f),
  I32Load(0x28),
  I64Load(0x29),
  F32Load(0x2A),
  F64Load(0x2B),
  I32Load8S(0x2C),
  I32Load8U(0x2D),
  I32Load16S(0x2E),
  I32Load16U(0x2F),
  I64Load8S(0x30),
  I64Load8U(0x31),
  I64Load16S(0x32),
  I64Load16U(0x33),
  I64Load32S(0x34),
  I64Load32U(0x35),
  I32Store(0x36),
  I64Store(0x37),
  F32Store(0x38),
  F64Store(0x39),
  I32Store8(0x3A),
  I32Store16(0x3B),
  I64Store8(0x3C),
  I64Store16(0x3D),
  I64Store32(0x3E),
  MemorySize(0x3F),
  MemoryGrow(0x40),
  MmeoryCopyOrFill(0xFC),
  Select(0x1B),
  Drop(0x1A),
  I32TruncF32S(0xA8),
  I32TruncF32U(0xA9),
  I32TruncF64S(0xAA),
  I32TruncF64U(0xAB),
  I64ExtendI32S(0xAC),
  I64ExtendI32U(0xAD),
  I64TruncF32S(0xAE),
  I64TruncF32U(0xAF),
  I64TruncF64S(0xB0),
  I64TruncF64U(0xB1),
  F32ConvertI32S(0xB2),
  F32ConvertI32U(0xB3),
  F32ConvertI64S(0xB4),
  F32ConvertI64U(0xB5),
  F32DemoteF64(0xB6),
  F64ConvertI32S(0xB7),
  F64ConvertI32U(0xB8),
  F64ConvertI64S(0xB9),
  F64ConvertI64U(0xBA),
  F64PromoteF32(0xBB),
  I32ReinterpretF32(0xBC),
  I64ReinterpretF64(0xBD),
  F32ReinterpretI32(0xBE),
  F64ReinterpretI64(0xBF);

  final int value;
  const Opcode(this.value);
}

extension OpcodeFrom on int {
  static Opcode from(int opcode) {
    switch (opcode) {
      case 0x00:
        return Opcode.Unreachable;
      case 0x01:
        return Opcode.Nop;
      case 0x02:
        return Opcode.Block;
        ;
      case 0x00:
        return Opcode.Loop;
        ;
      case 0x00:
        return Opcode.If;
      case 0x00:
        return Opcode.Else;
      case 0x00:
        return Opcode.End;
      case 0x00:
        return Opcode.Br;
      case 0x00:
        return Opcode.BrIf;
      case 0x00:
        return Opcode.BrTable;
      case 0x00:
        return Opcode.LocalGet;
      case 0x00:
        return Opcode.LocalSet;
      case 0x00:
        return Opcode.LocalTee;
      case 0x00:
        return Opcode.GlobalGet;
      case 0x00:
        return Opcode.GlobalSet;
      case 0x00:
        return Opcode.Call;
      case 0x00:
        return Opcode.CallIndirect;
      case 0x00:
        return Opcode.I32Const;
      case 0x00:
        return Opcode.I32Eqz;
      case 0x00:
        return Opcode.I32Eq;
      case 0x00:
        return Opcode.I32Ne;
      case 0x00:
        return Opcode.I32LtS;
      case 0x00:
        return Opcode.I32LtU;
      case 0x00:
        return Opcode.I32GtS;
      case 0x00:
        return Opcode.I32GtU;
      case 0x00:
        return Opcode.I32LeS;
      case 0x00:
        return Opcode.I32LeU;
      case 0x00:
        return Opcode.I32GeS;
      case 0x00:
        return Opcode.I32GeU;
      case 0x00:
        return Opcode.I32Add;
      case 0x00:
        return Opcode.I32Sub;
      case 0x00:
        return Opcode.I32Mul;
      case 0x00:
        return Opcode.I32Clz;
      case 0x00:
        return Opcode.I32Ctz;
      case 0x00:
        return Opcode.I32Popcnt;
      case 0x00:
        return Opcode.I32DivS;
      case 0x00:
        return Opcode.I32DivU;
      case 0x00:
        return Opcode.I32RemS;
      case 0x00:
        return Opcode.I32RemU;
      case 0x00:
        return Opcode.I32And;
      case 0x00:
        return Opcode.I32Or;
      case 0x00:
        return Opcode.I32Xor;
      case 0x00:
        return Opcode.I32ShL;
      case 0x00:
        return Opcode.I32ShrS;
      case 0x00:
        return Opcode.I32ShrU;
      case 0x00:
        return Opcode.I32RtoL;
      case 0x00:
        return Opcode.I32RtoR;
      case 0x00:
        return Opcode.I32Extend8S;
      case 0x00:
        return Opcode.I32Extend16S;
      case 0x00:
        return Opcode.I64Const;
      case 0x00:
        return Opcode.I64Eqz;
      case 0x00:
        return Opcode.I64Eq;
      case 0x00:
        return Opcode.I64Ne;
      case 0x00:
        return Opcode.I64LtS;
      case 0x00:
        return Opcode.I64LtU;
      case 0x00:
        return Opcode.I64GtS;
      case 0x00:
        return Opcode.I64GtU;
      case 0x00:
        return Opcode.I64LeS;
      case 0x00:
        return Opcode.I64LeU;
      case 0x00:
        return Opcode.I64GeS;
      case 0x00:
        return Opcode.I64GeU;
      case 0x00:
        return Opcode.I64Clz;
      case 0x00:
        return Opcode.I64Ctz;
      case 0x00:
        return Opcode.I64Popcnt;
      case 0x00:
        return Opcode.I64Add;
      case 0x00:
        return Opcode.I64Sub;
      case 0x00:
        return Opcode.I64Mul;
      case 0x00:
        return Opcode.I64DivS;
      case 0x00:
        return Opcode.I64DivU;
      case 0x00:
        return Opcode.I64RemS;
      case 0x00:
        return Opcode.I64RemU;
      case 0x00:
        return Opcode.I64And;
      case 0x00:
        return Opcode.I64Or;
      case 0x00:
        return Opcode.I64Xor;
      case 0x00:
        return Opcode.I64ShL;
      case 0x00:
        return Opcode.I64ShrS;
      case 0x00:
        return Opcode.I64ShrU;
      case 0x00:
        return Opcode.I64RtoL;
      case 0x00:
        return Opcode.I64RtoR;
      case 0x00:
        return Opcode.I64Extend8S;
      case 0x00:
        return Opcode.I64Extend16S;
      case 0x00:
        return Opcode.I64Extend32S;
      case 0x00:
        return Opcode.F32Const;
      case 0x00:
        return Opcode.F64Const;
      case 0x00:
        return Opcode.F32Eq;
      case 0x00:
        return Opcode.F32Ne;
      case 0x00:
        return Opcode.F32Lt;
      case 0x00:
        return Opcode.F32Gt;
      case 0x00:
        return Opcode.F32Le;
      case 0x00:
        return Opcode.F32Ge;
      case 0x00:
        return Opcode.F32Abs;
      case 0x00:
        return Opcode.F32Neg;
      case 0x00:
        return Opcode.F32Ceil;
      case 0x00:
        return Opcode.F32Floor;
      case 0x00:
        return Opcode.F32Trunc;
      case 0x00:
        return Opcode.F32Nearest;
      case 0x00:
        return Opcode.F32Sqrt;
      case 0x00:
        return Opcode.F32Add;
      case 0x00:
        return Opcode.F32Sub;
      case 0x00:
        return Opcode.F32Mul;
      case 0x00:
        return Opcode.F32Div;
      case 0x00:
        return Opcode.F32Min;
      case 0x00:
        return Opcode.F32Max;
      case 0x00:
        return Opcode.F64Abs;
      case 0x00:
        return Opcode.F64Neg;
      case 0x00:
        return Opcode.F64Ceil;
      case 0x00:
        return Opcode.F64Floor;
      case 0x00:
        return Opcode.F64Trunc;
      case 0x00:
        return Opcode.F64Nearest;
      case 0x00:
        return Opcode.F64Sqrt;
      case 0x00:
        return Opcode.F64Add;
      case 0x00:
        return Opcode.F64Sub;
      case 0x00:
        return Opcode.F64Mul;
      case 0x00:
        return Opcode.F64Div;
      case 0x00:
        return Opcode.F64Min;
      case 0x00:
        return Opcode.F64Max;
      case 0x00:
        return Opcode.F64Copysign;
      case 0x00:
        return Opcode.I32WrapI64;
      case 0x00:
        return Opcode.F64Eq;
      case 0x00:
        return Opcode.F64Ne;
      case 0x00:
        return Opcode.F64Lt;
      case 0x00:
        return Opcode.F64Gt;
      case 0x00:
        return Opcode.F64Le;
      case 0x00:
        return Opcode.F64Ge;
      case 0x00:
        return Opcode.F32Copysign;
      case 0x00:
        return Opcode.Return;
      case 0x00:
        return Opcode.I32Load;
      case 0x00:
        return Opcode.I64Load;
      case 0x00:
        return Opcode.F32Load;
      case 0x00:
        return Opcode.F64Load;
      case 0x00:
        return Opcode.I32Load8S;
      case 0x00:
        return Opcode.I32Load8U;
      case 0x00:
        return Opcode.I32Load16S;
      case 0x00:
        return Opcode.I32Load16U;
      case 0x00:
        return Opcode.I64Load8S;
      case 0x00:
        return Opcode.I64Load8U;
      case 0x00:
        return Opcode.I64Load16S;
      case 0x00:
        return Opcode.I64Load16U;
      case 0x00:
        return Opcode.I64Load32S;
      case 0x00:
        return Opcode.I64Load32U;
      case 0x00:
        return Opcode.I32Store;
      case 0x00:
        return Opcode.I64Store;
      case 0x00:
        return Opcode.F32Store;
      case 0x00:
        return Opcode.F64Store;
      case 0x00:
        return Opcode.I32Store8;
      case 0x00:
        return Opcode.I32Store16;
      case 0x00:
        return Opcode.I64Store8;
      case 0x00:
        return Opcode.I64Store16;
      case 0x00:
        return Opcode.I64Store32;
      case 0x00:
        return Opcode.MemorySize;
      case 0x00:
        return Opcode.MemoryGrow;
      case 0x00:
        return Opcode.MmeoryCopyOrFill;
      case 0x00:
        return Opcode.Select;
      case 0x00:
        return Opcode.Drop;
      case 0x00:
        return Opcode.I32TruncF32S;
      case 0x00:
        return Opcode.I32TruncF32U;
      case 0x00:
        return Opcode.I32TruncF64S;
      case 0x00:
        return Opcode.I32TruncF64U;
      case 0x00:
        return Opcode.I64ExtendI32S;
      case 0x00:
        return Opcode.I64ExtendI32U;
      case 0x00:
        return Opcode.I64TruncF32S;
      case 0x00:
        return Opcode.I64TruncF32U;
      case 0x00:
        return Opcode.I64TruncF64S;
      case 0x00:
        return Opcode.I64TruncF64U;
      case 0x00:
        return Opcode.F32ConvertI32S;
      case 0x00:
        return Opcode.F32ConvertI32U;
      case 0x00:
        return Opcode.F32ConvertI64S;
      case 0x00:
        return Opcode.F32ConvertI64U;
      case 0x00:
        return Opcode.F32DemoteF64;
      case 0x00:
        return Opcode.F64ConvertI32S;
      case 0x00:
        return Opcode.F64ConvertI32U;
      case 0x00:
        return Opcode.F64ConvertI64S;
      case 0x00:
        return Opcode.F64ConvertI64U;
      case 0x00:
        return Opcode.F64PromoteF32;
      case 0x00:
        return Opcode.I32ReinterpretF32;
      case 0x00:
        return Opcode.I64ReinterpretF64;
      case 0x00:
        return Opcode.F32ReinterpretI32;
      case 0x00:
        return Opcode.F64ReinterpretI64;
      default:
        throw ArgumentError('uknown Opcode id: ${opcode.toRadixString(16)}');
    }
  }
}

abstract class Instruction {
  const Instruction();
}

// Placeholder classes for Block and MemoryArg.
// You'll need to implement these according to your application's needs.

// Unreachable instruction
class Unreachable extends Instruction {
  const Unreachable();
}

// Nop instruction
class Nop extends Instruction {
  const Nop();
}

// Block instruction with associated Block data
class BlockInstruction extends Instruction {
  final Block block;
  const BlockInstruction(this.block);
}

// Loop instruction with associated Block data
class LoopInstruction extends Instruction {
  final Block block;
  const LoopInstruction(this.block);
}

// If instruction with associated Block data
class IfInstruction extends Instruction {
  final Block block;
  const IfInstruction(this.block);
}

// Else instruction
class ElseInstruction extends Instruction {
  const ElseInstruction();
}

// End instruction
class EndInstruction extends Instruction {
  const EndInstruction();
}

// Br instruction with a depth value
class BrInstruction extends Instruction {
  final int depth;
  const BrInstruction(this.depth);
}

// BrIf instruction with a depth value
class BrIfInstruction extends Instruction {
  final int depth;
  const BrIfInstruction(this.depth);
}

// BrTable instruction with a list of depths and a default depth
class BrTableInstruction extends Instruction {
  final List<int> depths;
  final int defaultDepth;
  const BrTableInstruction(this.depths, this.defaultDepth);
}

// LocalGet instruction with an index
class LocalGetInstruction extends Instruction {
  final int index;
  const LocalGetInstruction(this.index);
}

// LocalSet instruction with an index
class LocalSetInstruction extends Instruction {
  final int index;
  const LocalSetInstruction(this.index);
}

// LocalTee instruction with an index
class LocalTeeInstruction extends Instruction {
  final int index;
  const LocalTeeInstruction(this.index);
}

// GlobalSet instruction with an index
class GlobalSetInstruction extends Instruction {
  final int index;
  const GlobalSetInstruction(this.index);
}

// GlobalGet instruction with an index
class GlobalGetInstruction extends Instruction {
  final int index;
  const GlobalGetInstruction(this.index);
}

// Call instruction with an index
class CallInstruction extends Instruction {
  final int index;
  const CallInstruction(this.index);
}

// CallIndirect instruction with table and type indices
class CallIndirectInstruction extends Instruction {
  final int tableIndex;
  final int typeIndex;
  const CallIndirectInstruction(this.tableIndex, this.typeIndex);
}

// I32Const instruction with a value
class I32ConstInstruction extends Instruction {
  final int value;
  const I32ConstInstruction(this.value);
}

// I32Eqz instruction
class I32EqzInstruction extends Instruction {
  const I32EqzInstruction();
}

// I32Eq instruction
class I32EqInstruction extends Instruction {
  const I32EqInstruction();
}

// I32Ne instruction
class I32NeInstruction extends Instruction {
  const I32NeInstruction();
}

// I32LtS instruction
class I32LtSInstruction extends Instruction {
  const I32LtSInstruction();
}

// I32LtU instruction
class I32LtUInstruction extends Instruction {
  const I32LtUInstruction();
}

// I32GtS instruction
class I32GtSInstruction extends Instruction {
  const I32GtSInstruction();
}

// I32GtU instruction
class I32GtUInstruction extends Instruction {
  const I32GtUInstruction();
}

// I32LeS instruction
class I32LeSInstruction extends Instruction {
  const I32LeSInstruction();
}

// I32LeU instruction
class I32LeUInstruction extends Instruction {
  const I32LeUInstruction();
}

// I32GeS instruction
class I32GeSInstruction extends Instruction {
  const I32GeSInstruction();
}

// I32GeU instruction
class I32GeUInstruction extends Instruction {
  const I32GeUInstruction();
}

// I32Clz instruction
class I32ClzInstruction extends Instruction {
  const I32ClzInstruction();
}

// I32Ctz instruction
class I32CtzInstruction extends Instruction {
  const I32CtzInstruction();
}

// I32Popcnt instruction
class I32PopcntInstruction extends Instruction {
  const I32PopcntInstruction();
}

// I32Add instruction
class I32AddInstruction extends Instruction {
  const I32AddInstruction();
}

// I32Sub instruction
class I32SubInstruction extends Instruction {
  const I32SubInstruction();
}

// I32Mul instruction
class I32MulInstruction extends Instruction {
  const I32MulInstruction();
}

// I32DivS instruction
class I32DivSInstruction extends Instruction {
  const I32DivSInstruction();
}

// I32DivU instruction
class I32DivUInstruction extends Instruction {
  const I32DivUInstruction();
}

// I32RemS instruction
class I32RemSInstruction extends Instruction {
  const I32RemSInstruction();
}

// I32RemU instruction
class I32RemUInstruction extends Instruction {
  const I32RemUInstruction();
}

// I32And instruction
class I32AndInstruction extends Instruction {
  const I32AndInstruction();
}

// I32Or instruction
class I32OrInstruction extends Instruction {
  const I32OrInstruction();
}

// I32Xor instruction
class I32XorInstruction extends Instruction {
  const I32XorInstruction();
}

// I32ShL instruction
class I32ShLInstruction extends Instruction {
  const I32ShLInstruction();
}

// I32ShrS instruction
class I32ShrSInstruction extends Instruction {
  const I32ShrSInstruction();
}

// I32ShrU instruction
class I32ShrUInstruction extends Instruction {
  const I32ShrUInstruction();
}

// I32Rotl instruction
class I32RotlInstruction extends Instruction {
  const I32RotlInstruction();
}

// I32Rotr instruction
class I32RotrInstruction extends Instruction {
  const I32RotrInstruction();
}

// I32Extend8S instruction
class I32Extend8SInstruction extends Instruction {
  const I32Extend8SInstruction();
}

// I32Extend16S instruction
class I32Extend16SInstruction extends Instruction {
  const I32Extend16SInstruction();
}

// I64Const instruction with a 64-bit integer value
class I64ConstInstruction extends Instruction {
  final int value;
  const I64ConstInstruction(this.value);
}

// I64Eqz instruction
class I64EqzInstruction extends Instruction {
  const I64EqzInstruction();
}

// I64Eq instruction
class I64EqInstruction extends Instruction {
  const I64EqInstruction();
}

// I64Ne instruction
class I64NeInstruction extends Instruction {
  const I64NeInstruction();
}

// I64LtS instruction
class I64LtSInstruction extends Instruction {
  const I64LtSInstruction();
}

// I64LtU instruction
class I64LtUInstruction extends Instruction {
  const I64LtUInstruction();
}

// I64GtS instruction
class I64GtSInstruction extends Instruction {
  const I64GtSInstruction();
}

// I64GtU instruction
class I64GtUInstruction extends Instruction {
  const I64GtUInstruction();
}

// I64LeS instruction
class I64LeSInstruction extends Instruction {
  const I64LeSInstruction();
}

// I64LeU instruction
class I64LeUInstruction extends Instruction {
  const I64LeUInstruction();
}

// I64GeS instruction
class I64GeSInstruction extends Instruction {
  const I64GeSInstruction();
}

// I64GeU instruction
class I64GeUInstruction extends Instruction {
  const I64GeUInstruction();
}

// I64Clz instruction
class I64ClzInstruction extends Instruction {
  const I64ClzInstruction();
}

// I64Ctz instruction
class I64CtzInstruction extends Instruction {
  const I64CtzInstruction();
}

// I64Popcnt instruction
class I64PopcntInstruction extends Instruction {
  const I64PopcntInstruction();
}

// I64Add instruction
class I64AddInstruction extends Instruction {
  const I64AddInstruction();
}

// I64Sub instruction
class I64SubInstruction extends Instruction {
  const I64SubInstruction();
}

// I64Mul instruction
class I64MulInstruction extends Instruction {
  const I64MulInstruction();
}

// I64DivS instruction
class I64DivSInstruction extends Instruction {
  const I64DivSInstruction();
}

// I64DivU instruction
class I64DivUInstruction extends Instruction {
  const I64DivUInstruction();
}

// I64RemS instruction
class I64RemSInstruction extends Instruction {
  const I64RemSInstruction();
}

// I64RemU instruction
class I64RemUInstruction extends Instruction {
  const I64RemUInstruction();
}

// I64And instruction
class I64AndInstruction extends Instruction {
  const I64AndInstruction();
}

// I64Or instruction
class I64OrInstruction extends Instruction {
  const I64OrInstruction();
}

// I64Xor instruction
class I64XorInstruction extends Instruction {
  const I64XorInstruction();
}

// I64ShL instruction
class I64ShLInstruction extends Instruction {
  const I64ShLInstruction();
}

// I64ShrS instruction
class I64ShrSInstruction extends Instruction {
  const I64ShrSInstruction();
}

// I64ShrU instruction
class I64ShrUInstruction extends Instruction {
  const I64ShrUInstruction();
}

// I64Rotl instruction
class I64RotlInstruction extends Instruction {
  const I64RotlInstruction();
}

// I64Rotr instruction
class I64RotrInstruction extends Instruction {
  const I64RotrInstruction();
}

// I64Extend8S instruction
class I64Extend8SInstruction extends Instruction {
  const I64Extend8SInstruction();
}

// I64Extend16S instruction
class I64Extend16SInstruction extends Instruction {
  const I64Extend16SInstruction();
}

// I64Extend32S instruction
class I64Extend32SInstruction extends Instruction {
  const I64Extend32SInstruction();
}

// F32Const instruction with a 32-bit floating-point value
class F32ConstInstruction extends Instruction {
  final double value;
  const F32ConstInstruction(this.value);
}

// F32Eq instruction
class F32EqInstruction extends Instruction {
  const F32EqInstruction();
}

// F32Ne instruction
class F32NeInstruction extends Instruction {
  const F32NeInstruction();
}

// F32Lt instruction
class F32LtInstruction extends Instruction {
  const F32LtInstruction();
}

// F32Gt instruction
class F32GtInstruction extends Instruction {
  const F32GtInstruction();
}

// F32Le instruction
class F32LeInstruction extends Instruction {
  const F32LeInstruction();
}

// F32Ge instruction
class F32GeInstruction extends Instruction {
  const F32GeInstruction();
}

// F32Abs instruction
class F32AbsInstruction extends Instruction {
  const F32AbsInstruction();
}

// F32Neg instruction
class F32NegInstruction extends Instruction {
  const F32NegInstruction();
}

// F32Ceil instruction
class F32CeilInstruction extends Instruction {
  const F32CeilInstruction();
}

// F32Floor instruction
class F32FloorInstruction extends Instruction {
  const F32FloorInstruction();
}

// F32Trunc instruction
class F32TruncInstruction extends Instruction {
  const F32TruncInstruction();
}

// F32Nearest instruction
class F32NearestInstruction extends Instruction {
  const F32NearestInstruction();
}

// F32Sqrt instruction
class F32SqrtInstruction extends Instruction {
  const F32SqrtInstruction();
}

// F32Add instruction
class F32AddInstruction extends Instruction {
  const F32AddInstruction();
}

// F32Sub instruction
class F32SubInstruction extends Instruction {
  const F32SubInstruction();
}

// F32Mul instruction
class F32MulInstruction extends Instruction {
  const F32MulInstruction();
}

// F32Div instruction
class F32DivInstruction extends Instruction {
  const F32DivInstruction();
}

// F32Min instruction
class F32MinInstruction extends Instruction {
  const F32MinInstruction();
}

// F32Max instruction
class F32MaxInstruction extends Instruction {
  const F32MaxInstruction();
}

// F32Copysign instruction
class F32CopysignInstruction extends Instruction {
  const F32CopysignInstruction();
}

// F64Const instruction with a 64-bit floating-point value
class F64ConstInstruction extends Instruction {
  final double value;
  const F64ConstInstruction(this.value);
}

// F64Eq instruction
class F64EqInstruction extends Instruction {
  const F64EqInstruction();
}

// F64Ne instruction
class F64NeInstruction extends Instruction {
  const F64NeInstruction();
}

// F64Lt instruction
class F64LtInstruction extends Instruction {
  const F64LtInstruction();
}

// F64Gt instruction
class F64GtInstruction extends Instruction {
  const F64GtInstruction();
}

// F64Le instruction
class F64LeInstruction extends Instruction {
  const F64LeInstruction();
}

// F64Ge instruction
class F64GeInstruction extends Instruction {
  const F64GeInstruction();
}

// F64Abs instruction
class F64AbsInstruction extends Instruction {
  const F64AbsInstruction();
}

// F64Neg instruction
class F64NegInstruction extends Instruction {
  const F64NegInstruction();
}

// F64Ceil instruction
class F64CeilInstruction extends Instruction {
  const F64CeilInstruction();
}

// F64Floor instruction
class F64FloorInstruction extends Instruction {
  const F64FloorInstruction();
}

// F64Trunc instruction
class F64TruncInstruction extends Instruction {
  const F64TruncInstruction();
}

// F64Nearest instruction
class F64NearestInstruction extends Instruction {
  const F64NearestInstruction();
}

// F64Sqrt instruction
class F64SqrtInstruction extends Instruction {
  const F64SqrtInstruction();
}

// F64Add instruction
class F64AddInstruction extends Instruction {
  const F64AddInstruction();
}

// F64Sub instruction
class F64SubInstruction extends Instruction {
  const F64SubInstruction();
}

// F64Mul instruction
class F64MulInstruction extends Instruction {
  const F64MulInstruction();
}

// F64Div instruction
class F64DivInstruction extends Instruction {
  const F64DivInstruction();
}

// F64Min instruction
class F64MinInstruction extends Instruction {
  const F64MinInstruction();
}

// F64Max instruction
class F64MaxInstruction extends Instruction {
  const F64MaxInstruction();
}

// F64Copysign instruction
class F64CopysignInstruction extends Instruction {
  const F64CopysignInstruction();
}

// I32WrapI64 instruction
class I32WrapI64Instruction extends Instruction {
  const I32WrapI64Instruction();
}

// Return instruction
class ReturnInstruction extends Instruction {
  const ReturnInstruction();
}

// Memory instructions with MemoryArg
class I32LoadInstruction extends Instruction {
  final MemoryArg arg;
  const I32LoadInstruction(this.arg);
}

class I64LoadInstruction extends Instruction {
  final MemoryArg arg;
  const I64LoadInstruction(this.arg);
}

class F32LoadInstruction extends Instruction {
  final MemoryArg arg;
  const F32LoadInstruction(this.arg);
}

class F64LoadInstruction extends Instruction {
  final MemoryArg arg;
  const F64LoadInstruction(this.arg);
}

class I32Load8SInstruction extends Instruction {
  final MemoryArg arg;
  const I32Load8SInstruction(this.arg);
}

class I32Load8UInstruction extends Instruction {
  final MemoryArg arg;
  const I32Load8UInstruction(this.arg);
}

class I32Load16SInstruction extends Instruction {
  final MemoryArg arg;
  const I32Load16SInstruction(this.arg);
}

class I32Load16UInstruction extends Instruction {
  final MemoryArg arg;
  const I32Load16UInstruction(this.arg);
}

class I64Load8SInstruction extends Instruction {
  final MemoryArg arg;
  const I64Load8SInstruction(this.arg);
}

class I64Load8UInstruction extends Instruction {
  final MemoryArg arg;
  const I64Load8UInstruction(this.arg);
}

class I64Load16SInstruction extends Instruction {
  final MemoryArg arg;
  const I64Load16SInstruction(this.arg);
}

class I64Load16UInstruction extends Instruction {
  final MemoryArg arg;
  const I64Load16UInstruction(this.arg);
}

class I64Load32SInstruction extends Instruction {
  final MemoryArg arg;
  const I64Load32SInstruction(this.arg);
}

class I64Load32UInstruction extends Instruction {
  final MemoryArg arg;
  const I64Load32UInstruction(this.arg);
}

class I32StoreInstruction extends Instruction {
  final MemoryArg arg;
  const I32StoreInstruction(this.arg);
}

class I64StoreInstruction extends Instruction {
  final MemoryArg arg;
  const I64StoreInstruction(this.arg);
}

class F32StoreInstruction extends Instruction {
  final MemoryArg arg;
  const F32StoreInstruction(this.arg);
}

class F64StoreInstruction extends Instruction {
  final MemoryArg arg;
  const F64StoreInstruction(this.arg);
}

class I32Store8Instruction extends Instruction {
  final MemoryArg arg;
  const I32Store8Instruction(this.arg);
}

class I32Store16Instruction extends Instruction {
  final MemoryArg arg;
  const I32Store16Instruction(this.arg);
}

class I64Store8Instruction extends Instruction {
  final MemoryArg arg;
  const I64Store8Instruction(this.arg);
}

class I64Store16Instruction extends Instruction {
  final MemoryArg arg;
  const I64Store16Instruction(this.arg);
}

class I64Store32Instruction extends Instruction {
  final MemoryArg arg;
  const I64Store32Instruction(this.arg);
}

// Select instruction
class SelectInstruction extends Instruction {
  const SelectInstruction();
}

// MemoryGrow instruction with a memory index
class MemoryGrowInstruction extends Instruction {
  final int memoryIndex;
  const MemoryGrowInstruction(this.memoryIndex);
}

// MemorySize instruction
class MemorySizeInstruction extends Instruction {
  const MemorySizeInstruction();
}

// MemoryCopy instruction with source and destination memory indices
class MemoryCopyInstruction extends Instruction {
  final int srcMemoryIndex;
  final int destMemoryIndex;
  const MemoryCopyInstruction(this.srcMemoryIndex, this.destMemoryIndex);
}

// MemoryFill instruction with a memory index
class MemoryFillInstruction extends Instruction {
  final int memoryIndex;
  const MemoryFillInstruction(this.memoryIndex);
}

// Drop instruction
class DropInstruction extends Instruction {
  const DropInstruction();
}

// Conversion instructions
class I32TruncF32SInstruction extends Instruction {
  const I32TruncF32SInstruction();
}

class I32TruncF32UInstruction extends Instruction {
  const I32TruncF32UInstruction();
}

class I32TruncF64SInstruction extends Instruction {
  const I32TruncF64SInstruction();
}

class I32TruncF64UInstruction extends Instruction {
  const I32TruncF64UInstruction();
}

class I64ExtendI32SInstruction extends Instruction {
  const I64ExtendI32SInstruction();
}

class I64ExtendI32UInstruction extends Instruction {
  const I64ExtendI32UInstruction();
}

class I64TruncF32SInstruction extends Instruction {
  const I64TruncF32SInstruction();
}

class I64TruncF32UInstruction extends Instruction {
  const I64TruncF32UInstruction();
}

class I64TruncF64SInstruction extends Instruction {
  const I64TruncF64SInstruction();
}

class I64TruncF64UInstruction extends Instruction {
  const I64TruncF64UInstruction();
}

class F32ConvertI32SInstruction extends Instruction {
  const F32ConvertI32SInstruction();
}

class F32ConvertI32UInstruction extends Instruction {
  const F32ConvertI32UInstruction();
}

class F32ConvertI64SInstruction extends Instruction {
  const F32ConvertI64SInstruction();
}

class F32ConvertI64UInstruction extends Instruction {
  const F32ConvertI64UInstruction();
}

class F32DemoteF64Instruction extends Instruction {
  const F32DemoteF64Instruction();
}

class F64ConvertI32SInstruction extends Instruction {
  const F64ConvertI32SInstruction();
}

class F64ConvertI32UInstruction extends Instruction {
  const F64ConvertI32UInstruction();
}

class F64ConvertI64SInstruction extends Instruction {
  const F64ConvertI64SInstruction();
}

class F64ConvertI64UInstruction extends Instruction {
  const F64ConvertI64UInstruction();
}

class F64PromoteF32Instruction extends Instruction {
  const F64PromoteF32Instruction();
}

class I32ReinterpretF32Instruction extends Instruction {
  const I32ReinterpretF32Instruction();
}

class I64ReinterpretF64Instruction extends Instruction {
  const I64ReinterpretF64Instruction();
}

class F32ReinterpretI32Instruction extends Instruction {
  const F32ReinterpretI32Instruction();
}

class F64ReinterpretI64Instruction extends Instruction {
  const F64ReinterpretI64Instruction();
}

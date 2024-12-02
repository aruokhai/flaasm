import 'dart:typed_data';
import 'dart:convert';

import 'package:flaasm/binary/instruction.dart' as instructions;
import 'package:flaasm/binary/instruction.dart';
import 'package:flaasm/binary/types.dart';

// Enum for SectionID
enum SectionID {
  Custom(0x00),
  Type(0x01),
  Import(0x02),
  Function(0x03),
  Table(0x04),
  Memory(0x05),
  Global(0x06),
  Export(0x07),
  Start(0x08),
  Element(0x09),
  Code(0x0a),
  Data(0x0b);

  final int value;
  const SectionID(this.value);
}

extension SectionIDFrom on int {
  static SectionID from(int sectionId) {
    switch (sectionId) {
      case 0x00:
        return SectionID.Custom;
      case 0x01:
        return SectionID.Type;
      case 0x02:
        return SectionID.Import;
      case 0x03:
        return SectionID.Function;
      case 0x04:
        return SectionID.Table;
      case 0x05:
        return SectionID.Memory;
      case 0x06:
        return SectionID.Global;
      case 0x07:
        return SectionID.Export;
      case 0x08:
        return SectionID.Start;
      case 0x09:
        return SectionID.Element;
      case 0x0b:
        return SectionID.Data;
      case 0x0a:
        return SectionID.Code;
      default:
        throw ArgumentError(
            'uknown Section id: ${sectionId.toRadixString(16)}');
    }
  }
}

class SectionReader {
  ByteData _buf;
  int _offset = 0;

  SectionReader(Uint8List buf) : _buf = ByteData.sublistView(buf);

  // Factory constructor for easier instantiation
  factory SectionReader.from(Uint8List buf) {
    return SectionReader(buf);
  }

  // Read a single byte
  int readByte() {
    if (_offset >= _buf.lengthInBytes) {
      throw RangeError('End of buffer reached');
    }
    return _buf.getUint8(_offset++);
  }

  // Read u32 with LEB128 encoding (in Dart, we assume LEB128 decoding is done separately)
  int readU32() {
    // Assuming we already have an LEB128 decoder utility
    final result = decodeUleb128();
    if (result > 0xFFFFFFFF) {
      throw ArgumentError('u32 overflow');
    }
    return result;
  }

  // Read f32 (IEEE 754 floating-point number)
  double readF32() {
    if (_offset + 4 > _buf.lengthInBytes) {
      throw RangeError('Not enough data to read f32');
    }
    double value = _buf.getFloat32(_offset, Endian.little);
    _offset += 4;
    return value;
  }

  // Read f64 (IEEE 754 floating-point number)
  double readF64() {
    if (_offset + 8 > _buf.lengthInBytes) {
      throw RangeError('Not enough data to read f64');
    }
    double value = _buf.getFloat64(_offset, Endian.little);
    _offset += 8;
    return value;
  }

  // Read i32 with LEB128 encoding (assuming LEB128 decoder utility)
  int readI32() {
    // Assuming we have a signed LEB128 decoder utility
    return decodeSleb128();
  }

  // Read i64 with LEB128 encoding (assuming LEB128 decoder utility)
  int readI64() {
    return decodeSleb128();
  }

  // Read a sequence of bytes
  Uint8List readBytes(int num) {
    if (_offset + num > _buf.lengthInBytes) {
      throw RangeError('Not enough data to read $num bytes');
    }
    Uint8List bytes = _buf.buffer.asUint8List(_offset, num);
    _offset += num;
    return bytes;
  }

  // Read a string of the given length
  String readString(int size) {
    Uint8List bytes = readBytes(size);
    return utf8.decode(bytes);
  }

  // Check if the buffer has reached the end
  bool isEnd() {
    return _offset >= _buf.lengthInBytes;
  }

  /// Decodes an unsigned LEB128 integer from [ByteData] starting at [offset].
  int decodeUleb128() {
    int result = 0;
    int shift = 0;

    while (true) {
      if (_offset >= _buf.lengthInBytes) {
        throw Exception('End of ByteData while decoding ULEB128');
      }

      int byte = _buf.getUint8(_offset);
      _offset++;
      result |= (byte & 0x7F) << shift;

      if ((byte & 0x80) == 0) {
        return result;
      }

      shift += 7;
      if (shift > 35) {
        throw Exception('ULEB128 value is too large');
      }
    }
  }

  /// Decodes a signed LEB128 integer from [ByteData] starting at [offset].
  int decodeSleb128() {
    int result = 0;
    int shift = 0;

    while (true) {
      if (_offset >= _buf.lengthInBytes) {
        throw Exception('End of _ByteData while decoding SLEB128');
      }

      int byte = _buf.getUint8(_offset);
      _offset++;
      result |= (byte & 0x7F) << shift;

      shift += 7;

      if ((byte & 0x80) == 0) {
        // Handle sign extension
        if (shift < 32 && (byte & 0x40) != 0) {
          result |= -1 << shift;
        }
        return result;
      }

      if (shift > 63) {
        throw Exception('SLEB128 value is too large');
      }
    }
  }
}

// Base class for Section
abstract class Section {
  const Section();
}

// Custom section
class CustomSection extends Section {
  final String name; // Example property; adjust based on your requirements
  final Uint8List data;
  const CustomSection(this.name, this.data);

  static CustomSection decodeCustomSection(SectionReader reader) {
    final nameSize = reader.readU32();
    final name = reader.readString(nameSize);

    // Read remaining data based on current position
    final data = reader.readBytes(reader._buf.lengthInBytes - reader._offset);

    return CustomSection(name, data);
  }
}

// Section types as classes
class TypeSection extends Section {
  final List<FuncType> types;

  const TypeSection(this.types);

  static TypeSection decodeTypeSection(SectionReader reader) {
    final List<FuncType> funcTypes = [];
    final count = reader.readU32();

    for (int i = 0; i < count; i++) {
      final funcType = reader.readByte();
      if (0x60 != funcType) {
        throw Exception('Invalid function type: $funcType');
      }
      final FuncType func = FuncType(); // Create a new instance

      final size = reader.readU32();
      for (int j = 0; j < size; j++) {
        final valueType = reader.readByte(); // Convert appropriately
        func.params
            .add(ValueTypeFrom.from(valueType)); // Assume params is a list
      }

      final resultsSize = reader.readU32();
      for (int j = 0; j < resultsSize; j++) {
        final valueType = reader.readByte(); // Convert appropriately
        func.results
            .add(ValueTypeFrom.from(valueType)); // Assume results is a list
      }

      funcTypes.add(func);
    }
    return TypeSection(funcTypes);
  }
}

class ImportSection extends Section {
  final List<Import> imports;

  const ImportSection(this.imports);

  static ImportSection decodeImportSection(SectionReader reader) {
    final List<Import> imports = [];
    final count = reader.readU32();

    for (int i = 0; i < count; i++) {
      // Module name
      final moduleNameSize = reader.readU32();
      final module = reader.readString(moduleNameSize);

      // Field name
      final fieldNameSize = reader.readU32();
      final field = reader.readString(fieldNameSize);

      // Import kind
      final importKind = reader.readByte();
      ImportKind kind;

      switch (importKind) {
        case 0x00: // Function
          final typeIndex = reader.readU32();
          kind = ImportKind.func(typeIndex);
          break;
        case 0x01: // Table
          final table = decodeTable(reader);
          kind = ImportKind.table(table);
          break;
        case 0x02: // Memory
          final memory = decodeMemory(reader);
          kind = ImportKind.memory(memory);
          break;
        case 0x03: // Global
          final globalType = decodeGlobalType(reader);
          kind = ImportKind.global(globalType);
          break;
        default:
          throw Exception('Invalid import kind: $importKind');
      }

      imports.add(Import(module: module, field: field, kind: kind));
    }

    return ImportSection(imports);
  }
}

class FunctionSection extends Section {
  final List<int> functionIndices;

  const FunctionSection(this.functionIndices);

  static FunctionSection decodeFunctionSection(SectionReader reader) {
    final List<int> funcIdx = [];
    final count = reader.readU32();
    for (int i = 0; i < count; i++) {
      funcIdx.add(reader.readU32());
    }
    return FunctionSection(funcIdx);
  }
}

class TableSection extends Section {
  final List<Table> tables;

  const TableSection(this.tables);

  static TableSection decodeTableSection(SectionReader reader) {
    final count = reader.readU32();
    if (count != 1) {
      throw Exception('Invalid table count: $count');
    }
    final List<Table> tables = [];
    for (int i = 0; i < count; i++) {
      final table = decodeTable(reader);
      tables.add(table);
    }
    return TableSection(tables);
  }
}

Limits decodeLimits(SectionReader reader) {
  final limits = reader.readU32();
  final min = reader.readU32();
  final max = limits == 0x00 ? null : reader.readU32();
  return Limits(min: min, max: max);
}

Memory decodeMemory(SectionReader reader) {
  final limits = decodeLimits(reader);
  return Memory(limits: limits);
}

class MemorySection extends Section {
  final List<Memory> memories; // only 1 memory for now

  const MemorySection(this.memories);

  static MemorySection decodeMemorySection(SectionReader reader) {
    final count = reader.readU32();
    final List<Memory> mems = [];
    if (count != 1) {
      throw Exception('Invalid memory count: $count');
    }
    for (int i = 0; i < count; i++) {
      mems.add(decodeMemory(reader));
    }
    return MemorySection(mems);
  }
}

class GlobalSection extends Section {
  final List<Global> globals;

  const GlobalSection(this.globals);

  static GlobalSection decodeGlobalSection(SectionReader reader) {
    final count = reader.readU32();
    final List<Global> globals = [];
    for (int i = 0; i < count; i++) {
      final globalType = decodeGlobalType(reader);
      final initExpr = decodeExprValue(reader);
      final global = Global(globalType: globalType, initExpr: initExpr);
      globals.add(global);
    }
    return GlobalSection(globals);
  }
}

// Decoding functions
GlobalType decodeGlobalType(SectionReader reader) {
  final valueType = reader.readByte();
  final mutability = reader.readByte();
  final globalType = GlobalType(
    valueType: ValueType.values[valueType],
    mutability: Mutability.values[mutability],
  );
  return globalType;
}

ExprValue decodeExprValue(SectionReader reader) {
  final byte = reader.readByte();
  final op = instructions.OpcodeFrom.from(byte);

  ExprValue value;
  switch (op) {
    case instructions.Opcode.I32Const:
      final i32Value =
          reader.readI32(); // Assuming you have a method for reading i32
      value = ExprValue.i32(i32Value); // Create a concrete value for I32
      break;
    case instructions.Opcode.I64Const:
      final i64Value = reader.readI64(); // Replace with correct method for I64
      value = ExprValue.i64(i64Value); // Create a concrete value for I64
      break;
    case instructions.Opcode.F32Const:
      final f32Value = reader.readF32(); // Replace with correct method for F32
      value = ExprValue.f32(f32Value); // Create a concrete value for F32
      break;
    case instructions.Opcode.F64Const:
      final f64Value = reader.readF64(); // Replace with correct method for F64
      value = ExprValue.f64(f64Value); // Create a concrete value for F64
      break;
    default:
      throw Exception('Invalid initialization expression opcode: $byte');
  }

  final endByte = reader.readByte();
  if (endByte != instructions.Opcode.End) {
    throw Exception('Invalid initialization expression end opcode: $endByte');
  }
  return value;
}

Expr decodeExpr(SectionReader reader) {
  final byte = reader.readByte();
  final op = instructions.OpcodeFrom.from(byte);

  Expr value;
  switch (op) {
    case instructions.Opcode.I32Const:
      final i32Value = reader.readI32();
      value = Expr.value(ExprValue.i32(i32Value));
      break;
    case instructions.Opcode.I64Const:
      final i64Value = reader.readI64();
      value = Expr.value(ExprValue.i64(i64Value));
      break;
    case instructions.Opcode.F32Const:
      final f32Value = reader.readF32();
      value = Expr.value(ExprValue.f32(f32Value));
      break;
    case instructions.Opcode.F64Const:
      final f64Value = reader.readF64();
      value = Expr.value(ExprValue.f64(f64Value));
      break;
    case instructions.Opcode.GlobalGet:
      final globalIndex = reader.readU32();
      value = Expr.globalIndex(globalIndex);
      break;
    default:
      throw Exception('Invalid expression opcode: $byte');
  }

  final endByte = reader.readByte();
  if (endByte != instructions.Opcode.End) {
    throw Exception('Invalid expression end opcode: $endByte');
  }
  return value;
}

Table decodeTable(SectionReader reader) {
  final elemType = reader.readByte();
  if (elemType != 0x70) {
    throw Exception('Invalid element type: $elemType');
  }
  final limits = decodeLimits(reader);
  final table = Table(
    elemType: ElemTypeFrom.from(elemType), // Define conversion
    limits: limits,
  );
  return table;
}

class ExportSection extends Section {
  final List<Export> exports;

  const ExportSection(this.exports);

  static ExportSection decodeExportSection(SectionReader reader) {
    final count = reader.readU32();
    final List<Export> exports = [];
    for (int i = 0; i < count; i++) {
      final strLen = reader.readU32();
      final name = reader.readString(strLen);
      final exportKind = reader.readByte();
      final idx = reader.readU32();
      ExportDesc desc;

      switch (exportKind) {
        case 0x00:
          desc = FuncExport(idx);
          break;
        case 0x01:
          desc = TableExport(idx);
          break;
        case 0x02:
          desc = MemoryExport(idx);
          break;
        case 0x03:
          desc = GlobalExport(idx);
          break;
        default:
          throw Exception('Unknown export kind: $exportKind');
      }
      exports.add(Export(name: name, desc: desc));
    }
    return ExportSection(exports);
  }
}

class StartSection extends Section {
  final int startFunctionIndex;

  const StartSection(this.startFunctionIndex);

  static StartSection decodeStartSection(SectionReader reader) {
    final index = reader.readU32();
    return StartSection(index);
  }
}

class ElementSection extends Section {
  final List<Element> elements;

  const ElementSection(this.elements);

  static ElementSection decodeElementSection(SectionReader reader) {
    final List<Element> elements = [];
    final count = reader.readU32();

    for (int i = 0; i < count; i++) {
      final tableIndex = reader.readU32();
      final offset = decodeExpr(reader);
      final initCount = reader.readU32();
      final List<int> init = [];

      for (int j = 0; j < initCount; j++) {
        final index = reader.readU32();
        init.add(index);
      }

      elements.add(Element(tableIndex: tableIndex, offset: offset, init: init));
    }

    return ElementSection(elements);
  }
}

class DataSection extends Section {
  final List<Data> data;

  const DataSection(this.data);

  static DataSection decodeDataSection(SectionReader reader) {
    final List<Data> data = [];
    final count = reader.readU32();

    for (int i = 0; i < count; i++) {
      final memoryIndex = reader.readU32();
      final offset = decodeExpr(reader);
      final size = reader.readU32();
      final init = reader.readBytes(size);
      data.add(Data(memoryIndex: memoryIndex, offset: offset, init: init));
    }

    return DataSection(data);
  }
}

class CodeSection extends Section {
  final List<FunctionBody> functionBodies;

  const CodeSection(this.functionBodies);

  static CodeSection decodeCodeSection(SectionReader reader) {
    final List<FunctionBody> functions = [];
    final count = reader.readU32();

    for (int i = 0; i < count; i++) {
      final funcBodySize = reader.readU32();
      final bytes = reader.readBytes(funcBodySize);
      final body = SectionReader(Uint8List.fromList(bytes));
      functions.add(decodeFunctionBody(body));
    }
    return CodeSection(functions);
  }
}

FunctionBody decodeFunctionBody(SectionReader reader) {
  final functionBody = FunctionBody();

  // Count of local variable declarations
  final count = reader.readU32();
  for (int i = 0; i < count; i++) {
    final typeCount = reader.readU32();
    final valueType = ValueTypeFrom.from(
        reader.readByte()); // Assuming valueType can be directly instantiated
    functionBody.locals.add(FunctionLocal(typeCount, valueType));
  }

  while (!reader.isEnd()) {
    final inst = decodeInstruction(reader);
    functionBody.code.add(inst);
  }

  return functionBody;
}

BlockType decodeBlockType(SectionReader reader) {
  final byte = reader.readByte();
  if (byte == 0x40) {
    return const BlockType.empty();
  } else {
    final valueType = ValueTypeFrom.from(byte); // Convert byte to ValueType
    return BlockType.value([valueType]);
  }
}

Block decodeBlock(SectionReader reader) {
  final blockType = decodeBlockType(reader);
  return Block(blockType);
}

Future<instructions.Instruction> decodeInstruction(SectionReader reader) async {
  final byte = reader.readByte();
  final opcode = instructions.OpcodeFrom.from(byte);

  switch (opcode) {
    case instructions.Opcode.Unreachable:
      return const instructions.Unreachable();
    case instructions.Opcode.Nop:
      return const instructions
          .Nop(); // Assuming Instruction classes are instantiated like this
    case instructions.Opcode.Block:
      final block = await decodeBlock(reader);
      return instructions.BlockInstruction(block);
    case instructions.Opcode.Loop:
      final block = await decodeBlock(reader);
      return instructions.LoopInstruction(block);
    case instructions.Opcode.If:
      final block = await decodeBlock(reader);
      return instructions.IfInstruction(
          block); // Adjust according to your Instruction type for `Block`
    case instructions.Opcode.Else:
      return const instructions.ElseInstruction();
    case instructions.Opcode.End:
      return const instructions.EndInstruction();
    case instructions.Opcode.Br:
      final index = reader.readU32();
      return instructions.BrInstruction(index);
    case instructions.Opcode.BrTable:
      int count = reader.readU32();
      List<int> indexes = List.filled(count, 0);
      for (int i = 0; i < count; i++) {
        int index = reader.readU32();
        indexes[i] = index;
      }
      int defaultValue = reader.readU32();
      return instructions.BrTableInstruction(indexes, defaultValue);
    case instructions.Opcode.BrIf:
      final index = reader.readU32();
      return instructions.BrIfInstruction(
          index); // Adjust based on your actual Instruction class
    case instructions.Opcode.Call:
      final localIdx = reader.readU32();
      return instructions.CallInstruction(localIdx);
    case instructions.Opcode.CallIndirect:
      return instructions.CallIndirectInstruction(
          reader.readU32(), reader.readU32());
    case instructions.Opcode.Return:
      return const instructions.ReturnInstruction();
    case instructions.Opcode.LocalGet:
      final localIdx = reader.readU32();
      return instructions.LocalGetInstruction(localIdx);
    case instructions.Opcode.LocalSet:
      return instructions.LocalSetInstruction(reader.readU32());
    case instructions.Opcode.LocalTee:
      return instructions.LocalTeeInstruction(reader.readU32());
    case instructions.Opcode.GlobalSet:
      return instructions.GlobalSetInstruction(reader.readU32());
    case instructions.Opcode.GlobalGet:
      return instructions.GlobalGetInstruction(reader.readU32());
    case instructions.Opcode.I32Sub:
      return const instructions.I32SubInstruction();
    case instructions.Opcode.I32Add:
      return const instructions.I32AddInstruction();
    case instructions.Opcode.I32Mul:
      return const instructions.I32MulInstruction();
    case instructions.Opcode.I32Clz:
      return const instructions.I32ClzInstruction();
    case instructions.Opcode.I32Ctz:
      return const instructions.I32CtzInstruction();
    case instructions.Opcode.I32DivU:
      return const instructions.I32DivUInstruction();
    case instructions.Opcode.I32DivS:
      return const instructions.I32DivSInstruction();
    case instructions.Opcode.I32Eq:
      return const instructions.I32EqInstruction();
    case instructions.Opcode.I32Eq:
      return const instructions.I32EqInstruction();
    case instructions.Opcode.I32Eqz:
      return const instructions.I32EqzInstruction();
    case instructions.Opcode.I32Ne:
      return const instructions.I32NeInstruction();
    case instructions.Opcode.I32LtS:
      return const instructions.I32LtSInstruction();
    case instructions.Opcode.I32LtU:
      return const instructions.I32LtUInstruction();
    case instructions.Opcode.I32GtS:
      return const instructions.I32GtUInstruction();
    case instructions.Opcode.I32LeS:
      return const instructions.I32LeSInstruction();
    case instructions.Opcode.I32LeU:
      return const instructions.I32LeUInstruction();
    case instructions.Opcode.I32GeS:
      return const instructions.I32GeSInstruction();
    case instructions.Opcode.I32GeU:
      return const instructions.I32GeUInstruction();
    case instructions.Opcode.I32Popcnt:
      return const instructions.I32PopcntInstruction();
    case instructions.Opcode.I32RemS:
      return const instructions.I32RemSInstruction();
    case instructions.Opcode.I32RemU:
      return const instructions.I32RemUInstruction();
    case instructions.Opcode.I32And:
      return const instructions.I32AndInstruction();
    case instructions.Opcode.I32Or:
      return const instructions.I32OrInstruction();
    case instructions.Opcode.I32Xor:
      return const instructions.I32XorInstruction();
    case instructions.Opcode.I32ShL:
      return const instructions.I32ShLInstruction();
    case instructions.Opcode.I32ShrS:
      return const instructions.I32ShrSInstruction();
    case instructions.Opcode.I32ShrU:
      return const instructions.I32ShrUInstruction();
    case instructions.Opcode.I32RtoL:
      return const instructions.I32RotlInstruction();
    case instructions.Opcode.I32RtoR:
      return const instructions.I32RotrInstruction();
    case instructions.Opcode.I32Extend8S:
      return const instructions.I32Extend8SInstruction();
    case instructions.Opcode.I32Extend16S:
      return const instructions.I32Extend16SInstruction();
    case instructions.Opcode.I32Const:
      return instructions.I32ConstInstruction(reader.readI32());
    case instructions.Opcode.I64Sub:
      return const instructions.I64SubInstruction();
    case instructions.Opcode.I64Add:
      return const instructions.I64AddInstruction();
    case instructions.Opcode.I64Mul:
      return const instructions.I64MulInstruction();
    case instructions.Opcode.I64Clz:
      return const instructions.I64ClzInstruction();
    case instructions.Opcode.I64Ctz:
      return const instructions.I64CtzInstruction();
    case instructions.Opcode.I64DivU:
      return const instructions.I64DivUInstruction();
    case instructions.Opcode.I64DivS:
      return const instructions.I64DivSInstruction();
    case instructions.Opcode.I64Eq:
      return const instructions.I64EqInstruction();
    case instructions.Opcode.I64Eq:
      return const instructions.I64EqInstruction();
    case instructions.Opcode.I64Eqz:
      return const instructions.I64EqzInstruction();
    case instructions.Opcode.I64Ne:
      return const instructions.I64NeInstruction();
    case instructions.Opcode.I64LtS:
      return const instructions.I64LtSInstruction();
    case instructions.Opcode.I64LtU:
      return const instructions.I64LtUInstruction();
    case instructions.Opcode.I64GtS:
      return const instructions.I64GtUInstruction();
    case instructions.Opcode.I64LeS:
      return const instructions.I64LeSInstruction();
    case instructions.Opcode.I64LeU:
      return const instructions.I64LeUInstruction();
    case instructions.Opcode.I64GeS:
      return const instructions.I64GeSInstruction();
    case instructions.Opcode.I64GeU:
      return const instructions.I64GeUInstruction();
    case instructions.Opcode.I64Popcnt:
      return const instructions.I64PopcntInstruction();
    case instructions.Opcode.I64RemS:
      return const instructions.I64RemSInstruction();
    case instructions.Opcode.I64RemU:
      return const instructions.I64RemUInstruction();
    case instructions.Opcode.I64And:
      return const instructions.I64AndInstruction();
    case instructions.Opcode.I64Or:
      return const instructions.I64OrInstruction();
    case instructions.Opcode.I64Xor:
      return const instructions.I64XorInstruction();
    case instructions.Opcode.I64ShL:
      return const instructions.I64ShLInstruction();
    case instructions.Opcode.I64ShrS:
      return const instructions.I64ShrSInstruction();
    case instructions.Opcode.I64ShrU:
      return const instructions.I64ShrUInstruction();
    case instructions.Opcode.I64RtoL:
      return const instructions.I64RotlInstruction();
    case instructions.Opcode.I64RtoR:
      return const instructions.I64RotrInstruction();
    case instructions.Opcode.I64Extend8S:
      return const instructions.I64Extend8SInstruction();
    case instructions.Opcode.I64Extend16S:
      return const instructions.I64Extend16SInstruction();
    case instructions.Opcode.I64Const:
      return instructions.I64ConstInstruction(reader.readI32());
    case instructions.Opcode.F32Const:
      return instructions.F32ConstInstruction(reader.readF32());
    case instructions.Opcode.F32Eq:
      return const instructions.F32EqInstruction();
    case instructions.Opcode.F32Ne:
      return const instructions.F32NeInstruction();
    case instructions.Opcode.F32Lt:
      return const instructions.F32LtInstruction();
    case instructions.Opcode.F32Gt:
      return const instructions.F32GtInstruction();
    case instructions.Opcode.F32Le:
      return const instructions.F32LeInstruction();
    case instructions.Opcode.F32Abs:
      return const instructions.F32AbsInstruction();
    case instructions.Opcode.F32Ge:
      return const instructions.F32GeInstruction();
    case instructions.Opcode.F32Neg:
      return const instructions.F32NegInstruction();
    case instructions.Opcode.F32Ceil:
      return const instructions.F32CeilInstruction();
    case instructions.Opcode.F32Floor:
      return const instructions.F32FloorInstruction();
    case instructions.Opcode.F32Trunc:
      return const instructions.F32TruncInstruction();
    case instructions.Opcode.F32Nearest:
      return const instructions.F32NearestInstruction();
    case instructions.Opcode.F32Sqrt:
      return const instructions.F32SqrtInstruction();
    case instructions.Opcode.F32Add:
      return const instructions.F32AddInstruction();
    case instructions.Opcode.F32Sub:
      return const instructions.F32SubInstruction();
    case instructions.Opcode.F32Mul:
      return const instructions.F32MulInstruction();
    case instructions.Opcode.F32Div:
      return const instructions.F32DivInstruction();
    case instructions.Opcode.F32Min:
      return const instructions.F32MinInstruction();
    case instructions.Opcode.F32Max:
      return const instructions.F32MaxInstruction();
    case instructions.Opcode.F32Copysign:
      return const instructions.F32CopysignInstruction();
    case instructions.Opcode.I32WrapI64:
      return const instructions.I32WrapI64Instruction();
    case instructions.Opcode.F64Sqrt:
      return const instructions.F64SqrtInstruction();
    case instructions.Opcode.F64Eq:
      return const instructions.F64EqInstruction();
    case instructions.Opcode.F64Ne:
      return const instructions.F64NeInstruction();
    case instructions.Opcode.F64Lt:
      return const instructions.F64LtInstruction();
    case instructions.Opcode.F64Gt:
      return const instructions.F64GtInstruction();
    case instructions.Opcode.F64Le:
      return const instructions.F64LeInstruction();
    case instructions.Opcode.F64Abs:
      return const instructions.F64AbsInstruction();
    case instructions.Opcode.F64Ge:
      return const instructions.F64GeInstruction();
    case instructions.Opcode.F64Neg:
      return const instructions.F64NegInstruction();
    case instructions.Opcode.F64Ceil:
      return const instructions.F64CeilInstruction();
    case instructions.Opcode.F64Floor:
      return const instructions.F64FloorInstruction();
    case instructions.Opcode.F64Trunc:
      return const instructions.F64TruncInstruction();
    case instructions.Opcode.F64Nearest:
      return const instructions.F64NearestInstruction();
    case instructions.Opcode.F64Sqrt:
      return const instructions.F64SqrtInstruction();
    case instructions.Opcode.F64Add:
      return const instructions.F64AddInstruction();
    case instructions.Opcode.F64Sub:
      return const instructions.F64SubInstruction();
    case instructions.Opcode.F64Mul:
      return const instructions.F64MulInstruction();
    case instructions.Opcode.F64Div:
      return const instructions.F64DivInstruction();
    case instructions.Opcode.F64Min:
      return const instructions.F64MinInstruction();
    case instructions.Opcode.F64Max:
      return const instructions.F64MaxInstruction();
    case instructions.Opcode.F64Copysign:
      return const instructions.F64CopysignInstruction();
    case instructions.Opcode.F64Const:
      return instructions.F64ConstInstruction(reader.readF64());
    case instructions.Opcode.Drop:
      return const instructions.DropInstruction();
    case instructions.Opcode.I32Load:
      return instructions.I32LoadInstruction(ReadMemoryArg(reader));
    case instructions.Opcode.I64Load:
      return instructions.I64LoadInstruction(ReadMemoryArg(reader));
    case instructions.Opcode.F32Load:
      return instructions.F32LoadInstruction(ReadMemoryArg(reader));
    case instructions.Opcode.F64Load:
      return instructions.F64LoadInstruction(ReadMemoryArg(reader));
    case instructions.Opcode.I32Load8S:
      return instructions.I32Load8SInstruction(ReadMemoryArg(reader));
    case instructions.Opcode.I32Load8U:
      return instructions.I32Load8UInstruction(ReadMemoryArg(reader));
    case instructions.Opcode.I32Load16S:
      return instructions.I32Load16SInstruction(ReadMemoryArg(reader));
    case instructions.Opcode.I32Load16U:
      return instructions.I32Load16UInstruction(ReadMemoryArg(reader));
    case instructions.Opcode.I64Load8S:
      return instructions.I64Load8SInstruction(ReadMemoryArg(reader));
    case instructions.Opcode.I64Load8U:
      return instructions.I64Load8UInstruction(ReadMemoryArg(reader));
    case instructions.Opcode.I64Load16S:
      return instructions.I64Load16SInstruction(ReadMemoryArg(reader));
    case instructions.Opcode.I64Load16U:
      return instructions.I64Load16UInstruction(ReadMemoryArg(reader));
    case instructions.Opcode.I64Load32S:
      return instructions.I64Load32SInstruction(ReadMemoryArg(reader));
    case instructions.Opcode.I64Load32U:
      return instructions.I64Load32UInstruction(ReadMemoryArg(reader));
    case instructions.Opcode.I32Store:
      return instructions.I32StoreInstruction(ReadMemoryArg(reader));
    case instructions.Opcode.I64Store:
      return instructions.I64StoreInstruction(ReadMemoryArg(reader));
    case instructions.Opcode.F32Store:
      return instructions.F32StoreInstruction(ReadMemoryArg(reader));
    case instructions.Opcode.F64Store:
      return instructions.F64StoreInstruction(ReadMemoryArg(reader));
    case instructions.Opcode.I32Store8:
      return instructions.I32Store8Instruction(ReadMemoryArg(reader));
    case instructions.Opcode.I32Store16:
      return instructions.I32Store16Instruction(ReadMemoryArg(reader));
    case instructions.Opcode.I64Store8:
      return instructions.I64Store8Instruction(ReadMemoryArg(reader));
    case instructions.Opcode.I64Store16:
      return instructions.I64Store16Instruction(ReadMemoryArg(reader));
    case instructions.Opcode.I64Store32:
      return instructions.I64Store32Instruction(ReadMemoryArg(reader));
    case instructions.Opcode.MemoryGrow:
      return instructions.MemoryGrowInstruction(reader.readU32());
    case instructions.Opcode.MemorySize:
      final _ = reader.readByte();
      return const instructions.MemorySizeInstruction();
    // TODO: improve instruction decoding because opecode maybe tow bytes in the version 2
    // this instruction is defined in the version2 of the spec
    case instructions.Opcode.MmeoryCopyOrFill:
      switch (reader.readByte()) {
        case 0x0A:
          return instructions.MemoryCopyInstruction(
              reader.readU32(), reader.readU32());
        case 0x0B:
          return instructions.MemoryFillInstruction(reader.readU32());
      }
    case instructions.Opcode.Select:
      return const instructions.SelectInstruction();
    case instructions.Opcode.I32TruncF32S:
      return const instructions.I32TruncF32SInstruction();
    case instructions.Opcode.I32TruncF32U:
      return const instructions.I32TruncF32UInstruction();
    case instructions.Opcode.I32TruncF64S:
      return const instructions.I32TruncF64SInstruction();
    case instructions.Opcode.I32TruncF64U:
      return const instructions.I32TruncF64UInstruction();
    case instructions.Opcode.I64ExtendI32S:
      return const instructions.I64ExtendI32SInstruction();
    case instructions.Opcode.I64ExtendI32U:
      return const instructions.I64ExtendI32UInstruction();
    case instructions.Opcode.I64TruncF32S:
      return const instructions.I64TruncF32SInstruction();
    case instructions.Opcode.I64TruncF32U:
      return const instructions.I64TruncF32UInstruction();
    case instructions.Opcode.I64TruncF64S:
      return const instructions.I64TruncF64SInstruction();
    case instructions.Opcode.I64TruncF64U:
      return const instructions.I64TruncF64UInstruction();
    case instructions.Opcode.F32ConvertI32S:
      return const instructions.F32ConvertI32SInstruction();
    case instructions.Opcode.F32ConvertI32U:
      return const instructions.F32ConvertI32UInstruction();
    case instructions.Opcode.F32ConvertI64S:
      return const instructions.F32ConvertI64SInstruction();
    case instructions.Opcode.F32ConvertI64U:
      return const instructions.F32ConvertI64UInstruction();
    case instructions.Opcode.F32DemoteF64:
      return const instructions.F32DemoteF64Instruction();
    case instructions.Opcode.F64ConvertI32S:
      return const instructions.F64ConvertI32SInstruction();
    case instructions.Opcode.F64ConvertI32U:
      return const instructions.F64ConvertI32UInstruction();
    case instructions.Opcode.F64ConvertI64S:
      return const instructions.F64ConvertI64SInstruction();
    case instructions.Opcode.F64ConvertI64U:
      return const instructions.F64ConvertI64UInstruction();
    case instructions.Opcode.F64PromoteF32:
      return const instructions.F64PromoteF32Instruction();
    case instructions.Opcode.I32ReinterpretF32:
      return const instructions.I32ReinterpretF32Instruction();
    case instructions.Opcode.I64ReinterpretF64:
      return const instructions.I64ReinterpretF64Instruction();
    case instructions.Opcode.F32ReinterpretI32:
      return const instructions.F32ReinterpretI32Instruction();
    case instructions.Opcode.F64ReinterpretI64:
      return const instructions.F64ReinterpretI64Instruction();

    default:
      throw Exception("Invalid Opcode: $opcode");
  }

  throw Exception("Cannot Decode Exception");
}

Section Decode(SectionID id, Uint8List data) {
  final reader = SectionReader(data);

  switch (id) {
    case SectionID.Custom:
      return CustomSection.decodeCustomSection(reader);
    case SectionID.Type:
      return TypeSection.decodeTypeSection(reader);
    case SectionID.Import:
      return ImportSection.decodeImportSection(reader);
    case SectionID.Function:
      return FunctionSection.decodeFunctionSection(reader);
    case SectionID.Table:
      return TableSection.decodeTableSection(reader);
    case SectionID.Memory:
      return MemorySection.decodeMemorySection(reader);
    case SectionID.Global:
      return GlobalSection.decodeGlobalSection(reader);
    case SectionID.Export:
      return ExportSection.decodeExportSection(reader);
    case SectionID.Code:
      return CodeSection.decodeCodeSection(reader);
    case SectionID.Element:
      return ElementSection.decodeElementSection(reader);
    case SectionID.Data:
      return DataSection.decodeDataSection(reader);
    case SectionID.Start:
      return StartSection.decodeStartSection(reader);
  }
}

MemoryArg ReadMemoryArg(SectionReader reader) {
  final arg = MemoryArg(align: reader.readU32(), offset: reader.readU32());
  return arg;
}

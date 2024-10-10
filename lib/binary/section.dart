import 'dart:typed_data';
import 'dart:convert';

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

  // Placeholder for LEB128 decoding methods
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

  Section decodeImportSection(SectionReader reader) {
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
  final op = Opcode.fromU8(byte);

  ExprValue value;
  switch (op) {
    case Opcode.I32Const:
      final i32Value =
          reader.readI32(); // Assuming you have a method for reading i32
      value = ExprValue.i32(i32Value); // Create a concrete value for I32
      break;
    case Opcode.I64Const:
      final i64Value = reader.readI64(); // Replace with correct method for I64
      value = ExprValue.i64(i64Value); // Create a concrete value for I64
      break;
    case Opcode.F32Const:
      final f32Value = reader.readF32(); // Replace with correct method for F32
      value = ExprValue.f32(f32Value); // Create a concrete value for F32
      break;
    case Opcode.F64Const:
      final f64Value = reader.readF64(); // Replace with correct method for F64
      value = ExprValue.f64(f64Value); // Create a concrete value for F64
      break;
    default:
      throw Exception('Invalid initialization expression opcode: $byte');
  }

  final endByte = reader.byte();
  if (endByte != Opcode.End) {
    throw Exception('Invalid initialization expression end opcode: $endByte');
  }
  return value;
}

Expr decodeExpr(SectionReader reader) {
  final byte = reader.readByte();
  final op = Opcode.fromU8(byte);

  Expr value;
  switch (op) {
    case Opcode.I32Const:
      final i32Value = reader.readI32();
      value = Expr.value(ExprValue.i32(i32Value));
      break;
    case Opcode.I64Const:
      final i64Value = reader.readI64();
      value = Expr.value(ExprValue.i64(i64Value));
      break;
    case Opcode.F32Const:
      final f32Value = reader.readF32();
      value = Expr.value(ExprValue.f32(f32Value));
      break;
    case Opcode.F64Const:
      final f64Value = reader.readF64();
      value = Expr.value(ExprValue.f64(f64Value));
      break;
    case Opcode.GlobalGet:
      final globalIndex = reader.readU32();
      value = Expr.globalIndex(globalIndex);
      break;
    default:
      throw Exception('Invalid expression opcode: $byte');
  }

  final endByte = reader.readByte();
  if (endByte != Opcode.End) {
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
    elemType: ElemType.fromU8(elemType), // Define conversion
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
    return BlockType.empty();
  } else {
    final valueType = ValueTypeFrom.from(byte); // Convert byte to ValueType
    return BlockType.value([valueType]);
  }
}

Block decodeBlock(SectionReader reader) {
  final blockType = decodeBlockType(reader);
  return Block(blockType);
}

Future<Instruction> decodeInstruction(SectionReader reader) async {
  final byte = reader.byte();
  final opcode = decodeOpcode(byte);

  switch (opcode) {
    case Opcode.Unreachable:
      return Instruction(); // Assuming Instruction classes are instantiated like this
    case Opcode.Block:
      final block = await decodeBlock(reader);
      return Instruction(); // Adjust according to your Instruction type for `Block`
    case Opcode.Br:
      final index = reader.u32();
      return Instruction(); // Adjust based on your actual Instruction class
    case Opcode.Call:
      final localIdx = reader.u32();
      return Instruction(); // Adjust based on Call instruction
    case Opcode.I32Const:
      final value = reader.i32();
      return Instruction(); // Adjust based on I32Const instruction
    // Handle all other cases similarly
    default:
      throw Exception("Invalid Opcode: $opcode");
  }
}

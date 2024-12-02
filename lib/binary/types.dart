// https://webassembly.github.io/spec/core/binary/types.html#value-types
enum ValueType {
  I32, // 0x7F
  I64, // 0x7E
  F32, // 0x7D
  F64, // 0x7C
}

extension ValueTypeFrom on ValueType {
  static ValueType from(int valueType) {
    switch (valueType) {
      case 0x7F:
        return ValueType.I32;
      case 0x7E:
        return ValueType.I64;
      case 0x7D:
        return ValueType.F32;
      case 0x7C:
        return ValueType.F64;
      default:
        throw ArgumentError(
            'Invalid value type: ${valueType.toRadixString(16)}');
    }
  }
}

// https://webassembly.github.io/spec/core/binary/types.html#function-types
class FuncType {
  List<ValueType> params;
  List<ValueType> results;

  FuncType({List<ValueType>? params, List<ValueType>? results})
      : params = params ?? [],
        results = results ?? [];
}

// https://webassembly.github.io/spec/core/binary/modules.html#binary-codesec
class FunctionLocal {
  int typeCount;
  ValueType valueType;

  FunctionLocal(this.typeCount, this.valueType);
}

// Class for FunctionBody
class FunctionBody {
  List<FunctionLocal> locals;
  List<dynamic> code; // Placeholder for Instruction type

  FunctionBody({List<FunctionLocal>? locals, List<dynamic>? code})
      : locals = locals ?? [],
        code = code ?? [];
}

// Enum for ExportDesc
abstract class ExportDesc {
  const ExportDesc();
}

class FuncExport extends ExportDesc {
  final int value;

  FuncExport(this.value);
}

class TableExport extends ExportDesc {
  final int value;

  TableExport(this.value);
}

class MemoryExport extends ExportDesc {
  final int value;

  MemoryExport(this.value);
}

class GlobalExport extends ExportDesc {
  final int value;

  GlobalExport(this.value);
}

// Class for Export
class Export {
  String name;
  ExportDesc desc;

  Export({required this.name, required this.desc});
}

// Enum for ElemType
enum ElemType {
  FuncRef(0x70);

  final int value;
  const ElemType(this.value);
}

extension ElemTypeFrom on int {
  static ElemType from(int elemType) {
    switch (elemType) {
      case 0x70:
        return ElemType.FuncRef;
      default:
        throw ArgumentError('uknown elem type: ${elemType.toRadixString(16)}');
    }
  }
}

// Class for Table
class Table {
  ElemType elemType;
  Limits limits;

  Table({required this.elemType, required this.limits});
}

// Class for Memory
class Memory {
  Limits limits;

  Memory({required this.limits});
}

// Class for Limits
class Limits {
  int min;
  int? max;

  Limits({required this.min, this.max});
}

// Enum for Mutability
enum Mutability {
  Const(0x00),
  Var(0x01);

  final int value;
  const Mutability(this.value);
}

// Class for GlobalType
class GlobalType {
  ValueType valueType;
  Mutability mutability;

  GlobalType({required this.valueType, required this.mutability});
}

abstract class ExprValue {
  const ExprValue();

  const factory ExprValue.i32(int value) = I32Value;
  const factory ExprValue.i64(int value) = I64Value;
  const factory ExprValue.f32(double value) = F32Value;
  const factory ExprValue.f64(double value) = F64Value;
}

class I32Value extends ExprValue {
  final int value;
  const I32Value(this.value);
}

class I64Value extends ExprValue {
  final int value;
  const I64Value(this.value);
}

class F32Value extends ExprValue {
  final double value;
  const F32Value(this.value);
}

class F64Value extends ExprValue {
  final double value;
  const F64Value(this.value);
}

// Class for Expr
class Expr {
  ExprValue? value;
  int? globalIndex;

  Expr.value(this.value);
  Expr.globalIndex(this.globalIndex);
}

// Class for Global
class Global {
  GlobalType globalType;
  ExprValue initExpr;

  Global({required this.globalType, required this.initExpr});
}

// Enum for ImportKind
abstract class ImportKind {
  const ImportKind();

  const factory ImportKind.func(int value) = Func;
  const factory ImportKind.table(Table table) = TableKind;
  const factory ImportKind.memory(Memory memory) = MemoryKind;
  const factory ImportKind.global(GlobalType globalType) = GlobalKind;
}

class Func extends ImportKind {
  final int value;
  const Func(this.value);
}

class TableKind extends ImportKind {
  final Table table;
  const TableKind(this.table);
}

class MemoryKind extends ImportKind {
  final Memory memory;
  const MemoryKind(this.memory);
}

class GlobalKind extends ImportKind {
  final GlobalType globalType;
  const GlobalKind(this.globalType);
}

// Class for Import
class Import {
  String module;
  String field;
  ImportKind kind;

  Import({required this.module, required this.field, required this.kind});
}

// Class for Element
class Element {
  int tableIndex;
  Expr offset;
  List<int> init;

  Element({required this.tableIndex, required this.offset, required this.init});
}

// Class for Data
class Data {
  int memoryIndex;
  Expr offset;
  List<int> init;

  Data({required this.memoryIndex, required this.offset, required this.init});
}

// Class for Custom
class Custom {
  String name;
  List<int> data;

  Custom({required this.name, required this.data});
}

abstract class BlockType {
  const BlockType();

  const factory BlockType.empty() = EmptyBlockType;
  const factory BlockType.value(List<ValueType> values) = ValueBlockType;
}

class EmptyBlockType extends BlockType {
  const EmptyBlockType();
}

class ValueBlockType extends BlockType {
  final List<ValueType> values;
  const ValueBlockType(this.values);

  int resultCount() {
    return values.length;
  }
}

// Class for Block
class Block {
  BlockType blockType;

  Block(this.blockType);
}

// error.dart
class Error implements Exception {
  final String message;
  Error(this.message);

  @override
  String toString() => 'Error: $message';
}

class InvalidMemoryCountError extends Error {
  InvalidMemoryCountError() : super('invalid count of memory, must be 1');
}

class InvalidTableCountError extends Error {
  InvalidTableCountError() : super('invalid count of table, must be 1');
}

class InvalidElmTypeError extends Error {
  final int value;
  InvalidElmTypeError(this.value)
      : super('invalid elemtype of table, must be funcref, got $value');
}

class InvalidInitExprOpcodeError extends Error {
  final int opcode;
  InvalidInitExprOpcodeError(this.opcode)
      : super('invalid init expr instruction in expressions, got $opcode');
}

class InvalidInitExprEndOpcodeError extends Error {
  final int opcode;
  InvalidInitExprEndOpcodeError(this.opcode)
      : super('invalid end instruction in expressions, got $opcode');
}

class InvalidImportKindError extends Error {
  final int kind;
  InvalidImportKindError(this.kind)
      : super('invalid import kind at import section, got $kind');
}

class InvalidOpcodeError extends Error {
  final int opcode;
  InvalidOpcodeError(this.opcode)
      : super('invalid opcode: ${opcode.toRadixString(16)}');
}

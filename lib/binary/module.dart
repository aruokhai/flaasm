import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flaasm/binary/section.dart';
import 'package:flaasm/binary/types.dart';

class Module {
  String magic;
  int version;
  Custom? customSection;
  List<FuncType>? typeSection;
  List<Import>? importSection;
  List<int>? functionSection;
  List<Table>? tableSection;
  List<Memory>? memorySection;
  List<Global>? globalSection;
  List<Export>? exportSection;
  int? startSection;
  List<Element>? elementSection;
  List<Data>? dataSection;
  List<FunctionBody>? codeSection;

  Module({
    required this.magic,
    required this.version,
    this.customSection,
    this.typeSection,
    this.importSection,
    this.functionSection,
    this.tableSection,
    this.memorySection,
    this.globalSection,
    this.exportSection,
    this.startSection,
    this.elementSection,
    this.dataSection,
    this.codeSection,
  });

  void addSection(Section section) {
    switch (section.runtimeType) {
      case Custom:
        customSection = section as Custom;
        break;
      case TypeSection:
        typeSection = section as List<FuncType>;
        break;
      case ImportSection:
        importSection = section as List<Import>;
        break;
      case FunctionSection:
        functionSection = section as List<int>;
        break;
      case TableSection:
        tableSection = section as List<Table>;
        break;
      case MemorySection:
        memorySection = section as List<Memory>;
        break;
      case GlobalSection:
        globalSection = section as List<Global>;
        break;
      case ExportSection:
        exportSection = section as List<Export>;
        break;
      case CodeSection:
        codeSection = section as List<FunctionBody>;
        break;
      case ElementSection:
        elementSection = section as List<Element>;
        break;
      case DataSection:
        dataSection = section as List<Data>;
        break;
      case StartSection:
        startSection = section as int;
        break;
    }
  }
}

class Decoder {
  final RandomAccessFile reader;

  Decoder(this.reader);

  Future<bool> isEnd() async {
    return await reader.position() < await reader.length();
  }

  Future<int> byte() async {
    return (await reader.readByte()) & 0xff;
  }

  Future<Uint8List> bytes(int num) async {
    return await reader.read(num);
  }

  Future<int> decodeToU32() async {
    Uint8List data = await bytes(4);
    return ByteData.sublistView(data).getUint32(0, Endian.little);
  }

  Future<String> decodeToString(int num) async {
    Uint8List data = await bytes(num);
    return utf8.decode(data);
  }

  Future<int> u32() async {
    // Assuming LE format for u32 decoding
    int result = 0;
    int shift = 0;
    int byte;
    do {
      byte = await this.byte();
      result |= (byte & 0x7F) << shift;
      shift += 7;
    } while ((byte & 0x80) != 0);
    return result;
  }

  Future<Map<String, dynamic>> decodeSectionHeader() async {
    int id = await byte();
    int size = await u32();
    return {'id': id, 'size': size};
  }

  Future<Map<String, dynamic>> decodeHeader() async {
    String magic = await decodeToString(4);
    if (magic != '\u0000asm') {
      throw Exception('Invalid binary magic');
    }

    int version = await decodeToU32();
    if (version != 1) {
      throw Exception('Invalid binary version');
    }

    return {'magic': magic, 'version': version};
  }

  Future<Module> decode() async {
    var header = await decodeHeader();
    Module module = Module(magic: header['magic'], version: header['version']);

    while (await isEnd()) {
      var sectionHeader = await decodeSectionHeader();
      Uint8List sectionBytes = await bytes(sectionHeader['size']);
      Section section = Decode(sectionHeader['id'], sectionBytes);
      module.addSection(section);
    }
    return module;
  }
}

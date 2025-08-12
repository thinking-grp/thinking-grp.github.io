# Vermay関連仕様

## YAML-compatible YAML-frontmatter Markdown

article.md

```md
---
# [required] title
title: article title
# [optional] categories: allows file-able chars and slash; if omitted, be handled as in root
cats:
  - category
  - category
# [optional] access clearance: all/member/executive(abbr: exec)/representative(abbr: repr); default value is all
access: all
# [optional] edit clearance: all(equals member)/member/executive(abbr: exec)/representative(abbr: repr); 
default value is all
editable: exec
# [required] author or authors
author: author name <example.email@example.org>
# or
authors:
  - author name <example.email@example.org>
# [required] hash-id of this version
version: hash-id
# [required] created datetime of first version
createdAt: datetime
# [required] updated datetime of this version
thisVerAt: datetime
# [optional] updated datetime of latest version; if omitted, be handled as same with this version
latestAt: datetime
---
|+
## section title

paragraphs
```

## 使用ハッシュ関数類

### checksum

- barrel: Adler32(`Adler32.buf(bytes)`, from `pkg:adler32/adler32.dart`)
- version: CRC32-C(`Crc32C().convert(bytes).toBytes(4)`, from `pkg:crclib/catalog.dart`)

### hash-id

- file: top 8 bytes of Keccak256 (`Uint8List.sublistView(SHA3Digest(256).process(bytes), 0, 8)`, from `pkg:pointycastle/digests/sha3.dart`)
- version: top 8 bytes of Keccak256
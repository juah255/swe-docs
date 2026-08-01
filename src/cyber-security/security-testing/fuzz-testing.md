# Fuzz Testing

Fuzzing feeds malformed, random, or unexpected input into a program to find
crashes, memory bugs, and validation gaps.

High-value targets:

- **Parsers**: anything that interprets input formats.
- **APIs**: request bodies, headers, and query parameters.
- **File uploads**: malformed files and archives.
- **Serialization**: unexpected object graphs and formats.

Integrate fuzzing into CI with a corpus of good seed inputs and sanitizers such
as AddressSanitizer or MemorySanitizer to turn crashes into actionable reports.

Fuzzing complements [SAST](sast.md) and [DAST](dast.md): static analysis finds
code-level issues, DAST tests behavior, and fuzzing explores the input space
that neither covers exhaustively.

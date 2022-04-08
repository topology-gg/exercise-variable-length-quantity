## [Cairo exercise] Variable Length Quantity (VLQ)

#### Context
1. Felt (field element) manipulation serves as a good exercise for familiarizing with Cairo.
2. The ability to convert into / manipulate VLQ enables us to build Cairo library for MIDI generation, which serves as the foundation for onchain audio engine - a future item for Topology.

#### Problem statement
Variable Length Quantity (VLQ) is used heavily in MIDI file format, from specifing delta-time (interval between successive events, such as note-on / note-off events) to specifying the length of certain text descriptions. Somascape (Ref #1) has a wonderful description for VLQ with examples:

![image](https://user-images.githubusercontent.com/59590480/162447050-9a501ba4-a162-4208-9d25-8ef91edc0ddb.png)

Two functions are conceivably useful if implemented in Cairo:
1. `convert_numerical_felt_to_vlq_literal (num : felt) -> (vlq : felt)`: convert `num`, a numerical value in felt, into its corresponding VLQ representation in terms of string literal. Examples: `num = 0` -> `vlq = '00'`; `num = 128` (0x80) -> `vlq = '8100'` 
2. `convert_vlq_literal_to_numerical_felt (vlq : felt) -> (num : felt)`: the inverse function of `convert_numerical_felt_to_vlq_literal()`

#### Requirement
1. Create a folder in your name under `contracts/`, and a contract named `vlq.cairo` in your folder. The contract contains two `@view` functions: `convert_numerical_felt_to_vlq_literal()` and `convert_vlq_literal_to_numerical_felt()` in the function signatures specified above. Feel free to make a copy of the template contract located at `contracts/template/vlq.cairo`.
2. Implement the functions.
3. Pass the test: run `pytest -s tests/test.py --name <name-of-your-folder>`.
4. Have fun.

#### Reference
1. MIDI file specification by Somascape / http://www.somascape.org/midi/tech/mfile.html
2. Wikipedia page on VLQ / https://en.wikipedia.org/wiki/Variable-length_quantity

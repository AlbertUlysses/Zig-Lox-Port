const OpCode = enum { OP_RETURN };

const Chunk = struct {
    count: u32 = 0,
    capacity: u32 = 0,
    code: []u8, // still not understanding how to allocate data but will revisit here

    pub fn init(code: []u8) Chunk {
        return Chunk{
            .code = code,
        };
    }

    pub fn writeChunk(self: Chunk, byte: u8) void {
        if (.capcity < .count + 1) {
            const oldCapacity: u32 = self.capacity;
            self.capacity = .growCapacity(oldCapacity);
            self.code = .growArray();
        }
        self.code[self.count] = byte;
        self.count += 1;
    }

    fn growCapacity(capacity: u32) u32 {
        return capacity;
    }
};

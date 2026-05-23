package main_web

import "base:intrinsics"
import "core:c"
import "core:mem"

@(default_calling_convention = "c")
foreign _ {
	calloc :: proc(num, size: c.size_t) -> rawptr ---
	free :: proc(ptr: rawptr) ---
	malloc :: proc(size: c.size_t) -> rawptr ---
	realloc :: proc(ptr: rawptr, size: c.size_t) -> rawptr ---
}

emscripten_allocator :: proc() -> mem.Allocator {
	return {emscripten_allocator_proc, nil}
}

emscripten_allocator_proc :: proc(
	_: rawptr,
	mode: mem.Allocator_Mode,
	size, alignment: int,
	old_memory: rawptr,
	old_size: int,
	_ := #caller_location,
) -> (
	[]byte,
	mem.Allocator_Error,
) {

	aligned_alloc :: proc(
		size, alignment: int,
		zero: bool,
		old: rawptr = nil,
	) -> (
		[]byte,
		mem.Allocator_Error,
	) {
		a := max(alignment, align_of(rawptr))
		space := size + a - 1

		ptr: rawptr
		if old != nil {
			ptr = realloc(mem.ptr_offset((^rawptr)(old), -1)^, c.size_t(space + size_of(rawptr)))
		} else if zero {
			ptr = calloc(c.size_t(space + size_of(rawptr)), 1)
		} else {
			ptr = malloc(c.size_t(space + size_of(rawptr)))
		}

		aligned := rawptr(mem.ptr_offset((^u8)(ptr), size_of(rawptr)))
		addr := uintptr(aligned)
		aligned_addr := (addr - 1 + uintptr(a)) & -uintptr(a)
		diff := int(aligned_addr - addr)

		if (size + diff) > space || ptr == nil {return nil, .Out_Of_Memory}

		aligned = rawptr(aligned_addr)
		mem.ptr_offset((^rawptr)(aligned), -1)^ = ptr
		return mem.byte_slice(aligned, size), nil
	}

	aligned_free :: proc(p: rawptr) {
		if p != nil {free(mem.ptr_offset((^rawptr)(p), -1)^)}
	}

	switch mode {
	case .Alloc, .Alloc_Non_Zeroed:
		return aligned_alloc(size, alignment, mode == .Alloc)

	case .Free:
		aligned_free(old_memory)
		return nil, nil

	case .Resize, .Resize_Non_Zeroed:
		if old_memory == nil {return aligned_alloc(size, alignment, mode == .Resize)}
		bytes, err := aligned_alloc(size, alignment, true, old_memory)
		if err != nil {return nil, err}
		if size > old_size {intrinsics.mem_zero(raw_data(bytes[old_size:]), size - old_size)}
		return bytes, nil

	case .Query_Features:
		set := (^mem.Allocator_Mode_Set)(old_memory)
		if set != nil {set^ = {.Alloc, .Free, .Resize, .Query_Features}}
		return nil, nil

	case .Free_All, .Query_Info:
		return nil, .Mode_Not_Implemented
	}
	return nil, .Mode_Not_Implemented
}

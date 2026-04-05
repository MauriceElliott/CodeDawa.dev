package codedawa

import "core:os"
import "core:strings"
import "core:path/filepath"

make_dir_recursive :: proc(path: string) -> bool {
	if os.is_dir(path) do return true

	parent := filepath.dir(path)
	defer delete(parent)
	if parent != path && parent != "." && parent != "" {
		if !make_dir_recursive(parent) do return false
	}

	err := os.make_directory(path)
	return err == nil || os.is_dir(path)
}

remove_dir_recursive :: proc(path: string) -> bool {
	if !os.exists(path) do return true
	return os.remove_all(path) == nil
}

copy_file :: proc(src, dst: string) -> bool {
	parent := filepath.dir(dst)
	defer delete(parent)
	if !make_dir_recursive(parent) do return false

	data, read_err := os.read_entire_file_from_path(src, context.allocator)
	if read_err != nil do return false
	defer delete(data)
	return os.write_entire_file(dst, data) == nil
}

copy_dir :: proc(src, dst: string) -> bool {
	if !os.is_dir(src) do return true

	fd, open_err := os.open(src)
	if open_err != nil do return false

	entries, read_err := os.read_dir(fd, -1, context.allocator)
	os.close(fd)
	if read_err != nil do return false
	defer delete(entries)

	for entry in entries {
		src_path := strings.concatenate({src, "/", entry.name})
		defer delete(src_path)
		dst_path := strings.concatenate({dst, "/", entry.name})
		defer delete(dst_path)

		if entry.type == .Directory {
			if !make_dir_recursive(dst_path) do return false
			if !copy_dir(src_path, dst_path) do return false
		} else {
			if !copy_file(src_path, dst_path) do return false
		}
	}
	return true
}

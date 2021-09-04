module os

pub struct File {
pub:
	fd int
pub mut:
	is_opened bool
}

#const $buffer = require('buffer');

// todo(playX):   __as_cast is broken here
/*
pub struct ErrFileNotOpened {
	msg  string = 'os: file not opened'
	code int
}
pub struct ErrSizeOfTypeIs0 {
	msg  string = 'os: size of type is 0'
	code int
}
fn error_file_not_opened() IError {
	return IError(&ErrFileNotOpened{})
}
fn error_size_of_type_0() IError {
	return IError(&ErrSizeOfTypeIs0{})
}
*/
pub fn open_file(path string, mode string, options ...int) ?File {
	mut res := File{}
	$if js_node {
		#if (!options) { options = new array([]); }
		#let permissions = 0o666
		#if (options.arr.length > 0) { permissions = options.arr[0]; }
		#try {
		#res.fd = new int($fs.openSync(''+path,''+mode,permissions))
		#} catch (e) {
		#return builtin.error('' + e);
		#}

		res.is_opened = true
	} $else {
		error('cannot open file on non NodeJS runtime')
	}
	return res
}

// open tries to open a file for reading and returns back a read-only `File` object.
pub fn open(path string) ?File {
	f := open_file(path, 'r') ?
	return f
}

pub fn create(path string) ?File {
	f := open_file(path, 'w') ?
	return f
}

pub fn stdin() File {
	return File{
		fd: 0
		is_opened: true
	}
}

pub fn stdout() File {
	return File{
		fd: 1
		is_opened: true
	}
}

pub fn stderr() File {
	return File{
		fd: 2
		is_opened: true
	}
}

pub fn (f &File) read(mut buf []byte) ?int {
	if buf.len == 0 {
		return 0
	}
	mut nbytes := 0
	#try {
	#let buffer = $fs.readFileSync(f.fd.valueOf());
	#
	#for (const val of buffer.values()) { buf.arr[nbytes++] = val; }
	#}
	#catch (e) { return builtin.error('' + e); }

	return nbytes
}

pub fn (mut f File) write(buf []byte) ?int {
	if !f.is_opened {
		return error('file is not opened')
	}
	mut nbytes := 0
	#const b = $buffer.Buffer.from(buf.arr.map((x) => x.valueOf()))
	#try { $fs.writeSync(f.fd.valueOf(),b,0,buf.len.valueOf(),0); } catch (e) { return builtin.error('' + e); }

	return nbytes
}

// writeln writes the string `s` into the file, and appends a \n character.
// It returns how many bytes were written, including the \n character.
pub fn (mut f File) writeln(s string) ?int {
	mut nbytes := f.write(s.bytes()) ?
	nbytes += f.write('\n'.bytes()) ?
	return nbytes
}

pub fn (mut f File) write_to(pos u64, buf []byte) ?int {
	if !f.is_opened {
		return error('file is not opened')
	}
	mut nbytes := 0
	#const b = $buffer.Buffer.from(buf.arr.map((x) => x.valueOf()))
	#try { $fs.writeSync(f.fd.valueOf(),b,0,buf.len.valueOf(),pos.valueOf()); } catch (e) { return builtin.error('' + e); }

	return nbytes
}

// write_string writes the string `s` into the file
// It returns how many bytes were actually written.
pub fn (mut f File) write_string(s string) ?int {
	nbytes := f.write(s.bytes()) ?
	return nbytes
}

pub fn (mut f File) close() {
	#f.valueOf().fd.close()
}

pub fn (mut f File) write_full_buffer(s voidptr, buffer_len size_t) ? {}
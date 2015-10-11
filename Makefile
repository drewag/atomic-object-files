all: src/AtomicObjectFiles.swift

src/AtomicObjectFiles.swift: AtomicObjectFiles/*.swift
	@mkdir -p src
	@find AtomicObjectFiles -name '*.swift' -exec cat {} \; -exec echo \; -exec echo \; > src/AtomicObjectFiles.swift

clean:
	@rm -rf src/

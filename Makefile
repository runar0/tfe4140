LIBS=tests/lib/*vhd
SOURCES=src/*vhd tests/*vhd

.PHONY: build test_laision test_voter test_input_block test_output_block test_siporeg clean
build: $(SOURCES)
	php bin/build_liaison_tb_data.php	
	ghdl -a $(LIBS)
	ghdl -a $(SOURCES)

test_liaison: build
	ghdl --elab-run liaison_tb

test_voter: build
	ghdl --elab-run voter_tb

test_input_block: build
	ghdl --elab-run input_block_tb
	
test_output_block: build
	ghdl --elab-run output_block_tb
	
test_siporeg: build
	ghdl --elab-run siporeg_tb

clean:
	rm -f *o
	rm -f liaison_tb voter_tb input_block_tb output_block_tb siporeg_tb
	rm -f work-obj93.cf

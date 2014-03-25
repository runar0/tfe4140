LIBS=tests/lib/*vhd
SOURCES=src/*vhd tests/*vhd

.PHONY: build test test_laision test_voter test_input_block test_output_block test_siporeg clean

test: | test_siporeg test_voter test_output_block test_input_block test_liaison

test_liaison: build
	ghdl --elab-run liaison_tb --stop-time=4157640ns --wave=waves/liaison.ghw

test_voter: build
	ghdl --elab-run voter_tb --stop-time=1100ns --wave=waves/voter.ghw

test_input_block: build
	ghdl --elab-run input_block_tb --stop-time=800ns --wave=waves/input_block.ghw
	
test_output_block: build
	ghdl --elab-run output_block_tb --stop-time=700ns --wave=waves/output_block.ghw
	
test_siporeg: build
	ghdl --elab-run siporeg_tb --stop-time=1000ns --wave=waves/siporeg.ghw

build: clean $(SOURCES)
	php bin/build_liaison_tb_data.php	
	ghdl -a $(LIBS)
	ghdl -a $(SOURCES)
	mkdir waves/
	
clean:
	rm -f *o
	rm -f liaison_tb voter_tb input_block_tb output_block_tb siporeg_tb
	rm -f work-obj93.cf
	rm -f tests/liaision_tb_data.vhd
	rm -rf waves/

LIBS=tests/lib/*vhd
SOURCES=src/*vhd tests/*vhd

.PHONY: test_laision
test_liaison: $(SOURCES)
	php bin/build_liaison_tb_data.php	
	ghdl -a $(LIBS)
	ghdl -a $(SOURCES)
	ghdl --elab-run liaison_tb

.PHONY: clean
clean:
	rm *o
	rm liaison_tb
	rm work-obj93.cf

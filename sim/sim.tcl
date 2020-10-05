exec xvlog  -sv ../hdl/spi_master_top.sv
exec xvlog  -sv ./spi_master_top_tb.sv
exec xelab  spi_master_tb -s spi_master_tb_sim -debug typical
exec xsim   spi_master_tb_sim -gui
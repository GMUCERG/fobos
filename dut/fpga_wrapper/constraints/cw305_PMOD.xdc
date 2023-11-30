######JP3
#+----------+----------+----------+----------+
#|          |  din3    |  do_ready|  rst     |
#|  NC      |  D16     |  E16     |  F12     |
#+----------+----------+----------+----------+
#|  din0    |  din2    |  din1    |  do_valid|
#|  D15     |  E15     |  E13     |  F15     |
#+----------+----------+----------+----------+

#+----------+----------+----------+----------+
#|  dout1   |  dout3   |  di_ready|  clk     |
#|  B12     |  A13     |  B15     |  C11     |
#+----------+----------+----------+----------+
#|  dout0   |  dout2   |  di_valid|          |
#|  A12     |  A14     |  A15     |  C12     |
#+----------+----------+----------+----------+
set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 50.000 -name sys_clk_pin -waveform {0.000 25.000} -add [get_ports clk]

set_property -dict { PACKAGE_PIN F12    IOSTANDARD LVCMOS33 } [get_ports { rst }]; 
set_property -dict { PACKAGE_PIN E16    IOSTANDARD LVCMOS33 } [get_ports { do_ready }];
set_property -dict { PACKAGE_PIN D16    IOSTANDARD LVCMOS33 } [get_ports { din[3] }]; 
#set_property -dict { PACKAGE_PIN G6    IOSTANDARD LVCMOS33 } [get_ports { din[1] }]; 
set_property -dict { PACKAGE_PIN F15    IOSTANDARD LVCMOS33 } [get_ports { do_valid }]; 
set_property -dict { PACKAGE_PIN E13    IOSTANDARD LVCMOS33 } [get_ports { din[1] }];
set_property -dict { PACKAGE_PIN E15    IOSTANDARD LVCMOS33 } [get_ports { din[2] }];
set_property -dict { PACKAGE_PIN D15    IOSTANDARD LVCMOS33 } [get_ports { din[0] }];

#set_property -dict { PACKAGE_PIN C11    IOSTANDARD LVCMOS33 } [get_ports { rst }]; 
set_property -dict { PACKAGE_PIN B15    IOSTANDARD LVCMOS33 } [get_ports { di_ready }];
set_property -dict { PACKAGE_PIN A13    IOSTANDARD LVCMOS33 } [get_ports { dout[3] }]; 
set_property -dict { PACKAGE_PIN B12    IOSTANDARD LVCMOS33 } [get_ports { dout[1] }]; 
#set_property -dict { PACKAGE_PIN C12    IOSTANDARD LVCMOS33 } [get_ports {  }]; 
set_property -dict { PACKAGE_PIN A15    IOSTANDARD LVCMOS33 } [get_ports { di_valid }]; 
set_property -dict { PACKAGE_PIN A14    IOSTANDARD LVCMOS33 } [get_ports { dout[2] }]; 
set_property -dict { PACKAGE_PIN A12   IOSTANDARD LVCMOS33 } [get_ports { dout[0] }]; 


#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_IBUF]

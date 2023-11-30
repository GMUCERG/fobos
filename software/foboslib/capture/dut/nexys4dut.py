###DUT utilities 
##This can be used to program DUT
###Requiremet : This requires Digilent Adept runtime and utilities to be installed

import subprocess
class DUT():
   
   def __init__(self, programas = 'xilinx'):
      self.bitFile = ""
      self.deviceID = "Nexys4"
      self.jtagID = 0
      self.programas = programas #user used to run Digilent tools
                        #error seen when running in Jupyter-notebooks

   def setBitFile(self, bitFile):
      self.bitFile = bitFile

   def program(self):
      """
      runs a command similar to
      djtgcfg prog -d Nexys3 -i 0 -f ~/fobos_workspace/aes/FOBOS_DUT.bit 
      This requires Digilent Adept runtime and utilities to be installed
      """
      if self.bitFile == "":
         print("FATAL Error: DUT programming bit file not set. Please set it to a valid .bit file. Exiting...")
         exit()

#      cmd_init = ['sudo', '-u', self.programas, 
#                  'djtgcfg', 'init', '-d', self.deviceID]
#      cmd_prog = ['sudo', '-u', self.programas, 
#                  'djtgcfg', 'prog', '-d', self.deviceID, '-i', str(self.jtagID), '-f', self.bitFile]

      cmd_init = ['djtgcfg', 'init', '-d', self.deviceID]
      cmd_prog = ['djtgcfg', 'prog', '-d', self.deviceID, '-i', str(self.jtagID), '-f', self.bitFile]
      print("Programming device using the following commands:")
      print(" ".join(cmd_init))
      print(" ".join(cmd_prog))
      subprocess.check_output(cmd_init)
      output = subprocess.check_output(cmd_prog)
      print(output)
      if not (str(output).strip().find("Programming succeeded.") != -1):
         print("FATAL Error: DUT programming failed!. Exiting...")
         exit()

def main():
   dut = DUT()
   dut.setBitFile("/home/xilinx/fobosworkspace/aes/FOBOS_DUT.bit")
   dut.program()

if __name__ == "__main__":
   main()

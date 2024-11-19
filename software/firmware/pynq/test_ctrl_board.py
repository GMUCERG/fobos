import sys
from config.pynq_conf import FOBOS_HOME
sys.path.append(f"{FOBOS_HOME}/software/")
import foboslib as fb
from foboslib.commands import Commands as cmd
from foboslib.errors import Errors as err
from ctrl_board import CtrlBoard

class Ctrl_board_tester:
    def __init__(self):
        self.board = CtrlBoard()

    def test_operation(self, opcode, param):
        print(f'performing cmd {opcode} : {cmd.cmd_data[opcode]["name"]}')
        status, _, _ = self.board.do_operation(opcode, param)
        print(f'status {status} : {err.err_data[status]["err_msg"]}')
        print('#====================================')
        print()

    def test1(self):
        self.test_operation(cmd.SET_DUT_CLK, 2000)
        self.test_operation(cmd.SET_DUT_INTERFACE, fb.INTERFACE_4BIT)
        self.test_operation(cmd.OUT_LEN, 16)
        self.test_operation(cmd.TRG_MODE, fb.TRG_FULL)
        self.test_operation(cmd.SET_SAMPLING_FREQ, 50)
        self.test_operation(cmd.SET_SAMPLING_FREQ, 50000)
        self.test_operation(cmd.SET_ADC_GAIN, 40)
        self.test_operation(cmd.SET_ADC_HILO, 1)
        self.test_operation(cmd.SET_SAMPLES_PER_TRACE, 1000)

if __name__=='__main__':
    t = Ctrl_board_tester()
    t.test1()
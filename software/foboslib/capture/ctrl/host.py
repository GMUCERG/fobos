import os
import time
import json
import pwd
from foboslib.capture.ctrl.hardware_mgr import HardwareManager
from foboslib.capture.ctrl.pynqctrl import PYNQCtrl
from foboslib.capture.dut.jtag_target import Jtag_target
from foboslib.capture.dut.cw305_target import Cw305_target
from foboslib.capture.dut.digilent_target import Digilent_target
from foboslib.capture.dut.altera_target import Altera_target

CONFIG_FILE = "foboslib/capture/ctrl/config/host_config.json"

class Host:
    def __init__(self):
        self.config_file = CONFIG_FILE
        self.config = self.read_config()
        self.uid = os.getuid()

        import pwd

    def get_username(self, uid):
        try:
            return pwd.getpwuid(uid).pw_name
        except KeyError:
            return None

    def get_name(self):
        return self.config['hostname']

    def read_config(self):
        with open(self.config_file, 'r') as config_file:
            config = json.loads(config_file.read())
        return config

    def get_instances(self):
        return self.config['instances']

    def show_instances(self, get_status=False):
        insts = self.get_instances()
        for i in range(len(insts)):

            inst = insts[i]
            ip = inst['ip']
            name = inst['name']
            dut = inst['dut']

            if get_status:
                hw = HardwareManager(admin_ip=ip, admin_port=9996)
                err, _, uid, lock_time = hw.lock_status()
                
                # print(f'res={res}')
                if not err:
                    online_status = f'\t\033[92mOnline\033[0m'
                else:
                    online_status =f'\t\033[91mOffline\033[0m'

                if uid==0:
                    user_name = 'None'
                else:
                    user_name = self.get_username(uid)
                if lock_time ==0:
                    lock_time = 'None'
                else:
                    lock_time = time.ctime(lock_time)
                print(f"{'name: ' + name:<16}{'ip: ' + ip:<20}", end='')
                # print(f"{'ip: ' + ip:<20}", end='')
                # print(f"{'dut: ' + dut:<15}", end='')
                print(f"{'current_user: ' + user_name:<23}", end='')
                print(f"{'lock_time: ' + lock_time:<35}", end='')
                print(f"{online_status:<25}")

                # print(f"{i+1} - name = {name} ip={ip} dut={dut}\n\tcurrent_user={uid}\t\tlock_time={lock_time}\t {online_status}")
            else:
                print(f"{i+1} - name = {name}\t ip={ip}\t")
    
    def get_instance_by_name(self, inst_name):
        insts = self.config['instances']
        for inst in insts:
            if inst['name'] == inst_name:
                return inst
        
        return None

    def instance_status(self, inst_name):
        inst = self.get_instance_by_name(inst_name)
        print(f'getting instance {inst} status')
        inst_name = inst['name']
        inst_ip = inst['ip']

        hw = HardwareManager(admin_ip=inst_ip, admin_port=9996)
        res = hw.lock_status()
        return res

    def lock_instance(self, inst_name):
        inst = self.get_instance_by_name(inst_name)
        print(f'locking instance {inst}')
        inst_name = inst['name']
        inst_ip = inst['ip']

        hw = HardwareManager(admin_ip=inst_ip, admin_port=9996)
        res = hw.lock(self.uid)
        return res

    def unlock_instance(self, inst_name):
        inst = self.get_instance_by_name(inst_name)
        print(f'unlocking instance {inst}')
        inst_name = inst['name']
        inst_ip = inst['ip']

        hw = HardwareManager(admin_ip=inst_ip, admin_port=9996)
        res = hw.unlock(self.uid)
        return res
    
    def connect(self, instance_name):
        print(f'connecting to {instance_name} ...')
        inst = self.get_instance_by_name(instance_name)
        # print(f'instance found = {inst}')
        target_info = inst['dut']
        # print(f'target_info = {target_info}')
        if inst==None:
            print(f'Instance not found. Check host configuration file')
            return
        
        err, _, current_uid, lock_time = self.instance_status(instance_name)
        # print(f'instnce status = {err, current_uid, lock_time}')
        if err:
            print('Error checking intance status. Check if it is online')
            return
        
        if current_uid != 0 and current_uid != self.uid:
            print(f'Instantance already used by uid: {current_uid} since {lock_time}')
            return
        
        err, lock_granted, current_uid, lock_time = self.lock_instance(instance_name)
        print(f'lock granted = {lock_granted}')
        if err:
            print(f'error with locking instance')
            return
        
        if not lock_granted:
            print(f'Error: lock refuesd, curruent_uid = {current_uid}, lock_time= {lock_time}')
            return

        # print('lock granted!')
        inst_ip = inst['ip']
        ctrl = PYNQCtrl(inst_ip, 9995)
        ctrl.set_instance_name(instance_name)
        # print('getting target handle')
        target = self._get_dut(target_info)

        return ctrl, target
    
    def disconnect(self, ctrl):
        inst_name = ctrl.get_instance_name()
        ctrl.disconnect()
        self.unlock_instance(inst_name)
        print(f'instance {inst_name} disconnected!')

    def _get_dut(self, dut_info):
        dut_type = dut_info['type']
        
        if dut_type=='xilinx_jtag':
            jtag_cable = dut_info['jtag_cable']
            jtag_position = dut_info['jtag_position']
            if 'jtag_serial_number' in dut_info:
                jtag_serial_number = dut_info['jtag_serial_number']
            else:
                jtag_serial_number = "0"
            print(f"dut_type : {dut_type}")
            print(f"jtag_cable = {jtag_cable}")
            print(f"jtag_position = {jtag_position}")
            print(f"jtag_serial_number = {jtag_serial_number}")

            dut = Jtag_target(jtag_cable, jtag_position, jtag_serial_number)
        elif dut_type== 'cw305':
            usb_serial_number = dut_info['usb_serial_number']

            print(f"dut_type : {dut_type}")
            print(f"usb_serial_number = {usb_serial_number}")
            dut = Cw305_target(usb_serial_number)

        elif dut_type== 'altera_jtag':
            if 'jtag_position' in dut_info:
                jtag_position = dut_info['jtag_position']
            else:
                jtag_position = "0"
            print(f"dut_type : {dut_type}")
            print(f"jtag_position = {jtag_position}")
            dut = Altera_target(jtag_position)

        elif dut_type== 'digilent':
            device_ID = dut_info['deviceID']
            jtag_ID = dut_info['jtagID']
            print(f"dut_type : {dut_type}")
            print(f"deviceID : {device_ID}")
            dut = Digilent_target(device_ID, jtag_ID)
        else:
            print('DUT type not supported')
        
        return dut

def main():
    host = Host()
    # print(host.config)
    # print(' ====')
    # print(host.get_name())
    # print(' ====')
    # insts = host.get_instances()
    # print(insts)
    # print(' ====')
    # host.show_instances(get_status=False)
    # inst = host.get_instance_by_name('pynq1')
    # res = host.instance_status('pynq1')
    # print(res)
    # print(inst)
    # res = host.lock_instance('pynq1', uid=2)
    # print(res)
    # host.unlock_instance('pynq1', uid=1)
    bit_file = "/home/bakry/projects/GMU/fobos-proj/fobos-dev1/fobos/projects/aes/vivado/aes-128/aes-128.runs/impl_1/half_duplex_dut.bit"
    dut_info = {'type': 'xilinx_jtag', 'jtag_target_type': '/xilinx_tcf', 'jtag_target_name': '/Xilinx/13724327082e01', 'jtag_device_name': 'xc7a100t_0'}
    dut = host._get_dut(dut_info)
    print(dut)
    dut.program(bit_file=bit_file)

if __name__=='__main__':
    main()

import time
import json
from foboslib.capture.ctrl.hardware_mgr import HardwareManager
from foboslib.capture.ctrl.pynqctrl import PYNQCtrl

# CONFIG_FILE = "../../../../config/host_config.json"
CONFIG_FILE = "/home/bakry/projects/GMU/fobos-proj/fobos-dev1/fobos/config/host_config.json"

class Host:
    def __init__(self):
        self.config_file = CONFIG_FILE
        self.config = self.read_config()

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

                if uid==0: uid = 'None'
                if lock_time ==0:
                    lock_time = 'None'
                else:
                    lock_time = time.ctime(lock_time)
                print(f"{'name: ' + name:<12}{'ip: ' + ip:<20}", end='')
                # print(f"{'ip: ' + ip:<20}", end='')
                print(f"{'dut: ' + dut:<15}", end='')
                print(f"{'current_user: ' + str(uid):<20}", end='')
                print(f"{'lock_time: ' + lock_time:<30}", end='')
                print(f"{online_status:<25}")

                # print(f"{i+1} - name = {name} ip={ip} dut={dut}\n\tcurrent_user={uid}\t\tlock_time={lock_time}\t {online_status}")
            else:
                print(f"{i+1} - name = {name}\t ip={ip}\t dut={dut}\t")
    
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

    def lock_instance(self, inst_name, uid):
        inst = self.get_instance_by_name(inst_name)
        print(f'locking instance {inst}')
        inst_name = inst['name']
        inst_ip = inst['ip']

        hw = HardwareManager(admin_ip=inst_ip, admin_port=9996)
        res = hw.lock(uid=uid)
        return res

    def unlock_instance(self, inst_name, uid):
        inst = self.get_instance_by_name(inst_name)
        print(f'locking instance {inst}')
        inst_name = inst['name']
        inst_ip = inst['ip']

        hw = HardwareManager(admin_ip=inst_ip, admin_port=9996)
        res = hw.unlock(uid=uid)
        return res
    
    def connect(self, instance_name, uid):
        print(f'connecting to {instance_name} ...')
        inst = self.get_instance_by_name(instance_name)
        print(f'instance found = {inst}')
        if inst==None:
            print(f'Instance not found. Check host configuration file')
            return
        
        err, _, current_uid, lock_time = self.instance_status(instance_name)
        print(f'instnce status = {err, uid, lock_time}')
        if err:
            print('Error checking intance status. Check if it is online')
            return
        
        if current_uid != 0 and current_uid != uid:
            print(f'Instantance already used by uid: {current_uid} since {lock_time}')
            return
        
        err, lock_granted, current_uid, lock_time = self.lock_instance(instance_name, uid=uid)
        print(f'lock granted = {lock_granted}')
        if err:
            print(f'error with locking instance')
            return
        
        if not lock_granted:
            print(f'Error: lock refuesd, curruent_uid = {current_uid}, lock_time= {lock_time}')
            return

        print('lock granted!')
        inst_ip = inst['ip']
        ctrl = PYNQCtrl(inst_ip, 9995)
        ctrl.set_instance_name(instance_name)
        return ctrl
    
    def disconnect(self, ctrl, uid):
        inst_name = ctrl.get_instance_name()
        ctrl.disconnect()
        self.unlock_instance(inst_name, uid)
        print(f'instance {inst_name} disconnected!')


def main():
    host = Host()
    # print(host.config)
    # print(' ====')
    # print(host.get_name())
    # print(' ====')
    # insts = host.get_instances()
    # print(insts)
    # print(' ====')
    # host.show_instances(get_status=True)
    # inst = host.get_instance_by_name('pynq1')
    res = host.instance_status('pynq1')
    print(res)
    # print(inst)
    # res = host.lock_instance('pynq1', uid=2)
    # print(res)
    # host.unlock_instance('pynq1', uid=1)

if __name__=='__main__':
    main()
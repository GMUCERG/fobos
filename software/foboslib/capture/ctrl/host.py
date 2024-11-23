import time
import json
from foboslib.capture.ctrl.hardware_mgr import HardwareManager

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
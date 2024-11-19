import json

CONFIG_FILE = "../../../config/host_config.json"
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

    def show_instances(self):
        insts = self.get_instances()
        for i in range(len(insts)):
            inst = insts[i]
            print(f"{i+1} - name = {inst['name']}\t, ip = {inst['ip']}\t, dut = {inst['dut']}")

def main():
    host = Host()
    print(host.config)
    print(' ====')
    print(host.get_name())
    print(' ====')
    insts = host.get_instances()
    print(insts)
    print(' ====')
    host.show_instances()

if __name__=='__main__':
    main()
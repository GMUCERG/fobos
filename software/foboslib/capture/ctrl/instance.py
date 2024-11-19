class Instance:
    def __init__(self, config):
        self.name = config['name']
        self.ip = config['ip']
        self.port = config['port']
        self.admin_port = config['admin_port']
        self.dut = config['dut']

    def get_name(self):
        return self.name

    def get_ip(self):
        return self.ip

    def get_port(self):
        return self.port

    def get_admin_port(self):
        return self.get_admin_port
    
    def get_dut(self):
        return self.dut

    def __str__(self):
        return f"name = {self.get_name()}\t, ip = {self.get_ip()}\t, dut = {self.get_dut()}"

def main():
    inst = Instance(config={'name':'pynq1', 'ip':'192.168.10.99', 'port':'9995', 'admin_port':'9996', 'dut':'cw305', 'dut_prog_script':'prog_cw305.py'})
    print(' ====')
    print(inst.get_name())
    print(' ====')
    print(inst.get_ip())
    print(' ====')
    print(inst)
    

if __name__=='__main__':
    main()
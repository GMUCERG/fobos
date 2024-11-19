import os
import time
import socket
import pickle
# from foboslib.commands import Commands as cmd
import foboslib as fb

ADMIN_PORT = 9996
ADMIN_IP   = '192.168.10.99'

class HardwareManager():
    # class to allocate hardware to users
    TIMEOUT = 9 * 60 # timeout in seconds

    def __init__(self, admin_ip, admin_port= 9999):
        """Init method
        Parameters:
        -----
        ip   : string
            PYNQ ip address.
        port : int
        
            port where PYNQ server is listening.
        """
        self.MSG_LEN_SIZE = 10
        self.STATUS_SIZE = 4
        self.OPCODE_SIZE = 4
        self.PARAM_SIZE = 4
        self.RECV_TIMEOUT = 1
        self.RCV_BYTES = 512


        self.admin_ip = admin_ip
        self.admin_port = admin_port

    def _connect(self, ip, port):
        try:
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.connect((ip, port))
        except Exception as  e:
            # print(e)
            raise SystemExit('Could not connect to control board')

    def _printResponse(self, opeartion, status, responseMsg):
        print(f'{opeartion}')
        if status != 0:
            print(f'\t\033[91mError\033[0m : {responseMsg}')
        else:
            print(f'\t\033[92mOK\033[0m    : {responseMsg}')

    def _perform_command(self, opcode, param=0):
        status = 0
        responseMsg = (0, 0)
        try:
            self._connect(self.admin_ip, self.admin_port)
            self.sendMsg(opcode=opcode, param=param)
            status, responseMsg = self.recvMsg()
            # cmd_name = cmd.cmd_data[opcode]['name']
            # self._printResponse(f'Command {cmd_name} done!', status, resposnseMsg)
            # if status != 0:
                # raise SystemExit()
            err = False
        except:
            err = True

        return err, status, responseMsg

    def sendMsg(self, opcode, param, test_vector='010f'):
        # test_vector : hex string
        # print(f'send msg opcode={opcode}, param={param} tv={test_vector}')
        try:
            # param = pickle.dumps(param)
            test_vector_bytes = bytes.fromhex(test_vector)
            msg_len = self.OPCODE_SIZE + self.PARAM_SIZE + len(test_vector_bytes)
            msg = bytes(f'{msg_len :<{self.MSG_LEN_SIZE}}'  + \
                        f'{int(opcode):<{self.OPCODE_SIZE}}' + \
                        f'{int(param):<{self.PARAM_SIZE}}', 'utf-8') + \
                        test_vector_bytes
            # print(f'msg={msg}')
            self.socket.send(msg)
        except Exception as e:
            print('ERROR!!!!!!!!!!!!!')
            print(f'e={e}')
            raise SystemExit

    def recvMsg(self):
        full_msg = b''
        new_msg = True
        while True:
            try:
                msg = self.socket.recv(self.RCV_BYTES)
                if new_msg:
                    msg_len = int(msg[:self.MSG_LEN_SIZE])
                    new_msg = False
                full_msg += msg
                if len(full_msg) - self.MSG_LEN_SIZE ==msg_len:
                    status = int(full_msg[self.MSG_LEN_SIZE:self.MSG_LEN_SIZE + self.STATUS_SIZE])
                    response = pickle.loads(full_msg[self.MSG_LEN_SIZE + self.STATUS_SIZE:])
                    break
            except Exception as e:
                status = -1
                print('ERROR!!!!!!!!!!!!!')
                print(f'e={e}')
                response = ""
                break
                
        return status, response

    def lock(self, uid):
        # status, response = self._perform_command(cmd.CMD_LOCK, param=uid)
        err, status, response = self._perform_command(fb.CMD_LOCK, param=uid)
        current_uid, lock_time = response
        # print(f'lock: status={status}, response={response}')
        if status==0:
            return err, True, current_uid, lock_time
        else:
            return err, False, current_uid, lock_time

    def unlock(self, uid):
        # status, response = self._perform_command(cmd.CMD_UNLOCK, param=uid)
        err, status, response = self._perform_command(fb.CMD_UNLOCK, param=uid)
        current_uid, lock_time = response
        # print(f'unlock: status={status}, response={response}')
        if status==0:
            return err, True, current_uid, lock_time
        else:
            return err, False, current_uid, lock_time

    def lock_status(self):
        err, status, response = self._perform_command(fb.CMD_LOCK_STATUS)
        current_uid, lock_time = response
        # print(f'lock: status={status}, response={response}')
        return err, True, current_uid, lock_time

def main():
    import time

    hw = HardwareManager(admin_ip=ADMIN_IP, admin_port=ADMIN_PORT)

    res = hw.lock(uid=3)
    print(f'res={res}')
    time.sleep(1)
    res = hw.unlock(uid=2)
    print(f'res={res}')
    res = hw.lock_status()
    print(f'res={res}')

if __name__=='__main__':
    main()

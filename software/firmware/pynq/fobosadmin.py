import os
import sys
import logging
import socket
import time
import pickle
import json
from pathlib import Path
# from config.pynq_conf import FOBOS_HOME, IP
from pynq_drivers.config.pynq_conf import IP, PORT, FOBOS_HOME
sys.path.append(f"{FOBOS_HOME}/software/")
import foboslib as fb
from comm_handler import Comm_handler
# from foboslib.commands import Commands as cmd

STATUS_FILE     = "/tmp/fobos_admin_status.txt"
EXIT_FILE       = "/tmp/fobos_admin_exit"
LOG_FILE        = "/tmp/fobos.log"
MAX_START_RETRIES = 20
RETRY_WAIT      = 10
ADMIN_PORT      = 9996

RCV_ERR_NETWORK_ERR      = 1
RCV_ERR_INVALID_MSG_LEN  = 2
RCV_ERR_INVALID_MSG_DATA = 3

class Fobosadmin():
    def __init__(self, ip, port):
        print(f'FOBOS_HOME={FOBOS_HOME}')
        logging.basicConfig(filename=LOG_FILE, filemode='w', level=logging.DEBUG,
                            format='%(asctime)s %(name)s - %(levelname)s - %(message)s')
        self.logger = logging.getLogger('FOBOS admin')
        self.logger.info("Fobos admin starting ...")
        if os.path.isfile(EXIT_FILE):
            os.remove(EXIT_FILE)
        
        self.comm = Comm_handler(ip=ip, port=port, logger=self.logger)
        self.current_uid = 0
        self.lock_time = 0

    def acceptConnection(self):
        while True:
            if self.closeRequested():
                return False

            status = self.comm.accept_connection()
            self.touchStatusFile()
            if status:
                return True            

    def run(self):
        while True:
            self.logger.info("Fobos server ready. Waiting for connection ...")
            if not self.acceptConnection():
                self.logger.info("Recieved close command. Exitting ...")
                break
            status = self._handle_request()

    def _write_lock_file(self, uid, lock_time):
        lock_file = open('/tmp/fobos_lock', 'w')
        lock_dict = {'uid': uid, 'lock_time': lock_time}
        lock_file.write(json.dumps(lock_dict))
        lock_file.close()
            
    def _handle_request(self):
        rcv_status, opcode, param = self.comm.recv_msg()
        print(f'rcv_status={rcv_status}, opcode={opcode}, param={param}')
        uid = param
        if rcv_status ==0:
            if opcode == fb.CMD_LOCK:
                res, _, _ = self._lock(uid)
                if res:
                    self.comm.send_response(0, pickle.dumps([self.current_uid, self.lock_time]))
                    self.logger.info(f'Lock successful. Connection closed.')
                else:
                    self.comm.send_response(1, pickle.dumps([self.current_uid, self.lock_time]))
                    self.logger.info(f'Lock failed. Connection closed.')
                
            elif opcode==fb.CMD_UNLOCK:
                res, _, _ = self._unlock(uid)
                if res:
                    self.comm.send_response(0, pickle.dumps([self.current_uid, self.lock_time]))
                    self.logger.info(f'Unlock successful. Connection failed.')
                else:
                    self.comm.send_response(1, pickle.dumps([self.current_uid, self.lock_time]))
                    self.logger.info(f'Unlock failed. Connection closed.')                
            elif opcode==fb.CMD_LOCK_STATUS:
                self.comm.send_response(0, pickle.dumps([self.current_uid, self.lock_time]))
                self.logger.info(f'Status sent. Connection closed.')                
        else:
            if rcv_status==RCV_ERR_NETWORK_ERR:
                self.logger.error('Network error. Connection closed.')
            elif rcv_status == RCV_ERR_INVALID_MSG_LEN:
                self.logger.error("Invalid message leng. Closing connection")
            elif rcv_status == RCV_ERR_INVALID_MSG_DATA:
                self.logger.error("Invalid message data. Closing connection")
        self.comm.close()
        
        return rcv_status

    def touchStatusFile(self):
        Path(STATUS_FILE).touch()

    def closeRequested(self):
        if os.path.isfile(EXIT_FILE):
            os.remove(EXIT_FILE)
            return True
        return False

    def _lock(self, uid):
        print(f'_lock: curruid={self.current_uid}, uid={uid}')
        if self.current_uid==0 or self.current_uid==uid:
            self.current_uid = uid
            self.lock_time = time.time()
            res = True
        else:
            res = False
        print(f'_lock: res={res}')
        self._write_lock_file(self.current_uid, self.lock_time)
        return res, self.current_uid, self.lock_time

    def _unlock(self, uid):
        print(f'_unlock: curruid={self.current_uid}, uid={uid}')
        if self.current_uid==uid or self.current_uid==0:
            self.current_uid = 0
            self.lock_time = 0
            res = True
        else:
            res = False
        
        print(f'_unlock: res={res}')
        self._write_lock_file(self.current_uid, self.lock_time)
        return res, self.current_uid, self.lock_time

def main():
    admin = Fobosadmin(IP, ADMIN_PORT)
    admin.run()

if __name__=='__main__':
    main()

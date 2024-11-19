import os
import sys
import logging
import socket
import time
import pickle
from pathlib import Path
from config.pynq_conf import FOBOS_HOME, IP, PORT
sys.path.append(f"{FOBOS_HOME}/software/")
import foboslib as fb
from comm_handler import Comm_handler

#import numpy as np
# MSG_LEN_SIZE    = 10
# OPCODE_SIZE     = 4
# PARAM_SIZE      = 4
# STATUS_SIZE     = 4
# RCV_BYTES       = 512
# SOCKET_TIMEOUT  = 10 # seconds

STATUS_FILE     = "/tmp/fobos_status.txt"
EXIT_FILE       = "/tmp/fobos_exit"
LOG_FILE        = "/tmp/fobos.log"
MAX_START_RETRIES = 20
RETRY_WAIT      = 10

RCV_ERR_NETWORK_ERR      = 1
RCV_ERR_INVALID_MSG_LEN  = 2
RCV_ERR_INVALID_MSG_DATA = 3
class Fobos_server():
    def __init__(self, ip, port):
        logging.basicConfig(filename=LOG_FILE, filemode='w', level=logging.DEBUG,
                            format='%(asctime)s %(name)s - %(levelname)s - %(message)s')
        self.logger = logging.getLogger('FOBOS server')
        self.logger.info("Fobos server starting ...")
        if os.path.isfile(EXIT_FILE):
            os.remove(EXIT_FILE)
        
        self.comm = Comm_handler(ip=ip, port=port, logger=self.logger)

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

            while True:
                rcv_status, opcode, param = self.comm.recv_msg()
                print(f'rcv_status={rcv_status}, opcode={opcode}, param={param}')
                self.touchStatusFile()
                if rcv_status ==0:
                    if opcode == fb.DISCONNECT:
                        self.comm.send_response(0, pickle.dumps("Disconnect requested. Bye!"))
                        self.comm.close()
                        self.logger.info(f'Client done. Connection closed.')
                        break
                    
                    op_status, response = self.doOperation(opcode, param)
                    snd_status = self.comm.send_response(op_status, pickle.dumps(response))
                    if snd_status == -1:
                        self.logger.error('Could not send respose to client. Closing connection')
                        self.comm.close()
                        break
                else:
                    if rcv_status==RCV_ERR_NETWORK_ERR:
                        self.logger.error('Network error. Connection closed.')
                    elif rcv_status == RCV_ERR_INVALID_MSG_LEN:
                        self.logger.error("Invalid message leng. Closing connection")
                    elif rcv_status == RCV_ERR_INVALID_MSG_DATA:
                        self.logger.error("Invalid message data. Closing connection")

                    self.comm.close()
                    break

    def touchStatusFile(self):
        Path(STATUS_FILE).touch()

    def closeRequested(self):
        if os.path.isfile(EXIT_FILE):
            os.remove(EXIT_FILE)
            return True
        return False

    def doOperation(self, opcode, param):
        print(f'Do operation: opcode={opcode}, param={param}')
        op_status = 0
        response = 'operation done!'
        return op_status, response

def main():
    server = Fobos_server(IP, PORT)
    server.run()

if __name__=='__main__':
    main()

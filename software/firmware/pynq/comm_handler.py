import os
import sys
import logging
import socket
import time
import pickle
from pathlib import Path
# from config.pynq_conf import FOBOS_HOME, IP, PORT

#import numpy as np
MSG_LEN_SIZE    = 10
OPCODE_SIZE     = 4
PARAM_SIZE      = 4
STATUS_SIZE     = 4
RCV_BYTES       = 512
SOCKET_TIMEOUT  = 10 # seconds

STATUS_FILE     = "/tmp/fobos_status.txt"
EXIT_FILE       = "/tmp/fobos_exit"
LOG_FILE        = "/tmp/fobos.log"

MAX_START_RETRIES = 20
RETRY_WAIT      = 10

RCV_ERR_NETWORK_ERR      = 1
RCV_ERR_INVALID_MSG_LEN  = 2
RCV_ERR_INVALID_MSG_DATA = 3

class Comm_handler():
    def __init__(self, ip, port, logger):
        self.logger = logger
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        for i in range(MAX_START_RETRIES):
            try:
                self.logger.info(f'Attempting address binding. ip={ip} port={port}')
                self.socket.bind((ip, port))
                self.socket.listen(5)
                self.logger.info(f'Address binding succeeded.')
                break
            except:
                if i == MAX_START_RETRIES-1:
                    self.logger.error(f'Address binding failed. Exiting ...')
                    exit(1)
                self.logger.info(f'Address binding failed. Retrying in {RETRY_WAIT} seconds ...')
                time.sleep(RETRY_WAIT)
    
    def send_response(self, status, responseMsg):
        self.logger.debug(f'Send response: status={status}, response={responseMsg}')
        msg = bytes(f'{len(responseMsg) + STATUS_SIZE :<{MSG_LEN_SIZE}}' + f'{status:<{STATUS_SIZE}}', 'utf-8') + responseMsg
        try:
            self.clt.send(msg)
            status = 0
        except:
            print("error sending message")
            self.clt.close()
            status = -1
        return status

    def recv_msg(self):
        rcv_status = 0
        opcode = -1
        param = 0
        full_msg = b''
        new_msg = True
        while True:
            try:
                msg = self.clt.recv(RCV_BYTES)
            except:
                rcv_status = RCV_ERR_NETWORK_ERR
                break
            if new_msg:
                new_msg = False
                try:
                    msg_len = int(msg[:MSG_LEN_SIZE])
                except:
                    rcv_status = RCV_ERR_INVALID_MSG_LEN
                    break
            full_msg += msg
            if len(full_msg) - MSG_LEN_SIZE ==msg_len:
                rcv_status, opcode, param = self._parse_msg(full_msg)
                break
        
        return rcv_status, opcode, param

    def _parse_msg(self, msg):
        rcv_status = 0
        print(f'parseMsg: full_msg = {msg}')
        try:
            # parse message
            opcode = int(msg[MSG_LEN_SIZE : MSG_LEN_SIZE + OPCODE_SIZE])
            param  = int(msg[MSG_LEN_SIZE + OPCODE_SIZE : MSG_LEN_SIZE + OPCODE_SIZE + PARAM_SIZE])
            test_vector = msg[MSG_LEN_SIZE + OPCODE_SIZE + PARAM_SIZE :]
            # param = pickle.loads(msg[MSG_LEN_SIZE + STATUS_SIZE:])
        except:
            rcv_status = RCV_ERR_INVALID_MSG_DATA

        self.logger.debug(f'opcode={opcode}, param={param}, tv={test_vector}')
        print(f'tv = {test_vector.hex()}')
        return rcv_status, opcode, param
    
    def accept_connection(self):
        self.socket.settimeout(SOCKET_TIMEOUT)
        try:
            self.clt, addr = self.socket.accept()
            self.logger.info(f'Connection established. addr = {addr}')
            return True
        except:
            self.logger.debug(f'Socket accept timeout.')
            return False
    
    def close(self):
        self.clt.close()

# File      : fobosctl.py
# Puropose  : send control commands to fobos-server
# Author    : Abubakr Abdulgadir
# Date      : 6 June 2023

import logging
import os
import time
from pathlib import Path
import argparse
import subprocess
from config import pynq_conf

EXIT_FILE   = "/tmp/fobos_exit"
PYTHON_BIN  = "/usr/bin/python3"
SERVER_BIN  = "./pynqserver.py"

class Fobos_Manager:
    def __init__(self):
        logging.basicConfig(level=logging.DEBUG)
        self.logger = logging.getLogger('FOBOS Manager')

    def _get_server_pid(self):
        try:
            pids = subprocess.check_output(['pgrep', '-f', 'pynqserver'])
            pids = pids.decode().split('\n')[:-1]
            self.logger.debug(f'pid={pids}')
        except:
            self.logger.debug("FOBOS server is not running...")
            pids = None
        return pids
    
    def _kill_server(self, pids):
        for pid in pids:
            try:
                self.logger.info(f'Killing server pid={pid}')
                subprocess.call(['sudo', 'kill', '-9', pid])
            except:
                self.logger.error('Watchdog: Could not kill server')
    
    def _checkTimeout(self):
        try:
            stat = os.stat(self.statusFile)
            modifyTime = stat.st_mtime
            currentTime = time.time()
            delta = currentTime - modifyTime
            if delta > self.timeout:
                self.logger.error(f'Watchdog: Status file not updated for {delta} seconds. Timeout exceeded.')
                return True
            else:
                self.logger.info(f'Watchdog: Status file not updated for {delta} seconds. Timeout not exceeded.')
                return False
        except:
            return True

    def _removeStatusFile(self):
        try:
            self.logger.info('Watchdog: removing status file.')
            os.remove(self.statusFile)
        except:
            self.logger.error('Watchdog: could not remove status file')

    def fobos_status(self):
        pids = self._get_server_pid()
        if pids is not None:
            self.logger.info(f"FOBOS Server is running. pid={pids}")

    def stop_fobos(self):
        pids = self._get_server_pid()
        if pids is not None:
            self.logger.info(f'Stopping FOBOS server. pid={pids}')
            Path(EXIT_FILE).touch()
        else:
            self.logger.error('FOBOS server is not running')

    def start_fobos(self):
        pids = self._get_server_pid()
        if pids is None:
            print(os.getcwd())
            os.chdir(fobos_pynq_conf.FOBOS_HOME + '/software/firmware/pynq/')
            # pid = subprocess.Popen(["sudo", "-i", PYTHON_BIN, pynq_conf.FOBOS_HOME + '/software/firmware/pynq/' + SERVER_BIN]).pid
            pid = subprocess.Popen(["sudo", PYTHON_BIN, SERVER_BIN]).pid
            self.logger.info(f'Started FOBOS server. pid={pid}')
        else:
            self.logger.error('FOBOS server already running')

    def kill_fobos(self):
        pids = self._get_server_pid()
        if pids is not None:
            self.logger.info(f'Killing FOBOS server. pid={pids}')
            self._kill_server(pids)
        else:
            self.logger.error('FOBOS Server is not running')
    
    def watchdog(self):
        timedout = self._checkTimeout()
        if timedout:
            self.logger.info('Watchdog: restarting FOBOS')
            self.kill_fobos()
            self._removeStatusFile()
            self.start_fobos()
        else:
            self.logger.info('Watchdog: Timeout not exceeded. Nothing to do. Exiting')

def main():
    parser = argparse.ArgumentParser(description = 'FOBOS managemer. Runs on the PYNQ board.')

    parser.add_argument('action', help="supported actions (start, stop, status, kill)")

    args = parser.parse_args()

    action = args.action
    if not (action in ['start', 'stop', 'status', 'kill']):
        print(f'{action} is not a fobos-manager action.')
        print('try fobos-manager.py --help ')
        exit()

    args = parser.parse_args()
    manager = Fobos_Manager()

    if   action == 'stop':
        manager.stop_fobos()
    elif action == 'start':
        manager.start_fobos()
    elif action == 'status':
        manager.fobos_status()
    elif action == 'kill':
        manager.kill_fobos()
    elif action == 'watchdog':
        manager.watchdog()

if __name__ == '__main__':
    main()

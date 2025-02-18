import os
import signal
import time
import subprocess
import logging
import pynq_drivers.config.pynq_conf as conf

LOG_FILE = '/tmp/fobos.log'
class FobosWatchdog:
    """
    A class to make sure the the server is alive
    """

    def __init__(self):
        print(os.environ)
        logging.basicConfig(filename=LOG_FILE, filemode='w', level=logging.INFO,
                            format='%(asctime)s %(name)s - %(levelname)s - %(message)s')
        self.logger = logging.getLogger('FOBOS Watchdog')
        self.logger.debug("Fobos watchdog starting ...")
    
        self.serverStatusFile = "/tmp/fobos_status.txt"
        self.adminStatusFile = "/tmp/fobos_admin_status.txt"
        self.serverBin = f"{conf.FOBOS_HOME}/software/firmware/pynq/pynqserver.py"
        self.adminBin = f"{conf.FOBOS_HOME}/software/firmware/pynq/fobosadmin.py"
        self.timeout = 1 * 60 # seconds
        self.python3 = "/usr/local/share/pynq-venv/bin/python3"
    
    def checkTimeout(self, status_file_name):
        try:
            stat = os.stat(status_file_name)
            modifyTime = stat.st_mtime
            currentTime = time.time()
            delta = currentTime - modifyTime
            if delta > self.timeout:
                self.logger.error(f'Watchdog: Status file not updated for {delta} seconds. Timeout exceeded.')
                return True
            else:
                self.logger.debug(f'Watchdog: Status file not updated for {delta} seconds. Timeout not exceeded.')
                return False
        except:
            print('Error: checkTimeout')
            return True
    
    def removeStatusFile(self, status_file_name):
        try:
            self.logger.info('Watchdog: removing status file.')
            os.remove(status_file_name)
        except:
            self.logger.error('Watchdog: could not remove status file')

    def getServerPid(self):
        try:
            pids = subprocess.check_output(['pgrep', '-f', 'fobosadmin|pynqserver'])
            pids = pids.decode().split('\n')[:-1]
            self.logger.debug(f'pid={pids}')
        except:
            self.logger.debug("Watchdog: Pynq server not running...")
            pids = None
        return pids

    def restartServer(self):
        pid = subprocess.Popen(["sudo", self.python3, self.adminBin], start_new_session=True).pid
        self.logger.info(f'Watchdog: Ran fobosadmin pid = {pid}')
        pid2 = subprocess.Popen(["sudo", "-i", self.python3, self.serverBin], start_new_session=True).pid
        self.logger.info(f'Watchdog: Ran pynqserver pid = {pid2}')

    def killServer(self, pids):
        for pid in pids:
            try:
                # os.kill(pid, signal.SIGINT)
                print(pid)
                subprocess.call(['sudo', 'kill', '-9',  pid])
            except:
                self.logger.error('Watchdog: Could not kill server')

    def check_servers(self):
        server_timedout = self.checkTimeout(self.serverStatusFile)
        admin_timedout = self.checkTimeout(self.adminStatusFile)
        if admin_timedout or server_timedout:
            self.logger.error('Watchself: Fobos admin or server timed out restarting FOBOS')
            pids = self.getServerPid()
            if pids is not None:
                self.killServer(pids)
            self.removeStatusFile(self.serverStatusFile)
            self.removeStatusFile(self.adminStatusFile)
            self.restartServer()
        else:
            self.logger.debug('Watchdog: Timeout not exceeded. Nothing to do. Exiting')

def main():
    dog = FobosWatchdog()
    dog.check_servers()

if __name__ == '__main__':
    main()




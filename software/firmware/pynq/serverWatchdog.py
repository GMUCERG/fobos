import os
import signal
import time
import subprocess
import config.pynq_conf as conf

class FobosWatchdog:
    """
    A class to make sure the the server is alive
    """

    def __init__(self):
        self.statusFile = "/tmp/fobos_status.txt"
        self.serverBin = f"{conf.FOBOS_HOME}/software/firmware/pynq/pynqserver.py"
        self.timeout = 1 * 60 # seconds
        self.python3 = "/usr/local/share/pynq-venv/bin/python3"
        #self.python3 = "python3"
    
    def checkTimeout(self):
        try:
            stat = os.stat(self.statusFile)
            modifyTime = stat.st_mtime
            currentTime = time.time()
            delta = currentTime - modifyTime
            if delta > self.timeout:
                print(f'Watchdog: Status file not updated for {delta} seconds. Timeout exceeded.')
                return True
            else:
                print(f'Watchdog: Status file not updated for {delta} seconds. Timeout not exceeded.')
                return False
        except:
            print('Error: checkTimeout')
            return True
    
    def removeStatusFile(self):
        try:
            print('Watchdog: removing status file.')
            os.remove(self.statusFile)
        except:
            print('Watchdog: could not remove status file')

    def getServerPid(self):
        try:
            pids = subprocess.check_output(['pgrep', '-f', 'pynqserver'])
            pids = pids.decode().split('\n')[:-1]
            print(f'pid={pids}')
        except:
            print("Watchdog: Pynq server not running...")
            pids = None
        return pids

    def restartServer(self):
        cmd = self.serverBin
        # os.spawnl(os.P_NOWAIT, cmd)
        # my_env = os.environ.copy()
        # my_env["XILINX_XRT"] = "/usr"
        # pid = subprocess.Popen(["sudo", self.python3, self.serverBin], env=my_env).pid
        pid = subprocess.Popen(["sudo", "-i", self.python3, self.serverBin]).pid
        print(f'Watchdog: Ran server pid = {pid}')

    def killServer(self, pids):
        for pid in pids:
            try:
                # os.kill(pid, signal.SIGINT)
                print(pid)
                subprocess.call(['sudo', 'kill', pid])
            except:
                print('Watchdog: Could not kill server')
def main():
    dog = FobosWatchdog()
    timedout = dog.checkTimeout()
    if timedout:
        print('Watchdog: restarting FOBOS')
        pids = dog.getServerPid()
        if pids is not None:
            dog.killServer(pids)
        dog.removeStatusFile()
        dog.restartServer()
    else:
        print('Watchdog: Timeout not exceeded. Nothing to do. Exiting')
    
if __name__ == '__main__':
    main()




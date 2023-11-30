import os
import signal
import time
import subprocess

class FobosClientWatchdog:
    """
    A class to make sure the lock file is removed after timeout
    The server should restart and be ready (disconnecting client)

    """

    def __init__(self):
        self.lockFile = "/tmp/fobos.lock"
        self.timeout = 5 * 60 # (sec) must be greater than time needed for server to recover
    
    def checkTimeout(self):
        try:
            stat = os.stat(self.lockFile)
            modifyTime = stat.st_mtime
            currentTime = time.time()
            delta = currentTime - modifyTime
            if delta > self.timeout:
                print(f'Client Watchdog: Lock file not updated for {delta} seconds. Timeout exceeded.')
                return True
            else:
                print('Timout not exceeded.')
                return False
        except:
            #print('No lock file found.')
            return False
    
    def removeLockFile(self):
        try:
            print('Client Watchdog: removing  lock file.')
            os.remove(self.lockFile)
        except:
            print('Client Watchdog: could not remove status file')

    
def main():
    dog = FobosClientWatchdog()
    timedout = dog.checkTimeout()
    if timedout:
        print('Client Watchdog: removing lock!')
        dog.removeLockFile()
    else:
        pass
        #print('Client Watchdog: Timeout not exceeded or no lock file. Nothing to do. Exiting')
    
if __name__ == '__main__':
    main()




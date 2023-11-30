import os
import time

class HardwareManager():
    # class to allocate hardware to users
    LOCK_FILE_PATH = '/tmp/fobos.lock'
    TIMEOUT = 9 * 60 # timeout in seconds
    
    def lock(self):
        tic = time.time()
        while True:
            toc = time.time()
            if toc - tic > self.TIMEOUT:
                print('Hardware manager: timeout while waiting for control board. Please try again later.')
                return False
            if not self.isLocked():
                try:
                    open(self.LOCK_FILE_PATH, 'a').close()
                except Exception as e:
                    print(e)
                    return False
                return True
            if int(toc - tic) % 20 == 0:
                print('Waiting for current user to release hardware. Please wait ...')
            time.sleep(1)

    def isLocked(self):
#        return False # WORKAROUND for single user mode
        return os.path.isfile(self.LOCK_FILE_PATH)
    
    def unlock(self):
        if self.isLocked():
            try:
                os.remove(self.LOCK_FILE_PATH)
            except Exception as e:
                print(e)
            else:
                print('Released hardware lock.')

#############################################################################
#                                                                           #
#   Copyright 2019 CERG                                                     #
#                                                                           #
#   Licensed under the Apache License, Version 2.0 (the "License");         #
#   you may not use this file except in compliance with the License.        #
#   You may obtain a copy of the License at                                 #
#                                                                           #
#       http://www.apache.org/licenses/LICENSE-2.0                          #
#                                                                           #
#   Unless required by applicable law or agreed to in writing, software     #
#   distributed under the License is distributed on an "AS IS" BASIS,       #
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.#
#   See the License for the specific language governing permissions and     #
#   limitations under the License.                                          #
#                                                                           #
#############################################################################

import os
import shutil

class ProjectManager():
    """
    Class to manage project files and directories
    """

    def __init__(self):
        self.projName = ""
        self.workSpaceDir = ""
        self.captureDir = ""
        self.analysisDir = ""
        self.TVFile = ""  # test vector file
        self.fvrFile = ""  # fixed-vs-random meta file.

    def getCurrentDir(self):
        return os.getcwd()

    def setWorkSpaceDir(self, workSpaceDir):
        if os.path.isdir(workSpaceDir):
            self.workSpaceDir = workSpaceDir
            return
        elif workSpaceDir == "default":
            dirName = os.path.join(self.getCurrentDir(), "workspace")
            if os.path.isdir(dirName):
                self.workSpaceDir = dirName
                return
        else:
            dirName = workSpaceDir

        # create it
        try:
            os.mkdir(dirName)
            self.workSpaceDir = dirName
        except OSError as e:
            print ("FATAL ERROR: Cannot create directory:%s" % (dirName))
            exit()
        else:
            print("Successfully created workspace directory at %s" % (dirName))

    def getWorkSpaceDir(self):
        if self.workSpaceDir == "":
            # creat a default one
            print ("FATAL ERROR: Workspace directory not set. Please use ProjectManager.setWorkSpace().")
            exit()
        else:
            return self.workSpaceDir

    def setProjName(self, projectName):
        self.projName = projectName

    def getProjName(self):
        return self.projName

    def getProjDir(self):
        """
        returns project directory name. If it does't exist it creats it and
        returns it.
        """
        if self.workSpaceDir == "":
            # creat a default one
            print("FATAL ERROR: Workspace directory not set. Please use ProjectManager.setWorkSpace().")
            exit()
        elif self.projName == "":
            print("FATAL ERROR: Projetc name not set. Please use ProjectManager.setProjName().")
            exit()

        projDir = os.path.join(self.getWorkSpaceDir(), self.getProjName())
        if os.path.isdir(projDir):
            return projDir
        else:
            # create it and return it!
            try:
                os.mkdir(projDir)
            except OSError as e:
                print ("FATAL ERROR: Cannot create directory:%s" % (projDir))
                exit()
            else:
                print ("Successfully created workspace directory at %s" %
                       (projDir))
                return projDir

    def createCaptureDir(self):
        """
        creats a new directory to store capture attempt. It uses numbers to
        """
        cnt = 1
        while os.path.isdir(os.path.join(self.getProjDir(), "capture", "attempt-" + f'{cnt:02d}')):
            cnt += 1

        try:
            captureDir = os.path.join(
                self.getProjDir(), "capture", "attempt-" + f'{cnt:02d}')
            os.makedirs(captureDir)
            self.captureDir = captureDir
        except OSError as e:
            print ("FATAL ERROR: Cannot create directory:%s" % (captureDir))
            exit()
        else:
            print ("Successfully created new capture directory at %s" %
                   (captureDir))
        return self.captureDir

    def getCaptureDir(self):
        if self.captureDir == "":
            return self.createCaptureDir()
        else:
            return self.captureDir

    def createAnalysisDir(self):
        """
        creats a new directory to store analysis attempt. It uses numbers to
        """
        cnt = 1
        while os.path.isdir(os.path.join(self.getProjDir(), "analysis", "attempt-" + f'{cnt:02d}')):
            cnt += 1

        try:
            analysisDir = os.path.join(
                self.getProjDir(), "analysis", "attempt-" + f'{cnt:02d}')
            os.makedirs(analysisDir)
            self.analysisDir = analysisDir
        except OSError as e:
            print ("FATAL ERROR: Cannot create directory:%s" % (analysisDir))
            exit()
        else:
             print ("Successfully created new analysis directory at %s" %(analysisDir))
        return self.analysisDir

    def getAnalysisDir(self):
        if self.analysisDir == "":
            return self.createAnalysisDir()
        else:
            return self.analysisDir

    def getTVFile(self):
        """
        Returns a file name for the test vectors needed to run FOBOS
        """
        if self.TVFile == "":
            # creat a default one
            print("FATAL ERROR: Test vector file not set. Please use ProjectManager.setTVFile().")
            exit()
        else:
            return self.TVFile

    def setTVFile(self, fileName):
        if os.exits(fileName):
            self.TVFile = fileName
            print("Successfully set test vector file name to %s" % (fileName))
        else:
            print("FATAL ERROR: Test vector file not set. File %s does not exist." % (fileName))
            exit()

def main():
    # Testing
    pm = ProjectManager()
    # setting workspace
    print("getCurrentDir %s" % pm.getCurrentDir())
    # print "setting workspace"
    pm.setWorkSpaceDir("/home/bakry/fobosworkspace")
    # print "get workspace %s" % (pm.getWorkSpaceDir())

    # using default workspace
    print("Default workspace")
    # pm.setWorkSpaceDir("default")
    print("get workspace %s" % (pm.getWorkSpaceDir()))
    # creating project directory
    print("Getting project directory")
    pm.setProjName("aes")
    print(pm.getProjDir())
    # getting capture directory
    print("Getting capture directory")
    print(pm.getCaptureDir())
    print(pm.getCaptureDir())




if __name__ == '__main__':
    main()

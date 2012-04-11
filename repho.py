#!/usr/bin/env python
import os
import subprocess


if __name__ == "__main__":
  testingPath = "/home/user/software/repho/_repho.py"
  if os.path.exists(testingPath):
    print("testing path")
    subprocess.call([testingPath, "-p", "harmattan"])
  else:
    print("normal path")
    subprocess.call(["/opt/repho/_repho.py", "-p", "harmattan"])


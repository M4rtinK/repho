#!/usr/bin/env python
from __future__ import with_statement # for python 2.5
from gui import gui

import timer
import time
from threading import RLock

# RePho modules import
startTs = timer.start()
import options
import startup
timer.elapsed(startTs, "All modules combined")

# set current directory to the directory
# of this file
# like this, RePho can be run from absolute path
# eq.: ./opt/mieru/mieru.py -p harmattan -u harmattan
import os
abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
os.chdir(dname)

# append the platform modules folder to path
import sys
sys.path.append('platforms')

class RePho:

  def destroy(self):
    self.options.save()
    print "mieru quiting"
    self.gui.stopMainLoop()

  def __init__(self):
    # log start
    initTs = time.clock()
    self.startupTimeStamp = time.time()

    # parse startup arguments
    start = startup.Startup()
    args = start.args

    # restore the persistent options dictionary
    self.d = {}
    self.options = options.Options(self)
    # options value watching
    self.maxWatchId = 0
    self.watches = {}

    initialSize = (854,480)


    # get the platform module
    self.platform = None

    if args.p:
      if args.p == "maemo5":
        import maemo5
        self.platform = maemo5.Maemo5(self, GTK=False)
      elif args.p == "harmattan":
        import harmattan
        self.platform = harmattan.Harmattan(self)
      else:
        import pc
        self.platform = pc.PC(self)

    else:
      # no platform provided, fallback to PC module
      import pc
      self.platform = pc.PC(self)


    # create the GUI
    startTs1 = timer.start()

    # RePho currently has only a single GUI module
    self.gui = gui.getGui(self, 'QML', accel=True, size=initialSize)

    timer.elapsed(startTs1, "GUI module import")

    # check if a path was specified in the startup arguments
    if args.o != None:
      try:
        print("loading manga from: %s" % args.o)
        self.setActiveManga(self.openManga(args.o))
        print('manga loaded')
      except Exception, e:
        print("loading manga from path: %s failed" % args.o)
        print(e)

    """ restore previously saved state (if available and no manga was 
    sucessfully loaded from a path provided by startup arguments"""
#    self._restoreState()

#    self.gui.toggleFullscreen()

    timer.elapsed(initTs, "Init")
    timer.elapsed(startTs, "Complete startup")

    # start the main loop
    self.gui.startMainLoop()

  def getWindow(self):
    return self.window

  def notify(self, message, icon=""):
    print "notification: %s" % message
    self.platform.notify(message,icon)

  ## ** persistent dictionary handling * ##

  def getDict(self):
    return self.d

  def setDict(self, d):
    self.d = d

  def watch(self, key, callback, *args):
    """add a callback on an options key"""
    id = self.maxWatchId + 1 # TODO remove watch based on id
    self.maxWatchId = id # TODO: recycle ids ? (alla PID)
    if key not in self.watches:
      self.watches[key] = [] # create the initial list
    self.watches[key].append((id,callback,args))
    return id

  def _notifyWatcher(self, key, value):
    """run callbacks registered on an options key"""
    callbacks = self.watches.get(key, None)
    if callbacks:
      for item in callbacks:
        (id,callback,args) = item
        oldValue = self.get(key, None)
        if callback:
          callback(key,value,oldValue, *args)
        else:
          print "invalid watcher callback :", callback

  def get(self, key, default):
    """
    get a value from the persistent dictionary
    """
    try:
      return self.d.get(key, default)
    except Exception, e:
      print("options: exception while working with persistent dictionary:\n%s" % e)
      return default

  def set(self, key, value):
    """
    set a value in the persistent dictionary
    """
    self.d[key] = value
    self.options.save()
    if key in self.watches.keys():
      self._notifyWatcher(key, value)

  def _saveState(self):
    pass

  def _restoreState(self):
    pass


  def getFittingModes(self):
    """return list of fitting mode with key and description"""
    modes = [
            ("original", "fit to original size"),
            ("width", "fit to width"),
            ("height", "fit to height"),
            ("screen", "fit to screen")
            ]
    return modes

if __name__ == "__main__":
  mieru = RePho()

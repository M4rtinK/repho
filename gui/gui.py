"""a GUI chooser"""

class GUI:
  def __init__(self, repho):
    self.repho = repho

  def resize(self, w, h):
    """resize the GUI to given width and height"""
    pass

  def getWindow(self):
    """return the main window"""
    pass

  def getViewport(self):
    """return a (x,y,w,h) tupple"""
    pass

  def setWindowTitle(self, title):
    """set the window title to a given string"""
    pass

  def getToolkit(self):
    """report which toolkit the current GUI uses"""
    return

  def getAccel(self):
    """report if current GUI supports acceleration"""
    pass

  def toggleFullscreen(self):
    pass

  def startMainLoop(self):
    """start the main loop or its equivalent"""
    pass

  def stopMainLoop(self):
    """stop the main loop or its equivalent"""
    pass

  def showPreview(self, page, direction, onPressAction):
    """show a preview for a page"""
    pass

  def hidePreview(self):
    """hide any visible previews"""
    pass

  def getPage(self, flObject, name="", fitOnStart=True):
    """create a page from a file like object"""
    pass

  def showPage(self, page, mangaInstance=None, id=None):
    """show a page on the stage"""
    pass

  def getCurrentPage(self):
    """return the page that is currently shown
    if there is no page, return None"""
    pass

  def pageShownNotify(self, cb):
    """call the callback once a page is shown
    -> some large jpeg pages can take while to load"""
    pass

  def clearStage(self):
    pass

  def idleAdd(self, calllback, *args):
    pass

  def statusReport(self):
    """report current status of the gui"""
    return "It works!"

  def newActiveManga(self, manga):
    """this is a new manga instance reporting that it has been loaded
    NOTE: this can be the first manga loaded at satartup or a new manga instance
    replacing a previous one"""
    pass

  def getScale(self):
    """get current scale"""
    return None

  def getUpperLeftShift(self):
    return None

  def _destroyed(self):
    self.repho.destroy()

  def _keyPressed(self, keyName):
    self.repho.keyPressed(keyName)


def getGui(repho, type="gtk",accel=True, size=(800,480)):
  """return a GUI object"""
  if type=="gtk" and accel:
    import cluttergtk
    import clutter_gui
    return clutter_gui.ClutterGTKGUI(repho, type, size)
  elif type=="QML" and accel:
    import qml_gui
    return qml_gui.QMLGUI(repho, type, size)








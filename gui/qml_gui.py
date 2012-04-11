"""a QML GUI module for Repho"""

import sys
import re
import os
from PySide import QtCore, QtOpenGL
from PySide.QtCore import *
from PySide.QtGui import *
from PySide.QtDeclarative import *
#from PySide import QtOpenGL

import gui
import info

def newlines2brs(text):
  """ QML uses <br> instead of \n for linebreak """
  return re.sub('\n', '<br>', text)

class QMLGUI(gui.GUI):
  def __init__(self, repho, type, size=(854,480)):
    self.repho = repho

    self.activePage = None

    # Create Qt application and the QDeclarative view
    class ModifiedQDeclarativeView(QDeclarativeView):
      def __init__(self, gui):
        QDeclarativeView.__init__(self)
        self.gui = gui
        
      def closeEvent(self, event):
        print "shutting down"
        self.gui.repho.destroy()

    self.app = QApplication(sys.argv)
    self.view = ModifiedQDeclarativeView(self)
    # try OpenGl acceleration
    glw = QtOpenGL.QGLWidget()
    self.view.setViewport(glw)
    self.window = QMainWindow()
    self.window.resize(*size)
    self.window.setCentralWidget(self.view)
    self.view.setResizeMode(QDeclarativeView.SizeRootObjectToView)
#    self.view.setResizeMode(QDeclarativeView.SizeViewToRootObject)

    # add image providers
#    self.pageProvider = MangaPageImageProvider(self)
#    self.iconProvider = IconImageProvider()
#    self.view.engine().addImageProvider("page",self.pageProvider)
#    self.view.engine().addImageProvider("icons",self.iconProvider)
    rc = self.view.rootContext()
    # make the main context accessible from QML
    rc.setContextProperty("repho", Repho(self))
    # make options accessible from QML
    options = Options(self.repho)
    rc.setContextProperty("options", options)
    # make platform module accessible from QML
    platform = Platform(self.repho)
    rc.setContextProperty("platform", platform)

#    # ** history list handling **
#    # get the objects and wrap them
#    historyListController = HistoryListController(self.repho)
#    self.historyList = []
#    self.historyListModel = HistoryListModel(self.repho, self.historyList)
#    # make available from QML
#    rc.setContextProperty('historyListController', historyListController)
#    rc.setContextProperty('historyListModel', self.historyListModel)


    # Create an URL to the QML file
    print "QT VERSION"
    print QtCore.__version_info__
    if QtCore.__version_info__ >= (4,7,4):
      # use QtQuick 1.1
      url = QUrl('gui/qml/main.qml')
    else:
      # QtQuick 1.0 fallback
      url = QUrl('gui/qml_1.0_fremantle/main.qml')

    # Set the QML file and show it
    self.view.setSource(url)
    self.window.closeEvent = self._qtWindowClosed

    self.rootObject = self.view.rootObject()

    self.toggleFullscreen()

    # check if first start dialog has to be shown
    if self.repho.get("QMLShowFirstStartDialog", True):
      self.rootObject.openFirstStartDialog()

#  def resize(self, w, h):
#    self.window.resize(w,h)
#
#  def getWindow(self):
#    return self.window
#
#  def setWindowTitle(self, title):
#    self.window.set_title(title)
#
  def getToolkit(self):
    return "QML"

  def toggleFullscreen(self):
    if self.window.isFullScreen():
      self.window.showNormal()
    else:
      self.window.showFullScreen()

  def startMainLoop(self):
    """start the main loop or its equivalent"""

#    # restore page centering
#    mv = self.rootObject.findChild(QObject, "mainView")
#    mv.restoreContentShift()

    # start main loop
    self.view.showFullScreen()
    self.window.show()
    self.app.exec_()

  def _qtWindowClosed(self, event):
    print('qt window closing down')
    self.repho.destroy()

  def stopMainLoop(self):
    """stop the main loop or its equivalent"""
    # notify QML GUI first
    """NOTE: due to calling Python properties
    from onDestruction handlers causing
    segfault, we need this"""
    self.rootObject.shutdown()

    # quit the application
    self.app.exit()

  def getScale(self):
    """get scale from the page flickable"""
    mv = self.rootObject.findChild(QObject, "mainView")
    return mv.getScale()

  def getUpperLeftShift(self):
    #return (pf.contX(), pf.contY())
    mv = self.rootObject.findChild(QObject, "mainView")
    return (mv.getXShift(), mv.getYShift())

  def getWindow(self):
    return self.window

  def _notify(self, text, icon=""):
    """trigger a notification using the Qt Quick Components
    InfoBanner notification"""

    # QML uses <br> instead of \n for linebreak

    text = newlines2brs(text)
    self.rootObject.notify(text)

#  def idleAdd(self, callback, *args):
#    gobject.idle_add(callback, *args)
#
#  def _destroyCB(self, window):
#    self.repho.destroy()

class MangaPageImageProvider(QDeclarativeImageProvider):
  """the MangaPageImageProvider class provides manga pages to the QML layer"""
  def __init__(self, gui):
      QDeclarativeImageProvider.__init__(self, QDeclarativeImageProvider.ImageType.Image)
      self.gui = gui

  def requestImage(self, pathId, size, requestedSize):
    (path,id) = pathId.split('|',1)
    id = int(id) # string -> integer
    (page, id) = self.gui._getPageByPathId(path, id)
    imageFileObject = page.popImage()
    img=QImage()
    img.loadFromData(imageFileObject.read())

    return img

class IconImageProvider(QDeclarativeImageProvider):
  """the IconImageProvider class provides icon images to the QML layer as
  QML does not seem to handle .. in the url very well"""
  def __init__(self):
      QDeclarativeImageProvider.__init__(self, QDeclarativeImageProvider.ImageType.Image)

  def requestImage(self, iconFilename, size, requestedSize):
    try:
      f = open('icons/%s' % iconFilename,'r')
      img=QImage()
      img.loadFromData(f.read())
      f.close()
      return img
      #return img.scaled(requestedSize)
    except Exception, e:
      print("loading icon failed", e)

class Repho(QObject):
  def __init__(self, gui):
    QObject.__init__(self)
    self.gui = gui
    self.repho = gui.repho

  @QtCore.Slot(result=str)
  def next(self):
    activeManga = self.gui.repho.getActiveManga()
    if activeManga:
      path = activeManga.getPath()
      idValid, id = activeManga.next()
      if idValid:
        return "image://page/%s|%d" % (path, id)
      else:
        return "ERROR do something else"
    else:
      return "ERROR no active manga"

  @QtCore.Slot(result=str)
  def previous(self):
    activeManga = self.gui.repho.getActiveManga()
    if activeManga:
      path = activeManga.getPath()
      idValid, id = activeManga.previous()
      if idValid:
        return "image://page/%s|%d" % (path, id)
      else:
        return "ERROR do something else"
    else:
      return "ERROR no active manga"

  @QtCore.Slot(int)
  def goToPage(self, pageNumber):
    activeManga = self.gui.repho.getActiveManga()
    if activeManga:
      id = activeManga.PageNumber2ID(pageNumber)
      activeManga.gotoPageId(id)

  @QtCore.Slot(int, str)
  def setPageID(self, pageID, mangaPath):
    activeManga = self.gui.repho.getActiveManga()
    if activeManga:
      # filter out false alarms
      if activeManga.getPath() == mangaPath:
        activeManga.setActivePageId(pageID)

  @QtCore.Slot(result=str)
  def getPrettyName(self):
    activeManga = self.gui.repho.getActiveManga()
    if activeManga:
      return activeManga.getPrettyName()
    else:
      return "Name unknown"

  @QtCore.Slot(result=str)
  def getAboutText(self):
    return newlines2brs(info.getAboutText())

  @QtCore.Slot(result=str)
  def getVersionString(self):
    return newlines2brs(info.getVersionString())

  @QtCore.Slot(result=str)
  def toggleFullscreen(self):
    self.gui.toggleFullscreen()

  @QtCore.Slot(str)
  def fileOpened(self, path):
    # remove the "file:// part of the path"
    path = re.sub('file://', '', path, 1)
    folder = os.path.dirname(path)
    self.repho.set('lastChooserFolder', folder)
    #TODO: check if it is an image before saving
    self.repho.set('lastFile', path)

  @QtCore.Slot(result=str)
  def getSavedFileSelectorPath(self):
    defaultPath = self.repho.platform.getDefaultFileSelectorPath()
    lastFolder = self.repho.get('lastChooserFolder', defaultPath)
    return lastFolder

  @QtCore.Slot(result=str)
  def getSavedFilePath(self):
    defaultPath = ""
    lastFilePath = self.repho.get('lastFile', defaultPath)
    return lastFilePath


  @QtCore.Slot()
  def updateHistoryListModel(self):
    print "updating history list model"
    """the history list model needs to be updated only before the list
    is actually shown, no need to update it dynamically every time a manga is added
    to history"""
    mangaStateObjects = [MangaStateWrapper(state) for state in self.gui.repho.getSortedHistory()]
    self.gui.historyListModel.setThings(mangaStateObjects)
    self.gui.historyListModel.reset()

  @QtCore.Slot()
  def eraseHistory(self):
    print "erasing history"
    """the history list model needs to be updated only before the list
    is actually shown, no need to update it dynamically every time a manga is added
    to history"""
    self.gui.repho.clearHistory()

  @QtCore.Slot(result=float)
  def getActiveMangaScale(self):
    """return the saved scale of the currently active manga"""
    activeManga = self.repho.getActiveManga()
    if activeManga:
      return activeManga.getScale()
    else:
      return 1.0

  @QtCore.Slot(result=float)
  def getActiveMangaShiftX(self):
    """return the saved X shift of the currently active manga"""
    activeManga = self.repho.getActiveManga()
    print self.repho.getActiveManga()
    if activeManga:
      return activeManga.getShiftX()
    else:
      return 0.0

  @QtCore.Slot(result=float)
  def getActiveMangaShiftY(self):
    """return the saved Y shift of the currently active manga"""
    activeManga = self.repho.getActiveManga()
    if activeManga:
      return activeManga.getShiftY()
    else:
      return 0.0

  @QtCore.Slot()
  def quit(self):
    """shut down repho"""
    self.gui.repho.destroy()


class Stats(QtCore.QObject):
  """make stats available to QML and integrable as a property"""
  def __init__(self, stats):
      QtCore.QObject.__init__(self)
      self.stats = stats

  @QtCore.Slot(bool)
  def setOn(self, ON):
    self.repho.stats.setOn(ON)

  @QtCore.Slot()
  def reset(self):
    self.stats.resetStats()

  @QtCore.Slot(result=str)
  def getStatsText(self):
      print ""

  def _get_statsText(self):
    text = newlines2brs(re.sub('\n', '<br>', self.stats.getStatsText(headline=False)))
    return text

  def _set_statsText(self, statsText):
    """if this method is called, it should trigger the
    usual property changed notification
    NOTE: as the Info page is loaded from file each time
    it is opened, the stats text is updated on startup and
    thus this method doesn't need to be called"""
    self.on_statsText.emit()

  def _get_enabled(self):
    return self.stats.isOn()

  def _set_enabled(self, value):
    self.stats.setOn(value)
    self.on_enabled.emit()

  on_statsText = QtCore.Signal()
  on_enabled = QtCore.Signal()

  statsText = QtCore.Property(str, _get_statsText, _set_statsText,
          notify=on_statsText)
  enabled = QtCore.Property(bool, _get_enabled, _set_enabled,
          notify=on_enabled)

class Platform(QtCore.QObject):
  """make stats available to QML and integrable as a property"""
  def __init__(self, repho):
    QtCore.QObject.__init__(self)
    self.repho = repho

  @QtCore.Slot()
  def minimise(self):
    return self.repho.platform.minimise()

  @QtCore.Slot(result=bool)
  def showMinimiseButton(self):
    """
    Harmattan handles this by the Swype UI and
    on PC this should be handled by window decorator
    """
    return self.repho.platform.showMinimiseButton()

  @QtCore.Slot(result=bool)
  def showQuitButton(self):
    """
    Harmattan handles this by the Swype UI and
    on PC it is a custom to have the quit action in the main menu
    """
    return self.repho.platform.showQuitButton()

  @QtCore.Slot(result=bool)
  def incompleteTheme(self):
    """
    The theme is incomplete, use fail-safe or local icons.
    Hopefully, this can be removed once the themes are in better shape.
    """
    # the Fremantle theme is incomplete
    return self.repho.platform.getIDString() == "maemo5"

class Options(QtCore.QObject):
  """make options available to QML and integrable as a property"""
  def __init__(self, repho):
      QtCore.QObject.__init__(self)
      self.repho = repho

  """ like this, the function can accept
  and return different types to and from QML
  (basically anything that matches some of the decorators)
  as per PySide developers, there should be no perfromance
  penalty for doing this and the order of the decorators
  doesn't mater"""
  @QtCore.Slot(str, bool, result=bool)
  @QtCore.Slot(str, int, result=int)
  @QtCore.Slot(str, str, result=str)
  @QtCore.Slot(str, float, result=float)
  def get(self, key, default):
    """get a value from Rephos persistent options dictionary"""
    print "GET"
    print key, default, self.repho.get(key, default)
    return self.repho.get(key, default)


  @QtCore.Slot(str, bool)
  @QtCore.Slot(str, int)
  @QtCore.Slot(str, str)
  @QtCore.Slot(str, float)
  def set(self, key, value):
    """set a keys value in Rephos persistent options dictionary"""
    print "SET"
    print key, value
    return self.repho.set(key, value)

  # for old PySide versions that don't support multiple
  # function decorations

  @QtCore.Slot(str, bool, result=bool)
  def getB(self, key, default):
    print "GET"
    print key, default, self.repho.get(key, default)
    return self.repho.get(key, default)

  @QtCore.Slot(str, str, result=str)
  def getS(self, key, default):
    print "GET"
    print key, default, self.repho.get(key, default)
    return self.repho.get(key, default)

  @QtCore.Slot(str, int, result=int)
  def getI(self, key, default):
    print "GET"
    print key, default, self.repho.get(key, default)
    return self.repho.get(key, default)

  @QtCore.Slot(str, float, result=float)
  def getF(self, key, default):
    print "GET"
    print key, default, self.repho.get(key, default)
    return self.repho.get(key, default)

  @QtCore.Slot(str, bool)
  def setB(self, key, value):
    print "SET"
    print key, value
    return self.repho.set(key, value)

  @QtCore.Slot(str, str)
  def setS(self, key, value):
    print "SET"
    print key, value
    return self.repho.set(key, value)

  @QtCore.Slot(str, int)
  def setI(self, key, value):
    print "SET"
    print key, value
    return self.repho.set(key, value)

  @QtCore.Slot(str, float)
  def setF(self, key, value):
    print "SET"
    print key, value
    return self.repho.set(key, value)



# ** history list wrappers **

class MangaStateWrapper(QtCore.QObject):
  def __init__(self, state):
    QtCore.QObject.__init__(self)
    # unwrap the history storage wrapper
    state = state['state']
    self.path = state['path']
    self.mangaName = manga_module.path2prettyName(self.path)
    self.pageNumber = state['pageNumber'] + 1
    self.pageCount = state['pageCount']
    self.state = state
    self._checked = False

  def __str__(self):
    return u'%s %d/%d'.encode('utf-8') % (self.mangaName, self.pageNumber, self.pageCount)

  def _name(self):
    """NOTE: str(self) won't work due to some unicode issues"""
    return self.__str__()

  def is_checked(self):
    return self._checked

  def toggle_checked(self):
    self._checked = not self._checked
    self.changed.emit()

  # signals
  changed = QtCore.Signal()

  # setup the Qt properties
  name = QtCore.Property(unicode, _name, notify=changed)
  checked = QtCore.Property(bool, is_checked, notify=changed)

class HistoryListModel(QtCore.QAbstractListModel):
  COLUMNS = ('thing',)

  def __init__(self, repho, things):
    QtCore.QAbstractListModel.__init__(self)
    self.repho = repho
    self._things = things
    self.setRoleNames(dict(enumerate(HistoryListModel.COLUMNS)))

  def setThings(self, things):
    #print "SET THINGS"
    self._things = things

  def rowCount(self, parent=QtCore.QModelIndex()):
    #print "ROW"
    #print self._things
    return len(self._things)

  def checked(self):
    return [x for x in self._things if x.checked]

  def data(self, index, role):
    #print "DATA"
    #print self._things
    return self._things[index.row()]
#    if index.isValid() and role == HistoryListModel.COLUMNS.index('thing'):
#      return self._things[index.row()]
#    return None

  @QtCore.Slot()
  def removeChecked(self):
    paths = []
    checked = self.checked()
    #count = len(self.checked())
    for state in checked:
      paths.append(state.path)
    print paths
    self.repho.removeMangasFromHistory(paths)
    # quick and dirty remove
    for state in checked:
      self._things.remove(state)

class HistoryListController(QtCore.QObject):
  def __init__(self, repho):
    QtCore.QObject.__init__(self)
    self.repho = repho
        
  @QtCore.Slot(QtCore.QObject)
  def thingSelected(self, wrapper):
    self.repho.openMangaFromState(wrapper.state)

  @QtCore.Slot(QtCore.QObject, QtCore.QObject)
  def toggled(self, model, wrapper):
    wrapper.toggle_checked()
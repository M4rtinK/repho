"""a Repho information providing module"""

import os

def getAboutText(forum="meego"):
  text= "<p><b>main developer:</b> Martin Kolman</p>"
  text+= '<p><b>email</b>: <a href="mailto:repho.info@gmail.com">repho.info@gmail.com</a></p>'
  text+= '<p><b>Jabber</b>: m4rtink@jabbim.cz</p>'
  text+= '<p><b>www</b>:  <a href="https://github.com/M4rtinK/repho">https://github.com/M4rtinK/repho</a></p>'

  # TODO: add discussion link once a discussion thread exists
  #text+= '<p><b>discussion</b>: check <a href="http://talk.maemo.org/showthread.php?t=73907">talk.maemo.org thread</a></p>'
  return text

def getVersionString():
  versionString = "unknown version"
  versionFilePath = 'version.txt'

  # try read the version file
  if os.path.exists(versionFilePath):
    try:
      f = open(versionFilePath, 'r')
      versionString = f.read()
      f.close()
      # is it really a string ?
      versionString = str(versionString)

    except Exception, e:
      print "loading version info failed"
      print e

  return versionString








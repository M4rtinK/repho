"""args.py a mieru CLI processor
- it gets the commandline arguments and decides what to do
"""
#noinspection PyCompatibility
import argparse

class Startup():
  def __init__(self):
    parser = argparse.ArgumentParser(description="A flexible re-photography tool.")
    parser.add_argument('-p',
                        help="specify the platform", default="pc",
                        action="store", choices=["maemo5", "harmattan", "pc"])
    parser.add_argument('-o',
                        help="specify path to an old photo to open", default=None,
                        action="store", metavar="path to file",)
    self.args = parser.parse_args()


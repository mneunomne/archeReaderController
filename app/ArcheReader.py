import cv2
from globals import *

class ArcheReader:
  
  capture = None
  
  def __init__(self, test=False):
    self.test = test
    self.init()
  
  def init(self):
    # if test enabled, use static image
    if self.test == False:
      self.capture = cv2.VideoCapture(WEBCAM)
    self.run()
  
  def get_image(self):
    # if test enabled, use static image
    if self.test:
      return "test.jpg"
    # get current frame from webcam
    if self.capture == None:
      self.capture = cv2.VideoCapture(WEBCAM)
    if self.capture.isOpened():
      #do something
      ret, frame = self.capture.read()
      return frame
    else:
      print("Cannot open camera")
    
  def run(self):
    while True:
      # display image
      image = self.get_image()
      cv2.imshow('frame', image)
      if cv2.waitKey(1) & 0xFF == ord('q'):
        break
    # When everything done, release the capture
    self.capture.release()
    cv2.destroyAllWindows()
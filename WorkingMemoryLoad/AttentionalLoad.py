#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue Jan 10 11:48:56 2017

@author: labpc
"""


from psychopy import visual, core, event
from numpy.random import rand as ran
from numpy import sqrt
import time
import numpy
import csv

# setting stimulation parameters
blocks = 2
numStim = 40 #pr block
squareProb = 0.8

stimTime = 0.5
blankTime = 0.3 
jitter = 0.3

h = 1
w = 1
d = sqrt(h**2+w**2)
square = ((-h,-w),(-h,w),(h,w),(h,-w ))
diamond = ((0,d),(-d,0),(0,-d),(d,0))

responseTimes = numpy.zeros(numStim*blocks)

output = []

# dependent variables
stims = ran(numStim)
squareStims = stims<squareProb
SS = list(squareStims)
squareIdx  = [i for i in range(0,len(SS)) if SS[i]]
diamondIdx = [i for i in range(0,len(SS)) if not(SS[i])]
stimulus = list(stims)
for i in squareIdx: stimulus[i] = 1
for i in diamondIdx: stimulus[i] = 2

# getting user input
Participant = raw_input("Please enter participant number: ")
Session = raw_input("Please enter session number: ")


#create a window
mywin = visual.Window([800,600],monitor="testMonitor", units="deg")
fixation = visual.GratingStim(win=mywin, size=0.2, pos=[0,0], sf=0, rgb=-1)

#drawing initial window
while True:
    stim1 = visual.TextStim(win=mywin,text='Welcome to the test of doom!',pos=(0.0,1.5))
    stim2 = visual.TextStim(win=mywin,
            text='Press a button',pos=(0.0,-1.5))
    stim3 = visual.TextStim(win=mywin,
            text='to challenge your destiny!',pos=(0.0,-3.0))
    stim1.draw()
    stim2.draw()
    stim3.draw()
    mywin.flip()
    if len(event.getKeys())>0: break

# giving information to participants
info = ['In this experiment we will test your working memory. \n\nYou will be shown a sequence of letters, and we ask you a short amount of time.\n\n If you have any questions, please ask us. If not, press any button to continue the experiment.']
while True:
    stim = visual.TextStim(win=mywin,text='Instructions:',pos=(0.0,7.0),height=1.)
    stim1 = visual.TextStim(win=mywin,text=info[0],pos=(0.0,3.0),height=0.5)
    stim2 = visual.ShapeStim(win=mywin, vertices = square,pos=(-4.0,-3.0),fillColor='green')
    stim3 = visual.ShapeStim(win=mywin, vertices = diamond,pos=(4.0,-3.0),fillColor='green')
    stim4 = visual.TextStim(win=mywin,text='press when you see this',pos=(-4.0,-5.0),height=0.5)
    stim5 = visual.TextStim(win=mywin,text='not when you see this',pos=(4.0,-5.0),height=0.5)
    stim.draw()
    stim1.draw()
    stim2.draw()
    stim3.draw()
    stim4.draw()
    stim5.draw()
    mywin.flip()
    if len(event.getKeys())>0: break

# starting experiment
stim1 = visual.TextStim(win=mywin,text='get ready ...',pos=(0.0,1.0))
stim2 = visual.TextStim(win=mywin,text='3',pos=(0.0,-1.0))
stim1.draw()
stim2.draw()
mywin.flip()
time.sleep(1)

stim1 = visual.TextStim(win=mywin,text='get ready ...',pos=(0.0,1.0))
stim2 = visual.TextStim(win=mywin,text='2',pos=(0.0,-1.0))
stim1.draw()
stim2.draw()
mywin.flip()
time.sleep(1)

stim1 = visual.TextStim(win=mywin,text='get ready ...',pos=(0.0,1.0))
stim2 = visual.TextStim(win=mywin,text='1',pos=(0.0,-1.0))
stim1.draw()
stim2.draw()
mywin.flip()
time.sleep(1)

#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue Dec 13 16:35:11 2016

@author: labpc
"""

from psychopy import visual, core, event
from numpy.random import rand as ran
from numpy.random import randint as rint
from numpy import sqrt
import time
import numpy
import csv

date = time.strftime("%Y%m%d")

# setting stimulation parameters
numBlocks = 5
numStim = 30 #pr block

numLetters = 12
numColors = 5
numCases = 2
numTargets = 4

stimTime = 0.70
blankTime = 0.2 
jitter = 0.2

letters = [['a', 'd', 't', 'x', 'q', 'w', 'r', 'p', 's', 'f', 'g', 'h', 'j', 'k', 'l', 'z', 'c', 'v', 'b', 'n', 'm'],
           ['A', 'D', 'T', 'X', 'Q', 'W', 'R', 'P', 'S', 'F', 'G', 'H', 'J', 'K', 'L', 'Z', 'C', 'V', 'B', 'N', 'M']]
colorNames = ['cyan', 'yellow', 'black', 'magenta', 'red']
colors = [(-1.,1.,1.),(1.,1.,-1.),(-1.,-1.,-1.),(1.,-1.,1.),(1.,-1.,-1.)]
targets = ['A', 'D', 'T', 'X']


responseTimes = numpy.zeros(numStim*numBlocks)
output = []

# dependent variables
stimLetter = rint(0,numLetters,(numStim,numBlocks))
stimColor = rint(0,numColors,(numStim,numBlocks))
stimCase = rint(0,numCases,(numStim,numBlocks))
stimTarget = []
for i in range(numBlocks):
    stimTarget.append(targets[i%4])

# getting user input
Participant = raw_input("Please enter participant number: ")
Session = raw_input("Please enter session number: ")


#create a window
mywin = visual.Window([1300,700],monitor="testMonitor", units="deg",color=[0.0,0.0,0.0])
fixation = visual.GratingStim(win=mywin, size=0.2, pos=[0,0], sf=0, rgb=-1)

#drawing initial window
while True:
    stim1 = visual.TextStim(win=mywin,text='Welcome!',pos=(0.0,1.5))
    stim2 = visual.TextStim(win=mywin,
            text='Press any button',pos=(0.0,-1.5))
    stim3 = visual.TextStim(win=mywin,
            text='to start.',pos=(0.0,-3.0)) 
    stim1.draw()
    stim2.draw()
    stim3.draw()
    mywin.flip()
    if len(event.getKeys())>0: break

# giving information to participants
info = ['In this experiment we will test your attention and reaction time. You will be shown two different letters in rapid succession, and should press space whenever your target letter appears. \n\nYour goal is to press space as quickly as possible whenever you see your target letter. Otherwise, you should not press any button.\n\n If you have any questions, please ask us. If not, press any button to continue the experiment.']
while True:
    stim = visual.TextStim(win=mywin,text='Instructions:',pos=(0.0,7.0),height=1.)
    stim1 = visual.TextStim(win=mywin,text=info[0],pos=(0.0,3.0),height=0.5)
    stim.draw()
    stim1.draw()
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

DynamicBlockUpdate = False
DynamicTrialUpdate = False
    
for i in range(0,numBlocks):   
    stim1 = visual.TextStim(win=mywin,text='Your target is:',pos=(0.0,4.0),height=1.)
    stim2 = visual.TextStim(win=mywin,text=stimTarget[i],pos=(0.0,0.0),height=3.)
    stim1.draw()
    stim2.draw()
    mywin.flip()
    time.sleep(2)
    mywin.flip()
    time.sleep(blankTime)
    
    # Update parameters for the block
    if DynamicBlockUpdate:
        stimeTime = stimTime
        blankTime = blankTime
        jitter = jitter
        
    #draw the stimuli and update the window
    for a in range(0,numStim): 
        # Update parameters for the trial
        if DynamicTrialUpdate:
            stimeTime = stimTime
            blankTime = blankTime
            jitter = jitter 
            
        stim = visual.TextStim(win=mywin,text=letters[stimCase[a][i]][stimLetter[a][i]],pos=(0.0,0.0),height=3.,
                               color=colors[stimColor[a][i]])
      
        # Presenting stimulus 
        startTime = time.time()
        t = time.time()+stimTime
        while time.time()<t:
            stim.draw()
            mywin.flip()
            if len(event.getKeys())>0:  
                responseTimes[a]=time.time()-startTime
                break
            event.clearEvents()
      
        trialJit = ran()*jitter
        t = time.time()+blankTime+trialJit
        while time.time()<t:
            fixation.draw()
            mywin.flip()
            if len(event.getKeys())>0:  
                responseTimes[a]=time.time()-startTime
                event.clearEvents()
      
                    #output.append([])
        output.append([int(date), int(Participant), int(Session),i, a, stimTarget[i],
                       letters[stimCase[a][i]][stimLetter[a][i]], colorNames[stimColor[a][i]],
                       responseTimes[a],stimTime,blankTime,trialJit])
      #  if len(event.getKeys())>0: break
      #  
        
#txt = 'You made '+str(errors)+' errors...'
txt = 'Thank you for participating :)'

#drawing initial window
while True:
    stim1 = visual.TextStim(win=mywin,text=txt)
    stim1.draw()
    mywin.flip()
    if len(event.getKeys())>0: break

print output


# write it
with open('Bekinschtein_data.csv', 'a') as csvfile:
    writer = csv.writer(csvfile)
    [writer.writerow(r) for r in output]
     
    
    
#cleanup
mywin.close()
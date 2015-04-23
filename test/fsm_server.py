#!/usr/bin/env python
import socket 

class ExceptionFSM(Exception):

    """This is the FSM Exception class."""

    def __init__(self, value):
        self.value = value

    def __str__(self):
        return `self.value`

class FSM:

    """This is a Finite State Machine (FSM).
    """
    
    def __init__(self, initial_state,server,port):

        # Map transition(input_event, current_state) --> (transition action, next_state).
        self.state_transitions = {}
		# Map (current_state) --> (action during the state)
        self.state_actions = {}

        self.transition_action = None
        self.input_event = None
        self.initial_state = initial_state
        self.current_state = self.initial_state
        self.next_state = None

		# Networking part
        self.sock=socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.server=server
        self.port=int(port)


    def reset (self):
        self.current_state = self.initial_state
        self.input_event = None

    def add_transition (self, input_event, state, action=None, next_state=None):
        if next_state is None:
            next_state = state
        self.state_transitions[(input_event, state)] = (action, next_state)

    def set_default_transition (self, action, next_state):
        self.default_transition = (action, next_state)

    def get_transition (self, input_event, state):
        if self.state_transitions.has_key((input_event, state)):
            return self.state_transitions[(input_event, state)]
        else:
            raise ExceptionFSM ('Transition is undefined: (%s, %s).' %
                (str(input_event), str(state)) )

    def add_state_action (self, state, action=None):
        self.state_actions[state] = action

    def process (self, input_event):
        try:
            (self.transition_action, self.next_state) = self.get_transition (self.input_event, self.current_state)
            if self.transition_action is not None:
                self.transition_action(self)
            self.current_state = self.next_state
            self.next_state = None
            print "Entering state", self.current_state
            if self.state_actions[self.current_state] is not None:
                self.state_actions[self.current_state](self)
        except ExceptionFSM, e:
            print "ERROR, FSM STOPPED !"
            print str(e)
            os._exit(1)

    def start_fsm(self):
        print "Entering initial state", self.current_state
        if self.state_actions[self.current_state] is not None:
            self.state_actions[self.current_state](self)



import sys, os, traceback, optparse, time, string

# Define the actions of the transitions triggerred by the input events. 
def sendHello (fsm):
    print "TRANSITION ==> sending HELLO"
    fsm.sock.sendto('HELLO', (fsm.server, fsm.port))

def sendBye (fsm):
    print "TRANSITION ==> sending BYE"
    fsm.sock.sendto('BYE', (fsm.server, fsm.port))

# Define the actions for states 
def unregistered(fsm):
    print "STATE ",fsm.current_state," ==> updating my HTTP server..."
    print "STATE ",fsm.current_state," ==> waiting for new events !"
    msg = raw_input()
    if (msg == 'H'):
        event='SAY_HELLO'
    elif (msg == 'S'):
	    event='STOP'
    else:
        event='UNDEFINED'
    fsm.input_event=event

def registering(fsm):
    print "STATE ",fsm.current_state," ==> Waiting for server response !"
    msg, rserver = fsm.sock.recvfrom(255)
    if (msg == 'RECORDED'):
        event= 'RECORDED'
    elif (msg == 'BYE'):
        event='HAS_FAILED'
    elif (msg == 'S'):
	    event='STOP'
    else:
        event='UNDEFINED'
    fsm.input_event = event

def registered(fsm):
    print "STATE ",fsm.current_state," ==> updating my HTTP server..."
    print "STATE ",fsm.current_state," ==> waiting for new events !"
    msg = raw_input()
    if (msg == 'B'):
	    event='BYE'
    elif (msg == 'S'):
	    event='STOP'
    else:
        event='UNDEFINED'
    fsm.input_event=event


# Main program

f = FSM ('UNREGISTERED',sys.argv[1],sys.argv[2])
# TRANSITIONS and ASSOCIATED ACTIONS
f.add_transition      ('SAY_HELLO', 'UNREGISTERED',     sendHello,    'REGISTERING')
f.add_transition      ('HAS_FAILED','REGISTERING',      None,         'UNREGISTERED')
f.add_transition      ('RECORDED',  'REGISTERING',      None,         'REGISTERED')
f.add_transition      ('BYE',       'REGISTERED',       sendBye,      'UNREGISTERED')
# STATE ACTIONS
f.add_state_action('UNREGISTERED',unregistered)
f.add_state_action('REGISTERING',registering)
f.add_state_action('REGISTERED',registered)

# To deal with keyboard and user interaction !
print  "\n H: SAY_HELLO \n R: RECORDED \n B: BYE \n S: STOP \n anything else : UNDEFINED \n\n" 
# FSM START
f.start_fsm()
try :
    while (f.input_event!='STOP'):
        f.process(f.input_event)
except KeyboardInterrupt:
    print "Keyboard interrupt ! ==> LEAVING !"



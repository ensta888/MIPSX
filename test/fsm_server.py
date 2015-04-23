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
        try:
            self.sock.bind((self.server, self.port))
        except socket.error, err:
            print "Can not bind to port %d : %s" % (port, err)
            raise SystemExit
        self.client_sock=None
        self.NAO_dict={}


    def reset (self):
        self.current_state = self.initial_state
        self.input_event = None

    def add_transition (self, input_event, state, action=None, next_state=None):
        if next_state is None:
            next_state = state
        self.state_transitions[(input_event, state)] = (action, next_state)

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
def sendBye (fsm):
    print "TRANSITION ==> sending BYE"
    fsm.sock.sendto("BYE", (fsm.client_sock))

def sendRecorded (fsm):
    print "TRANSITION ==> sending RECORDED"
    fsm.sock.sendto("RECORDED", (fsm.client_sock))

# Define the actions for states 

def waiting_for_NAOs(fsm):
    print "STATE ",fsm.current_state," ==> waiting for NAOs ! "
    print "STATE ",fsm.current_state," ==> Known NAOs : ", fsm.NAO_dict
    msg,fsm.client_sock = fsm.sock.recvfrom(255)
    if (msg=='HELLO'):
        event = 'HELLO'
    elif (msg=='BYE'):
        event = 'BYE'
    elif (msg=='S'):
        event = 'STOP'
    else:
        event='UNDEFINED'
    fsm.input_event=event

def ip_checking(fsm):
    print "STATE ",fsm.current_state," ==> checking client IP !"
    o1=fsm.client_sock[0].split(".")[0]
    o2=fsm.client_sock[0].split(".")[1]
    o3=fsm.client_sock[0].split(".")[2]
    o4=fsm.client_sock[0].split(".")[3]
    if ((o1=='172') and (o2=='20')and (o3=='25') and int(o4)<13 and int(o4)>0):
        event='IS_NAO'
    else:
        event='NO_NAO'
    fsm.input_event=event

def recording(fsm):
    print "STATE ",fsm.current_state," ==> updating my HTTP server with a new record..."
    print "\t \t New NAO : ", fsm.client_sock
    number=fsm.client_sock[0].split(".")[3]
    name="NAO"+str(number)
    fsm.NAO_dict[name]=fsm.client_sock
    event='RECORD_DONE'
    fsm.input_event=event

def clearing_a_NAO(fsm):
    print "STATE ",fsm.current_state," ==> clearing records..."
    number=fsm.client_sock[0].split(".")[3]
    name="NAO"+str(number)
    print "STATE ",fsm.current_state," ==> removing ", name
    del fsm.NAO_dict[name]
    event='CLEAR_DONE'
    fsm.input_event=event

# Main program

f = FSM ('WAITING_FOR_NAOS',sys.argv[1],sys.argv[2])
# TRANSITIONS and ASSOCIATED ACTIONS
f.add_transition      ('HELLO',      'WAITING_FOR_NAOS',   None,         'IP_CHECKING')
f.add_transition      ('BYE',        'WAITING_FOR_NAOS',   None,         'CLEARING_A_NAO')
f.add_transition      ('IS_NAO',     'IP_CHECKING',        None,         'RECORDING')
f.add_transition      ('NO_NAO',     'IP_CHECKING',        sendBye,      'WAITING_FOR_NAOS')
f.add_transition      ('RECORD_DONE','RECORDING',          sendRecorded, 'WAITING_FOR_NAOS')
f.add_transition      ('CLEAR_DONE', 'CLEARING_A_NAO',     None,         'WAITING_FOR_NAOS')
# STATE ACTIONS
f.add_state_action('WAITING_FOR_NAOS',waiting_for_NAOs)
f.add_state_action('IP_CHECKING',ip_checking)
f.add_state_action('RECORDING',recording)
f.add_state_action('CLEARING_A_NAO',clearing_a_NAO)

# FSM START
f.start_fsm()
try :
    while (f.input_event!='STOP'):
        f.process(f.input_event)
except KeyboardInterrupt:
    print "Keyboard interrupt ! ==> LEAVING !"

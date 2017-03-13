#!/usr/bin

import time
import datetime
import logging
import re
import sys
import json
import conf

from twisted.internet import reactor, protocol
from twisted.protocols.basic import LineReceiver
from twisted.python import log
from twisted.web.client import getPage
from twisted.application import service, internet

#ProxyHerd Implementation
class ProxyHerdProtocol(LineReceiver):

    def __init__(self, factory):
        self.factory = factory

    def connectionMade(self):
        self.factory.connections += 1
        logging.info("Connection established. Total: {0}".format(self.factory.connections))

    def lineReceived(self, line):
        logging.info("Line received: {0}".format(line))
        params = line.split(" ")

        if (params[0] == "IAMAT"):
            self.process_IAMAT(line)
        elif (params[0] == "WHATSAT"):
            self.process_WHATSAT(line)
        elif (params[0] == "AT"):
            self.process_AT(line)
        else:
            self.Failure(line)
        return

    def Failure(self, line, appendix = ""):
        logging.error("Invalid command: " + line + " " + appendix)
        self.transport.write("? " + line + "\n")
        return


        #IAMAT
    def process_IAMAT(self, line):
        params = line.split(" ")
        if len(params) != 4:
            logging.error("Invalid IAMAT command: {0}".format(line))
            self.transport.write("? {0}\n".format(line))
            return

        command, clientID, position, clientTime = params
        timeDifference =  time.time() - float(params[3])

        if timeDifference >= 0:
            response = "AT {0} +{1} {2}".format(self.factory.serverName, timeDifference, line)
        else:
            response = "AT {0} {1} {2}".format(self.factory.serverName, timeDifference, line)


        if clientID in self.factory.clients:
            logging.info("Update from existing client: {0}".format(clientID))
        else:
            logging.info("New client: {0}".format(clientID))

        self.factory.clients[clientID] = {"msg":response, "time":clientTime}
        logging.info("Server response: {0}".format(response))
        self.transport.write("{0}\n".format(response))

        #propagate updates
        logging.info("Broadcasting location update to neighbors")
        self.updateLocation(response)


    #AT
    def process_AT(self, line):
        params = line.split()
        #check validity of command
        if len(params) != 7:
            logging.error("Invalid AT command: {0}".format(line))
            self.transport.write("? {0}\n".format(line))
            return

        command_AT, server, timeDifference, command_IAMAT, clientID, position, clientTime = params

        #check for duplicate update
        if (clientID in self.factory.clients) and (clientTime <= self.factory.clients[clientID]["time"]):
            logging.info("Duplicate location update from {0}".format(server))
            return

        if clientID in self.factory.clients:
            logging.info("(AT) Location update from existing client: {0}".format(clientID))
        else:
            logging.info("(AT) Location update from new client: {0}".format(clientID))

        self.factory.clients[clientID] = { "msg":("{0} {1} {2} {3} {4} {5} {6}".format(command_AT, server, timeDifference, command_IAMAT, clientID, position, clientTime)),
                                           "time":clientTime }
        logging.info("Added {0} : {1}".format(clientID, self.factory.clients[clientID]["msg"]))


        self.updateLocation(self.factory.clients[clientID]["msg"])
        return


    #WHATSAT
    def process_WHATSAT(self, line):
        params = line.split(" ")
        if len(params) != 4:
            logging.error("Invalid WHATSAT command: {0}".format(line))
            self.transport.write("? {0}\n".format(line))
            return
        command_WHATSAT, clientID, radius, limit = params

        #cache check
        stored_response = self.factory.clients[clientID]["msg"]
        logging.info("Stored response: {0}".format(stored_response))
        command_AT, server, timeDifference, command_IAMAT, clientID_2, position, clientTime = stored_response.split()


        position = re.sub(r'[-]', ' -', position)
        position = re.sub(r'[+]', ' +', position).split()
        position_calibrated = position[0] + "," + position[1]

        #API CALLS
        request = "{0}location={1}&radius={2}&sensor=false&key={3}".format(conf.API_ENDPOINT, position_calibrated, radius, conf.API_KEY)
        logging.info("API request: {0}".format(request))
        response = getPage(request)

        response.addCallback(callback = lambda x:(self.jsonPrint(x, clientID, limit)))




    #auxiliary functions
    def jsonPrint(self, response, clientID, limit):
        data = json.loads(response)
        results = data["results"]

        #filter out
        data["results"] = results[0:int(limit)]
        logging.info("API Response: {0}".format(json.dumps(data, indent=4)))
        msg = self.factory.clients[clientID]["msg"]

        full_response = "{0}\n{1}\n\n".format(msg, json.dumps(data, indent=4))
        self.transport.write(full_response)


    def connectionLost(self, reason):
        self.factory.connections -= 1
        logging.info("Connection was lost. Total now = {0}".format(self.factory.connections))


    def updateLocation(self, message):
        for n in conf.NEIGHBORS[self.factory.serverName]:
            reactor.connectTCP('localhost', conf.PORT_NUM[n], ProxyHerdClient(message))
            logging.info("Updated location sent by client {0} to client {1}".format(self.factory.serverName, n))
        return



#ProxyHerdServer
class ProxyHerdServer(protocol.ServerFactory):
    def __init__(self, serverName):
        self.serverName = serverName
        self.portNum = conf.PORT_NUM[self.serverName]
        self.clients = {}
        self.connections = 0

        #create log file with timestamp
        filename = self.serverName + "_" + re.sub(r'[:T]', '_', datetime.datetime.utcnow().isoformat().split('.')[0]) + ".log"
        logging.basicConfig(filename = filename, level=logging.DEBUG)
        logging.info('{0}:{1} server started'.format(self.serverName, self.portNum))

    def buildProtocol(self, addr):
        return ProxyHerdProtocol(self)

    def stopFactory(self):
        logging.info("{0} server shutdown".format(self.serverName))
    # logging.info(logMessage)



#Proxy Herd Client
class ProxyHerdClient(protocol.ClientFactory):
    def __init__(self, message):
        self.message = message

    def buildProtocol(self, addr):
        return ProxyHerdClientProtocol(self)


class ProxyHerdClientProtocol(LineReceiver):
    def __init__ (self, factory):
        self.factory = factory

    def connectionMade(self):
        self.sendLine(self.factory.message)
        self.transport.loseConnection()



#Main
def main():
    if len(sys.argv) != 2:
        print "Error:  Need 2 args"
        exit()
    serverName = sys.argv[1]
    factory = ProxyHerdServer(serverName)
    reactor.listenTCP(conf.PORT_NUM[serverName], factory)
    reactor.run()

if __name__ == '__main__':
    main()





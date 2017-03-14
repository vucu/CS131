#!/usr/bin

import re
import logging
import time
import json
import sys
import conf

from twisted.web.client import getPage
from twisted.internet import reactor, protocol
from twisted.protocols.basic import LineReceiver

def isFloat(s):
    try:
        float(s)
        return True
    except ValueError:
        return False

class ServerProtocol(LineReceiver):
    def __init__(self, factory):
        self.factory = factory

    def connectionMade(self):
        self.factory.connections += 1
        logging.info("Connection made. Total: {0}".format(self.factory.connections))

    def lineReceived(self, line):
        logging.info("Line received: {0}".format(line))
        params = line.split(" ")

        if params[0] == "IAMAT":
            self.process_IAMAT(line)
        elif params[0] == "WHATSAT":
            self.process_WHATSAT(line)
        elif params[0] == "AT":
            self.process_AT(line)
        else:
            logging.error("? " + line)
            self.transport.write("? " + line + "\n")

        logging.info("Done!")
        return

    # IAMAT
    def process_IAMAT(self, line):
        params = line.split(" ")
        if len(params) != 4:
            logging.error("Invalid IAMAT: {0}".format(line))
            self.transport.write("? {0}\n".format(line))
            return
        logging.info("IAMAT begin")

        token = params[0]
        client_id = params[1]
        position = params[2]
        client_time = params[3]
        time_difference = time.time() - float(params[3])

        if "+" not in position and "-" not in position:
            logging.error("Invalid IAMAT location")
            self.transport.write("Invalid IAMAT location\n")
            return
        location = position.replace("+", " +").replace("-", " -").split()
        if len(location) != 2 or (not isFloat(location[0]) or not isFloat(location[1])):
            logging.error("Invalid IAMAT location")
            self.transport.write("Invalid IAMAT location\n")
            return
        if not isFloat(client_time):
            logging.error("Invalid IAMAT time")
            self.transport.write("Invalid IAMAT time\n")
            return

        if time_difference >= 0:
            response = "AT {0} +{1} {2}".format(self.factory.serverName, time_difference, line)
        else:
            response = "AT {0} {1} {2}".format(self.factory.serverName, time_difference, line)

        if client_id in self.factory.clients:
            logging.info("Update from existing client: {0}".format(client_id))
        else:
            logging.info("New client: {0}".format(client_id))

        self.factory.clients[client_id] = {"msg": response, "time": client_time}
        logging.info("Response: {0}".format(response))
        self.transport.write("{0}\n".format(response))

        logging.info("Propagate to neighbors")
        for n in conf.NEIGHBORS[self.factory.serverName]:
            reactor.connectTCP('localhost', conf.PORT_NUM[n], Client(response))
            logging.info("Success! {0} propagated to {1}".format(self.factory.serverName, n))

    # WHATSAT
    def process_WHATSAT(self, line):
        params = line.split(" ")
        if len(params) != 4:
            logging.error("Invalid WHATSAT: {0}".format(line))
            self.transport.write("? {0}\n".format(line))
            return
        logging.info("WHATSAT begin")

        token = params[0]
        client_id = params[1]
        radius = params[2]
        limit = params[3]

        if not isFloat(radius):
            logging.error("Invalid radius")
            self.transport.write("Invalid radius\n")
            return
        if float(radius) <= 0 or float(radius) > 50:
            logging.error("Radius not in range")
            self.transport.write("Radius not in range\n")
            return
        if not limit.isdigit():
            logging.error("Invalid limit")
            self.transport.write("Invalid limit\n")
            return
        if int(limit) <= 0 or int(limit) > 20:
            logging.error("Limit not in range")
            self.transport.write("Limit not in range\n")
            return

        if client_id not in self.factory.clients:
            logging.error("Client not found")
            self.transport.write("Client not found\n")
            return

        cache_response = self.factory.clients[client_id]["msg"]
        logging.info("Cache response: {0}".format(cache_response))
        cache_params = cache_response.split()
        at = cache_params[0]
        server = cache_params[1]
        time_difference = cache_params[2]
        iamat = cache_params[3]
        client_id2 = cache_params[4]
        position = cache_params[5]
        client_time = cache_params[6]

        position = re.sub(r'[-]', ' -', position)
        position = re.sub(r'[+]', ' +', position).split()
        position_xy = position[0] + "," + position[1]

        request = "{0}location={1}&radius={2}&sensor=false&key={3}".format(
            conf.API_ENDPOINT,
            position_xy,
            radius,
            conf.API_KEY)
        logging.info("Google Place request: {0}".format(request))
        response = getPage(request)

        response.addCallback(callback=lambda x: (self.print_json(x, client_id, limit)))

    # AT
    def process_AT(self, line):
        params = line.split()
        if len(params) != 7:
            logging.error("Invalid AT: {0}".format(line))
            self.transport.write("? {0}\n".format(line))
            return
        logging.info("AT begin")

        token = params[0]
        server = params[1]
        time_difference = params[2]
        iamat = params[3]
        client_id = params[4]
        position = params[5]
        client_time = params[6]

        if server not in conf.PORT_NUM:
            logging.error("Invalid server name")
            return
        if not isFloat(client_time):
            logging.error("Invalid client time")
            return

        # check duplicate
        if (client_id in self.factory.clients) and (client_time <= self.factory.clients[client_id]["time"]):
            logging.info("Duplicate from {0}".format(server))
            return

        if client_id in self.factory.clients:
            logging.info("(AT) Update from existing client: {0}".format(client_id))
        else:
            logging.info("(AT) Update from new client: {0}".format(client_id))

        self.factory.clients[client_id] = {"msg": (
            "{0} {1} {2} {3} {4} {5} {6}".format(token, server, time_difference, iamat, client_id, position,
                                                 client_time)),
            "time": client_time}
        logging.info("Added {0} : {1}".format(client_id, self.factory.clients[client_id]["msg"]))

        logging.info("Propagate to neighbors")
        response = self.factory.clients[client_id]["msg"]
        for n in conf.NEIGHBORS[self.factory.serverName]:
            reactor.connectTCP('localhost', conf.PORT_NUM[n], Client(response))
            logging.info("Success! {0} propagated to {1}".format(self.factory.serverName, n))
        return

    def print_json(self, response, client_id, limit):
        data = json.loads(response)
        results = data["results"]
        data["results"] = results[0:int(limit)]
        logging.info("Google Place response: {0}".format(json.dumps(data, indent=4)))
        msg = self.factory.clients[client_id]["msg"]
        full_response = "{0}\n{1}\n\n".format(msg, json.dumps(data, indent=4))
        self.transport.write(full_response)

    def connectionLost(self, reason):
        self.factory.connections -= 1
        logging.info("Lost connection. Total: {0}".format(self.factory.connections))



class Server(protocol.ServerFactory):
    def __init__(self, serverName):
        self.serverName = serverName
        self.portNum = conf.PORT_NUM[self.serverName]
        self.clients = {}
        self.connections = 0

        filename = self.serverName + ".log"
        logging.basicConfig(filename=filename, level=logging.DEBUG)
        logging.info('Log start')
        logging.info('Server {0}'.format(self.serverName))
        logging.info('Port {0}'.format(self.portNum))

    def buildProtocol(self, addr):
        return ServerProtocol(self)

    def stopFactory(self):
        logging.info("Server terminated")


class ClientProtocol(LineReceiver):
    def __init__(self, factory):
        self.factory = factory

    def connectionMade(self):
        self.sendLine(self.factory.message)
        self.transport.loseConnection()


class Client(protocol.ClientFactory):
    def __init__(self, message):
        self.message = message

    def buildProtocol(self, addr):
        return ClientProtocol(self)


def main():
    if len(sys.argv) != 2:
        print "usage: server.py [SERVER_NAME].\n"
        exit()
    server_name = sys.argv[1]
    if server_name not in conf.PORT_NUM:
        print "Invalid Server Name " + server_name + ".\n"
        exit(1)
    factory = Server(server_name)
    reactor.listenTCP(conf.PORT_NUM[server_name], factory)
    reactor.run()


if __name__ == '__main__':
    main()

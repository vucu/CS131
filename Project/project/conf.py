# A configuration file for the Twisted Places proxy herd

# Google Places API key
API_KEY="AIzaSyCnI8rdETbHR_UNbw1sEkPzDdPRdRMZdBI"
# Google Places Nearby API Endpoint
API_ENDPOINT="https://maps.googleapis.com/maps/api/place/nearbysearch/json?"

# TCP port numbers for each server instance (server ID: case sensitive)
# Please use the port numbers allocated by the TA.
PORT_NUM = {
    'Alford': 12130,
    'Ball': 12131,
    'Hamilton': 12132,
    'Holiday': 12133,
    'Welsh': 12134
}

# Each Server can talk with other servers within the given 5, and we define
# a neighbor as a server another server can talk to. Note that this communication
# is bidirectional.
NEIGHBORS = {
	'Alford': ['Hamilton', 'Welsh'],
	'Ball': ['Holiday', 'Welsh'],
	'Hamilton': ['Holiday', 'Alford'],
	'Welsh': ['Alford', 'Ball'],
	'Holiday': ['Ball', 'Hamilton']
}

PROJ_TAG="Winter 2017"

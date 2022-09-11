//To create the constraints for the Airline and Airport Nodes to avoid duplicate id values:	
CREATE CONSTRAINT ON (a:Airline) ASSERT a.id IS UNIQUE;
CREATE CONSTRAINT ON (p:Airport) ASSERT p.id IS UNIQUE;

//To import the airline nodes:
LOAD CSV WITH HEADERS
FROM "file:///airlines.csv" AS line
WITH DISTINCT line
MERGE (airline:Airline{ id: toInteger(line.`AirlineID`)})
    set airline.Name = toUpper(line.`Name`)

//To import the airport nodes:
LOAD CSV WITH HEADERS
FROM "file:///airports.csv" AS line
WITH DISTINCT line
MERGE (airport:Airport{ id: toInteger(line.`AirportID`)})
SET airport.Name = toUpper(line.`Name`),
    airport.City = toUpper(line.`City`),
    airport.Country = toUpper(line.`Country`),
    airport.IATA = toUpper(line.`IATA`),
    airport.Latitude = line.`Latitude`,
    airport.Longitude = line.`Longitude`

//To import the route nodes:
LOAD CSV WITH HEADERS
FROM "file:///routes.csv" AS line
MERGE (r:Route {RouteID: toUpper(toString(line.Source) + toString(line.Destination))})
SET r.Airline = toInteger(line.`AirlineID`),
    r.PlaneType = toUpper(line.`Equipment`),
    r.SourceAirport = toUpper(line.Source),
    r.DestinationAirport = toUpper(line.Destination)

//To create the ‘Belongs to’ Relationship between Airlines and Routes:
MATCH (r:Route)
MATCH (airline:Airline)
WHERE r.Airline = airline.id
MERGE (r)-[:BelongsTo]->(airline)

//To create the ‘DepartsFrom’ Relationship between Airports and Routes:
MATCH (r:Route)
MATCH (airport:Airport)
WHERE r.SourceAirport = airport.IATA
MERGE (r)-[:DepartsFrom]->(airport)

//To create the ‘ArrivesTo’ Relationship between Airports and Routes:
MATCH (r:Route)
MATCH (airport:Airport)
WHERE r.DestinationAirport = airport.IATA
MERGE (r)-[:ArrivesTo]->(airport)






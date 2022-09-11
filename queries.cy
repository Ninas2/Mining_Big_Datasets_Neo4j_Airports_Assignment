// Query 1
CALL {MATCH (r:Route)-[:ArrivesTo]->(airport:Airport)
RETURN airport.Name AS `Airport Name`, COUNT(*) AS count
    UNION
MATCH (r:Route)-[:DepartsFrom]->(airport:Airport)
RETURN airport.Name AS `Airport Name`, COUNT(*) AS count
}
RETURN `Airport Name`, SUM(count) AS `Total Flights`
ORDER BY `Total Flights` DESC
LIMIT 5;


// Query 2
MATCH (a:Airport)
RETURN a.Country AS Country, COUNT(*) AS count
ORDER BY count DESC
LIMIT 5;


// Query 3
MATCH (rin:Route)-[:ArrivesTo]->(airin:Airport)
MATCH (rin)-[:DepartsFrom]->(airout:Airport)
MATCH (rin)-[:BelongsTo]->(airline:Airline)
WHERE ((airin.Country<>'GREECE' AND airout.Country='GREECE')
OR (airin.Country='GREECE' AND airout.Country<>'GREECE'))
RETURN airline.Name AS `Airline Name`, COUNT(*) AS `Total Flights From/To Greece`
ORDER BY `Total Flights From/To Greece` DESC
LIMIT 5;


// Query 4
MATCH (rin:Route)-[:ArrivesTo]->(airin:Airport)
MATCH (rin)-[:DepartsFrom]->(airout:Airport)
MATCH (rin)-[:BelongsTo]->(airline:Airline)
WHERE ((airin.Country='GERMANY' AND airout.Country='GERMANY'))
RETURN airline.Name AS `Airline Name`, COUNT(*) AS `Local Flights in Germany`
ORDER BY `Local Flights in Germany` DESC
LIMIT 5;


// Query 5
MATCH (rin:Route)-[:ArrivesTo]->(airin:Airport)
MATCH (rin)-[:DepartsFrom]->(airout:Airport)
MATCH (rin)-[:BelongsTo]->(airline:Airline)
WHERE ((airin.Country='GREECE') AND (airout.Country <> 'GREECE'))
RETURN airout.Country AS `Country`, COUNT(*) AS `Flights to Greece`
ORDER BY `Flights to Greece` DESC
LIMIT 10;


// Query 6
CALL {MATCH (r:Route)-[:ArrivesTo]->(airport:Airport)
WHERE(airport.Country = 'GREECE')
RETURN  COUNT(*) AS count
    UNION
MATCH (r:Route)-[:DepartsFrom]->(airport:Airport)
WHERE(airport.Country = 'GREECE')
RETURN COUNT(*) AS count
}
WITH SUM(count) AS `Total Flights`

CALL {MATCH (r:Route)-[:ArrivesTo]->(airport:Airport)
WHERE(airport.Country = 'GREECE')
RETURN  airport.City AS City ,COUNT(*) AS `Flights Proportion`
    UNION
MATCH (r:Route)-[:DepartsFrom]->(airport:Airport)
WHERE(airport.Country = 'GREECE')
RETURN  airport.City AS City ,COUNT(*) AS `Flights Proportion`
}
RETURN City, ROUND((SUM(`Flights Proportion`)*1.0/`Total Flights`)*100,2) AS `Flights Percentage`
ORDER BY `Flights Percentage` DESC;


// Query 7
MATCH (rin:Route)-[:ArrivesTo]->(airin:Airport)
MATCH (rin)-[:DepartsFrom]->(airout:Airport)
WHERE ((airin.Country='GREECE' AND airout.Country <>'GREECE')
AND (rin.PlaneType='738'OR rin.PlaneType='320' ))
RETURN rin.PlaneType AS `Plane Type`, COUNT(*) AS `International Flights to Greece`

// Query 8
MATCH (rin:Route)-[:ArrivesTo]->(airin:Airport)
MATCH (rin)-[:DepartsFrom]->(airout:Airport)
WITH point({longitude: toFloat(airout.Longitude), latitude: toFloat(airout.Latitude)}) as p1, point({longitude: toFloat(airin.Longitude),latitude: toFloat(airin.Latitude)}) as p2, airin.Name as `Airport From`,airout.Name as `Airport To`
RETURN DISTINCT `Airport From`,`Airport To`, round((point.distance(p1,p2)/1000),2) as `Distance in km` 
ORDER BY `Distance in km`  DESC
LIMIT 5;

// Query 9
CALL {MATCH (rin:Route)-[:ArrivesTo]->(airin:Airport)
MATCH (rin)-[:DepartsFrom]->(airout:Airport)
WHERE (airin.City='BERLIN')
WITH airin.City AS `Stop`,
    COLLECT(airout.City) AS `FromAir`
MATCH (r)-[:DepartsFrom]->(airpout:Airport)
WHERE NOT (airpout.City) IN `FromAir`
RETURN airpout.City AS `Airport From`
}
RETURN `Airport From`, COUNT(*) AS `Number of Routes`
ORDER BY `Number of Routes` DESC
LIMIT 5;

// Query 10
MATCH (airin:Airport {City:'SYDNEY', Country:'AUSTRALIA'})
MATCH (airout:Airport {City:'ATHENS', Country:'GREECE'})
MATCH p = allShortestPaths((airout)-[:DepartsFrom|ArrivesTo*]-(airin))
RETURN DISTINCT [n in nodes(p) | n.City] AS `All Shortest Paths`, length(p) as `Path Length`


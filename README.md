# TrainSchedules
Create a database to manage train schedules. The database will store data about the routes of
all the trains. The entities of interest to the problem domain are: Trains, Train Types, Stations,
and Routes. Each train has a name and belongs to a type. The train type has only a description.
Each station has a name. Station names are unique. Each route has a name, an associated train,
and a list of stations with arrival and departure times in each station. Route names are unique.
The arrival and departure times are represented as hour:minute pairs, e.g., train arrives at 5pm
and leaves at 5:10pm.
 Implement a stored procedure that receives a route, a station, arrival and departure times,
and adds the station to the route. If the station is already on the route, the arrival and departure
times are updated.
 Implement a function that lists the names of the stations with more than R routes, where R>=1
is a function parameter.

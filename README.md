TestCLVisit
===========
TestCLVisit
===========
iOS 8 sample that demonstrates the new CLVisit ability (including demonstrating the problems with the current beta release).  All visits are saved in a Core Data store and displayed in the main viewController sequentially.

Issues

1.  Sometimes either an arrival or a departure is not delivered.  You can see this in the app where Visit n and Visit n+1 are both arrivals (no departure delivered) or vice versa (two departures in a row - missing an arrival).

2.  Visits are delivered in wildly different timespans - sometimes a few minutes after the event occurs, sometimes nearly an hour later.


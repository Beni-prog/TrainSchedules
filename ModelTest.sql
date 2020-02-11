--create database tables--
if OBJECT_ID('RoutesStations','U') IS NOT NULL
   DROP TABLE RoutesStations
if OBJECT_ID('Stations','U') IS NOT NULL
   DROP TABLE Stations
if OBJECT_ID('Routes','U') IS NOT NULL
   DROP TABLE Routes
if OBJECT_ID('Trains','U') IS NOT NULL
   DROP TABLE Trains
if OBJECT_ID('TrainTypes','U') IS NOT NULL
   DROP TABLE TrainTypes
GO

--CREATE TABLES--
create table TrainTypes
   (TTID INT PRIMARY KEY IDENTITY(1,1),
   Description VARCHAR(500))
create table Trains
   (TID INT PRIMARY KEY IDENTITY(1,1),
   TName VARCHAR(500),
   TTID INT REFERENCES TrainTypes(TTID))
--the key in this table            the key to which I reference to
create table Routes
   (RID INT PRIMARY KEY IDENTITY(1,1),
   RName VARCHAR(500) UNIQUE,
   TID INT REFERENCES Trains(TID))
create table Stations
   (SID INT PRIMARY KEY IDENTITY(1,1),
   SName VARCHAR(500) UNIQUE)
--this table is actually a many-to-many relation
create table RoutesStations
   (RID INT REFERENCES Routes(RID),
   SID INT REFERENCES Stations(SID),
   Arrival TIME,
   Departure TIME,
   PRIMARY KEY(RID,SID))--do not forget to add the primary key in the link table
   GO
   --stored procedure--
   create or alter proc upStationOnRoute
      @SName VARCHAR(500),@RName VARCHAR(500),@Arrival TIME,@Departure TIME
      AS
	  DECLARE @SID INT=(SELECT SID
	                    FROM Stations
						WHERE SName=@SName),
			  @RID INT=(SELECT RID
	                    FROM Routes
						WHERE RName=@RName)
	  IF @SID IS NULL OR @RID IS NULL
	  BEGIN
	     RAISERROR('NO SUCH STATION/ROUTE',16,1)
		 RETURN -1
	  END
	  IF EXISTS(SELECT * FROM RoutesStations
	            where RID=@RID AND SID=@SID)
			UPDATE RoutesStations
			SET Arrival=@Arrival,
			    Departure=@Departure
				where RID=@RID AND SID=@SID
	  ELSE
	        INSERT RoutesStations(RID,SID,Arrival,Departure)
			       VALUES(@RID,@SID,@Arrival,@Departure)
GO

--POPULATE TABLES--
INSERT TrainTypes VALUES('INTERREGIO'),('REGIO')
INSERT Trains VALUES('T1',1),('T2',1),('T3',1)
INSERT Routes VALUES('R1',1),('R2',2),('R3',3)
INSERT Stations VALUES('S1'),('S2'),('S3')
GO

--EXEC PROCEDURES--
upStationOnRoute 'S1','R1','6:10','6:20'
EXEC upStationOnRoute 'S2','R1','6:30','6:35'
EXEC upStationOnRoute 'S3','R1','6:40','6:45'
EXEC upStationOnRoute 'S3','R2','7:40','7:45'
EXEC upStationOnRoute 'S3','R3','8:40','8:45'

SELECT * FROM RoutesStations
GO

--CREATE THE REQUIRED FUNCTION--
CREATE OR ALTER FUNCTION uspFilterStations(@R INT)
RETURNS TABLE
RETURN SELECT S.SName
FROM Stations S
WHERE S.SID IN(SELECT RS.SID
               FROM RoutesStations RS
               GROUP BY RS.SID
               HAVING COUNT(*)>=@R)
GO

--CALL THE FUNCTION--
SELECT * FROM uspFilterStations(3)

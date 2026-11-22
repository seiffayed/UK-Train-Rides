/*
    UK Train Rides - Step 3: analysis queries
    Simple queries that answer the main business questions.
    Their results are used to check the numbers shown in Power BI.

    Run one query at a time: select it and press Execute (F5).
*/

USE UK_Train_Rides;
GO

/* ---------------------------------------------------------------------------
   Q1. Sales KPIs: total revenue, tickets sold and average ticket price
--------------------------------------------------------------------------- */
SELECT
    SUM(Price)            AS Total_Revenue,
    COUNT(Transaction_ID) AS Tickets_Sold,
    AVG(Price)            AS Average_Ticket_Price
FROM Fact_TicketSales;


/* ---------------------------------------------------------------------------
   Q2. Revenue and tickets by month (month of the journey)
--------------------------------------------------------------------------- */
SELECT
    d.[Month],
    SUM(t.Price) AS Revenue,
    COUNT(*)     AS Tickets
FROM Fact_TicketSales AS t
JOIN Fact_Journey     AS j ON t.JourneyID = j.JourneyID
JOIN Dim_Date         AS d ON j.JourneyDateKey = d.DateKey
GROUP BY d.[Month]
ORDER BY d.[Month];


/* ---------------------------------------------------------------------------
   Q3. Top 10 routes by revenue
   Dim_Station is joined twice: once for the departure station (dep)
   and once for the arrival station (arr).
--------------------------------------------------------------------------- */
SELECT TOP 10
    dep.Station_Name AS Departure_Station,
    arr.Station_Name AS Arrival_Station,
    SUM(t.Price)     AS Revenue,
    COUNT(*)         AS Tickets
FROM Fact_TicketSales AS t
JOIN Fact_Journey     AS j   ON t.JourneyID = j.JourneyID
JOIN Dim_Route        AS r   ON j.RouteID = r.RouteID
JOIN Dim_Station      AS dep ON r.Departure_StationID = dep.StationID
JOIN Dim_Station      AS arr ON r.Arrival_StationID = arr.StationID
GROUP BY dep.Station_Name, arr.Station_Name
ORDER BY Revenue DESC;


/* ---------------------------------------------------------------------------
   Q4. Tickets by departure hour (peak hours)
--------------------------------------------------------------------------- */
SELECT
    DATEPART(HOUR, j.Departure_Time) AS Departure_Hour,
    COUNT(*)                         AS Tickets
FROM Fact_TicketSales AS t
JOIN Fact_Journey     AS j ON t.JourneyID = j.JourneyID
GROUP BY DATEPART(HOUR, j.Departure_Time)
ORDER BY Departure_Hour;


/* ---------------------------------------------------------------------------
   Q5. Journey status, counted once per journey (not per ticket)
--------------------------------------------------------------------------- */
SELECT
    Journey_Status,
    COUNT(*) AS Journeys,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Fact_Journey) AS DECIMAL(5,1)) AS Percentage
FROM Fact_Journey
GROUP BY Journey_Status
ORDER BY Journeys DESC;

-- Average delay of delayed journeys (cancelled journeys have no delay value)
SELECT AVG(CAST(Delay_Minutes AS DECIMAL(6,1))) AS Average_Delay_Minutes
FROM Fact_Journey
WHERE Journey_Status = 'Delayed';


/* ---------------------------------------------------------------------------
   Q6. Routes with the highest disruption rate (delayed or cancelled)
   Only routes with at least 100 journeys.
--------------------------------------------------------------------------- */
SELECT TOP 10
    dep.Station_Name AS Departure_Station,
    arr.Station_Name AS Arrival_Station,
    COUNT(*)         AS Journeys,
    SUM(CASE WHEN j.Journey_Status <> 'On Time' THEN 1 ELSE 0 END) AS Disrupted_Journeys,
    CAST(SUM(CASE WHEN j.Journey_Status <> 'On Time' THEN 1 ELSE 0 END) * 100.0
         / COUNT(*) AS DECIMAL(5,1)) AS Disruption_Rate
FROM Fact_Journey AS j
JOIN Dim_Route    AS r   ON j.RouteID = r.RouteID
JOIN Dim_Station  AS dep ON r.Departure_StationID = dep.StationID
JOIN Dim_Station  AS arr ON r.Arrival_StationID = arr.StationID
GROUP BY dep.Station_Name, arr.Station_Name
HAVING COUNT(*) >= 100
ORDER BY Disruption_Rate DESC;


/* ---------------------------------------------------------------------------
   Q7. Refund requests by journey status
--------------------------------------------------------------------------- */
SELECT
    j.Journey_Status,
    COUNT(*) AS Tickets,
    SUM(CASE WHEN t.Refund_Request = 'Yes' THEN 1 ELSE 0 END) AS Refund_Requests,
    CAST(SUM(CASE WHEN t.Refund_Request = 'Yes' THEN 1 ELSE 0 END) * 100.0
         / COUNT(*) AS DECIMAL(5,1)) AS Refund_Request_Rate
FROM Fact_TicketSales AS t
JOIN Fact_Journey     AS j ON t.JourneyID = j.JourneyID
GROUP BY j.Journey_Status
ORDER BY Refund_Request_Rate DESC;


/* ---------------------------------------------------------------------------
   Q8. Refund request rate by delay reason (delayed and cancelled journeys)
--------------------------------------------------------------------------- */
SELECT
    dr.Reason_for_Delay,
    COUNT(*) AS Tickets,
    SUM(CASE WHEN t.Refund_Request = 'Yes' THEN 1 ELSE 0 END) AS Refund_Requests,
    CAST(SUM(CASE WHEN t.Refund_Request = 'Yes' THEN 1 ELSE 0 END) * 100.0
         / COUNT(*) AS DECIMAL(5,1)) AS Refund_Request_Rate
FROM Fact_TicketSales AS t
JOIN Fact_Journey     AS j  ON t.JourneyID = j.JourneyID
JOIN Dim_DelayReason  AS dr ON j.DelayReasonID = dr.DelayReasonID
WHERE j.Journey_Status <> 'On Time'
GROUP BY dr.Reason_for_Delay
ORDER BY Refund_Request_Rate DESC;

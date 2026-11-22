/*
    UK Train Rides - Step 2: create the 11 tables of the star schema
    9 dimension tables + 2 fact tables, with primary keys, foreign keys and check constraints.

    The script can be run again: it drops the tables first.
    Tables are dropped in reverse order (facts first) because of the foreign keys.
*/

USE UK_Train_Rides;
GO

DROP TABLE IF EXISTS Fact_TicketSales;
DROP TABLE IF EXISTS Fact_Journey;
DROP TABLE IF EXISTS Dim_Route;
DROP TABLE IF EXISTS Dim_Station;
DROP TABLE IF EXISTS Dim_Date;
DROP TABLE IF EXISTS Dim_TicketType;
DROP TABLE IF EXISTS Dim_TicketClass;
DROP TABLE IF EXISTS Dim_Railcard;
DROP TABLE IF EXISTS Dim_PaymentMethod;
DROP TABLE IF EXISTS Dim_PurchaseType;
DROP TABLE IF EXISTS Dim_DelayReason;
GO

/* ---------------------------- Dimension tables ---------------------------- */

CREATE TABLE Dim_Station (
    StationID      INT          NOT NULL,
    Station_Name   VARCHAR(50)  NOT NULL,
    City           VARCHAR(50)  NOT NULL,
    Region         VARCHAR(50)  NOT NULL,
    CONSTRAINT PK_Dim_Station PRIMARY KEY (StationID),
    CONSTRAINT UQ_Dim_Station_Name UNIQUE (Station_Name)
);

CREATE TABLE Dim_Route (
    RouteID              INT           NOT NULL,
    Departure_StationID  INT           NOT NULL,
    Arrival_StationID    INT           NOT NULL,
    Distance_km          DECIMAL(6,1)  NULL,   -- straight-line distance
    CONSTRAINT PK_Dim_Route PRIMARY KEY (RouteID),
    CONSTRAINT FK_Route_DepartureStation FOREIGN KEY (Departure_StationID) REFERENCES Dim_Station (StationID),
    CONSTRAINT FK_Route_ArrivalStation   FOREIGN KEY (Arrival_StationID)   REFERENCES Dim_Station (StationID),
    CONSTRAINT UQ_Dim_Route_Stations UNIQUE (Departure_StationID, Arrival_StationID)
);

CREATE TABLE Dim_Date (
    DateKey     INT          NOT NULL,   -- format YYYYMMDD
    [Date]      DATE         NOT NULL,
    Day_Name    VARCHAR(10)  NOT NULL,
    Is_Weekend  BIT          NOT NULL,
    [Month]     INT          NOT NULL,
    [Quarter]   INT          NOT NULL,
    [Year]      INT          NOT NULL,
    CONSTRAINT PK_Dim_Date PRIMARY KEY (DateKey),
    CONSTRAINT UQ_Dim_Date_Date UNIQUE ([Date])
);

CREATE TABLE Dim_TicketType (
    TicketTypeID  INT           NOT NULL,
    Ticket_Type   VARCHAR(20)   NOT NULL,
    Discount_Pct  DECIMAL(5,2)  NOT NULL,
    CONSTRAINT PK_Dim_TicketType PRIMARY KEY (TicketTypeID),
    CONSTRAINT UQ_Dim_TicketType UNIQUE (Ticket_Type)
);

CREATE TABLE Dim_TicketClass (
    TicketClassID  INT          NOT NULL,
    Ticket_Class   VARCHAR(20)  NOT NULL,
    CONSTRAINT PK_Dim_TicketClass PRIMARY KEY (TicketClassID),
    CONSTRAINT UQ_Dim_TicketClass UNIQUE (Ticket_Class)
);

CREATE TABLE Dim_Railcard (
    RailcardID    INT           NOT NULL,
    Railcard      VARCHAR(20)   NOT NULL,
    Discount_Pct  DECIMAL(5,2)  NOT NULL,
    CONSTRAINT PK_Dim_Railcard PRIMARY KEY (RailcardID),
    CONSTRAINT UQ_Dim_Railcard UNIQUE (Railcard)
);

CREATE TABLE Dim_PaymentMethod (
    PaymentMethodID  INT          NOT NULL,
    Payment_Method   VARCHAR(20)  NOT NULL,
    CONSTRAINT PK_Dim_PaymentMethod PRIMARY KEY (PaymentMethodID),
    CONSTRAINT UQ_Dim_PaymentMethod UNIQUE (Payment_Method)
);

CREATE TABLE Dim_PurchaseType (
    PurchaseTypeID  INT          NOT NULL,
    Purchase_Type   VARCHAR(20)  NOT NULL,
    CONSTRAINT PK_Dim_PurchaseType PRIMARY KEY (PurchaseTypeID),
    CONSTRAINT UQ_Dim_PurchaseType UNIQUE (Purchase_Type)
);

CREATE TABLE Dim_DelayReason (
    DelayReasonID     INT          NOT NULL,
    Reason_for_Delay  VARCHAR(30)  NOT NULL,
    Reason_Category   VARCHAR(20)  NOT NULL,
    CONSTRAINT PK_Dim_DelayReason PRIMARY KEY (DelayReasonID),
    CONSTRAINT UQ_Dim_DelayReason UNIQUE (Reason_for_Delay)
);
GO

/* ------------------------------- Fact tables ------------------------------ */

CREATE TABLE Fact_Journey (
    JourneyID               INT          NOT NULL,
    RouteID                 INT          NOT NULL,
    JourneyDateKey          INT          NOT NULL,
    DelayReasonID           INT          NOT NULL,
    Departure_Time          TIME(0)      NOT NULL,
    Scheduled_Arrival_Time  TIME(0)      NOT NULL,
    Actual_Arrival_Time     TIME(0)      NULL,   -- empty for cancelled journeys
    Journey_Status          VARCHAR(10)  NOT NULL,
    Delay_Minutes           INT          NULL,   -- empty for cancelled journeys
    CONSTRAINT PK_Fact_Journey PRIMARY KEY (JourneyID),
    CONSTRAINT FK_Journey_Route       FOREIGN KEY (RouteID)        REFERENCES Dim_Route (RouteID),
    CONSTRAINT FK_Journey_Date        FOREIGN KEY (JourneyDateKey) REFERENCES Dim_Date (DateKey),
    CONSTRAINT FK_Journey_DelayReason FOREIGN KEY (DelayReasonID)  REFERENCES Dim_DelayReason (DelayReasonID),
    CONSTRAINT CK_Journey_Status CHECK (Journey_Status IN ('On Time', 'Delayed', 'Cancelled')),
    CONSTRAINT CK_Journey_Delay  CHECK (Delay_Minutes >= 0)
);

CREATE TABLE Fact_TicketSales (
    Transaction_ID     VARCHAR(30)   NOT NULL,
    JourneyID          INT           NOT NULL,
    PurchaseDateKey    INT           NOT NULL,
    PurchaseTypeID     INT           NOT NULL,
    PaymentMethodID    INT           NOT NULL,
    RailcardID         INT           NOT NULL,
    TicketClassID      INT           NOT NULL,
    TicketTypeID       INT           NOT NULL,
    Time_of_Purchase   TIME(0)       NOT NULL,
    Price              DECIMAL(8,2)  NOT NULL,
    Refund_Request     VARCHAR(3)    NOT NULL,
    Days_Booked_Ahead  INT           NOT NULL,
    CONSTRAINT PK_Fact_TicketSales PRIMARY KEY (Transaction_ID),
    CONSTRAINT FK_Ticket_Journey       FOREIGN KEY (JourneyID)       REFERENCES Fact_Journey (JourneyID),
    CONSTRAINT FK_Ticket_PurchaseDate  FOREIGN KEY (PurchaseDateKey) REFERENCES Dim_Date (DateKey),
    CONSTRAINT FK_Ticket_PurchaseType  FOREIGN KEY (PurchaseTypeID)  REFERENCES Dim_PurchaseType (PurchaseTypeID),
    CONSTRAINT FK_Ticket_PaymentMethod FOREIGN KEY (PaymentMethodID) REFERENCES Dim_PaymentMethod (PaymentMethodID),
    CONSTRAINT FK_Ticket_Railcard      FOREIGN KEY (RailcardID)      REFERENCES Dim_Railcard (RailcardID),
    CONSTRAINT FK_Ticket_TicketClass   FOREIGN KEY (TicketClassID)   REFERENCES Dim_TicketClass (TicketClassID),
    CONSTRAINT FK_Ticket_TicketType    FOREIGN KEY (TicketTypeID)    REFERENCES Dim_TicketType (TicketTypeID),
    CONSTRAINT CK_Ticket_Price    CHECK (Price > 0),
    CONSTRAINT CK_Ticket_Refund   CHECK (Refund_Request IN ('Yes', 'No')),
    CONSTRAINT CK_Ticket_DaysAhead CHECK (Days_Booked_Ahead >= 0)
);
GO

/* --------------------------------- Check ---------------------------------- */

-- Should list 11 tables
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- Should list 12 foreign keys
SELECT name AS foreign_key, OBJECT_NAME(parent_object_id) AS table_name
FROM sys.foreign_keys
ORDER BY table_name, foreign_key;

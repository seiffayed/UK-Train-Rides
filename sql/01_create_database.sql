/*
    UK Train Rides - Step 1: create the database
    Run this script once in SSMS (Execute or F5).
*/

IF DB_ID('UK_Train_Rides') IS NULL
    CREATE DATABASE UK_Train_Rides;
GO

USE UK_Train_Rides;
GO

SELECT name, create_date
FROM sys.databases
WHERE name = 'UK_Train_Rides';

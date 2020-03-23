-- PolyBase installation
exec sp_configure 'polybase enabled', '1'
go
RECONFIGURE
go
CREATE DATABASE PolyBaseTest
GO
USE [PolyBaseTest]
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD  = '<<SomeSecureKey>>';
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO
CREATE DATABASE SCOPED CREDENTIAL MLServicesUser
WITH IDENTITY = 'sa', Secret = 'SomeBadPassword3,';
GO
CREATE EXTERNAL DATA SOURCE MLServicesContainer WITH
(
    LOCATION = 'sqlserver://192.168.20.212:51432',
    PUSHDOWN = ON,
    CREDENTIAL = MLServicesUser
);
GO
CREATE EXTERNAL TABLE dbo.Model
(
    ModelName VARCHAR(30),
    Model VARBINARY(MAX)
)
WITH
(
    DATA_SOURCE = MLServicesContainer,
    LOCATION = 'NativeScoringTest.dbo.Model'
);
GO
SELECT * FROM dbo.Model;
GO
CREATE TABLE #LinearRegressionInputDataTest
(
    Feature1 float,
    Feature2 float,
    Feature3 float
);
INSERT INTO #LinearRegressionInputDataTest
(
    Feature1,
    Feature2,
    Feature3
)
VALUES
    (1,2,3),
    (31.778, 48.016, -29.3);
GO

DECLARE
    @LinearModel VARBINARY(MAX);

SELECT 
    @LinearModel = Model
FROM dbo.Model m
WHERE
    m.ModelName = N'LinearModel';

SELECT
    d.Feature1,
    d.Feature2,
    d.Feature3,
    p.Label_Pred
FROM PREDICT(MODEL = @LinearModel, DATA = #LinearRegressionInputDataTest AS d)
    WITH(Label_Pred float) AS p;
GO

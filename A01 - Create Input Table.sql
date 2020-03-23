-- ML Services container
exec sp_configure 'external scripts enabled', '1'
go
RECONFIGURE
go
exec sp_execute_external_script
    @language = N'R',
    @script = N'print("Hello, test")'
GO
CREATE DATABASE [NativeScoringTest]
GO
USE [NativeScoringTest]
GO
CREATE TABLE dbo.LinearRegressionInputData
(
    [Id] int IDENTITY(1,1) NOT NULL,
    [Feature1] float NOT NULL,
    [Feature2] float NOT NULL,
    [Feature3] float NOT NULL,
    [Label] float NOT NULL,
    CONSTRAINT [PK_LinearRegressionInputData] PRIMARY KEY CLUSTERED
    (
        Id
    )
);
GO
SELECT * FROM dbo.LinearRegressionInputData;
GO
SELECT COUNT(*) FROM dbo.LinearRegressionInputData;
GO
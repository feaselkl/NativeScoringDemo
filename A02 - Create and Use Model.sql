USE NativeScoringTest
GO
CREATE TABLE dbo.Model
(
    ModelName VARCHAR(30) NOT NULL CONSTRAINT [PK_Model] PRIMARY KEY CLUSTERED,
    Model VARBINARY(MAX)
);
GO
CREATE OR ALTER PROCEDURE dbo.GenerateLinearModel
(
@TrainedModel VARBINARY(MAX) OUTPUT
)
AS
BEGIN
    DECLARE
        @SQL NVARCHAR(MAX) = N'
    SELECT
        l.Feature1,
        l.Feature2,
        l.Feature3,
        l.Label
    FROM dbo.LinearRegressionInputData l
    WHERE
        l.Id <= 100000';

    exec sp_execute_external_script
        @language = N'R',
        @script = N'
require(RevoScaleR)

model <- rxLinMod(Label ~ Feature1 + Feature2 + Feature3, data = InputData)
serialized_model <- rxSerializeModel(model, realtimeScoringOnly = TRUE)
',
    @input_data_1 = @SQL,
    @input_data_1_name = N'InputData',
    @params = N'@serialized_model VARBINARY(MAX) OUTPUT',
    @serialized_model = @TrainedModel OUTPUT;
END
GO
DECLARE
    @TrainedModel VARBINARY(MAX);

EXEC dbo.GenerateLinearModel
    @TrainedModel = @TrainedModel OUTPUT;

INSERT INTO dbo.Model
(
    ModelName,
    Model
)
SELECT 'LinearModel', @TrainedModel;
GO
CREATE TABLE dbo.LinearRegressionLoadTest
(
    Feature1 float,
    Feature2 float,
    Feature3 float,
    Label float,
    Label_Pred float
);
CREATE CLUSTERED COLUMNSTORE INDEX [CIX_LInearRegressionLoadTest] ON dbo.LinearRegressionLoadTest;
GO
DROP TABLE IF EXISTS #LinearRegressionInputDataTest;

SELECT TOP(4000000) *
INTO #LinearRegressionInputDataTest
FROM dbo.LinearRegressionInputData d
    CROSS JOIN sys.columns c
WHERE
    d.Id > 100000;
GO
DECLARE
    @LinearModel VARBINARY(MAX);

SELECT 
    @LinearModel = Model
FROM dbo.Model m
WHERE
    m.ModelName = N'LinearModel';

INSERT INTO dbo.LinearRegressionLoadTest
(
    Feature1,
    Feature2,
    Feature3,
    Label,
    Label_Pred
)
SELECT
    d.Feature1,
    d.Feature2,
    d.Feature3,
    d.Label,
    p.Label_Pred
FROM PREDICT(MODEL = @LinearModel, DATA = #LinearRegressionInputDataTest AS d)
    WITH(Label_Pred float) AS p;
GO
SELECT COUNT(*) FROM dbo.LinearRegressionLoadTest;
SELECT
    SQRT(AVG(POWER(Label_Pred - Label, 2))) AS RootMeanSquaredError,
    AVG(ABS(Label_Pred)) AS SumOfPredictions
FROM dbo.LinearRegressionLoadTest;
GO
SELECT TOP(100)
    *
FROM dbo.LinearRegressionLoadTest;
GO
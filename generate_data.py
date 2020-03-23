import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn import datasets, linear_model
from sklearn.metrics import mean_squared_error, r2_score
import sqlalchemy
import urllib

X, y = datasets.make_regression(n_samples = 250000, n_features = 3, noise = 15)
df = pd.DataFrame(X, columns=['Feature1', 'Feature2', 'Feature3'])
dfl = pd.DataFrame(y, columns = ['Label'])
dfM = pd.concat([df, dfl], axis=1)

server = 'localhost'
port = '51432'
db = 'NativeScoringTest'

conn_str = "DRIVER={ODBC Driver 17 for SQL Server};SERVER=" + server + "," + port + ";DATABASE=" + db + ";UID=sa;PWD=SomeBadPassword3,"

params = urllib.parse.quote_plus(conn_str)
engine = sqlalchemy.create_engine("mssql+pyodbc:///?odbc_connect=%s" % params)
conn = engine.connect().connection
cursor = conn.cursor()

# Create column list for insertion
cols = ",".join([str(i) for i in dfM.columns.tolist()])

# Insert dataframe records one by one
for i, row in dfM.iterrows():
    sql = "INSERT INTO dbo.LinearRegressionInputData (" + cols + ") VALUES (" + "?," * (len(row)-1) + "?)"
    cursor.execute(sql, tuple(row))

conn.commit()
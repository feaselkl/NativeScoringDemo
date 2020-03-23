# SQL Server 2019 Native Scoring
## A Brief Demo
This is a quick demonstration of native scoring in SQL Server 2019 Machine Learning Services.

## Basic Process
1. Grab Docker examples.  We'll want to use these to spin up containers fairly quickly.
https://github.com/microsoft/mssql-docker/blob/master/linux/preview/examples/mssql-mlservices/
https://github.com/microsoft/mssql-docker/blob/master/linux/preview/examples/mssql-polybase/

2.  Modify each Dockerfile example and change to deal with "mssql-server-preview" to "mssql-server-2019" in the `add-apt-repository` command.  Hopefully Microsoft will update these Dockerfiles at some point.

3.  Navigate to the directories you created when pulling the samples and build images.  If you brought them down to `C:\SourceCode\` then the commands would be:
`cd C:\SourceCode\mssql-mlservices`

`docker build -t mssql-mlservices .`

`cd C:\SourceCode\mssql-polybase`

`docker build -t mssql-polybase .`

4.  Start up two Docker containers, one for each image.  You probably want to use a better password than the one I have here.
`docker run -d -e MSSQL_PID=Developer -e ACCEPT_EULA=Y -e ACCEPT_EULA_ML=Y -e SA_PASSWORD=SomeBadPassword3, -p 51432:1433 mssql-mlservices`

`docker run -d -e MSSQL_PID=Developer -e ACCEPT_EULA=Y -e ACCEPT_EULA_ML=Y -e SA_PASSWORD=SomeBadPassword3, -p 51433:1433 mssql-polybase`

5.  Run the script labeled `A01 - Create Input Table.sql` on the SQL Server instance on port 51432.

6.  Run the script labeled `generate_data.py`.  Note that this will be a slow process, depending upon your machine.

7.  Run the script labeled `A02 - Create and Use Model.sql` on the SQL Server instance on port 51432.

8.  Run the script labeled `B01 - PolyBase Instance.sql` on the SQL Server instance on port 51433.  **Ensure that the IP address in the script is your host IP address!**  It should not be the IP address of either Docker container, as those are isolated.  We need to go through the host machine for PolyBase to work.
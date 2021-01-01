PREREQUISITE :

Terraform installed in your local machine and connection to your AWS account using keys.

1. Run the "main.tf" file to create all the resources required for this use case.
2. Uploading the CSV file "dd-test.csv" with the contents to S# will add the items to DynamoDB table using the lambda function "create.py".
3. API gateway is created using the swagger file which will create the appropriate methods and resources.
4. Lambda function read.py will read the data based on the id from DynamoDB table.
5. Lambda function update.py will update the data based on the id from DynamoDB table. 
6. Lambda function delete.py will delete the data based on the id from DynamoDB table.
7. readdeleteevent.json is the test event json for the lambda functions read.py and delete.py.
8. updateevent.json is the test event json for the lambda functions update.py.
9. authorizer.py will authorise the requests coming from API gateway using the username and password based on the checking the auth header. (API key will be created as part of terraform template)
10. All the resources are created for testing and best naming convention should be "appname-environment-resourceName".





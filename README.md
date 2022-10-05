# API Endpoints

/api/get - get all the tasks
/api/add - add tasks ( take "task" in the request body )
/api/delete - delete tasks ( take "id" in the request body )


# Terraform

Change shared_credentials_file in variables.tf file to add your aws credentials path

``` terraform plan -var-file="secrets.tfvars" ```

``` terraform apply -var-file="secrets.tfvars" ```

# Server config

mysql -h terraform-20221005133323185600000001.cd9bdp7cb6pz.us-east-1.rds.amazonaws.com -P 3306 -p 


CREATE TABLE todolist ( id int auto_increment primary key, task varchar(255) );
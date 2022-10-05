# API Endpoints

/api/get - get all the tasks <br>
/api/add - add tasks ( take "task" in the request body ) <br>
/api/delete - delete tasks ( take "id" in the request body ) <br>


# Terraform apply

* First you should add secrets.tfvars files to the tf directory including;
```
  db_username = ""
  db_password = ""
```
* Then, edit variables.tf file including the shared_credentials_file path of your local computer
```
  variable "shared_credentials_file" {
    default = "/home/savicloud/.aws/credentials"
  }
```
* Make sure terraform script doesn't have any syntax errors from running ``` terraform validate ``` command
* Generate SSH key pair using ```ssh-keygen -t rsa -b 4096 -m pem -f todoapp_kp```. (.gitignore file will make sure private key won't get pushed to the repository)
* Next, preview the changes before making them from running ```terraform plan -var-file="secrets.tfvars"``` command
* Finally, apple the changes using ``` terraform apply -var-file="secrets.tfvars" ``` command


# Configure the webserver

* Install nodejs, nginx, and mysql-client
* Log into the database server and create a new table
```
  mysql -h terraform-20221005133323185600000001.cd9bdp7cb6pz.us-east-1.rds.amazonaws.com -P 3306 -p 
```
```
  CREATE TABLE todolist ( id int auto_increment primary key, task varchar(255) );
```

* Install pm2 and typescript packages from the node package manager
* Clone the project and run ```tsc index.ts``` command from the *server* directory
* run ```pm2 start index.js --name "todoapp"``` to start the project 

## Nginx setup

* Edit /etc/nginx/sites-available/default files as below/
```
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        # assuming project is cloned in /home/ubuntu/ directory
        root /home/ubuntu/codimite-assignment/server/frontend;

        index index.html index.htm index.nginx-debian.html;

        server_name ec2-54-157-183-111.compute-1.amazonaws.com;

        location /api/ {
                proxy_pass http://localhost:8000/api/;
        }
}

```
* Restart nginx
```
sudo systemctl restart nginx
```




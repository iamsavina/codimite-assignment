//GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
//ALTER USER 'root' IDENTIFIED WITH mysql_native_password BY 'example';

import mysql from 'mysql2/promise'

const dbCon = mysql.createPool({
        host:'localhost',
        user:'root',
        password:'example',
        database:'todo',
        port:3306
    })

export default dbCon;
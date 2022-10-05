//GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
//ALTER USER 'root' IDENTIFIED WITH mysql_native_password BY 'example';

import {createPool} from 'mysql2/promise';

const dbCon = createPool({
        host:'localhost',
        user:'root',
        password:'example1234',
        database:'todo',
        port:3306
    })

export default dbCon;
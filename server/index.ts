import { Request, Response } from 'express'
import * as express from 'express';
import dbCon from './dbcon'
import log from './logger'

const app = express();
const port = 8000;

app.use(express.json());    
app.use(express.urlencoded({extended:true}));

app.use(express.static('frontend'))//serve the frontend

//start the server if db connection is valid
const startTheServer = async () => {

    try{
        const [rows] = await dbCon.execute('select 1');

        log.info("Connected to the database")
        app.listen(port, () => log.info(`Sever running on localhost:${port}`))

    }catch(e: any){//TODO: Need to add proper generic
        if(e.code === 'ECONNREFUSED'){
            log.fatal("Error connecting to database")
            log.fatal(e)
            await new Promise(resolve => setTimeout(resolve, 2000))
            log.info("Reconnecting to the database")
            startTheServer()
        }else{
            log.fatal('Error connecting to the database')
            log.fatal(e)
            process.exit(1)
        }
    }
}

startTheServer()

app.get('/api/get', async (req: Request, res:Response) => {
    const sql = `SELECT * FROM todolist`;
    try{
        const [row] = await dbCon.execute(sql);        
        return res.json({row});

    }catch(e: any){
        log.fatal('Cannot get the tasks');
        log.fatal(e);
        return res.json({"Error":e})
    }
});

app.post('/api/add', async (req: Request<{},{},{task:String}>, res:Response) => {
    if ( (req.body.task == undefined) || req.body.task.length < 1) { return res.json({Error:"Invalid input"}) }

    const sql = `INSERT INTO todolist (task) VALUES ('${req.body.task}')`;
    try{
        const [ resultHeader ] = await dbCon.execute(sql)
        // const resultHeaderAny : any = resultHeader
        // return res.json(resultHeaderAny.insertId);
        return res.json({Success:"Successfully added"});
    }catch(e: any){
        log.fatal('Cannot add the task');
        log.fatal(e);
        return res.json({"Error":e})
    }

});

app.post('/api/delete', async (req: Request<{},{},{id:Number}>, res:Response) => {
    if ( req.body.id == undefined ) { return res.json({Error:"Invalid input"}) }

    const sql = `DELETE FROM todolist WHERE id='${req.body.id}'`;

    try{
        const [row] = await dbCon.execute(sql);
        return res.json(row);
    }catch(e: any){
        log.fatal('Cannot delete the task');
        log.fatal(e);
        return res.json({"Error":e})
    }

});
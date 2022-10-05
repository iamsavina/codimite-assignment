import logger from 'pino'
import * as dayjs from 'dayjs'

const log = logger({
    transport: {
      target: "pino-pretty",
    },
    level:'info',
    base: {
      pid: false,
    },
    timestamp: () => `,"time":"${dayjs().format()}"`,
  });
  

export default log;

let mysql = require('mysql2')

// Create connection pool
const pool = mysql.createPool({
    waitForConnections: true,
    connectionLimit   : 10,
    host              : 'classmysql.engr.oregonstate.edu',
    user              : 'cs340_previshj',
    password          : 'AviDSgSVbxxU',
    database          : 'cs340_previshj'
}).promise();

module.exports = pool;
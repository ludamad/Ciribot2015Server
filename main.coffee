###############################################################################
# Handle imports
###############################################################################

bodyParser = require('body-parser')
express = require('express')
sql = require('sqlite3').verbose()
fs = require('fs')

###############################################################################
# Server configuration
###############################################################################

port = process.env.PORT or 8080
# Database didn't exist, stop to fill it explicitly:
if not fs.existsSync('test.db')
    db = new sql.Database('test.db')
    console.log("Only preparing DB. Re-run for server.")
    db.serialize () -> # Ensure statements are run in correct order:
        # Add mock data
        db.run("CREATE TABLE level_stats (name TEXT, lowest_frame_count INTEGER)")
        stmt = db.prepare("INSERT INTO level_stats VALUES (?, ?)")
        for i in [1..3]
            stmt.run("area0#{i}", 200 + i * 50 )
        stmt.finalize()
    return

# Database existed, keep going:
db = new sql.Database('test.db')

app = express()
app.use(bodyParser.urlencoded(extended: true))
app.use(bodyParser.json())
###############################################################################
# API routes 
###############################################################################

levelApi = {
    '/stats': (req, res) ->
        db.all(
            "SELECT * from level_stats" 
            (err, rows) -> 
                # JSON encodes a list of objects in the format eg {name: "areaFoo", lowest_frame_count: 200}
                # Data for all levels is sent using JSON over an HTTP request.
                res.json(rows)
        )

}

###############################################################################
# Setup the server 
###############################################################################

levelApiRouter = express.Router()
for path of levelApi
    levelApiRouter.get(path, levelApi[path])
app.use('/levels', levelApiRouter)
app.listen(port)
console.log('Server listening on port ' + port)

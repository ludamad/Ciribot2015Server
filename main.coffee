###############################################################################
# Handle imports
###############################################################################

bodyParser = require('body-parser')
express = require('express')
sql = require('sqlite3').verbose()

###############################################################################
# Server configuration
###############################################################################

port = process.env.PORT or 8080
# For testing purposes, in-memory database:
db = new sql.Database(':memory:')
db.run("CREATE TABLE level_stats (name TEXT, lowest_frame_count INTEGER)")

app = express()
app.use(bodyParser.urlencoded(extended: true))
app.use(bodyParser.json())

###############################################################################
# Mock data
###############################################################################
stmt = db.prepare("INSERT INTO level_stats VALUES (?)")
for i in [1..3]
    stmt.run("area0#{i}", 200 + i * 50 )
stmt.finalize()

###############################################################################
# API routes 
###############################################################################

levelAPI = {
    '/stats': (req, res) ->
        rows = db.all("SELECT * from level_stats")
        # JSON encodes a list of objects in the format eg {name: "areaFoo", lowest_frame_count: 200}
        # Data for all levels is sent using JSON over an HTTP request.
        res.json(rows)
}

###############################################################################
# Setup the server 
###############################################################################

router = express.Router()
for path of routes do router.get(path, routes[path])
app.use('/levels', levelAPI)
app.listen(port)
console.log('Server listening on port ' + port)

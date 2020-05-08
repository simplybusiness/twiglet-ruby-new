const Logger = require('./logger')

const PORT = 8080

const log = Logger({
  now: Date.now,
  output: console,
  service: "petshop"
})

// Start our petshop
log.info({
  event: {
    action: "startup"
  },
  message: `Ready to go, listening on port ${PORT}`,
  server: {
    port: PORT
  }
})

// We get a request
const request_log = log.with({ event: { action: "HTTP request" }, trace: { id: "126bb6fa-28a2-470f-b013-eefbf9182b2d" }})

// Oh noes!
db_err = true // this time!
if (db_err) {
  request_log.error({ message: "DB connection failed." })
}

// We return an error to the requester
request_log.info({ message: "The process ends here", http: { request: { method: 'GET'}, response: { status_code: 500 }}})

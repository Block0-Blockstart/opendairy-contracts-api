'use strict';

const port = process.env.PORT || 42002;
const env = process.env.NODE_ENV || 'development';

const express = require('express');
const path = require('path');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');
const rfs = require('rotating-file-stream');
const contractsController = require('./contracts/contracts.controller');

const app = express();

const accessLogStream = rfs.createStream('access.log', {
  interval: '1d', // rotate logs daily
  path: path.join(__dirname, '..', 'logs'),
});

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

if (env === 'development') {
  app.use(morgan('dev', { // outputs logs to console if status code >= 400
    skip: function (req, res) { return res.statusCode < 400; },
  }));
}
app.use(morgan('common', { stream: accessLogStream })); // outputs all logs to local log file

app.use('/', contractsController);

app.use((req, res) => {
  res.status(404).send({ message: req.originalUrl + 'not found' });
});

app.listen(port, () => console.log(`Server is listenning on port ${port}`));

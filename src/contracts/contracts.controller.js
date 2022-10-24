'use strict';
const express = require('express');
const getContractPattern = require('./contracts.service');

const contractController = express.Router();

contractController.get('/', (req, res) => {
  try {
    const contractPattern = getContractPattern(req.query.name);
    res
      .status(200)
      .send(contractPattern);
  } catch (e) {
    res
      .status(400)
      .send({
        error: `Nothing to fetch with params name = ${req.query.name}`,
      });
  }
});

module.exports = contractController;

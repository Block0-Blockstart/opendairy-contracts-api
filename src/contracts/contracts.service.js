'use strict';
const fs = require('fs');
const path = require('path');

const getContractPattern = name => {

  name = name.trim().toLowerCase();

  const abiPath = path.join(__dirname, '..', '..', 'contracts', name, 'pattern', 'abi.json');
  const bytecodePath = path.join(__dirname, '..', '..', 'contracts', name, 'pattern', 'bytecode.json');

  const abi = JSON.parse(fs.readFileSync(abiPath));
  const bytecode = JSON.parse(fs.readFileSync(bytecodePath));

  return JSON.stringify({
    name,
    abi,
    bytecode,
  });
};

module.exports = getContractPattern;

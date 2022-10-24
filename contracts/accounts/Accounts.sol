// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "../oz/Ownable.sol";
import "../oz/Pausable.sol";

contract Accounts is Ownable, Pausable  {
  
  struct Account {
      address _addr;
      string _pubKey;
      string _emailHash;
  }

  mapping(address => Account) private _accounts;
  address[] private _mapKeys;

  event addedAccount(address sender, string pubKey, string emailHash);
  event changedEmail(address sender, string emailHash);
  
  function pause() external onlyOwner {
      _pause();
  }
  
  function unpause() external onlyOwner {
      _unpause();
  }


  function _exists(address addr) internal view returns (bool) {
    return _accounts[addr]._addr != address(0);
  }

  function addAccount(string memory pubKey, string memory emailHash) public whenNotPaused {
      address addr = _msgSender();
      require(_exists(addr) == false, "Accounts: account already exists");
      _mapKeys.push(addr);
      _accounts[addr] = Account(addr, pubKey, emailHash);
      emit addedAccount(addr, pubKey, emailHash);
  }

  function changeEmail(string memory emailHash) public whenNotPaused {
      address addr = _msgSender();
      require(_exists(addr) == true, "Accounts: account does not exist");
      _accounts[addr]._emailHash = emailHash;
      emit changedEmail(addr, emailHash);
  }

  function getAccount (address addr) public view returns (address, string memory, string memory) {
      Account memory a = _accounts[addr];
      return (a._addr, a._pubKey, a._emailHash);
  }

  function getAccounts () public view returns (address[] memory, string[] memory, string[] memory) {
      uint len = _mapKeys.length;
      address[] memory addresses = new address[](len);
      string[] memory pubKeys = new string[](len);
      string[] memory emailHashes = new string[](len);

      for (uint i = 0 ; i < len ; i++) {
          addresses[i] = _accounts[_mapKeys[i]]._addr;
          pubKeys[i] = _accounts[_mapKeys[i]]._pubKey;
          emailHashes[i] = _accounts[_mapKeys[i]]._emailHash;
      }

      return (addresses, pubKeys, emailHashes);
  }
}

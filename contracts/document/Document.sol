// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "../oz/Ownable.sol";
import "../oz/Pausable.sol";

contract Document is Pausable, Ownable {

    // States :
    //1 -> TO_BE_REVIEWED, this dr has received a dd, waiting decision
    //2 -> UPDATE_REQUIRED,	the dd has been rejected and waits for an update
    //3 -> ACCEPTED,	the dd is definitely accepted
    //4 -> REJECTED,	the dd is definitely rejected
    //5 -> DROPPED,	the dd should not be reviewed, as it was cancelled by document issuer
    mapping(bytes32 => uint8) private _status;

    bytes32 private _lastDocumentReceived;
    bytes32[] private _mapKeys;

    //events
    event sentDocument(address sender, address receiver, bytes32 hash, uint8 status);
    event acceptedDocument(address receiver, bytes32 hash, uint8 status);
    event rejectedDocument(address receiver, bytes32 hash, uint8 status);
    event askedUpdateDocument(address receiver, bytes32 hash, uint8 status);

    // at least one document was sent by the requestedTo
    modifier atLeastOneDocument {
        require(_lastDocumentReceived != 0x0, "No document has been sent yet");
        _;
    }

    modifier notAccepted {
        require(_status[_lastDocumentReceived] != 3, "The document has already been accepted");
        _;
    }

    modifier notRejected {
        require(_status[_lastDocumentReceived] != 4, "The document has already been rejected");
        _;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // the sender sends a new document
    // can only be done by the requestedTo
    // can only be done if the last document status is NOT ACCEPTED AND NOT REJECTED
    function sendDocument(bytes32 hash) external notAccepted notRejected whenNotPaused{
        require(_status[hash] != 1, "Same document is already waiting for review");
        // when the previous document has not been reviewed yet
        if (_status[_lastDocumentReceived] == 1 && hash != _lastDocumentReceived){
            _status[_lastDocumentReceived] = 5;
        }
        _lastDocumentReceived = hash;
        _mapKeys.push(hash);
        _status[hash] = 1;
        emit sentDocument(_msgSender(), owner(), hash, _status[_lastDocumentReceived]);
    }

    // can only be done if the last document status is NOT ACCEPTED, NOT REJECTED
    // lastDocumentReceived cannot be undefined
    function acceptDocument() external onlyOwner atLeastOneDocument notAccepted notRejected whenNotPaused{
        _status[_lastDocumentReceived] = 3;
        emit acceptedDocument(owner(), _lastDocumentReceived, _status[_lastDocumentReceived]);
    }

    // can only be done if the last document status is NOT ACCEPTED, NOT REJECTED
    // lastDocumentReceived cannot be undefined
    function rejectDocument() external onlyOwner atLeastOneDocument notAccepted notRejected whenNotPaused{
        _status[_lastDocumentReceived] = 4;
        emit rejectedDocument(owner(), _lastDocumentReceived, _status[_lastDocumentReceived]);
    }

    // can only be done if the last document status is NOT ACCEPTED, NOT REJECTED
    // lastDocumentReceived cannot be undefined
    function askUpdateDocument() external onlyOwner atLeastOneDocument notAccepted notRejected whenNotPaused{
        _status[_lastDocumentReceived] = 2;
        emit askedUpdateDocument(owner(), _lastDocumentReceived, _status[_lastDocumentReceived]);
    }

    function getStatus(bytes32 hash) public view returns (uint8) {
        return(_status[hash]);
    }

    function getHistory() public view returns (bytes32[] memory, uint8[] memory) {
        uint mapLength = _mapKeys.length;
        
        uint8[] memory allStatus = new uint8[](mapLength);
        bytes32[] memory allHashes = new bytes32[](mapLength);

        for (uint i=0; i<mapLength; i++) {
            allStatus[i] = _status[_mapKeys[i]];
            allHashes[i] = _mapKeys[i];
        }
        return (allHashes, allStatus);
    }
}

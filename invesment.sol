//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Invesment {
    address investor;
    address public contractAddress;
    string public chasisNumber;
    uint public tokens;

    constructor (address _user, string memory _carRef, uint _tokens) {
        investor = _user;
        contractAddress = address(this);
        chasisNumber = _carRef;
        tokens = _tokens;
    }

    modifier OnlyInvestor(address _sender) {
        require(_sender == investor, "No tienes permisos para realizar esta accion");
        _;
    }

    function addInvesment(uint _tokens) public OnlyInvestor(msg.sender) {
        tokens += _tokens;
    }

    function withdrawInvesment(uint _tokens) public OnlyInvestor(msg.sender) {
        require(_tokens <= tokens, "No posee una inversion de esa magnitud para retirar.");
        tokens -= _tokens;
    }
}
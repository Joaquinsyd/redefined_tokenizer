//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Rental {
    address renter;
    address contractAddress;
    string chasisNumber;
    uint public returnDate;
    bool public active;

    constructor (address _user, string memory _carRef, uint _months) {
        renter = _user;
        contractAddress = address(this);
        chasisNumber = _carRef;
        active = true;
        returnDate = block.timestamp + (_months*30 days);
    }

    modifier OnlyRenter(address _sender) {
        require(_sender == renter, "No tienes permisos para realizar esta accion");
        _;
    }

    function returnVehicle() public OnlyRenter(msg.sender) {
        require(returnDate >= block.timestamp, "Se paso, hay que cobrar un agregado. //TODO");
        active = false;
    }

    function extendRental(uint _time) public OnlyRenter(msg.sender) {
        require(returnDate >= block.timestamp, "Se paso, hay que cobrar un agregado. //TODO");
        returnDate += _time;
    }
}
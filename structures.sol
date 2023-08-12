//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;


// ------------------------------------ ESTRUCTURAS ------------------------------------

struct Vehicle {
    string chasisNumber;
    string engineNumber;
    string domain;
    string vehicleType;
    string model;
    string brand;
    uint rentalPrice;
    uint tokensLeft;
    bool rented;
}

struct RentableItem {
    string identifier;
    uint tokensLeft;
}
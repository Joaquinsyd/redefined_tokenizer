//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "./SafeMath.sol"; //Esta librería provee funciones aritméticas preparadas para manejar errores que pueden aparecer
import "./ERC20.sol"; //El contrato que creamos para usar en nuestro marketplace
import "./structures.sol"; //

import "./rental.sol";
import "./invesment.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract car_rental {

    // ---------------------------------- DECLARACIONES ----------------------------------

    //Instancia al contrato
    IERC20 private tokenManager;
    address payable public owner;
    address public contractAddress;
    uint constant initialTokens = 1000000;  // ******** REDEFINIR ********

    using SafeMath for uint256;

    constructor() {
        owner = payable(msg.sender); // La cuenta a la que le vamos a pagar del proyecto
        contractAddress = address(this);
        tokenManager = new ERC20Basic(initialTokens);
    }

    string[] public batch;
    string[] itemsWithTokensLeft;
    mapping(string => RentableItem) details;

    mapping(string => address[]) public invesmentsByItem;
    mapping(string => address) carRental;

    mapping(address => address[]) public invesmentsByUser; // redefinir, usuario referenciado por id
    mapping(address => address[]) rentalsByUser;

    mapping(address => Invesment) invesments;

    modifier OnlyOwner(address _sender) {
        require(_sender == owner, "No tienes permisos para realizar esta accion");
        _;
    }

    // -------------------------------- GESTION DE TOKENS --------------------------------

    //Funcion para establecer precio de tokens
    function priceTokens(uint _tokens) internal pure returns(uint){
        return _tokens * (0.001 ether);   // 200 euros
    }

    //Funcion para comprar tokens
    function buyTokens(uint _tokens) internal{
        uint cost = priceTokens(_tokens);
        require(msg.value >= cost, "Fondos insuficientes");
        uint returnValue = msg.value - cost;

        payable(msg.sender).transfer(returnValue);

        uint balance = balanceOf();

        require(_tokens <= balance, "Tokens insuficientes");

        tokenManager.transfer(msg.sender, _tokens);
    }

    function balanceOf() public view returns(uint){
        return tokenManager.balanceOf(contractAddress);
    }

    //Visualizar tokens
    function myTokens() public view returns(uint) {
        return tokenManager.balanceOf(msg.sender);
    }

    //Generar mas tokens
    function acquireTokens(uint _amount) public OnlyOwner(msg.sender) {
        tokenManager.increaseTotalSupply(_amount);
    }

    //Recuperar dinero al devolver tokens
    function returnTokens(uint _tokens) public payable {
        require(myTokens() >= _tokens, "No tienes fondos suficientes para realizar esta accion");
        //Devolucion de los tokens
        tokenManager.transferAsThirdParty(msg.sender, contractAddress, _tokens);
        //Pago de ethers
        payable(msg.sender).transfer(priceTokens(_tokens));
    }

    function importTokens() public view returns(address){
        return address(tokenManager);
    }

    // -------------------------------- ADQUISICIONES --------------------------------

    function addCar(string memory chasisNumber) public OnlyOwner(msg.sender) {   // NA
        require(keccak256(abi.encodePacked(details[chasisNumber].identifier)) != keccak256(abi.encodePacked(chasisNumber)), "Ya existe este vehiculo");
        details[chasisNumber] = RentableItem(chasisNumber, 100);
        batch.push(chasisNumber);
        itemsWithTokensLeft.push(chasisNumber);
    }

    function invest(uint _tokens) public payable{
        buyTokens(_tokens);
        require(myTokens() >= _tokens, "No tiene fondos sufucientes para realizar esta accion");
        uint tokensInvested = 0;
        for(uint i = itemsWithTokensLeft.length-1; i >= 0; i--){
            if(details[itemsWithTokensLeft[i]].tokensLeft > _tokens-tokensInvested){
                investInAVehicle(msg.sender, itemsWithTokensLeft[i], _tokens-tokensInvested);
                break;
            } else {
                uint auxTokens = details[itemsWithTokensLeft[i]].tokensLeft;
                investInAVehicle(msg.sender, itemsWithTokensLeft[i], auxTokens); // msg.sender???? o otro address definido
                itemsWithTokensLeft.pop();
                i++;
                tokensInvested += auxTokens;
            }
        }
    }

    function investInAVehicle(address _invester, string memory _vehicle, uint _tokens) private {
        // Si un cliente invierte en mas de un token se genera un solo contrato para la cantidad de tokens
        Invesment inv = new Invesment(_invester, _vehicle, _tokens);
        address add = inv.contractAddress();
        // tokenManager.transferAsThirdParty(_invester, owner, _tokens);
        invesments[add] = inv;
        invesmentsByItem[_vehicle].push(add);
        details[_vehicle].tokensLeft = details[_vehicle].tokensLeft - _tokens;
        invesmentsByUser[_invester].push(add);
    }

    // -------------------------------- GETTERS --------------------------------

    function myInvestments() public view returns(address[] memory) {
        return invesmentsByUser[msg.sender];
    }

}

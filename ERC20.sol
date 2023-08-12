//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "./SafeMath.sol";

interface IERC20 {

    //Devuelve la cantidad de tokens en existencia
    function totalSupply() external view returns(uint256);

    function increaseTotalSupply(uint _newTokenAmount) external;

    //Devuelve la cantidad de tokens para una direccion
    function balanceOf(address account) external view returns(uint256);

    //Devuelve el numero de tokeks que el spender podra gastar en nombre del propietario
    function allowance(address owner, address spender) external view returns(uint256);

    //Devuelve un booleano con el resultado de una transferencia.
    function transfer(address recipient, uint256 amount) external returns(bool);
    function transferAsThirdParty(address sender, address recipient, uint256 amount) external returns(bool);

    //Devuelve un booleano con el resultado de la aprobacion de una transferencia
    function approve(address spender, uint256 amount) external returns(bool);

    //Devuelve un booleano con el resultado de la operacion de pasaje de una cantidad de tokens
    // usando el metodo allowance()
    function transferFrom(address recipient, address sender, uint256 amount) external returns(bool);

    //Evento que se debe emitir cuando una cantidad de tokens son tranferidas de un origen a un destino
    event Transfer(address indexed from, address indexed to, uint256 value);

    //Evento que se debe emitir cuando se establece una asignacion on el metodo allowance()
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20Basic is IERC20 {

    string public constant name = "Soluty";
    string public constant symbol = "SLT";
    uint8 public constant decimals = 0;

    using SafeMath for uint256;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    uint256 totalSupply_;

    constructor (uint256 initialSupply) {
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns(uint256){
        return totalSupply_;
    }

    function balanceOf(address _tokenOwner) public override view returns(uint256){
        return balances[_tokenOwner];
    }

    function increaseTotalSupply(uint _newTokenAmount) public override {
        totalSupply_ += _newTokenAmount;
        balances[msg.sender] += _newTokenAmount;
    }

    function allowance(address _owner, address _spender) public override view returns(uint256){
        return allowed[_owner][_spender];
    }

    function transfer(address _recipient, uint256 _tokens) public override returns(bool){
        require(_tokens <= balances[msg.sender], "No dispone de fondos suficientes para realizar esta accion");
        balances[msg.sender] = balances[msg.sender].sub(_tokens);
        balances[_recipient] = balances[_recipient].add(_tokens);
        emit Transfer(msg.sender, _recipient, _tokens);
        return true;
    }

    function transferAsThirdParty(address _sender, address _recipient, uint256 _tokens) public override returns(bool){
        require(_tokens <= balances[_sender], "No dispone de fondos suficientes para realizar esta accion");
        balances[_sender] = balances[_sender].sub(_tokens);
        balances[_recipient] = balances[_recipient].add(_tokens);
        emit Transfer(_sender, _recipient, _tokens);
        return true;
    }

    function approve(address _spender, uint256 _tokens) public override returns(bool){
        allowed[msg.sender][_spender] = _tokens;
        emit Approval(msg.sender, _spender, _tokens);
        return true;
    }

    function transferFrom(address _owner, address _buyer, uint256 _tokens) public override returns(bool){
        require(_tokens <= balances[_owner], "El propietario no dispone de fondos suficientes para realizar esta accion");
        require(_tokens <= allowed[_owner][msg.sender], "No tiene permisos para tranferir dicha cantidad");

        balances[_owner] = balances[_owner].sub(_tokens);
        allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_tokens);
        balances[_buyer] = balances[_buyer].add(_tokens);
        emit Transfer(_owner, _buyer, _tokens);
        return true;
    }

}


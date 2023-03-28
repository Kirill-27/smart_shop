// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract MyShop {
    address public owner;
    mapping (address => uint256) public payments;
    uint256 public maximumToWithdraw;
    uint public firstLevelValue;
    uint public secondLevelValue;
    uint public thirdLevelValue;
    uint256 public secondLevel;
    uint256 public thirdLevel;

    constructor() {
        owner = msg.sender;
        firstLevelValue  = 1;
        secondLevelValue = 3;
        thirdLevelValue = 5;
        secondLevel = 2 ether/100;
        thirdLevel  = 10 ether/100;
    }

    function payForItem() public payable {
        payments[msg.sender] += msg.value;
        maximumToWithdraw += msg.value*(100-thirdLevelValue)/100;
    }

    function calculateDiscount(uint256 balance) public view returns(uint256) {
        uint256 _result = balance*firstLevelValue/100;
        if(balance >= thirdLevel) {
            _result = balance*thirdLevelValue/100;
        } else if(balance >= secondLevel) {
            _result = balance*secondLevelValue/100;
        }
        return _result; 
    }

    function checkMyMoney() public view returns (uint256){
        return calculateDiscount(payments[msg.sender]);
    }


    function withdraw() public  {
        uint256 _contractBalance = address(this).balance;
        require(0<_contractBalance, "There are not enough funds on the contract balance now, please try again later.");
        uint256 _value = payments[msg.sender];
        require(_value>0, "Your current cashback is zero.");
        uint256 _result = calculateDiscount(_value);
        if(_result>_contractBalance) {
            _result = _contractBalance;
            maximumToWithdraw = 0;
        } else {
            maximumToWithdraw += _value*thirdLevelValue/100;
            maximumToWithdraw -= _result;
        }
        address payable _to =  payable(msg.sender);
        payments[msg.sender] -= _value;
        _to.transfer(_result);
    }

    function ownerWithdraw() public  {
        require(msg.sender==owner, "Your are not an owner.");
        uint256 _valueToWithdraw = maximumToWithdraw;
        address payable _to = payable(owner);
        _to.transfer(_valueToWithdraw);
        maximumToWithdraw -= _valueToWithdraw;
    }


    function ownerWithdrawValue(uint256 value) public  {
        require(msg.sender==owner, "Your are not an owner.");
        require(value<=(address(this)).balance, "Value is higer than contract balance");
        address payable _to = payable(owner);
        _to.transfer(value);
        if(maximumToWithdraw<=value) {
            maximumToWithdraw = 0;
        } else {
            maximumToWithdraw -= value;
        }
        
    }

}
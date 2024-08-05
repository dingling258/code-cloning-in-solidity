// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract AccessControl{
    event GrantRole(bytes32 role, address account);
    event RevokeRole(bytes32 role, address account);

    address immutable tokenAddress;
    
    mapping(bytes32 => mapping(address => bool)) roles;
    mapping(address => uint256) balances;


    bytes32 public constant DEFAULT_ADMIN_ROLE =   keccak256(abi.encodePacked("ADMIN"));
    bytes32 public constant REVIEWER_ROLE = keccak256(abi.encodePacked("REVIEWER"));


    constructor(address _tokenAddress){
        tokenAddress = _tokenAddress;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    //This function should be protected
    function initialize() public {
        //Anyone can call the init function 
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(REVIEWER_ROLE, msg.sender);
    }

    modifier onlyRole(bytes32 role){
        require(roles[role][msg.sender]);
        _;
    }

    function deposit() public payable{
        require(msg.value >= 1 ether, "Not enough ether");
        balances[msg.sender] += msg.value;
    }

    //This function should be protected
    function withdraw() public{
        payable(msg.sender).transfer(address(this).balance);
    }

    function _grantRole(bytes32 _role, address _account) internal{
        roles[_role][_account] = true;
    }

    function grantRole(bytes32 _role, address _account) external onlyRole(DEFAULT_ADMIN_ROLE){
        _grantRole(_role, _account);
        emit GrantRole(_role, _account);
    }

    function revokeRole(bytes32 role, address _account) external onlyRole(DEFAULT_ADMIN_ROLE){
        roles[role][_account] = false;
        emit RevokeRole(role, _account);
    }
}
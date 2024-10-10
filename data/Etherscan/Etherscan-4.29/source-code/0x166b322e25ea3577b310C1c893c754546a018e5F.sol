/**
 *Submitted for verification at Etherscan.io on 2024-03-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;

        _;
        _status = _NOT_ENTERED;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}



contract Vault is ReentrancyGuard {
    IERC20 public token;

    

    address owner;
    address dev;
    address teamMember1;
    address teamMember2;
    address teamMember3;
    address teamMember4;  
    address teamMember5;  
    address teamMember6;  
    address teamMember7;

   struct Team {
    address member;
    uint256 amountDue;
    uint256 amountClaimed;
    uint256 nextClaim;
    uint8 timesClaimed;
   }

   struct Partner {
    address member;
    uint256 amountDue;
    uint256 amountClaimed;
    uint256 nextClaim;
    uint8 timesClaimed;
   }

   
   uint8 public partnerLimit = 60;
   uint8 public partnerTotal = 0;

   uint8 public partnerVestingPeriods = 24;
   uint8 public teamVestingPeriods = 24;

   uint8 public partnerVestingPercent = 33; 
   uint8 public teamVestingPercent = 33;


    uint8 public tgePercent = 200; //This number is the % multiplied by 10

   

   
    mapping (address => Team) public team;
    mapping (address => Partner) public partner;
    

    
    uint256 public totalTLB = 3 * 10 **9 * 10 **18;
    uint256 public tge = 1711998000; //1711998000 April 1, 2024 (arbitrary)
    

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(
        address  _owner,
        address _dev,
        address _teamMember1,
        address _teamMember2,
        address _teamMember3,
        address _teamMember4,
        address _teamMember5,
        address _teamMember6,
        address _teamMember7
    ) {

        owner = _owner;
        dev = _dev;
        teamMember1 = _teamMember1;
        teamMember2 = _teamMember2;
        teamMember3 = _teamMember3;
        teamMember4 = _teamMember4;
        teamMember5 = _teamMember5;
        teamMember6 = _teamMember6;
        teamMember7 = _teamMember7;

        team[_owner] = Team(
            _owner,
            (totalTLB * 8)/100,
            0,
            tge,
            0          
        );
        team[_dev] = Team(
            _dev,
            (totalTLB * 1)/100,
            0,
            tge,
            0
        );
        team[_teamMember1] = Team(
            _teamMember1,
            (totalTLB * 5)/1000,
            0,
            tge,
            0
        );
        team[_teamMember2] = Team(
            _teamMember2,
            (totalTLB * 5)/1000,
            0,
            tge,
            0
        );
        team[_teamMember3] = Team(
            _teamMember3,
            (totalTLB * 1)/100,
            0,
            tge,
            0
        );
        team[_teamMember4] = Team(
            _teamMember4,
            (totalTLB * 1)/100,
            0,
            tge,
            0
        );
         team[_teamMember5] = Team(
            _teamMember5,
            (totalTLB * 5)/1000,
            0,
            tge,
            0
        );
         team[_teamMember6] = Team(
            _teamMember6,
            (totalTLB * 25)/10000,
            0,
            tge,
            0
        );
         team[_teamMember7] = Team(
            _teamMember7,
            (totalTLB * 25)/10000,
            0,
            tge,
            0
        );    
    
    }

    function getVaultBalance() external view returns (uint256){
        return token.balanceOf(address(this));
    }


    //Added getclaim period function to let people know they can claim their next batch
    function getTeamClaimPeriod(address _addr) public view returns (uint256) {
        return team[_addr].nextClaim;
    }

    function getPartnerClaimPeriod(address _addr) public view returns (uint256) {
        return partner[_addr].nextClaim;
    }

    function getTeamAmountDue(address _addr) public view returns (uint256){
        return team[_addr].amountDue;
    }
    function getPartnerAmountDue(address _addr) public view returns (uint256){
        return partner[_addr].amountDue;
    }


    /* Add partner by address and %. You cannot add decimals, therefore, to calculate _percentInBasePoints
    * take the decimal that you want to add and multiply by 1000. For example,
    * 2% or 0.02 would be 20, and .2% or .002 would be 2.
    */
    function addPartner(address _partner, uint8 _percentInBasePoints) external onlyOwner {
        require(0 < _percentInBasePoints && _percentInBasePoints <= partnerLimit, "Added amount exceeds total partner limit");
        require(_percentInBasePoints + partnerTotal <= partnerLimit, "Added amount exceeds partner allocation limit");
        require(partner[_partner].member == address(0), "Partner already added!");
        partner[_partner] = Partner (
            _partner,
            (totalTLB * _percentInBasePoints)/1000,
            0,
            tge,
            0  
        );
        partnerTotal+= _percentInBasePoints;

    }

    

    function teamClaim() external nonReentrant {
        require(
            msg.sender == team[msg.sender].member,
            "Team Member not found!"
        );
        require(
            block.timestamp > team[msg.sender].nextClaim,
            "Not time for next vesting"
        );
        require(
            team[msg.sender].timesClaimed < teamVestingPeriods,
            "You're already fully vested!"
        );
        require(
            team[msg.sender].amountDue > 0,
            "You are not due to collect anymore."
        );

        

         if (team[msg.sender].timesClaimed == 0){
            uint256 amountReceived = (team[msg.sender].amountDue *
                tgePercent) / 1000;
            require(
                token.balanceOf(address(this)) >= amountReceived,
                "Insufficient balance of TLB held in contract to complete claim"
            );

            token.transfer(msg.sender, amountReceived );

            team[msg.sender].nextClaim = block.timestamp + 2629743; //2629743 1 month
            team[msg.sender].amountClaimed += amountReceived;
            team[msg.sender].timesClaimed++;
        }


        else if (team[msg.sender].timesClaimed == (teamVestingPeriods - 1)) {
            uint256 remainder = team[msg.sender].amountDue -
                team[msg.sender].amountClaimed;
            require(
                token.balanceOf(address(this)) >= remainder,
                "Insufficient balance of TLB held in contract to complete claim"
            );

            token.transfer(msg.sender, remainder);

            team[msg.sender].amountClaimed += remainder;
            team[msg.sender].timesClaimed++;
        } else if ((team[msg.sender].amountDue - team[msg.sender].amountClaimed) < (team[msg.sender].amountDue * teamVestingPercent)/1000) {
            uint256 remainder = team[msg.sender].amountDue -
                team[msg.sender].amountClaimed;
             require(
                token.balanceOf(address(this)) >= remainder,
                "Insufficient balance of TLB held in contract to complete claim"
            );

            token.transfer(msg.sender, remainder);

            team[msg.sender].amountClaimed += remainder;
            team[msg.sender].timesClaimed++;
        }
        
        else {
            uint256 amountReceived = (team[msg.sender].amountDue *
                teamVestingPercent) / 1000;
            require(
                token.balanceOf(address(this)) >= amountReceived,
                "Insufficient balance of TLB held in contract to complete claim"
            );

            token.transfer(msg.sender, amountReceived);

            team[msg.sender].nextClaim = block.timestamp + 2629743; //2629743 1 month;
            team[msg.sender].amountClaimed += amountReceived;
            team[msg.sender].timesClaimed++;
        }
    }

    
    function partnerClaim() external nonReentrant {
        require(
            msg.sender == partner[msg.sender].member,
            "Team Member not found!"
        );
        require(
            block.timestamp > partner[msg.sender].nextClaim,
            "Not time for next vesting"
        );
        require(
            partner[msg.sender].timesClaimed < partnerVestingPeriods,
            "You're already fully vested!"
        );
        require(
            partner[msg.sender].amountDue > 0,
            "You are not due to collect anymore."
        );

        

         if (partner[msg.sender].timesClaimed == 0){
            uint256 amountReceived = (partner[msg.sender].amountDue *
                tgePercent) / 1000;
            require(
                token.balanceOf(address(this)) >= amountReceived,
                "Insufficient balance of TLB held in contract to complete claim"
            );

            token.transfer(msg.sender, amountReceived );

            partner[msg.sender].nextClaim = block.timestamp + 2629743; //1 month
            partner[msg.sender].amountClaimed += amountReceived;
            partner[msg.sender].timesClaimed++;
        }


        else if (partner[msg.sender].timesClaimed == (partnerVestingPeriods - 1)) {
            uint256 remainder = partner[msg.sender].amountDue -
                partner[msg.sender].amountClaimed;
            require(
                token.balanceOf(address(this)) >= remainder,
                "Insufficient balance of TLB held in contract to complete claim"
            );

            token.transfer(msg.sender, remainder);

            partner[msg.sender].amountClaimed += remainder;
            partner[msg.sender].timesClaimed++;
        } else if ((partner[msg.sender].amountDue - partner[msg.sender].amountClaimed) < (partner[msg.sender].amountDue * partnerVestingPercent)/1000) {
            uint256 remainder = partner[msg.sender].amountDue -
                partner[msg.sender].amountClaimed;
             require(
                token.balanceOf(address(this)) >= remainder,
                "Insufficient balance of TLB held in contract to complete claim"
            );

            token.transfer(msg.sender, remainder);

            partner[msg.sender].amountClaimed += remainder;
            partner[msg.sender].timesClaimed++;
        }
        
        else {
            uint256 amountReceived = (partner[msg.sender].amountDue *
                partnerVestingPercent) / 1000;
            require(
                token.balanceOf(address(this)) >= amountReceived,
                "Insufficient balance of TLB held in contract to complete claim"
            );

            token.transfer(msg.sender, amountReceived);

            partner[msg.sender].nextClaim = block.timestamp + 2629743; //2592000;
            partner[msg.sender].amountClaimed += amountReceived;
            partner[msg.sender].timesClaimed++;
        }
    }

    function setTge(uint256 _newTge) external onlyOwner{
        tge = _newTge;
    }

    function setTgePercent(uint8 _percent) external onlyOwner {
        require(_percent > 0 && _percent <= 100, "Invalid percentage entered");
        tgePercent = _percent * 10;
    }

    function setToken(address _token) external onlyOwner {
        token = IERC20(_token);
    }

    
    
    function setVesting(
        uint8 _newTeamPeriod, 
        uint8 _newTeamPercent,
        uint8 _newPartnerPeriod,
        uint8 _newPartnerPercent
        )
        external
        onlyOwner
    {
        teamVestingPeriods = _newTeamPeriod;
        teamVestingPercent = _newTeamPercent;
        partnerVestingPeriods = _newPartnerPeriod;
        partnerVestingPercent = _newPartnerPercent;
    }

    function setPartnerLimit (uint8 _percent) external onlyOwner {
        require(_percent > 0 && _percent <= 100, "Invalid percentage entered");
        partnerLimit = _percent * 10;
    }

    

    function transferOwnership(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    

   
}
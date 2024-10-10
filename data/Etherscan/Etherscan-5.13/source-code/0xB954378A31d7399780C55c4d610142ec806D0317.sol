// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.18;

//This Predictions Market is not compatible with hopping oracles.
//This is experimental and later versions will include more flushed out features. 
//To be compatible with oracle hops, requestItems would need to hash in the oracle's address incase of a new oracle address.
//This PM does not support oracle hops. So don't make any markets too far into the future.

contract $PM{
    address admin;
    address THIS = address(this);
    address address0 = address(0);
    uint public constant tickSize = 1e15;
    uint constant unit = 1e18;
    uint constant $ANON_burn = 1e16;
    uint constant $LULZ_burn = 1e18;
    bool activated = true;
    uint constant houseFee = 400;//10000
    uint constant hostShare = 40;//100
    uint teamLulz;
    uint teamAnon;
    uint lastWithdraw;
    TOKEN $ANON = TOKEN(0x1f0eFA15e9cB7ea9596257DA63fECc36ba469b30);
    TOKEN $LULZ = TOKEN(0x466353Bcadab13081F59aBB4D400FD27b0F0642a);
    ORACLE $HALO = ORACLE(0x50E8BE2BcB56Ce40e96e5626A15771cb1d53B7AD); 
    mapping(uint => uint8) requestType;//0 - market approval, 1 - market resolution
    mapping(uint => uint) requestItem;//index of item the request ticket pertains to
    mapping(address => uint) public ETH;
    
    constructor(){
		admin = msg.sender;
        lastWithdraw = block.timestamp;
	}

    function powerSwitch(bool a)internal{
        require(msg.sender == admin);
        activated = a;
    }

    function changeOwner(address _newOwner)internal{
        require(msg.sender == admin);
        admin = _newOwner;
    }
    
    function housePull()internal{
        require(msg.sender == admin && lastWithdraw+((teamAnon*120+teamLulz*20)*60)>block.timestamp);
        lastWithdraw = block.timestamp;
        $ANON.transfer(admin, teamAnon*$ANON_burn);
        $LULZ.transfer(admin, teamLulz*$LULZ_burn);
        teamAnon = 0;
        teamLulz = 0;
    }

    uint public markets;
    mapping(uint => Market) market;
    struct Market{
        address creator;
        uint blocknumber;//for retrieving event data. Title & Description
        uint closeDate;
        uint8 approval;
        bool pendingResults;
        bool result;
        bool finalized;
        uint initialSellingPrice;
        bool doubtedOutcome;
        uint8 lulzBonus;
        uint pool;
        mapping(address => mapping(bool => uint)) shares;
        OrderBookPosition[] orderbook;
    }

    struct OrderBookPosition{
        address owner;
        uint8 sellBuyYesNo;
        uint amount;
        uint price;
    }

    event PositionUpdated(uint indexed marketID, uint indexed positionID, address indexed owner, uint8 sellBuyYesNo, uint amount, uint price);
    event TradeExecuted(uint indexed marketID, address indexed trader, uint8 SBYN, uint tradeAmount, uint tradePrice);
    event PositionsAdded(uint indexed marketID, address owner, uint8[] sellBuyYesNo, uint[] amounts, uint[] prices);

    function getHaloCost() public view returns(uint){
        (uint part1, uint part2) = $HALO.getFee();
        return part2+part1;
    }

    event MarketCreated(string title, string description, uint closing_date, uint ticket_id, uint market_id);
    function CreateMarket(string calldata title, string calldata description, uint closeDate, uint initialSellingPrice, uint jumpstartCash, bool doubtedOutcome, bool lulzBonus, bool anonBonus) public payable returns(uint marketID){
        address sender = msg.sender;
        uint DAO_cost = getHaloCost();
        ETH[sender] = ETH[sender] + msg.value - DAO_cost - jumpstartCash;
        
        require(activated && initialSellingPrice % tickSize == 0);

        marketID = markets++;
        uint blocknumber = block.number;
        uint requestTicket = $HALO.fileRequestTicket{value: DAO_cost}(true);
        emit MarketCreated(title,description,closeDate,requestTicket,marketID);
        requestItem[requestTicket] = marketID;
        requestType[requestTicket] = 0;

        Market storage _market = market[marketID];
        _market.creator = sender;
        _market.blocknumber = blocknumber;
        _market.initialSellingPrice = initialSellingPrice;
        _market.doubtedOutcome = doubtedOutcome;
        _market.closeDate = closeDate;
        _market.pool = jumpstartCash;
        if(lulzBonus || anonBonus){
            _market.lulzBonus = lulzBonus?1:2;
            require(  (lulzBonus?$LULZ:$ANON).transferFrom(sender,THIS,(lulzBonus?$LULZ_burn:$ANON_burn)));
        }
    }
    
    event MintedShares(uint indexed marketID, uint value, uint sellingPrice, bool doubtedOutcome, bool existingPosition, uint existingPositionID);
    function buyShares(uint marketID, uint value, uint sellingPrice, bool doubtedOutcome, bool existingPosition, uint existingPositionID, uint[][] calldata sellAgainstPositions_expectedPrices_amounts, bool allOrNone)public payable{
        //existing position ID can be of an exisitng position you own or one that is empty.
        Market storage _market = market[marketID];
        emit MintedShares( marketID,  value, sellingPrice, doubtedOutcome,  existingPosition, existingPositionID);
        require(sellingPrice % tickSize == 0 && _market.approval==2);
        address sender = msg.sender;
        ETH[sender] = ETH[sender] + msg.value - value;//baked in safe math should revert underflows.
        
        _market.shares[sender][!doubtedOutcome] += value;
        _market.pool += value;
        
        if(sellingPrice>0 || existingPosition){//if we're going to create sell order for the side we doubt
            if(existingPosition){
                OrderBookPosition storage obp = _market.orderbook[existingPositionID];
                if(obp.owner==address0){
                    obp.owner = sender;
                    obp.price = sellingPrice;
                    obp.sellBuyYesNo = doubtedOutcome?1:0;
                }else if(obp.owner==address0 && doubtedOutcome==(obp.sellBuyYesNo%2==0) ){
                    //just add money to the existing position
                }else{
                    revert('You can only point to existing positions that are empty or match one of your pre-existing ones');
                }
                obp.amount += value;
            }else{
                OrderBookPosition memory newPosition = OrderBookPosition({
                    owner: sender,
                    sellBuyYesNo: doubtedOutcome?1:0,// sellBuy is 0 + ?
                    price: sellingPrice,
                    amount: value
                });
                _market.orderbook.push(newPosition);
            }
        }else{
            _market.shares[sender][doubtedOutcome] += value;
            if(sellAgainstPositions_expectedPrices_amounts.length>0) addToPoolAndSellDoubtedSideToExistingPositions(marketID,doubtedOutcome, sellAgainstPositions_expectedPrices_amounts[0], sellAgainstPositions_expectedPrices_amounts[1],sellAgainstPositions_expectedPrices_amounts[2], allOrNone);
        }
    }

    function addToPoolAndSellDoubtedSideToExistingPositions(uint marketID, bool yesNo, uint[] calldata sellAgainstPositions, uint[] calldata expectedPrices, uint[] calldata amounts, bool allOrNone) internal{
        uint L = sellAgainstPositions.length;
        uint8[] memory expectedSBYN = new uint8[](L);
        for(uint i;i<L;i++){
            expectedSBYN[i] = 2+(yesNo?1:0);
        }
        trade(marketID,sellAgainstPositions,expectedPrices,expectedSBYN,amounts,allOrNone,true);
    }
    
    modifier marketExists(uint256 marketID) {
        require(marketID < markets, "Value exceeds the threshold");
        _;
    }

    function addPositions(uint M, uint8[] calldata sellBuyYesNo, uint[] calldata price, uint[] calldata amounts, bool[] calldata replaceDeadPosition, uint[] calldata positionIDs) public  payable {
        emit PositionsAdded(M, msg.sender, sellBuyYesNo, amounts, price);
        Market storage _market = market[M];
        require(_market.approval==2 && !isMarketFinalizedOrPastClosingDate(_market));
        M = 0;// repurpose M to tally how much ETH is needed in msg.value.
        uint[] memory req = new uint[](2);
        for(uint i=0;i<sellBuyYesNo.length;i++){
            if(sellBuyYesNo[i]/2==1){//tally how much ETH is needed to be in msg.value
                M += amounts[i];
            }else{//tally how much of each type of share is needed by the sender.
                if(sellBuyYesNo[i]%2==0){
                    req[0]+=amounts[i];
                }else{
                    req[1]+=amounts[i];
                }
            }
            addPosition(_market, msg.sender, sellBuyYesNo[i], amounts[i], price[i], replaceDeadPosition[i], positionIDs[i]);
        }
        //make sure the assets exist to add these positions to the orderbook
        _market.shares[msg.sender][false] -= req[0];//will revert if underflow
        _market.shares[msg.sender][true] -= req[1];//will revert if underflow
        ETH[msg.sender] = ETH[msg.sender] + msg.value - M;
    }

    function addPosition(Market storage _market, address owner, uint8 sellBuyYesNo, uint amount, uint price, bool attemptReplace, uint positionID) internal{
        require(price>0 && price % tickSize == 0);
        
        if(attemptReplace){
            OrderBookPosition storage obp;
            obp = _market.orderbook[positionID];
            if(obp.amount == 0){
                obp.owner = owner;
                obp.amount = amount;
                obp.price = price;
                obp.sellBuyYesNo = sellBuyYesNo;
                return;
            }
        }
        
        OrderBookPosition memory newPosition = OrderBookPosition({
            owner: owner,
            sellBuyYesNo: sellBuyYesNo,
            price: price,
            amount: amount
        });
        _market.orderbook.push(newPosition);
    }

    function SBYN(uint sellBuyYesNo)internal pure returns(uint){
        return (sellBuyYesNo/2==1)?2:( (sellBuyYesNo%2==0)?0:1 );
    }

    function updatePosition(uint marketID, uint[] calldata positions, uint[] calldata amounts, uint[] calldata price) public payable marketExists(marketID){
        Market storage _market = market[marketID];
        OrderBookPosition storage obp;
        require(_market.approval==2);
        uint x; 
        address sender = msg.sender;
        uint[] memory requiredAmounts = new uint[](6);
        for(uint i;i<positions.length;i++){
            obp = _market.orderbook[ positions[i] ];
            require(obp.owner == sender);
            if(price[i]>0){
                require(price[i] % tickSize == 0, "Price must be a multiple of tickSize");
                obp.price = price[i];
            }

            x = SBYN(obp.sellBuyYesNo);
            
            if(0==(obp.amount = obp.amount + amounts[i] - amounts[i+positions.length])){
                delete obp.owner;
                delete obp.sellBuyYesNo;
                delete obp.price;
            }
            emit PositionUpdated(marketID, positions[i], sender, obp.sellBuyYesNo, obp.amount, obp.price);
            requiredAmounts[x]+=amounts[i];
            requiredAmounts[x+3]+=amounts[i+positions.length];
        }
        _market.shares[sender][false] =_market.shares[sender][false] + requiredAmounts[3] - requiredAmounts[0];//will revert if underflow
        _market.shares[sender][true] =_market.shares[sender][true]+ requiredAmounts[4] - requiredAmounts[1];//will revert if underflow
        ETH[sender] = ETH[sender] + msg.value + requiredAmounts[5] - requiredAmounts[2];//should revert if underflow
    }


    function isMarketFinalizedOrPastClosingDate(Market storage m) internal view returns (bool) {
        return m.finalized || block.timestamp > m.closeDate;
    }

    function rmath(uint x, uint amount, uint expectedPrice, bool Y)internal pure returns(uint){
        if(Y)
            {return (x - amount)*unit/expectedPrice;}
        else
            {return (x - amount)*expectedPrice/unit;}
    }
    
    function trade(uint x, uint[] calldata positions, uint[] calldata expectedPrices, uint8[] memory expectedSBYN, uint[] memory amounts, bool allOrNone, bool ignorePayable)public payable{
        uint[] memory UINTs = new uint[](7);//01:-+yes, 23:-+no, 45:-+ETH
        UINTs[6] = x;
        Market storage _market = market[x];
        require(_market.approval==2 && !isMarketFinalizedOrPastClosingDate(_market));
        OrderBookPosition storage obp;
        address sender = msg.sender;
        bool yesno;
        for(uint i; i<positions.length; i++){
            obp = _market.orderbook[ positions[i] ];
            if(expectedSBYN[i]/2==0){
                x = amounts[i]*unit/expectedPrices[i];
            }else{
                x = amounts[i]*expectedPrices[i]/unit;
            }

            if(allOrNone && obp.amount<x){revert('allOrNone flag is set to All and a posiition selected is insufficient');}

            if( expectedSBYN[i] == obp.sellBuyYesNo && expectedPrices[i] == obp.price){//to prevent front-running
                if(obp.amount<x){//if an order went ahead of you that causes you to have excess && you're !allOrNone, salvage excess.
                    amounts[i] = rmath(x, obp.amount,expectedPrices[i],expectedSBYN[i]/2==0);
                    x = obp.amount;
                }
                yesno = expectedSBYN[i]%2==1;
                if(expectedSBYN[i]/2==0){//you are sending ETH in
                    ETH[obp.owner] += amounts[i];
                    UINTs[4] += amounts[i];
                    UINTs[(yesno?0:2)+1] += x;
                }else{//you are sending tokens
                    UINTs[5] += x;
                    UINTs[yesno?0:2] += amounts[i];
                    _market.shares[obp.owner][yesno] += amounts[i];
                }
                emit TradeExecuted(UINTs[6], sender, expectedSBYN[i], amounts[i], obp.price);
                obp.amount -= x;
                if(0==obp.amount){
                    delete obp.owner;
                    delete obp.sellBuyYesNo;
                    delete obp.price;
                }
            }else{//if the order changes from what the user expects
                if(allOrNone){
                   revert('Order Book Position was changed before your trade could go through'); 
                }
            }
        }
        ETH[sender] = (ETH[sender] + (ignorePayable?0:msg.value) + UINTs[5]) - UINTs[4];
        _market.shares[sender][false] =( _market.shares[sender][false] + UINTs[3]) - UINTs[2];
        _market.shares[sender][true] = (_market.shares[sender][true] + UINTs[1]) - UINTs[0];
    }

    function addPositionsThenTrade(uint marketID, uint8[][] calldata _SBYN, uint[][] calldata PAPPEA, bool[] calldata replaceDeadPosition, bool allOrNone) public payable{
        addPositions(marketID, _SBYN[0], PAPPEA[0], PAPPEA[1],replaceDeadPosition,PAPPEA[2]);
        trade( marketID, PAPPEA[3], PAPPEA[4], _SBYN[1], PAPPEA[5], allOrNone,true);
    }
    function updatePositionThenTrade(uint marketID, uint[] calldata positionsToUpdate, uint[] calldata updateAmounts, uint[] calldata priceUpdates, uint[][] calldata PEA, uint8[] calldata _SBYN, bool allOrNone) public payable{
        updatePosition(marketID, positionsToUpdate, updateAmounts, priceUpdates);
        trade( marketID, PEA[0], PEA[1], _SBYN, PEA[2], allOrNone,true);
    }

    function transfer(uint marketID, address to, bool yesNo, uint amount) public{
        Market storage _market = market[marketID];
        _market.shares[msg.sender][yesNo] -= amount;//solidity should revert if underflow. no require() needed
        _market.shares[to][yesNo] += amount;
    }

    event ResolveMarket(uint indexed market_id, uint ticket_id, uint market_datablock, bool earlyResolve);
    function resolveMarket(uint marketID) public payable marketExists(marketID){
        //request is different if it's early.
        Market storage _market = market[marketID];
        require(!_market.pendingResults && _market.approval==2 && !_market.finalized);
        _market.pendingResults = true;
        uint DAO_cost = getHaloCost();
        uint requestTicket = $HALO.fileRequestTicket{value: DAO_cost}(false);
        bool early = block.timestamp<_market.closeDate;
        emit ResolveMarket(marketID, requestTicket, _market.blocknumber, early);
        requestItem[requestTicket] = marketID;
        requestType[requestTicket] = early?2:1;
        ETH[msg.sender] = ETH[msg.sender] + msg.value - DAO_cost;
    }
    
    event Claim(uint indexed marketID, address indexed account, uint amount);
    function claim(uint marketID, uint[] calldata positionIDs, bool _withdraw)public{
        Market storage _market = market[marketID];
        address sender = msg.sender;
        require(_market.finalized);
        bool resolve = _market.result;
        uint shareValue = _market.shares[sender][resolve];
        delete _market.shares[sender][true];
        delete _market.shares[sender][false];
        uint positionValue;
        uint L = positionIDs.length;
        uint index;
        OrderBookPosition storage obp;
        uint8 _SBYN;
        for(uint i;i<L;i++){
            index = positionIDs[i];
            obp = _market.orderbook[index];
            if(obp.owner==sender){
                _SBYN = obp.sellBuyYesNo;
                if( (_SBYN/2==0) && ((_SBYN%2==1) == resolve) ){
                    positionValue+= obp.amount;
                }
                delete obp.sellBuyYesNo;
                delete obp.amount;
                delete obp.price;
                delete obp.owner;
            }
        }
        uint $$$ = shareValue + positionValue;
        $$$ = $$$-($$$*houseFee/10000);
        ETH[sender] += $$$;
        emit Claim(marketID, sender,$$$);
        
        if(_withdraw) withdraw();
    }

    event Withdraw(address indexed account, uint amount);
    function withdraw() public{
        address sender = msg.sender;
        uint val = ETH[sender];
        ETH[sender] = 0;
        (bool success, ) = payable(sender).call{value: val}("");
        require(success);
        emit Withdraw(sender, val);
    }

    event MarketApproved(uint indexed marketID, address creator, bool approved);
    function oracleIntFallback(uint ticketID, uint numberOfOptions, uint[] calldata optionWeights, int[] calldata options) public{
        require(msg.sender == address($HALO));
        
        uint optWeight;
		uint positive;
		uint negative;

		//YES OR NO?
		for(uint i; i < numberOfOptions; i+=1){
			optWeight = optionWeights[i];
			if(options[i]>0){
				positive += optWeight;
			}else{
				negative += optWeight;
			}
		}

        uint8 rType = requestType[ticketID];
        
        uint marketID = requestItem[ticketID];
        Market storage _market = market[marketID];
        if(rType == 0){
            address creator = _market.creator;
            uint jumpStartCash = _market.pool;
            bool approved = positive>negative;
            uint8 lulzBonus = _market.lulzBonus;
            if(approved){
                _market.approval = 2;
                uint initialSellingPrice = _market.initialSellingPrice;
                _market.shares[creator][!_market.doubtedOutcome] = jumpStartCash;
                if(initialSellingPrice>0){
                    OrderBookPosition memory newPosition = OrderBookPosition({
                        owner: creator,
                        sellBuyYesNo: _market.doubtedOutcome?1:0,// sellBuy is 0 + ?
                        price: initialSellingPrice,
                        amount: jumpStartCash
                    });
                    _market.orderbook.push(newPosition);
                }else{
                    _market.shares[creator][_market.doubtedOutcome] = jumpStartCash;
                }
                if(lulzBonus==1){ teamLulz += 1; }
                if(lulzBonus==2){ teamAnon += 1; }
            }else{
                _market.approval = 1;
                ETH[creator] += jumpStartCash;
                
                if(lulzBonus==1){ $LULZ.transfer(creator, $LULZ_burn); }
                if(lulzBonus==2){ $ANON.transfer(creator, $ANON_burn); }
            }
            emit MarketApproved(marketID, _market.creator, approved);

        }
    }

    event MarketResponse(uint indexed marketID, bool result, bool finalized);
    function oracleObjectiveIntFallback(uint ticketID, int resolved_int) external {
        require(msg.sender == address($HALO));

        uint marketID = requestItem[ticketID];
        Market storage _market = market[marketID];

        if(resolved_int == 0){
            //The request to resolve the market early was denied or the oracle didn't respond
            _market.pendingResults = false;
        }else{
            _market.finalized = true;
            if(resolved_int == 2){//Market resolveed to YES
                _market.result = true;
            }//implicit else: Market Resolved to NO

            uint house = _market.pool*houseFee/10000;
            uint lul = _market.lulzBonus>0 ? house*hostShare/100 : 0;

            $HALO.payService{value:house - lul}();
            ETH[_market.creator] += lul;
        }
        emit MarketResponse(marketID, _market.result, _market.finalized);

    }


    function viewOrderBookPositions(uint marketID, uint offset, uint limit) public view returns (OrderBookPosition[] memory) {
        Market storage m = market[marketID];
        uint length = m.orderbook.length;
        
        if (offset > length){
            return new OrderBookPosition[](0); // Return an empty array if the offset is beyond the array length
        }
        
        if (limit == 0 || (offset + limit) > length || limit > length){
            limit = length - offset; // Adjust limit if it's beyond the end of the array or if it's 0
        }
        
        OrderBookPosition[] memory positions = new OrderBookPosition[](limit);
        for (uint i = 0; i < limit; i++) {
            positions[i] = m.orderbook[offset + i];
        }
        return positions;
    }

    struct MarketData {
        uint ID;
        address creator;
        uint blocknumber;
        uint closeDate;
        uint8 approval;
        bool pendingResults;
        bool result;
        bool finalized;
        bool doubtedOutcome;
        uint8 lulzBonus;
        uint pool;
        uint orderBookLength;
        uint yesShares;
        uint noShares;
    }

    function getMarketData(uint marketID, address addr) public view marketExists(marketID) returns (MarketData memory){
        Market storage m = market[marketID];
        return MarketData({
            ID: marketID,
            creator: m.creator,
            blocknumber: m.blocknumber,
            closeDate: m.closeDate,
            approval: m.approval,
            pendingResults: m.pendingResults,
            result: m.result,
            finalized: m.finalized,
            doubtedOutcome: m.doubtedOutcome,
            lulzBonus: m.lulzBonus,
            pool: m.pool,
            orderBookLength: m.orderbook.length,
            yesShares: m.shares[addr][true],
            noShares: m.shares[addr][false]
        });
    }

    function getMultipleMarketData(address addr, uint count, uint offset) public view returns (MarketData[] memory) {
        uint marketCount = markets;
        if (marketCount == 0 || count == 0 || offset >= marketCount) {
            return new MarketData[](0);
        }
        
        uint startIndex = offset < marketCount ? marketCount - offset : 0;
        uint endIndex = startIndex > count ? startIndex - count : 0;
        uint resultCount = startIndex - endIndex;
        MarketData[] memory results = new MarketData[](resultCount);
        
        for (uint i = 0; i < resultCount; i++) {
            results[i] = getMarketData(endIndex + i, addr);
        }
        return results;
    }

}

abstract contract TOKEN{
	function transfer(address _to, uint256 _value) public virtual returns (bool);
	function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool);
}
abstract contract ORACLE{
    function fileRequestTicket(bool subjective) public payable virtual returns(uint ticketID);
    function getFee() public view virtual returns(uint txCoverageFee, uint serviceFee);
    function payService() public payable virtual;
}
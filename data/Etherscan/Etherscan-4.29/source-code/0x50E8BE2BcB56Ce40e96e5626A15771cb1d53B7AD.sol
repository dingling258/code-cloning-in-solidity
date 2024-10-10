// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.18;

interface IERC721Receiver {
	function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) external returns (bytes4);
}

contract DAO is IERC721Receiver {
	address ORACLE = address(0);
	address address0 = address(0);

	struct RequestTicket{
		uint ID;
		address sender;
		uint timeRequested;
		uint timeWindow;
		bool finalized;
		uint serviceFee;
		bool subjective;

		mapping(address => mapping(address => bool)) attacks;
		mapping(address => bool) damaged;

		//commit
		mapping(address => bool) committed;
		mapping(address => bytes32) commitHash;

		//reveal
		mapping(address => bool) revealed;
		mapping(address => int) votes;

		//RESULTS
		int resolve;
	}

	//oracle configs
	uint constant ROUNDTABLE_SEATS = 0;
	uint constant RESPONSE_TIME_WINDOW = 1;
	uint constant DELEGATE_REWARDSHARE = 2;
	uint constant SERVICE_FEE = 3;
	uint constant TX_FEE_PER = 4;
	uint constant CONFIGS = 5;

	uint[] public oracleConfigurations = new uint[](CONFIGS);
	
	mapping(address => uint) resolveWeight;
	mapping(address => uint) weightLocked;
	
	mapping(uint => RequestTicket) requestTickets;
	uint requestTicketCount;
	//ROUND TABLE & Candidates
	mapping(uint => address) public chairsCandidate; // only looks at the first X indexes
	mapping(address => uint) candidatesChair;
	mapping(address => uint) timeSeated; // watchers aren't responsible for requestTickets that came in before them
	mapping(address => bool) isWatcher;
	mapping(address => uint) public stakeID;
	mapping(address => uint) seatingNonce;
	uint chairs;
	uint public hotSeats;

	uint256 constant scaleFactor = 0x10000000000000000;
	//PAYROLL
		//of user
		mapping(address => uint) earnings;
		mapping(address => mapping(address => uint256)) public backingNonce;
		mapping(address => mapping(address => mapping(uint => uint))) public shares;
		mapping(address => mapping(address => mapping(uint => uint))) payouts;
		//of pool
		mapping(address => mapping(uint => uint)) totalShares;
		mapping(address => mapping(uint => uint)) earningsPerShare;

	//Tx Coverage fee
	uint earningsPerWatcher;
	uint public totalWatchers;
	mapping(address => uint256) watcherPayouts;


	//lazy UI data
	mapping(address => address[]) public yourBacking;
	mapping(address => mapping(address => bool)) public alreadyBacking;
	
	address pyramidAddress = 0x668D201319765c560cc5A38a7CEEfFEBfF05645C;
	Pyramid public pyramid;
	ResolveToken public resolveToken;
	address payable pineapples;
	
	address THIS = address(this);
	
	constructor(){
		pyramid = Pyramid(pyramidAddress);
		resolveToken = pyramid.resolveToken();
		pineapples = payable(msg.sender);

		freshConfigs();
		registered[THIS] = true;
		jobs.push(THIS);
	}

	function freshConfigs() internal{
		hotSeats = 7;
		oracleConfigurations[ROUNDTABLE_SEATS] = 7;
		oracleConfigurations[RESPONSE_TIME_WINDOW] = 4000;
		oracleConfigurations[DELEGATE_REWARDSHARE] = 25*1e18;
		oracleConfigurations[SERVICE_FEE] = 1e16/5;
		oracleConfigurations[TX_FEE_PER] = 1e16/5;
	}

	function _now() internal view returns(uint){
		return block.number;
	}

	function addShares(address pool, address account, uint amount) internal{
		update(pool, account);
		uint seatNonce = seatingNonce[pool];
		totalShares[pool][seatNonce] += amount;
		shares[pool][account][seatNonce] += amount;

		if(pool == ORACLE){
			updateWatcherTxEarnings(account,false);
			if (account != address0){
				totalWatchers += 1;
				isWatcher[account] = true;
			}
		}
	}

	function removeShares(address pool, address account, uint amount) internal{
		update(pool, account);
		uint seatNonce = seatingNonce[pool];
		totalShares[pool][seatNonce] -= amount;
		shares[pool][account][seatNonce] -= amount;

		if(pool == ORACLE){
			updateWatcherTxEarnings(account,true);
			if (account != address0){
				isWatcher[account] = false;
				uint emptiedSeat = candidatesChair[account];

				address tail = chairsCandidate[totalWatchers-1];
				chairsCandidate[ emptiedSeat ] = tail;
				candidatesChair[tail] = emptiedSeat;

				totalWatchers -= 1;
			}
		}
	}

	function dividendsOf(address pool, address account) public view returns(uint){
		uint seatNonce = backingNonce[account][pool];
		uint owedPerShare = earningsPerShare[pool][seatNonce] - payouts[pool][account][seatNonce];
		if(pool == ORACLE && !isWatcher[account])
			return 0;
		return shares[pool][account][seatNonce] * owedPerShare / scaleFactor;
	}
	
	function currentTotalShares(address watcher) private view returns(uint){
		return totalShares[watcher][seatingNonce[watcher]];
	}

	event WatcherPayroll(address watcher, uint paidOut);
	function update(address pool, address account) internal {
		uint seatNonce = backingNonce[account][pool];
		uint newMoney = dividendsOf(pool, account);
		payouts[pool][account][seatNonce] = earningsPerShare[pool][seatNonce];

		if(pool == ORACLE){
			uint eth4Watcher = newMoney * oracleConfigurations[DELEGATE_REWARDSHARE] / (1e20);
			earnings[account] += eth4Watcher;
			dividendsForElectorate(account, newMoney - eth4Watcher);
		}else{
			earnings[account] += newMoney;
		}
	}

	function dividendsForElectorate(address watcher, uint amount) internal {
		uint watcherShares = currentTotalShares(watcher);
		if(watcherShares>0){
			//this is what the watcher has to distribute to its electorates
			earningsPerShare[watcher][seatingNonce[watcher]] += amount * scaleFactor / watcherShares;
		}
	}

	event TxCashout(address watcher, uint amount);
	function updateWatcherTxEarnings(address watcher, bool paying) internal {
		uint owed = earningsPerWatcher - watcherPayouts[watcher];
		watcherPayouts[watcher] = earningsPerWatcher;
		if(paying) earnings[watcher] += owed;
		emit TxCashout(watcher, owed);
	}

	event StakeResolves( address indexed addr, uint256 amountStaked, bytes _data );
	function tokenFallback(address from, uint value, bytes calldata _data) external{
		if( msg.sender == address(resolveToken) ){
			if(from == pyramidAddress){
				return;// if the pyramid is sending resolve tokens back to this contract, then do nothing.
			}
			resolveWeight[from] += value;

			emit StakeResolves(from, value, _data);
			
			address backImmediately = bytesToAddress( _data );

			if( backImmediately != address0){
				backCandidate(from, backImmediately, value);
			}

		}else{
			revert();
		}
	}

	event UnstakeResolves(address sender, uint amount);
	function unstakeResolves(uint amount) public{
		address sender = msg.sender;
		if( amount <= ( resolveWeight[sender] - weightLocked[sender] ) ){
			resolveWeight[sender] -= amount;

			emit UnstakeResolves(sender, amount);

			resolveToken.transfer(sender, amount);
		}else{
			revert();
		}
	}

	event BackCandidate(address sender,address candidate, uint amount);
	function stakeCandidate(address candidate, uint amount) public{ backCandidate(msg.sender, candidate, amount); }
	function backCandidate(address sender, address candidate, uint amount) internal{
		require(candidate!=ORACLE);
		uint _seatingNonce = seatingNonce[candidate];
		if(_seatingNonce!=backingNonce[sender][candidate]){
			update(candidate,sender); 	
		}
		
		if( amount <= ( resolveWeight[sender] - weightLocked[sender] ) && !isWatcher[candidate] ){
			weightLocked[sender] += amount;
			
			backingNonce[sender][candidate] = _seatingNonce;
			addShares(candidate, sender, amount);

			emit BackCandidate(sender, candidate, amount);
			//LAZY U.I.
			if(!alreadyBacking[sender][candidate]){
				yourBacking[sender].push(candidate);
				alreadyBacking[sender][candidate] = true;
			}
		}else{
			revert();
		}	
	}
	
	event PullBacking(address sender, address candidate, uint amount);
	function pullBacking( address candidate, uint amount ) public{
		address sender = msg.sender;
		if( amount <= shares[candidate][sender][seatingNonce[candidate]] && !isWatcher[candidate] ){
			weightLocked[sender] -= amount;
			removeShares(candidate, sender, amount);
			emit PullBacking(sender, candidate, amount);
		}else{
			revert();
		}
	}

	function pullAllTheWay(address candidate, uint amount) public{
		pullBacking(candidate, amount);
		unstakeResolves(amount);
	}

	event AssertCandidate(address candidate, bool successfulAssert, address replacedWatcher, uint newSeat, uint shares);
	function assertCandidate() public returns(bool success){
		address candidate = msg.sender;
		uint weakestChair;
		bool nullSeat;
		require( hotSeats > 0);
		address thisWatcher;
		address otherWatcher;
		uint seatNonce;
		uint seatNonce2;
		if(hotSeats == totalWatchers){
			for(uint i; i<hotSeats; i+=1){
				thisWatcher = chairsCandidate[i];
				seatNonce = seatingNonce[thisWatcher];
				otherWatcher = chairsCandidate[weakestChair];
				seatNonce2 = seatingNonce[otherWatcher];
				if( totalShares[ thisWatcher ][seatNonce] < totalShares[ otherWatcher ][seatNonce2] ){
					weakestChair = i;
				}
			}
		}else{
			nullSeat = true;
			weakestChair = totalWatchers;
		}

		uint totalShares_candidate = currentTotalShares(candidate);
		uint totalShares_other = currentTotalShares(otherWatcher);
		if( (totalShares_candidate > totalShares_other || nullSeat ) && !isWatcher[candidate] ){
			
			if(!nullSeat){
				uint pullAmount = totalShares_other;
				removeShares(ORACLE, otherWatcher, pullAmount);
				pyramid.pullResolves(stakeID[otherWatcher],pullAmount);
			}else{
				otherWatcher = address0;
			}

			addShares(ORACLE, candidate, totalShares_candidate);
			stakeID[candidate] = pyramid.totalSupply();
			resolveToken.transfer(pyramidAddress, totalShares_candidate);
			
			timeSeated[candidate] = _now();

			chairsCandidate[weakestChair] = candidate; 
			candidatesChair[candidate] = weakestChair;

			emit AssertCandidate(candidate, true, otherWatcher, weakestChair, totalShares_candidate);
			return true;
		}

		emit AssertCandidate(candidate, false, address0, weakestChair, 0);
		return false;
	}

	//mapping(uint => uint) internalRequestID;
	mapping(uint => bool) internalRequestType;
	mapping(uint => uint8) configType;
	mapping(uint => uint) configSetting;
	event OracleConfigRequest(uint8 config, uint setting, uint indexed ticket_id);
	function oracleConfigRequest(uint8 config, uint setting) public payable returns(uint ticketID){
		ticketID = this.fileRequestTicket{value: msg.value }(true);
		require(config<CONFIGS);
		configType[ticketID] = config;
		configSetting[ticketID] = setting;
		emit OracleConfigRequest(config, setting, ticketID);
	}

	mapping(uint => address) requestedContract;
	mapping(address => bool) public registered;
	address[] private jobs;
	mapping(address => uint256) public jobIndex;
	mapping(address => uint256) public jobBlock;

	event OracleJobRequest(string description, address contract_address, bool updated_state , uint indexed ticket_id);
	function oracleJobRequest(string memory description, address _contract, bool updatedState) public payable returns(uint ticketID){
		ticketID = this.fileRequestTicket{ value: msg.value }(true);
		internalRequestType[ticketID] = true;
		configSetting[ticketID] = updatedState?_now():0;
		requestedContract[ticketID] = _contract;
		emit OracleJobRequest(description, _contract, updatedState, ticketID);
	}

	event JobStatusResponse(address job_address, bool job_state, uint indexed ticket_id, bool update_successful);
	event ConfigResponse(uint8 config_type, uint config_setting, uint indexed ticket_id, bool accepted);
	function oracleIntFallback(uint ticketID, uint numberOfOptions, uint[] calldata optionWeights, int[] calldata options) public{
		uint optWeight;
		uint positive;
		uint negative;
		require( msg.sender == THIS );

		//YES OR NO?
		for(uint i; i < numberOfOptions; i+=1){
			optWeight = optionWeights[i];
			if(options[i]>0){
				positive += optWeight;
			}else{
				negative += optWeight;
			}
		}

		if(internalRequestType[ticketID]){
			address _requestedContract = requestedContract[ticketID];
			uint blockJob = configSetting[ticketID];
			bool updatedState = blockJob>0;
			if(positive>negative){
				registered[_requestedContract] = updatedState;
				if(updatedState){
					if(jobIndex[_requestedContract] == 0){
						jobIndex[_requestedContract] = jobs.length;
						jobs.push(_requestedContract);
					}
					jobBlock[_requestedContract] = blockJob;
				}else{
					if(jobIndex[_requestedContract] != 0){
						uint256 indexToRemove = jobIndex[_requestedContract];
						address lastJob = jobs[jobs.length - 1];

						jobs[indexToRemove ] = lastJob;
						jobIndex[lastJob] = indexToRemove;

						jobs.pop();
						delete jobIndex[_requestedContract];
						delete jobBlock[_requestedContract];
					}
				}
				
				emit JobStatusResponse(_requestedContract, updatedState, ticketID, true);
			}else{
				emit JobStatusResponse(_requestedContract, updatedState, ticketID, false);
			}
		}else{
			uint8 _configType = configType[ticketID];
			uint _configSetting = configSetting[ticketID];

			if(positive>negative){
				
				if(_configType == RESPONSE_TIME_WINDOW){ _configSetting = _configSetting>180?_configSetting:180; }
				if(_configType == ROUNDTABLE_SEATS){
					_configSetting = _configSetting>7?_configSetting:7;
				}
				if(_configType == DELEGATE_REWARDSHARE){ _configSetting = _configSetting>1e20?1e20:_configSetting; }

				oracleConfigurations[_configType] = _configSetting;

				if(_configType == ROUNDTABLE_SEATS){
					if(hotSeats<oracleConfigurations[ROUNDTABLE_SEATS]){
						hotSeats = oracleConfigurations[ROUNDTABLE_SEATS];
					}
				}

				emit ConfigResponse(_configType, _configSetting, ticketID, true);	
			}else{
				emit ConfigResponse(_configType, _configSetting, ticketID, false);
			}
		}
	
	}

	function getFee() public view returns(uint txCoverageFee, uint serviceFee){
		return ( oracleConfigurations[TX_FEE_PER]*hotSeats, oracleConfigurations[SERVICE_FEE] );
	}

	uint public devFunds;
	function updatePines(address addr) public{
		require(msg.sender == pineapples);
		pineapples = payable(addr);
	}

	function devPull() public{
		require(msg.sender == pineapples);
		uint money = devFunds;
		devFunds = 0;
		(bool success, ) = payable(msg.sender).call{value: money}("");
        require(success);
	}

	//------------------------------ Request Ticket Life Cycle
	//
	uint[] private watcherTickets;
	mapping(uint256 => uint256) public ticketIndex;

	event FileRequestTicket(address job_address, uint ticket_id, bool subjective, uint response_time_window, uint fee_paid);
	function fileRequestTicket( bool subjective) public payable returns(uint ticketID){
		uint ETH = msg.value;
		address sender = msg.sender;
		(uint txCoverageFee, uint serviceFee) = getFee();
		
		uint finalServiceFee = ETH - txCoverageFee;
		uint devFee = finalServiceFee/20;
		finalServiceFee -= devFee;

		require( registered[sender] );

		if(ETH >= txCoverageFee + serviceFee){
			ticketID = requestTicketCount;
			RequestTicket storage ticket = requestTickets[requestTicketCount];
			requestTicketCount++;

			ticket.timeRequested = _now();
			ticket.timeWindow = oracleConfigurations[RESPONSE_TIME_WINDOW];
			ticket.ID = ticketID;
			ticket.sender = sender;
			ticket.subjective = subjective;
			ticket.serviceFee = finalServiceFee;

			ticketIndex[ticketID] = jobs.length;
			watcherTickets.push(ticketID);

			devFunds += devFee;

			earningsPerWatcher += txCoverageFee / totalWatchers;

			emit FileRequestTicket(msg.sender, ticketID, subjective, ticket.timeWindow, ETH);
		}else{
			revert();
		}
	}

	event CommitVote(address voter, uint ticket_id, bytes32 hash);
	function commitVote(uint[] memory tickets, bytes32[] memory voteHashes) external{
		address sender = msg.sender;
		RequestTicket storage ticket;
		for(uint R; R<tickets.length; R+=1 ){
			ticket = requestTickets[ tickets[R] ];
			if( _now() <= ticket.timeRequested + ticket.timeWindow ){
				ticket.committed[sender] = true;
				ticket.commitHash[sender] = voteHashes[R];
				emit CommitVote(sender, tickets[R], voteHashes[R]);
			}else{
				revert();//outside of timewindow
			}
		}
	}
	
	event RevealVote(address voter, uint ticket_id, int vote, string comment);
	function revealVote(uint[] memory tickets, int[] memory votes, uint[] memory passwords, string[] memory comments) external{
		address sender = msg.sender;
		RequestTicket storage ticket;
		bytes memory abiEncodePacked;
		for(uint R; R<tickets.length; R+=1 ){
			ticket = requestTickets[ tickets[R] ];
			if( ticket.committed[sender] ){
				if(_now() > ticket.timeRequested + ticket.timeWindow && _now() <= ticket.timeRequested + ticket.timeWindow*2 ){
					
					abiEncodePacked = abi.encodePacked(  votes[R], passwords[R] );
				
					if( compareBytes( keccak256(abiEncodePacked), requestTickets[ tickets[R] ].commitHash[sender] ) ){
						
						require(!requestTickets[ tickets[R] ].revealed[sender]);

						requestTickets[ tickets[R] ].revealed[sender] = true;
						requestTickets[ tickets[R] ].votes[sender] = votes[R];
					
						emit RevealVote(sender, tickets[R], votes[R], comments.length==0?'':comments[R]);
					}else{
						revert();//not a match
					}
				}else{
					revert();//outside of timewindow
				}
			}else{
				revert();//hasn't committed
			}
		}
	}

	event SubjectiveStance(address voter, uint ticket_id, address defender, bool stance, string comment);
	function subjectiveStance(uint[] memory tickets, address[] memory defenders, bool[] memory stances, string[] memory comments) external{
		address sender = msg.sender;
		RequestTicket storage ticket;
		for(uint R; R<tickets.length; R+=1 ){
			ticket = requestTickets[ tickets[R] ];
			if(timeSeated[sender] <= ticket.timeRequested){
				if( timeSeated[defenders[R]] <= ticket.timeRequested && _now() > ticket.timeRequested + ticket.timeWindow*2 && _now() <= ticket.timeRequested + ticket.timeWindow*3 ){
					ticket.attacks[sender][defenders[R]] = stances[R];
					emit SubjectiveStance(sender, tickets[R], defenders[R], stances[R], comments.length==0?'':comments[R]);
				}else{
					revert();//outside timewindow
				}
			}else{
				revert();//you just got here homie, whatchu takin' shots for?
			}
		}
	}

	function calculateDamage(uint ticketID) internal view returns(uint combatWeight, uint[] memory damage){
		RequestTicket storage ticket = requestTickets[ticketID];
		address offensiveWatcher;
		address defender;
		uint Y;
		uint X;
		uint seatNonce;
		uint totalShares_offensiveWatcher;
		damage = new uint[](hotSeats);
		if(ticket.subjective){
			for(X = 0; X < hotSeats; X+=1){
				offensiveWatcher = chairsCandidate[X];
				seatNonce = seatingNonce[offensiveWatcher];
				if( isWatcher[offensiveWatcher] && timeSeated[offensiveWatcher] <= ticket.timeRequested && ticket.revealed[offensiveWatcher] ){
					totalShares_offensiveWatcher=totalShares[offensiveWatcher][seatNonce];
					combatWeight += totalShares_offensiveWatcher;
					for(Y = 0; Y < hotSeats; Y+=1){
						defender = chairsCandidate[Y];
						if( isWatcher[defender] && timeSeated[defender] <= ticket.timeRequested){
							if(ticket.attacks[offensiveWatcher][defender]){
								damage[Y] += totalShares_offensiveWatcher;
							}
						}
					}	
				}
			}
		}
	}

	event FinalizedRequest(uint ticket_id, address[] watchers);
	function finalizeRequests(uint[] memory tickets) external{
		for(uint R; R<tickets.length; R+=1 ){
			finalizeRequest( tickets[R] );
		}
	}
	
	function prune(uint[] memory ticketIDs) public{
		RequestTicket storage ticket;
		
		uint L = ticketIDs.length;
		if(L==0){
			ticketIDs = watcherTickets;
			L = ticketIDs.length;
		}
		uint ticketID;
		uint256 indexToRemove;
		uint256 lastTicket;
		for(uint i;i<L;i++){
			ticketID = ticketIDs[i];
			ticket = requestTickets[ticketID];
			if( _now() > ticket.timeRequested+ticket.timeWindow*10 ){
				indexToRemove = ticketIndex[ticketID];
				lastTicket = watcherTickets[watcherTickets.length - 1];

				watcherTickets[indexToRemove - 1] = lastTicket;
				ticketIndex[lastTicket] = indexToRemove;

				watcherTickets.pop();
				delete ticketIndex[ticketID];
			}
		}
	}

	function finalizeRequest(uint uintility) public{
		// if response time window is over or all delegates have voted,
		// anyone can finalize the request to trigger the event
		RequestTicket storage ticket = requestTickets[uintility];
		if(!ticket.finalized){
			
			address watcher;
			
			int[] memory options = new int[](hotSeats);
			uint[] memory optionWeights = new uint[](hotSeats);

			address[] memory watchers = new address[](hotSeats);// lazy UI data

			uint[] memory UINTs = new uint[](6);//0= weight of votes, 2= number of options, 3=top Option, 5 = combat weight, 1  = loop for saving subjectives to storage

			uint opt;
			uint[] memory damage;
			(UINTs[5]/*combatWeight*/, damage) = calculateDamage(uintility);
			
			
			for(uint chair = 0; chair < hotSeats; chair+=1){
				watcher = chairsCandidate[chair];
				watchers[chair] = watcher;
				if(damage[chair]<=UINTs[5]/*combatWeight*//2){
					if( watcher!=address0 && isWatcher[watcher] && timeSeated[watcher] <= ticket.timeRequested && ticket.revealed[watcher] ){
						uintility = currentTotalShares(watcher);
						UINTs[0]/*weight of votes*/ += uintility;
						//check to see if chosen option already is accounted for, if so, add weight to it.
										
						for(opt = 0; opt<UINTs[2]/*option count*/; opt+=1){
							if( options[opt] == ticket.votes[watcher] ){
								optionWeights[opt] += uintility;
								if(optionWeights[opt] > optionWeights[UINTs[3]/*top option*/] && !ticket.subjective){
									UINTs[3]/*top option*/ = opt;
								}
								break;
							}
						}
					

						//add new unique option
						if(opt == UINTs[2]/*option count*/){
							options[UINTs[2]/*option count*/] = ticket.votes[watcher];
							optionWeights[UINTs[2]/*option count*/] = uintility;
							
							UINTs[2]/*option count*/+=1;
						}
					
					}
				}else{
					ticket.damaged[watcher] = true;
				}
			}
			
			if(  _now() > ticket.timeRequested + ticket.timeWindow*(ticket.subjective?3:2)  ){
				
				//write results in stone
				int resolve = options[UINTs[3]/*top option*/];
				if(!ticket.subjective){
					ticket.resolve = resolve;
				}

				//dish out the rewards
				uint oracleTotal = totalShares[ORACLE][0];
				if(oracleTotal>0)
					earningsPerShare[ORACLE][0] += ticket.serviceFee * scaleFactor / oracleTotal;

				ticket.finalized = true;
				if(ticket.subjective){
					Requestor(ticket.sender).oracleIntFallback(ticket.ID, UINTs[2]/*number of options*/, optionWeights, options);
				}else{
					Requestor(ticket.sender).oracleObjectiveIntFallback(ticket.ID, resolve);
				}
				
				emit FinalizedRequest(ticket.ID, watchers);
			}else{
				revert();
			}
		}
	}

	event PayService(uint paid);
	function payService() public payable{
		uint val = msg.value;
		uint pines = val/20;
		uint forOracle = val - pines;
		devFunds += pines;
		earningsPerShare[ORACLE][0] += forOracle * scaleFactor / totalShares[ORACLE][0];
		emit PayService(msg.value);
	}

	event Cashout(address addr, uint ETH);
	function cashout(address[] memory pools) external{
		address payable sender = payable(msg.sender);
		for(uint p; p < pools.length; p+=1){
			update(pools[p], sender);
		}
		runWatcherPayroll(sender);
		uint ETH = earnings[sender];
		earnings[sender] = 0;
		emit Cashout(sender, ETH);
		(bool success, ) = payable(sender).call{value: ETH}("");
        require(success);
	}

	function runWatcherPayroll(address watcher) public{
		if( isWatcher[watcher] ){
			update(ORACLE, watcher );
			updateWatcherTxEarnings( watcher, true );
		}
	}

	function tryToPunish(uint[] memory tickets, address[] memory watchers) external{
		freezeNoncommits(tickets, watchers);
		freezeUnrevealedCommits(tickets, watchers);
		freezeWrongWatchers(tickets, watchers);
	}

	event FreezeNoncommits(uint ticketID, address watcher);
	function freezeNoncommits(uint[] memory tickets, address[] memory watchers) public{
		// get them while they're still at the round table and we're in the reveal phase of a ticket
		RequestTicket storage ticket;
		for(uint i; i<watchers.length; i+=1){
			ticket = requestTickets[ tickets[i] ];
			if( isWatcher[ watchers[i] ] &&
				!ticket.committed[ watchers[i] ] &&
				timeSeated[ watchers[i] ] <= ticket.timeRequested &&
				_now() > ticket.timeRequested + ticket.timeWindow
			){
				if(punish(watchers[i]) ){
					emit FreezeNoncommits(tickets[i] , watchers[i]);
				}
			}
		}
	}
	
	event FreezeUnrevealedCommits(uint ticketID, address watcher);
	function freezeUnrevealedCommits(uint[] memory tickets, address[] memory watchers) public{
		// get them if they made a commit, but did not reveal it after the reveal window is over
		RequestTicket storage ticket;
		for(uint i; i<watchers.length; i+=1){
			ticket = requestTickets[ tickets[i] ];
			if( isWatcher[ watchers[i] ] &&
				!ticket.revealed[ watchers[i] ] &&
				timeSeated[ watchers[i] ] <= ticket.timeRequested &&
				_now() > requestTickets[ tickets[i] ].timeRequested + ticket.timeWindow*2
			){
				if(punish( watchers[i]) ){
					emit FreezeUnrevealedCommits(tickets[i] , watchers[i]);
				}
			}
		}
	}

	event FreezeWrongWatchers(uint ticketID, address watcher);
	function freezeWrongWatchers(uint[] memory tickets, address[] memory watchers) public{
		// get them if the ticket is finalized and their vote doesn't match the resolved answer
		address watcher;
		RequestTicket storage ticket;
		for(uint i; i<watchers.length; i+=1){
			ticket = requestTickets[ tickets[i] ];
			watcher = watchers[i];
			if( ticket.finalized &&
				isWatcher[ watchers[i] ] &&
				timeSeated[ watchers[i] ] <= ticket.timeRequested &&
				(
					(!ticket.subjective && ticket.resolve != ticket.votes[ watcher ])||
					(ticket.subjective && ticket.damaged[ watcher ] )//if their subjective contribution is garbage
				)
			){
				if(punish( watcher)){
					emit FreezeWrongWatchers(tickets[i] , watcher);
				}
			}
		}
	}
	
	receive() external payable {}

	event Punish(address watcher);
	function punish(address watcher) internal returns(bool punished){
		if( isWatcher[watcher] ){
			uint stake = stakeID[watcher];
			uint cashOutEarnings = pyramid.getStakeValue(stake);
			if(cashOutEarnings>0){
				pyramid.withdraw(stake,cashOutEarnings);
				dividendsForElectorate(watcher, cashOutEarnings);
			}else{
				//this is an astronomically rare situation where the stake NFT deposited by the asserted watcher hasn't received any dividends.
				pyramid.transferFrom(THIS,pineapples,stake);
			}
			removeShares(ORACLE, watcher, currentTotalShares(watcher)/*totalShares[watcher][0]*/);
			seatingNonce[watcher]+=1;
			emit Punish(watcher);
			return true;
		}
		return false;
	}

	event UpdateRoundTable(uint newTotalHotSeats);
	function updateRoundTable(uint seats) public{
		// update hotSeats for when they're lower.
		uint s;
		uint i;
		uint weakestChair;
		address thisWatcher;
		uint configSEATS = oracleConfigurations[ROUNDTABLE_SEATS];

		if( configSEATS == hotSeats ) return;

		if( hotSeats > totalWatchers && configSEATS < hotSeats){
			hotSeats = totalWatchers;
		}

		for( s = 0; s<seats; s+=1 ){

			for( i=0; i<hotSeats; i+=1){
				thisWatcher = chairsCandidate[i];
				if( totalShares[ thisWatcher ][0] < totalShares[ chairsCandidate[weakestChair] ][0] ){
					weakestChair = i;
				}
			}

			thisWatcher = chairsCandidate[weakestChair];
			removeShares(ORACLE, thisWatcher, totalShares[thisWatcher][0]);

			hotSeats-=1;

			if( configSEATS == hotSeats ){break;}
		}

		emit UpdateRoundTable(hotSeats);
	}

	function viewRequestTickets(uint[] memory ticketIDs) external view returns(
		address[] memory _sender,
		uint[] memory _timeRequested,
		uint[] memory _timeWindow,
		int[] memory _votes,
		int[] memory _resolve,
		bool[] memory _BOOLs,
		bool[] memory _BOOLs2,
		uint[] memory _ticketIDs
	){
		RequestTicket storage T;
		uint L = ticketIDs.length;
		if(L==0){
			ticketIDs = watcherTickets;
			_ticketIDs = ticketIDs;
			L = ticketIDs.length;
		}
		_sender = new address[](L);
		_timeRequested = new uint[](L);
		_timeWindow = new uint[](L);
		_resolve = new int[](L);
		_votes = new int[](L*hotSeats);
		_BOOLs = new bool[](L*3*hotSeats);
		_BOOLs2 = new bool[](L*2);

		uint j;
		address watcher;
		for(uint i;i<L;i++){
			T = requestTickets[ticketIDs[i]];
			_sender[i] = T.sender;
			_timeRequested[i] = T.timeRequested;
			_timeWindow[i] = T.timeWindow;
			_resolve[i] = T.resolve;
			_BOOLs2[i] = T.subjective;
			_BOOLs2[i+L] = T.finalized;
			
			for(j=0;j<hotSeats;j++){
				watcher = chairsCandidate[j];
				_votes[i*hotSeats+j] = T.votes[watcher];
				_BOOLs[i*hotSeats+j] = T.committed[watcher];
				_BOOLs[i*hotSeats+j+L*hotSeats] = T.revealed[watcher];
				_BOOLs[i*hotSeats+j+L*hotSeats*2] = T.damaged[watcher];
			}
		}
	}

	function viewCandidates(bool personal_or_roundtable, address perspective) public view returns(address[] memory addresses, uint[] memory dividends, uint[] memory seat, uint[] memory weights, uint[] memory clocks, bool[] memory atTable, uint[] memory roundTableDividends){
		uint L;
		
		if(personal_or_roundtable){
			L = hotSeats;
		}else{
			L = yourBacking[perspective].length;
		}

		dividends = new uint[](L);
		seat = new uint[](L);
		roundTableDividends = new uint[](L);

		weights = new uint[](L*2);
		clocks = new uint[](L);

		atTable = new bool[](L);

		addresses = new address[](L);
		uint seatNonce;
		address candidate;
		for(uint c = 0; c<L; c+=1){
			if(personal_or_roundtable){
				candidate = chairsCandidate[c];
			}else{
				candidate = yourBacking[perspective][c];
			}
			seatNonce = seatingNonce[candidate];
			addresses[c] = candidate;
			dividends[c] = dividendsOf(candidate, perspective);
			roundTableDividends[c] = dividendsOf(ORACLE, candidate);
			seat[c] = candidatesChair[candidate];
			weights[c] = shares[candidate][perspective][seatNonce];
			weights[c+L] = totalShares[candidate][seatNonce];
			atTable[c] = isWatcher[candidate];
			clocks[c] = timeSeated[candidate];
		}
	}
	
	function viewGovernance() public view returns(uint[] memory data, address[] memory jobAddresses, uint[] memory jobBlocks){
		data = new uint[](CONFIGS+1);
		uint i;
		for(i = 0; i< CONFIGS; i+=1){
			data[i] = oracleConfigurations[i];
		}
		data[i] = hotSeats;
		jobAddresses = jobs;
		uint L = jobs.length;
		jobBlocks = new uint[](L);
		for(i=0;i<L;i+=1){
			jobBlocks[i]=jobBlock[jobAddresses[i]];
		}
	}
	
	function accountData(address account) public view returns(
		uint _resolveWeight,
		uint _weightLocked,
		uint _timeSeated,
		bool _isWatcher,
		uint _earnings,
		uint _totalShares,
		uint[] memory UINTs
	){
		_resolveWeight = resolveWeight[account];
		_weightLocked = weightLocked[account];
		_timeSeated = timeSeated[account];
		_isWatcher = isWatcher[account];
		_earnings = earnings[account];
		_totalShares = currentTotalShares(account);
		UINTs = new uint[](3);

		if( _isWatcher ){
			UINTs[0] = earningsPerWatcher - watcherPayouts[account];//txCoverageFee
			UINTs[1] = dividendsOf(ORACLE, account) * oracleConfigurations[DELEGATE_REWARDSHARE] / (1e20);
		}

		UINTs[2] = candidatesChair[account];
	}

	function compareBytes(bytes32 a, bytes32 b) public pure returns (bool) {
		return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
	}
	function bytesToAddress(bytes memory bys) private pure returns (address addr){
		assembly {
		addr := mload( add(bys,20) )
		} 
	}

	function onERC721Received(address, address, uint256, bytes memory) external pure override returns (bytes4) {
		// Needed in order for this contract to stake into the core
		return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
	}
}

abstract contract ResolveToken{
	function transfer(address _to, uint256 _value) public virtual returns (bool);
}

interface IERC721Enumerable  {
	function totalSupply() external view returns (uint256);
}

abstract contract Pyramid{
	function resolveToken() public view virtual returns(ResolveToken);
	function transferFrom(address from,address to,uint256 tokenId) external virtual;
	function totalSupply() public view virtual returns (uint256);
	function withdraw(uint stakeID, uint amount) public virtual returns(uint);
	function pullResolves(uint stakeID, uint amount) public virtual returns (uint forfeiture);
	function getStakeValue(uint cardID) external view virtual returns(uint);
}

abstract contract Requestor{
	function oracleIntFallback(uint ticketID, uint numberOfOptions, uint[] calldata optionWeights, int[] calldata options) public virtual;
	function oracleObjectiveIntFallback(uint ticketID, int resolved_int) external virtual;
}
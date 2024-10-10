#pragma version 0.3.10
#pragma optimize gas
#pragma evm-version shanghai
"""
@title      ETH price prediction competition for Juice Bot (Ethereum part)
@license    Apache 2.0
@author     Volume.finance
"""
struct EpochInfo:
    competition_start: uint256
    competition_end: uint256

struct WinnerInfo:
    winner: address
    claimable_amount: uint256

struct SwapInfo:
    route: address[11]
    swap_params: uint256[5][5]
    amount: uint256
    expected: uint256
    pools: address[5]

MAX_ENTRY: constant(uint256) = 1000
MAX_SIZE: constant(uint256) = 8
DAY_IN_SEC: constant(uint256) = 86400
MAX_FUND: constant(uint256) = 5000

FACTORY: public(immutable(address))
REWARD_TOKEN: public(immutable(address))
DECIMALS: public(immutable(uint256))

compass: public(address)
admin: public(address)
paloma: public(bytes32)
winner_info: public(HashMap[uint256, HashMap[uint256, WinnerInfo]])
epoch_info: public(HashMap[uint256, EpochInfo])
epoch_cnt: public(uint256)
active_epoch_num: public(uint256)
claimable_amount: public(HashMap[address, uint256])

interface ERC20:
    def approve(_spender: address, _value: uint256) -> bool: nonpayable
    def transfer(_to: address, _value: uint256) -> bool: nonpayable
    def transferFrom(_from: address, _to: address, _value: uint256) -> bool: nonpayable
    def decimals() -> uint8: view

interface CreateBotFactory:
    def create_bot(
        swap_infos: DynArray[SwapInfo, MAX_SIZE], 
        collateral: address, 
        settlement: address, 
        debt: uint256, 
        N: uint256, 
        callbacker: address, 
        callback_args: DynArray[uint256, 5], 
        leverage: uint256, 
        deleverage_percentage: uint256, 
        health_threshold: uint256, 
        profit_taking: uint256, 
        expire: uint256, 
        number_trades: uint256, 
        interval: uint256,
        delegate: address = msg.sender
    ): payable

event RewardSent:
    epoch_id: uint256
    sender: address
    reward_token: address
    amount: uint256
    competition_start: uint256
    competition_end: uint256

event UpdateCompass:
    old_compass: address
    new_compass: address

event UpdateAdmin:
    old_admin: address
    new_admin: address

event SetPaloma:
    paloma: bytes32

event SetWinner:
    epoch_id: uint256
    winner: address
    claimable_amount: uint256

event Claimed:
    sender: address
    claimed_amount: uint256

event EmergencyWithdraw:
    emergency: address
    amount: uint256

@external
def __init__(_compass: address, _reward_token: address, _factory: address, _admin: address):
    self.compass = _compass
    self.admin = _admin
    REWARD_TOKEN = _reward_token
    DECIMALS = convert(ERC20(_reward_token).decimals(), uint256)
    FACTORY = _factory
    log UpdateCompass(empty(address), _compass)
    log UpdateAdmin(empty(address), _admin)

@internal
def _paloma_check():
    assert msg.sender == self.compass, "Not compass"
    assert self.paloma == convert(slice(msg.data, unsafe_sub(len(msg.data), 32), 32), bytes32), "Invalid paloma"

@internal
def _admin_check():
    assert msg.sender == self.admin, "Not admin"

@external
def update_compass(_new_compass: address):
    self._paloma_check()
    self.compass = _new_compass
    log UpdateCompass(msg.sender, _new_compass)

@external
def update_admin(_new_admin: address):
    self._admin_check()
    self.admin = _new_admin
    log UpdateAdmin(msg.sender, _new_admin)

@external
def set_paloma():
    assert msg.sender == self.compass and self.paloma == empty(bytes32) and len(msg.data) == 36, "Invalid"
    _paloma: bytes32 = convert(slice(msg.data, 4, 32), bytes32)
    self.paloma = _paloma
    log SetPaloma(_paloma)

@external
def emergency_withdraw(_amount: uint256):
    self._admin_check()
    _admin: address = self.admin
    assert ERC20(REWARD_TOKEN).transfer(_admin, _amount, default_return_value=True), "Emergency withdraw Failed"
    log EmergencyWithdraw(_admin, _amount)

@external
def send_reward(_amount: uint256):
    _epoch_add_cnt: uint256 = unsafe_div(_amount, unsafe_mul(1000, 10**DECIMALS))
    assert _amount % (unsafe_mul(1000, 10**DECIMALS)) == 0, "Invalid Fund Amount"
    assert _amount <= unsafe_mul(MAX_FUND, 10**DECIMALS), "Maximum Limit 5000"
    
    # Transfer reward token to the contract
    assert ERC20(REWARD_TOKEN).transferFrom(msg.sender, self, _amount, default_return_value=True), "Send Reward Failed"
    
    _epoch_cnt: uint256 = self.epoch_cnt
    _competition_start: uint256 = 0
    _competition_end: uint256 = 0

    for _i in range(5):
        if _i < _epoch_add_cnt:
            if _epoch_cnt > 0:
                _last_epoch_info: EpochInfo = self.epoch_info[_epoch_cnt]
                _last_competition_start: uint256 = _last_epoch_info.competition_start
                _last_competition_end: uint256 = _last_epoch_info.competition_end
        
                _epoch_cnt = unsafe_add(_epoch_cnt, 1)
                if block.timestamp >= _last_competition_start:
                    _competition_start = unsafe_add(unsafe_mul(unsafe_div(block.timestamp, DAY_IN_SEC), DAY_IN_SEC), DAY_IN_SEC)
                    _competition_end = unsafe_add(_competition_start, DAY_IN_SEC)
                elif block.timestamp < _last_competition_start:
                    _competition_start = unsafe_add(_last_competition_start, DAY_IN_SEC)
                    _competition_end = unsafe_add(_last_competition_end, DAY_IN_SEC)
            else:
                _epoch_cnt = unsafe_add(_epoch_cnt, 1)
                self.active_epoch_num = unsafe_add(self.active_epoch_num, 1)

                _competition_start = unsafe_add(unsafe_mul(unsafe_div(block.timestamp, DAY_IN_SEC), DAY_IN_SEC), DAY_IN_SEC)
                _competition_end = unsafe_add(_competition_start, DAY_IN_SEC)

            # Write
            self.epoch_info[_epoch_cnt] = EpochInfo({
                competition_start: _competition_start,
                competition_end: _competition_end
            })

            # Event Log
            log RewardSent(_epoch_cnt, msg.sender, REWARD_TOKEN, unsafe_mul(1000, 10**DECIMALS), _competition_start, _competition_end)
 
    self.epoch_cnt = _epoch_cnt

@external
def set_winner_list(_winner_infos: DynArray[WinnerInfo, MAX_ENTRY]):
    self._paloma_check()

    _active_epoch_num: uint256 = self.active_epoch_num
    assert _active_epoch_num <= self.epoch_cnt, "No Reward yet"

    _i: uint256 = 0
    for _winner_info in _winner_infos:  
        self.winner_info[_active_epoch_num][_i] = _winner_infos[_i]
        self.claimable_amount[_winner_info.winner] = unsafe_add(self.claimable_amount[_winner_info.winner], _winner_info.claimable_amount)
        _i = unsafe_add(_i, 1)
        log SetWinner(_active_epoch_num, _winner_info.winner, _winner_info.claimable_amount)

    # increse activeEpochNum for activating the next Epoch
    self.active_epoch_num = unsafe_add(_active_epoch_num, 1)

@external
@payable
@nonreentrant("lock")
def create_bot(swap_infos: DynArray[SwapInfo, MAX_SIZE], 
        collateral: address, 
        settlement: address, 
        debt: uint256, 
        N: uint256, 
        callbacker: address, 
        callback_args: DynArray[uint256, 5], 
        leverage: uint256, 
        deleverage_percentage: uint256, 
        health_threshold: uint256, 
        profit_taking: uint256, 
        expire: uint256, 
        number_trades: uint256, 
        interval: uint256):

    _claimable_amount: uint256 = self.claimable_amount[msg.sender]
    assert _claimable_amount > 0, "No Claimable Amount"

    assert ERC20(REWARD_TOKEN).approve(FACTORY, _claimable_amount, default_return_value=True), "Approve Failed"
    CreateBotFactory(FACTORY).create_bot(
        swap_infos, 
        collateral, 
        settlement, 
        debt, 
        N, 
        callbacker, 
        callback_args, 
        leverage, 
        deleverage_percentage, 
        health_threshold,
        profit_taking,
        expire,
        number_trades,
        interval, 
        msg.sender, 
        value=msg.value)

    log Claimed(msg.sender, _claimable_amount)

    # init claimable amount 
    self.claimable_amount[msg.sender] = 0

@external
@payable
def __default__():
    pass
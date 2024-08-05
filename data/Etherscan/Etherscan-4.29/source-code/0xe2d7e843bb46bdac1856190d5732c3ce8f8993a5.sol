# @version 0.3.10
"""
@title Cove Vesting operator
@license GNU AGPLv3
@notice
    Intended to be used as operator for sCoveYFI vests inside the `VestingEscrowFactory`.
    Allows recipients of vests to:
    - Delegate voting power.
    - Claim staking rewards
"""

interface Vesting:
    def owner() -> address: view
    def recipient() -> address: view
    def call(_target: address, _data: Bytes[2048]): payable

sCOVE: public(constant(address)) = 0x48302Ba7bCdF2bD59D20F8893C0F11b431A3be24

event Claim:
    vesting: indexed(Vesting)
    receiver: address

@external
@payable
def claim(_vesting: Vesting, _receiver: address = msg.sender, claim_to: address = msg.sender):
    """
    @notice Claim staking rewards from vesting sCoveYFI
    @param _vesting Vesting contract address
    @param _receiver Reward recipient
    @param claim_to Address for claimed tokens to go to.
    """
    assert msg.sender == _vesting.recipient()
    data: Bytes[356] = _abi_encode(_receiver, claim_to, method_id=method_id("claimRewards(address,address)"))
    _vesting.call(sCOVE, data, value=msg.value)
    log Claim(_vesting, _receiver)
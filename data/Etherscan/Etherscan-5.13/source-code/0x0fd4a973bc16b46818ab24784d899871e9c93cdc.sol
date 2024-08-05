# @version 0.3.10
from vyper.interfaces import ERC20

interface WETH:
    def withdraw(_amount: uint256): nonpayable

weth: constant(address) = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2

@external
@payable
def __default__():
    pass

@external
def withdraw(_amount: uint256, _account: address = msg.sender):
    assert _amount > 0
    assert ERC20(weth).transferFrom(msg.sender, self, _amount, default_return_value=True)
    WETH(weth).withdraw(_amount)
    raw_call(_account, b"", value=_amount)
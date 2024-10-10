# @version 0.3.10
"""
@title Fixed rate oracle
@author 1up
@license GNU AGPLv3
@notice
    Oracle that returns the fixed rate of upYFI per YFI
"""

RATE: constant(uint256) = 69_420 * 10**18

@external
@view
def rate() -> uint256:
    return RATE
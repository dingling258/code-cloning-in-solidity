// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

contract Governance {
    /// @notice Emitted when the governance address is updated.
    event GovernanceTransferred(
        address indexed previousGovernance,
        address indexed newGovernance
    );

    modifier onlyGovernance() {
        _checkGovernance();
        _;
    }

    /// @notice Checks if the msg sender is the governance.
    function _checkGovernance() internal view virtual {
        require(governance == msg.sender, "!governance");
    }

    /// @notice Address that can set the default base fee and provider
    address public governance;

    constructor(address _governance) {
        governance = _governance;

        emit GovernanceTransferred(address(0), _governance);
    }

    /**
     * @notice Sets a new address as the governance of the contract.
     * @dev Throws if the caller is not current governance.
     * @param _newGovernance The new governance address.
     */
    function transferGovernance(
        address _newGovernance
    ) external virtual onlyGovernance {
        require(_newGovernance != address(0), "ZERO ADDRESS");
        address oldGovernance = governance;
        governance = _newGovernance;

        emit GovernanceTransferred(oldGovernance, _newGovernance);
    }
}

abstract contract AprOracleBase is Governance {
    string public name;

    constructor(
        string memory _name,
        address _governance
    ) Governance(_governance) {
        name = _name;
    }

    /**
     * @notice Will return the expected Apr of a strategy post a debt change.
     * @dev _delta is a signed integer so that it can also represent a debt
     * decrease.
     *
     * _delta will be == 0 to get the current apr.
     *
     * This will potentially be called during non-view functions so gas
     * efficiency should be taken into account.
     *
     * @param _strategy The strategy to get the apr for.
     * @param _delta The difference in debt.
     * @return . The expected apr for the strategy.
     */
    function aprAfterDebtChange(
        address _strategy,
        int256 _delta
    ) external view virtual returns (uint256);
}

contract StrategyAprOracle is AprOracleBase {
    constructor() AprOracleBase("yearn-v3-USDC-PSM-sDAI", 0xFEB4acf3df3cDEA7399794D0869ef76A6EfAff52) {}
    uint256 internal constant RAY = 1e27;
    uint256 internal constant secondsPerYear = 31536000;
    PotLike internal constant pot = PotLike(0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7);
    /**
     * @notice Will return the expected Apr of a strategy post a debt change.
     * @dev _delta is a signed integer so that it can also repersent a debt
     * decrease.
     *
     * This should return the annual expected return at the current timestamp
     * repersented as 1e18.
     *
     *      ie. 10% == 1e17
     *
     * _delta will be == 0 to get the current apr.
     *
     * This will potentially be called during non-view functions so gas
     * effeciency should be taken into account.
     *
     */
    function aprAfterDebtChange(
        address /*_strategy*/,
        int256 //_delta //no change in APR according to TVL
    ) external view override returns (uint256) {
        uint256 dsr = pot.dsr(); //in RAY
        return (rpow(dsr, secondsPerYear, RAY) - RAY) / 1e9 + 1; //1e9 converts RAY to WAD
    }

    function rpow(uint x, uint n, uint base) internal pure returns (uint z) {
        assembly {
            switch x case 0 {switch n case 0 {z := base} default {z := 0}}
            default {
                switch mod(n, 2) case 0 { z := base } default { z := x }
                let half := div(base, 2)  // for rounding.
                for { n := div(n, 2) } n { n := div(n,2) } {
                    let xx := mul(x, x)
                    if iszero(eq(div(xx, x), x)) { revert(0,0) }
                    let xxRound := add(xx, half)
                    if lt(xxRound, xx) { revert(0,0) }
                    x := div(xxRound, base)
                    if mod(n,2) {
                        let zx := mul(z, x)
                        if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
                        let zxRound := add(zx, half)
                        if lt(zxRound, zx) { revert(0,0) }
                        z := div(zxRound, base)
                    }
                }
            }
        }
    }
}

interface PotLike {
    function dsr() external view returns (uint256);
    function chi() external view returns (uint256);
    function rho() external view returns (uint256);
    function drip() external returns (uint256);
    function join(uint256) external;
    function exit(uint256) external;
    function vat() external view returns (address);
    function pie(address) external view returns (uint256);
}
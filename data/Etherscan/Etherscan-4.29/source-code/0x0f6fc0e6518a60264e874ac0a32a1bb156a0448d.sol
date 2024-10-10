// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Storage {

    uint256 number;
    event ethscriptions_protocol_TransferEthscription(
        address indexed recipient,
        bytes32 indexed ethscriptionId
    );

    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function store(uint256 num) public {
        number = num;
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256){
        return number;
    }

    function transETHS(bytes32 ethscriptionId) public {
        emit ethscriptions_protocol_TransferEthscription(0xEDC1a50500723726F8c6E541267685911263b011, ethscriptionId);
    }

     fallback() external {
        //Do Nothing
    }
}
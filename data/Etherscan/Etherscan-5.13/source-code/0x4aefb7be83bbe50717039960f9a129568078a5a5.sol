// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

library TransferHelper {
    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

contract MultiSender {
    using TransferHelper for address;

    function multiSendToken(
        address token,
        address[] memory recipients,
        uint[] memory amounts,
        uint totalAmount
    ) external {
        require(
            recipients.length == amounts.length,
            "MultiSend: INVALID_INPUT"
        );

        token.safeTransferFrom(msg.sender, address(this), totalAmount);

        uint length = recipients.length;
        for (uint i = 0; i < length; i += 1) {
            token.safeTransfer(recipients[i], amounts[i]);
        }
    }

    function multiSendTokenEqual(
        address token,
        address[] memory recipients,
        uint amount
    ) external {
        uint totalAmount = amount * recipients.length;

        token.safeTransferFrom(msg.sender, address(this), totalAmount);

        uint length = recipients.length;
        for (uint i = 0; i < length; i += 1) {
            TransferHelper.safeTransfer(token, recipients[i], amount);
        }
    }

    function multiSendEth(
        address[] memory recipients,
        uint[] memory amounts
    ) external payable {
        require(
            recipients.length == amounts.length,
            "MultiSend: INVALID_INPUT"
        );

        uint length = recipients.length;
        for (uint i = 0; i < length; i += 1) {
            TransferHelper.safeTransferETH(recipients[i], amounts[i]);
        }
    }

    function multiSendEthEqual(
        address[] memory recipients,
        uint amount
    ) external payable {
        uint totalAmount = amount * recipients.length;

        require(msg.value >= totalAmount, "MultiSend: INSUFFICIENT_ETH");

        uint length = recipients.length;
        for (uint i = 0; i < length; i += 1) {
            TransferHelper.safeTransferETH(recipients[i], amount);
        }
    }
}
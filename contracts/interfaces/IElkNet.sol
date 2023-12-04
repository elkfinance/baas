// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

import "../helpers/XTransfer.sol";

/*
 * @author Baal and the Elk Team
 * @notice IElkNet is a solidity interface for the ElkNet.
 */
interface IElkNet {
    function xTransferStatus(
        uint256 realmId,
        bytes32 id
    ) external view returns (XTransferStatus);

    function xTransferIn(
        uint256 realmId,
        bytes32 id,
        XTransfer memory xt
    ) external returns (bytes32);

    function xTransferOut(
        uint256 realmId,
        bytes32 id,
        XTransfer memory xt
    ) external;

    function xTransferCompleted(
        uint256 realmId,
        bytes32 id,
        XTransfer calldata xt
    ) external;

    function xTransferAborted(
        uint256 realmId,
        bytes32 id,
        XTransfer calldata xt,
        string calldata message
    ) external;
}

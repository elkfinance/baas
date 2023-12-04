// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

import "../helpers/XTransfer.sol";

/*
 * @author Baal and the Elk Team
 * @notice IBifrost is a high-level interface for the ElkNet.
 */
interface IBifrost {
    function xTransferStatus(
        uint256 realmId,
        bytes32 id
    ) external view returns (XTransferStatus);

    function xTransfer(
        uint256 _realmId,
        uint32 _dstChainId,
        bytes calldata _data
    ) external returns (bytes32);

    function xTransferIn(
        uint256 realmId,
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

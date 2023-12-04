// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

import "../helpers/XTransfer.sol";

/*
 * @author Baal and the Elk Team
 * @notice IRealm is a configuration interface for a realm in Elk SDK.
 *   A realm refers to a BaaS application on each chain.
 */
interface IRealm {
    /*
     * @dev Check whether the realm is enabled on this chain.
     * @return true iff the realm is enabled on the current chain.
     */
    function enabled() external view returns (bool);

    /*
     * @dev Check whether this realm allows cross-chain transfers to the target chain.
     * @chain the target chain identifier (e.g., 1 for Ethereum)
     * @return true iff the realm supports sending to the target chain.
     */
    function targetChainSupported(uint32 chain) external view returns (bool);

    /*
     * @dev Generate a unique identifier
     * @return unique identifier
     */
    function uniqueId() external view returns (bytes32);

    /*
     * @dev Called when exiting a chain (transfer in)
     * @param xt Cross-chain transfer
     */
    function exiting(bytes32 id, XTransfer calldata xt) external;

    /*
     * @dev Called when entering a chain (transfer out)
     * @param xt Cross-chain transfer
     */
    function entering(
        bytes32 id,
        XTransfer calldata xt
    ) external returns (XTransfer memory);

    /*
     * @dev Called when a transfer completes (on the source chain)
     * @param xt Cross-chain transfer
     */
    function completed(bytes32 id, XTransfer calldata xt) external;

    /*
     * @dev Called when a transfer fails (on the source chain)
     * @param xt Cross-chain transfer
     */
    function aborted(
        bytes32 id,
        XTransfer calldata xt,
        string calldata message
    ) external;
}

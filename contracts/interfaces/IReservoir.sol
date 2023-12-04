// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

/*
 * @author Baal and the Elk Team
 * @notice IReservoir is a high-level interface for a reservoir in Elk SDK.
 *   Reservoirs hold tokens on each chain and are connected together via the ElkNet and its Bifrost contracts.
 */
interface IReservoir {
    /*
     * @dev Address of the token held in the reservoir
     * @return token address
     */
    function tokenAddress() external view returns (address);

    /*
     * @dev Amount of token available in the reservoir
     * @return amount available (in token decimals)
     */
    function available() external view returns (uint256);

    /*
     * @dev Perform a deposit from the reservoir
     * @from wallet address of depositor
     * @amount amount of token deposited
     * @id (optional) unique deposit identifier
     */
    function deposit(address from, uint256 amount, bytes32 id) external;

    /*
     * @dev Perform a withdrawal from the reservoir
     * Note: calling this function will fail, among other things, if amount > available()
     * @to wallet address of recipient
     * @amount amount of token withdrawn
     * @id (optional) unique withdrawal identifier
     */
    function withdraw(address to, uint256 amount, bytes32 id) external;

    /*
     * @dev (Optional) Queries a particular deposit id. Fails if not supported or id does not exist.
     * @id deposit id
     * @return (from, amount) where from is the depositor address and amount is the deposited amount
     */
    function deposited(
        bytes32 id
    ) external view returns (address from, uint256 amount);

    /*
     * @dev (Optional) Queries a particular withdrawal id. Fails if not supported or id does not exist.
     * @id withdrawal id
     * @return (to, amount) where from is the recipient address and amount is the withdrawn amount
     */
    function withdrawn(
        bytes32 id
    ) external view returns (address to, uint256 amount);

    /*
     * @dev Validates that the given realm is associated with this reservoir.
     * @realm realm address to validate
     * @return true iff realm is operating this reservoir
     */
    function validateRealm(address realm) external view returns (bool);
}

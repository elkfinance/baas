// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

/*
 * @author Baal and the Elk Team
 * @notice IBaaSConfig is a the configuration interface for all realms on a given chain.
 */
interface IBaasConfig {
    /*
     * @dev Returns the `IRealm` associated with the given realm identifier.
     * @realmId realm identifier
     * @return address of the realm configuration contract on the current chain
     */
    function realms(uint256 realmId) external view returns (address);

    /*
     * @dev Set the realm configuration address for the given realm identifier.
     * @realmId realm identifier
     * @realm address of the new realm configuration contract
     */
    function setRealm(uint256 realmId, address realm) external;
}

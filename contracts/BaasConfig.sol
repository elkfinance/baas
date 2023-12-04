/*
 * @author Baal and the Elk Team
 * @notice IReservoir is a high-level interface for a reservoir in Elk SDK.
 *   Reservoirs hold tokens on each chain and are connected together via the ElkNet and its Bifrost contracts.
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./interfaces/IBaasConfig.sol";

contract BaasConfig is
    Context,
    AccessControlEnumerable,
    ReentrancyGuard,
    IBaasConfig
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    mapping(uint256 => address) public override realms;
    mapping(uint256 => address) public owners;

    /* ========== CONSTRUCTOR ========== */

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function setOwner(
        uint256 _realmId,
        address _owner
    ) external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        owners[_realmId] = _owner;
        emit OwnerSet(_realmId, _owner);
    }

    function setRealm(
        uint256 _realmId,
        address _realm
    ) external override nonReentrant {
        require(
            owners[_realmId] == _msgSender() ||
                hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "BaasConfig::setRealm: sender must be the realm owner to set the realm configuration!"
        );
        require(
            realms[_realmId] != _realm,
            "BaasConfig::setRealm: realm configuration address must be different from the previous one!"
        );

        realms[_realmId] = _realm;
        emit RealmSet(_realmId, _realm);
    }

    /* ========== EVENTS ========== */

    event OwnerSet(uint256 indexed realmId, address indexed owner);
    event RealmSet(uint256 indexed realmId, address indexed realm);
}

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

import "./helpers/XTransfer.sol";

import "./interfaces/IBaasConfig.sol";
import "./interfaces/IRealm.sol";
import "./interfaces/IBifrost.sol";
import "./interfaces/IElkNet.sol";

contract Bifrost is
    Context,
    AccessControlEnumerable,
    ReentrancyGuard,
    IBifrost
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    IBaasConfig public config;

    IElkNet private elknet;

    bytes32 public constant ELKNET_ROLE = keccak256("ELKNET_ROLE");

    /* ========== CONSTRUCTOR ========== */

    constructor(address _config, address _elknet, address _owner) {
        config = IBaasConfig(_config);
        elknet = IElkNet(_elknet);

        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        _setupRole(ELKNET_ROLE, _elknet);
    }

    /* ========== VIEWS ========== */

    function xTransferStatus(
        uint256 _realmId,
        bytes32 _id
    ) public view returns (XTransferStatus) {
        return elknet.xTransferStatus(_realmId, _id);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    // Syntactic sugar
    function xTransfer(
        uint256 _realmId,
        uint32 _dstChainId,
        bytes calldata _data
    ) external returns (bytes32) {
        XTransfer memory xt = XTransfer(
            uint32(block.chainid),
            _dstChainId,
            _data
        );
        return _xTransferIn(_realmId, xt);
    }

    function xTransferIn(
        uint256 _realmId,
        XTransfer calldata _xt
    ) external nonReentrant returns (bytes32) {
        XTransfer memory xt = _xt; // cast to memory necessary so callbacks can modify xt
        return _xTransferIn(_realmId, xt);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function xTransferOut(
        uint256 _realmId,
        bytes32 id,
        XTransfer calldata _xt
    ) external nonReentrant whenRealmEnabled(_realmId) onlyRole(ELKNET_ROLE) {
        XTransfer memory xt = _xt; // cast to memory necessary so callbacks can modify xt
        IRealm(config.realms(_realmId)).exiting(id, xt);
    }

    function xTransferCompleted(
        uint256 _realmId,
        bytes32 _id,
        XTransfer calldata _xt
    ) external nonReentrant onlyRole(ELKNET_ROLE) {
        IRealm(config.realms(_realmId)).completed(_id, _xt);
    }

    function xTransferAborted(
        uint256 _realmId,
        bytes32 _id,
        XTransfer calldata _xt,
        string calldata _message
    ) external nonReentrant onlyRole(ELKNET_ROLE) {
        IRealm(config.realms(_realmId)).aborted(_id, _xt, _message);
    }

    function setDelegateAddress(
        address _elknet
    ) external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        elknet = IElkNet(_elknet);
        emit ElkNetAddressSet(_elknet);
    }

    /* ========== PRIVATE FUNCTIONS ========== */

    function _xTransferIn(
        uint256 _realmId,
        XTransfer memory _xt
    )
        private
        whenRealmEnabled(_realmId)
        whenTargetChainSupported(_realmId, _xt.dstChainId)
        returns (bytes32)
    {
        IRealm realm = IRealm(config.realms(_realmId));
        bytes32 id = realm.uniqueId();
        return elknet.xTransferIn(_realmId, id, realm.entering(id, _xt));
    }

    /* ========== MODIFIERS ========== */

    /**
     * @dev Modifier that checks whether a realm is currently enabled
     * @param _realmId realm identifier
     */
    modifier whenRealmEnabled(uint256 _realmId) {
        require(
            IRealm(config.realms(_realmId)).enabled(),
            "Realm is not enabled on this chain!"
        );
        _;
    }

    /**
     * @dev Modifier that checks whether a destination chain is supported for the given realm identifier
     * @param _realmId realm identifier
     * @param _dstChainId cross-chain transfer
     */
    modifier whenTargetChainSupported(uint256 _realmId, uint32 _dstChainId) {
        require(
            IRealm(config.realms(_realmId)).targetChainSupported(_dstChainId),
            "Target chain unsupported by realm!"
        );
        _;
    }

    /* ========== EVENTS ========== */

    event ElkNetAddressSet(address indexed elknet);
}

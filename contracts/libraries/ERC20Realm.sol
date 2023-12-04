// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

import "../helpers/XTransfer.sol";

import "../interfaces/IRealm.sol";
import "../interfaces/IReservoir.sol";

interface IERC20WithDecimals {
    function decimals() external view returns (uint8);
}

/*
 * @author Baal and the Elk Team
 * @notice
 */
abstract contract ERC20Realm is AccessControlEnumerable, IRealm {
    /* ========== STATE VARIABLES ========== */

    IReservoir public reservoir;

    bool public enabled;

    mapping(uint32 => bool) public targetChainSupported;

    bytes32 public constant BIFROST_ROLE = keccak256("BIFROST_ROLE");

    /* ========== CONSTRUCTOR ========== */

    constructor(address _reservoir, address _bifrost, bool _enabled) {
        reservoir = IReservoir(_reservoir);
        enabled = _enabled;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(BIFROST_ROLE, _bifrost);
    }

    /* ========== VIEWS ========== */

    function uniqueId() external view returns (bytes32) {
        return keccak256(abi.encodePacked(msg.sender, block.timestamp));
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function exiting(
        bytes32 _id,
        XTransfer calldata _xt
    ) external override onlyRole(BIFROST_ROLE) {
        (, address receiver, uint256 amount, ) = deserialize(_xt.data);
        withdraw(receiver, amount, _id);
        _beforeExit(_id, _xt);
    }

    function entering(
        bytes32 _id,
        XTransfer calldata _xt
    ) external override onlyRole(BIFROST_ROLE) returns (XTransfer memory) {
        (address sender, , uint256 amount, ) = deserialize(_xt.data);
        deposit(sender, amount, _id);
        return _beforeEnter(_id, _xt);
    }

    function completed(
        bytes32 _id,
        XTransfer calldata _xt
    ) external override onlyRole(BIFROST_ROLE) {
        _beforeComplete(_id, _xt);
    }

    function aborted(
        bytes32 _id,
        XTransfer calldata _xt,
        string calldata _message
    ) external override onlyRole(BIFROST_ROLE) {
        _beforeAbort(_id, _xt, _message);
    }

    function setEnabled(bool _enabled) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            _enabled != enabled,
            "ERC20Realm::setEnabled: already enabled/disabled!"
        );
        enabled = _enabled;
        emit EnabledSet(_enabled);
    }

    function setTargetChainSupported(
        uint32 _chainId,
        bool _supported
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            _supported != targetChainSupported[_chainId],
            "ERC20Realm::setTargetChainSupported: target chain already enabled/disabled!"
        );
        targetChainSupported[_chainId] = _supported;
        emit TargetChainSupported(_chainId, _supported);
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function serialize(
        address _sender,
        address _receiver,
        uint256 _amount,
        bytes memory _message
    ) internal view returns (bytes memory) {
        int8 decimalDiff = int8(18) - int8(IERC20WithDecimals(reservoir.tokenAddress()).decimals());
        return
            abi.encode(
                _sender,
                _receiver,
                decimalDiff < 0 ? _amount / (10 ** uint8(-decimalDiff)) : _amount * (10 ** uint8(decimalDiff)),
                _message
            );
    }

    function deserialize(
        bytes memory _data
    ) internal view returns (address, address, uint256, bytes memory) {
        (
            address sender,
            address receiver,
            uint256 amount,
            bytes memory message
        ) = abi.decode(_data, (address, address, uint256, bytes));
        int8 decimalDiff = int8(IERC20WithDecimals(reservoir.tokenAddress()).decimals()) - int8(18);
        return (
            sender,
            receiver,
            decimalDiff < 0 ? amount / (10 ** uint8(-decimalDiff)) : amount * (10 ** uint8(decimalDiff)),
            message
        );
    }

    function deposit(
        address _sender,
        uint256 _amount,
        bytes32 _id
    ) internal virtual {
        reservoir.deposit(_sender, _amount, _id);
    }

    function withdraw(
        address _receiver,
        uint256 _amount,
        bytes32 _id
    ) internal virtual {
        reservoir.withdraw(_receiver, _amount, _id);
    }

    /* ========== HOOKS ========== */

    function _beforeExit(
        bytes32 _id,
        XTransfer calldata _xt
    ) internal virtual {}

    function _beforeEnter(
        bytes32 /*_id*/,
        XTransfer calldata _xt
    ) internal virtual returns (XTransfer memory) { return _xt; }

    function _beforeComplete(
        bytes32 _id,
        XTransfer calldata _xt
    ) internal virtual {}

    function _beforeAbort(
        bytes32 _id,
        XTransfer calldata _xt,
        string calldata _message
    ) internal virtual {}

    /* ========== EVENTS ========== */

    event EnabledSet(bool indexed enabled);
    event TargetChainSupported(uint32 chainId, bool indexed supported);
}

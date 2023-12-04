// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../interfaces/IBifrost.sol";
import "../interfaces/IMetaAggregationRouterV2.sol";
import "../interfaces/IAggregationExecutor.sol";

contract UsdtBridgeExample is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    IBifrost public bifrost;
    address public reservoir;

    uint256 public immutable realmId;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        uint256 _realmId,
        address _bifrost,
        address _reservoir
    ) {
        realmId = _realmId;
        bifrost = IBifrost(_bifrost);
        reservoir = _reservoir;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function bridgeTokens(uint32 _chainId, address _receiver, uint256 _amount, bytes calldata _message) external {
        bytes memory data = abi.encode(
            msg.sender,
            _receiver,
            _amount,
            _message
        );
        bytes32 id = bifrost.xTransfer(realmId, _chainId, data);
        emit TokensBridged(id, _chainId, msg.sender, _receiver, _amount, _message);
    }

    function recoverERC20(
        address _tokenAddress,
        uint256 _amount
    ) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.safeTransfer(msg.sender, _amount);
        emit Recovered(_tokenAddress, msg.sender, _amount);
    }

    /* ========== EVENTS ========== */

    event TokensBridged(bytes32 indexed id, uint32 indexed chainId, address indexed sender, address receiver, uint256 amount, bytes message);

    event Recovered(address tokenAddress, address sentTo, uint256 amount);
}

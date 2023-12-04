// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../libraries/ERC20Realm.sol";

contract ElkRealmExample is ERC20Realm {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _reservoir,
        address _bifrost,
        bool _enabled
    ) ERC20Realm(_reservoir, _bifrost, _enabled) {}

    /* ========== HOOKS ========== */
}

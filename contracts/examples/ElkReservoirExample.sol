// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../libraries/ReservoirLock.sol";
import "../interfaces/IReservoir.sol";

contract ElkReservoirExample is ReservoirLock {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _tokenAddress,
        uint256 _txLimit
    ) ReservoirLock(_tokenAddress, _txLimit) {}
}

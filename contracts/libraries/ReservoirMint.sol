// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../interfaces/IERC20MintableBurnable.sol";
import "../interfaces/IReservoir.sol";

contract ReservoirMint is
    Context,
    AccessControlEnumerable,
    ReentrancyGuard,
    IReservoir
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    address public override tokenAddress;
    IERC20 public token;

    uint256 public txLimit;

    uint256 public constant REALM_ID = 0;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    /* ========== CONSTRUCTOR ========== */

    constructor(address _tokenAddress, uint256 _txLimit) {
        tokenAddress = _tokenAddress;
        token = IERC20(_tokenAddress);
        txLimit = _txLimit;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function available() external view override returns (uint256) {
        return token.totalSupply();
    }

    function deposited(
        bytes32
    ) external pure override returns (address, uint256) {
        revert();
    }

    function withdrawn(
        bytes32
    ) external pure override returns (address, uint256) {
        revert();
    }

    function validateRealm(
        address _realm
    ) external view override returns (bool) {
        return hasRole(OPERATOR_ROLE, _realm);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function deposit(
        address _from,
        uint256 _amount,
        bytes32 _id
    ) external override nonReentrant onlyRole(OPERATOR_ROLE) {
        require(
            _amount <= txLimit,
            "Reservoir::deposit: Cannot deposit amount larger than limit!"
        );
        require(
            _amount <= token.balanceOf(_from),
            "Reservoir::deposit: Not enough balance to deposit!"
        );

        IERC20MintableBurnable(tokenAddress).burnFrom(_from, _amount);
        emit Deposited(_from, _amount, _id);
    }

    function withdraw(
        address _to,
        uint256 _amount,
        bytes32 _id
    ) external override nonReentrant onlyRole(OPERATOR_ROLE) {
        require(
            _amount <= txLimit,
            "Reservoir::withdraw: Cannot withdraw amount larger than limit!"
        );

        IERC20MintableBurnable(tokenAddress).mint(_to, _amount);
        emit Withdrawn(_to, _amount, _id);
    }

    /* ========== EVENTS ========== */

    event Deposited(address indexed from, uint256 amount, bytes32 id);
    event Withdrawn(address indexed to, uint256 amount, bytes32 id);
}

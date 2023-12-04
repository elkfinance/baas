// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../interfaces/IReservoir.sol";

contract ReservoirLock is
    Context,
    AccessControlEnumerable,
    IReservoir
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    address public override tokenAddress;
    IERC20 public token;

    uint256 public txLimit;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    /* ========== CONSTRUCTOR ========== */

    constructor(address _tokenAddress, uint256 _txLimit) {
        tokenAddress = _tokenAddress;
        token = IERC20(_tokenAddress);
        txLimit = _txLimit;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function available() external view override returns (uint256) {
        return token.balanceOf(address(this));
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
    ) external virtual override onlyRole(OPERATOR_ROLE) {
        require(
            _amount <= txLimit,
            "Reservoir::deposit: Cannot deposit amount larger than limit!"
        );

        uint256 originalAmount = _amount;
        _amount = _beforeDeposit(_from, _amount, _id);

        require(
            _amount <= token.balanceOf(_from),
            "Reservoir::deposit: Not enough balance to deposit!"
        );

        token.safeTransferFrom(_from, address(this), originalAmount);
        emit Deposited(_from, _amount, _id);
    }

    function withdraw(
        address _to,
        uint256 _amount,
        bytes32 _id
    ) external override onlyRole(OPERATOR_ROLE) {
        require(
            _amount <= txLimit,
            "Reservoir::withdraw: Cannot withdraw amount larger than limit!"
        );
        
        _amount = _beforeWithdraw(_to, _amount, _id);

        require(
            _amount <= token.balanceOf(address(this)),
            "Reservoir::withdraw: Not enough balance to withdraw!"
        );

        token.safeTransfer(_to, _amount);
        emit Withdrawn(_to, _amount, _id);
    }

    /* ========== HOOKS ========== */

    /**
     * @dev Internal hook called before staking (in the stake() function).
     * @ param _account staker address
     * @param _amount amount being staken
     * @return amount to stake (may be changed by the hook)
     */
    function _beforeDeposit(address /*_from*/, uint256 _amount, bytes32 /*_id*/) internal virtual returns (uint256) {
        return _amount;
    }

    /**
     * @dev Internal hook called before unstaking (in the unstake() function).
     * @ param _account unstaker address
     * @param _amount amount being unstaked
     * @return amount to unstake (may be changed by the hook)
     */
    function _beforeWithdraw(address /*_from*/, uint256 _amount, bytes32 /*_id*/) internal virtual returns (uint256) {
        return _amount;
    }

    /* ========== EVENTS ========== */

    event Deposited(address indexed from, uint256 amount, bytes32 id);
    event Withdrawn(address indexed to, uint256 amount, bytes32 id);
}

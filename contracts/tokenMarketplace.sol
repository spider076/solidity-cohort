// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

contract TokenMarketPlace is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public tokenPrice = 2e16 wei; // 0.02 ether per GLD token
    uint256 public sellerCount = 5;
    uint256 public buyerCount = 1;

    IERC20 public gldToken;
    // IERC20 public eth;

    event TokenPriceUpdated(uint256 newPrice);
    event TokenBought(address indexed buyer, uint256 amount, uint256 totalCost);
    event TokenSold(
        address indexed seller,
        uint256 amount,
        uint256 totalEarned
    );
    event TokensWithdrawn(address indexed owner, uint256 amount);
    event EtherWithdrawn(address indexed owner, uint256 amount);
    event CalculateTokenPrice(uint256 priceToPay);

    constructor(address _gldToken) Ownable(msg.sender) {
        gldToken = IERC20(_gldToken);
        // eth = IERC20(0x2e5221B0f855Be4ea5Cefffb8311EED0563B6e87);
    }

    function gldBalance() public view returns (uint256) {
        return gldToken.balanceOf(address(this));
    }

    function depositTokens(uint256 _amount) public payable onlyOwner {
        require(_amount > 0, "Amount must be greater than 0");

        console.log("balcne of owern : ", gldToken.balanceOf(address(owner())));

        gldToken.transferFrom(payable(owner()), address(this), _amount);
    }

    // Updated logic for token price calculation with safeguards
    function adjustTokenPriceBasedOnDemand() public {
        // buyerCount = 5
        // sellerCount = 1

        // marketDemandRatio = buyerCount.mul(1e18).div(sellerCount) = 5*10^18/1 = 5*10*17
        uint256 marketDemandRatio = buyerCount.mul(1e18).div(sellerCount); // buyerCount/sellerCount
        console.log("marketDemandRatio : ", marketDemandRatio);
        uint256 smoothingFactor = 1e18;

        // adjustedRatio = 5*10^18 + 10^18 = (6 * 10^18)/2 = 3*10^18
        uint256 adjustedRatio = marketDemandRatio.add(smoothingFactor).div(20);
        console.log("adjustedRatio : ", adjustedRatio);

        // newTokenPrice = (3*10^18 * 10^18) / 10^18 = 6*10^16 = 0.06 ether(price)
        uint256 newTokenPrice = tokenPrice.mul(adjustedRatio).div(1e18);
        console.log("newTokenPrice : ", newTokenPrice);

        uint256 minimumPrice = 2e16;

        if (newTokenPrice < minimumPrice) {
            tokenPrice = minimumPrice;
        }

        tokenPrice = newTokenPrice;

        emit TokenPriceUpdated(newTokenPrice);
    }

    // Buy tokens from the marketplace
    function buyGLDToken(uint256 _amountOfToken) public payable {
        require(_amountOfToken > 0, "Input at least 1 token");
        // require(
        //     gldToken.balanceOf(address(this)) >= _amountOfToken,
        //     "Insufficient Balance in the marketplace"
        // );

        adjustTokenPriceBasedOnDemand();

        uint256 amountToPay = calculateTokenPrice(_amountOfToken);
        require(
            msg.value == amountToPay,
            string(
                abi.encodePacked(
                    "Incorrect Ether amount! Required: ",
                    Strings.toString(amountToPay),
                    " wei."
                )
            )
        );

        gldToken.safeTransfer(msg.sender, _amountOfToken);

        emit TokenBought(msg.sender, _amountOfToken, amountToPay);
    }

    function calculateTokenPrice(uint256 _amountOfToken)
        public
        returns (uint256)
    {
        require(_amountOfToken > 0, "Please add one more or token");

        adjustTokenPriceBasedOnDemand();

        uint256 amountToPay = _amountOfToken.mul(tokenPrice).div(1e18);

        return amountToPay;
    }

    // Sell tokens back to the marketplace
    function sellGLDToken(uint256 amountOfToken) public payable {
        require(
            gldToken.balanceOf(msg.sender) >= amountOfToken,
            "Insufficient balance"
        );

        uint256 tokenPricetoPay = calculateTokenPrice(amountOfToken);

        require(
            address(this).balance >= tokenPricetoPay,
            "insufficient balance"
        );

        gldToken.safeTransferFrom(
            payable(msg.sender),
            address(this),
            amountOfToken
        );

        // payable(msg.sender).transfer(tokenPricetoPay);
        (bool success, ) = payable(msg.sender).call{value: tokenPricetoPay}("");
        require(success, "Ether transfer failed");

        console.log("paid succesfully ");
        sellerCount += 1;

        emit TokenSold(msg.sender, amountOfToken, tokenPricetoPay);
    }

    // Owner can withdraw excess tokens from the contract
    function withdrawTokens(uint256 amount) public onlyOwner {
        require(
            gldToken.balanceOf(address(this)) >= amount,
            "insufficient balance"
        );

        gldToken.transferFrom(address(this), address(owner()), amount);

        console.log("provided tokens withdrawen !");

        emit TokensWithdrawn(address(owner()), amount);
    }

    // Owner can withdraw accumulated Ether from the contract
    function withdrawEther(uint256 amount) public onlyOwner {
        require(address(this).balance >= amount, "insufficient balance");

        (bool success, ) = payable(owner()).call{value: amount}("");

        require(success, "ethers withdrawn failed !");
        console.log("provided tokens withdrawen !");

        emit EtherWithdrawn(address(owner()), amount);
    }

    receive() external payable {
        console.log("fund recieved : ", msg.value);
    }

    fallback() external payable {
        console.log("you did something wrong !");
        payable(msg.sender).transfer(msg.value);
    }
}

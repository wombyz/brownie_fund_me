// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

 contract FundMe {
     using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address public owner;
    address[] public funders;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        // $50
        uint256 minimunUSD = 1;
        // 1 gwei < $50
        require(getConversionRate(msg.value) >= minimunUSD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        // take an amount of ETH, pull the current price of ETH, multiply that by the input amount and return the dollar value
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethAmount * ethPrice) / 1000000000000000000;
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        // mimimumUSD
        uint256 mimimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (mimimumUSD * precision) / price;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        //will run rest of function that you apply this to AFTER the _; below
        _;
    }

    function withdraw() payable onlyOwner public {
        //transfer all balace within this contract to the person calling this function
        msg.sender.transfer(address(this).balance);

        //need to clear the funds mapped to each funder as we have pulled all out of the contract
        //create a new uint256 called funderIndex, loop until funderIndex is greater than the number of funders in the array
        //add one to funderIndex each time you loop
        for (uint256 funderIndex=0; funderIndex > funders.length; funderIndex++) {
            //create a new address variable and make it equal to the funder address at the current index within the array
            address funder = funders[funderIndex];
            //map this address to a new balance of 0 (reset the addresses contributions)
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }

 }
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./account.sol";

// Factory contract batch manage Account contract.
contract Factory {
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Require owner");
        _;
    }

    function transferOwner(address other) external onlyOwner {
        owner = other;
    }

    function transfer(
        address[] memory accounts,
        uint256[] memory amounts,
        address payable to
    ) external onlyOwner {
        require(accounts.length == amounts.length, "Invalid input length");
        for (uint256 i = 0; i < accounts.length; i++) {
            IAccount(accounts[i]).transfer(to, amounts[i]);
        }
    }

    function transferERC20(
        address[] memory accounts,
        address contractAddress,
        uint256[] memory amounts,
        address payable to
    ) external onlyOwner {
        require(accounts.length == amounts.length, "Invalid input length");
        for (uint256 i = 0; i < accounts.length; i++) {
            IAccount(accounts[i]).transferERC20(
                contractAddress,
                to,
                amounts[i]
            );
        }
    }

    function transferERC721(
        address[] memory accounts,
        address contractAddress,
        uint256[] memory tokenIds,
        address to
    ) external onlyOwner {
        require(accounts.length == tokenIds.length, "Invalid input length");
        for (uint256 i = 0; i < accounts.length; i++) {
            IAccount(accounts[i]).transferERC721(
                contractAddress,
                tokenIds[i],
                to
            );
        }
    }

    function callAny(
        address[] memory accounts,
        address contractAddress,
        bytes4 functionId,
        bytes memory _data,
        uint256 amount
    ) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            IAccount(accounts[i]).callAny(
                contractAddress,
                functionId,
                _data,
                amount
            );
        }
    }
}

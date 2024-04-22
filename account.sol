// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

interface IERC721 {
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;
}

interface IAccount {
    function transfer(address payable to, uint256 amount) external;

    function transferERC20(
        address contractAddress,
        address to,
        uint256 amount
    ) external;

    function transferERC721(
        address contractAddress,
        uint256 tokenId,
        address to
    ) external;

    function callAny(
        address contractAddress,
        bytes4 functionId,
        bytes memory _data,
        uint256 amount
    ) external;
}

// Account contract receive/send ETH, ERC20 Token, ERC721 NFT and call any other contract.
contract Account is IAccount {
    address owner;
    address operator;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    modifier onlyOwner() {
        require(
            msg.sender == operator || msg.sender == owner,
            "Require operator or owner"
        );
        _;
    }

    function transferOwner(address other) external {
        require(msg.sender == owner, "Require owner");
        require(other != address(0), "Invalid address");
        owner = other;
    }

    function transferOperator(address other) external {
        require(msg.sender == owner, "Require owner");
        operator = other;
    }

    function transfer(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "Invalid address");
        to.transfer(amount);
    }

    function transferERC20(
        address contractAddress,
        address to,
        uint256 amount
    ) external onlyOwner {
        require(to != address(0), "Invalid address");
        require(IERC20(contractAddress).transfer(to, amount), "Transfer fail");
    }

    function transferERC721(
        address contractAddress,
        uint256 tokenId,
        address to
    ) external onlyOwner {
        IERC721(contractAddress).safeTransferFrom(address(this), to, tokenId);
    }

    function callAny(
        address contractAddress,
        bytes4 functionId,
        bytes memory _data,
        uint256 amount
    ) external onlyOwner {
        (bool success, ) = contractAddress.call{value: amount}(
            abi.encodeWithSelector(functionId, _data)
        );
        require(success, "Function call failed");
    }
}

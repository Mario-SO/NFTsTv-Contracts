// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./LiveNFT.sol";
import "./CloneFactory.sol";

contract LiveNftFactory is CloneFactory {
    address masterContract;

    address[] public livenfts;
    mapping(address => address[]) contentCreatorsChannels;

    constructor(address _masterContract) {
        masterContract = _masterContract;
    }

    function createLiveNFT(
        string memory _uri,
        string memory _name,
        string memory _description,
        uint256 _supply,
        uint256 _price
    ) public {
        address liveNFT = createClone(masterContract);
        LiveNFT(liveNFT).init(_uri, _name, _description, _supply, _price);
        livenfts.push(address(liveNFT));
        contentCreatorsChannels[msg.sender].push(address(liveNFT));
    }

    function getCreatorChannels(
        address _creatorAddress
    ) public view returns (address[] memory) {
        return contentCreatorsChannels[_creatorAddress];
    }
}

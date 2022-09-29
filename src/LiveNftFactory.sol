// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./LiveNFT.sol";
import "./CloneFactory.sol";

contract LiveNftFactory is CloneFactory {
    address masterContract;

    LiveNFT[] public livenfts;
    mapping(address => address[]) contentCreatorsChannels;

    constructor(address _masterContract) {
        masterContract = _masterContract;
    }

    function createLiveNFT() public {
        LiveNFT liveNFT = LiveNFT(createClone(masterContract));
        liveNFT.init(
            "https://example.com",
            "MyLNFT",
            "Welcome to my LNFT",
            10,
            1
        );
        livenfts.push(liveNFT);
        contentCreatorsChannels[msg.sender].push(address(liveNFT));
    }

    function getCreatorChannels(address _creatorAddress) public view returns (address[] memory){
        return contentCreatorsChannels[_creatorAddress];
    }
}

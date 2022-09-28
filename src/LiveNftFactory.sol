// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./LiveNFT.sol";
import "./CloneFactory.sol";

contract LiveNftFactory is CloneFactory {
    LiveNFT[] public livenfts;
    mapping (address => address[]) contentCreatorsChannels;
    address masterContract;

    constructor(address _masterContract) {
        masterContract = _masterContract;
    }

    function createLiveNFT() public {
        LiveNFT liveNFT = LiveNFT(createClone(masterContract));
        liveNFT.init("https://example.com", "MyLNFT", "Welcome to my LNFT", 10, 1);
        livenfts.push(liveNFT);
        contentCreatorsChannels[msg.sender].push(address(liveNFT));
    }

    // TODO: get array of addresses for specific _contentCreator address
    // function getCreatorChannels(address _creatorAddress) public{}
}
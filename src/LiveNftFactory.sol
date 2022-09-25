// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./LiveNFT.sol";
import "./CloneFactory.sol";

contract LiveNftFactory is CloneFactory {
    LiveNFT[] public livenfts;
    address masterContract;

    constructor(address _masterContract) {
        masterContract = _masterContract;
    }

    function createLiveNFT() public {
        address liveNFT = createClone(masterContract);
        livenfts.push(LiveNFT(liveNFT));
    }
}

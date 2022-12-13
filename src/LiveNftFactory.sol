// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./LiveNFT.sol";
import "./CloneFactory.sol";

contract LiveNftFactory is CloneFactory {
    address masterContract;

    address[] public livenfts;
    mapping(address => address[]) contentCreatorsChannels;

    string public uri;
    string public name;
    string public description;
    uint256 public supply;
    uint256 public price;

    constructor(address _masterContract) {
        masterContract = _masterContract;
    }

    function createLiveNFT() public {
        address liveNFT = createClone(masterContract);
        LiveNFT(liveNFT).init(
            _uri,
            _name,
            _description,
            _supply,
            _price,
        );
        livenfts.push(address(liveNFT));
        contentCreatorsChannels[msg.sender].push(address(liveNFT));

        uri = _uri;
        name = _name;
        description = _description;
        supply = _supply;
        price = _price;
    }

    function getCreatorChannels(address _creatorAddress) public view returns (address[] memory){
        return contentCreatorsChannels[_creatorAddress];
    }
}

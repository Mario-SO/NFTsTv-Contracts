// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "solmate/tokens/ERC721.sol";
import "openzeppelin-contracts/utils/Strings.sol";
import "openzeppelin-contracts/access/Ownable.sol";

error MintPriceNotPaid();
error NonExistentTokenURI();
error WithdrawTransfer();

contract LiveNFT is ERC721, Ownable {
    using Strings for uint256;
    uint256 public currentTokenId;

    string public baseTokenURI;
    string public LNFTname;
    string public description;
    uint256 public totalSupply;
    uint256 public mintPrice;

    address[] emitterAddresses;

    constructor() ERC721("LiveNFT", "LNFT") {}

    function init(
        string memory _baseTokenURI,
        string memory _name,
        string memory _description,
        uint256 _totalSupply,
        uint256 _mintPrice
    ) external {
        baseTokenURI = _baseTokenURI;
        LNFTname = _name;
        description = _description;
        totalSupply = _totalSupply;
        mintPrice = _mintPrice;
    }

    function addEmiterAddress(address _newEmitter) public onlyOwner {
        emitterAddresses.push(_newEmitter);
    }

    function setTokenURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (ownerOf(tokenId) == address(0)) {
            revert NonExistentTokenURI();
        }
        return
            bytes(baseTokenURI).length > 0
                ? string(abi.encodePacked(baseTokenURI, tokenId.toString()))
                : "";
    }

    function mintTo(address recipient) public payable returns (uint256) {
        if (msg.value != mintPrice) {
            revert MintPriceNotPaid();
        }
        uint256 newTokenId = ++currentTokenId;
        _safeMint(recipient, newTokenId);
        return newTokenId;
    }

    function withdrawPayments(address payable payee) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool transferTx, ) = payee.call{value: balance}("");
        if (!transferTx) {
            revert WithdrawTransfer();
        }
    }
}

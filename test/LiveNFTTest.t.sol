// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/LiveNFT.sol";

contract LiveNFTTest is Test {
    using stdStorage for StdStorage;

    LiveNFT private livenft;

    function setUp() public {
        // Deploy LiveNFT contract
        livenft = new LiveNFT("https://example.com");
    }

    function testFailNoMintPricePaid() public {
        livenft.mintTo(address(1));
    }

    function testMintPricePaid() public {
        livenft.mintTo{value: 0.08 ether}(address(1));
    }

    function testFailMintToZeroAddress() public {
        livenft.mintTo{value: 0.08 ether}(address(0));
    }

    function testNewMintOwnerRegistered() public {
        livenft.mintTo{value: 0.08 ether}(address(1));
        uint256 slotOfNewOwner = stdstore
            .target(address(livenft))
            .sig(livenft.ownerOf.selector)
            .with_key(1)
            .find();

        uint160 ownerOfTokenIdOne = uint160(
            uint256(
                (vm.load(address(livenft), bytes32(abi.encode(slotOfNewOwner))))
            )
        );
        assertEq(address(ownerOfTokenIdOne), address(1));
    }

    function testBalanceIncremented() public {
        livenft.mintTo{value: 0.08 ether}(address(1));
        uint256 slotBalance = stdstore
            .target(address(livenft))
            .sig(livenft.balanceOf.selector)
            .with_key(address(1))
            .find();

        uint256 balanceFirstMint = uint256(
            vm.load(address(livenft), bytes32(slotBalance))
        );
        assertEq(balanceFirstMint, 1);

        livenft.mintTo{value: 0.08 ether}(address(1));
        uint256 balanceSecondMint = uint256(
            vm.load(address(livenft), bytes32(slotBalance))
        );
        assertEq(balanceSecondMint, 2);
    }

    function testSafeContractReceiver() public {
        Receiver receiver = new Receiver();
        livenft.mintTo{value: 0.08 ether}(address(receiver));
        uint256 slotBalance = stdstore
            .target(address(livenft))
            .sig(livenft.balanceOf.selector)
            .with_key(address(receiver))
            .find();

        uint256 balance = uint256(
            vm.load(address(livenft), bytes32(slotBalance))
        );
        assertEq(balance, 1);
    }

    function testFailUnSafeContractReceiver() public {
        vm.etch(address(1), bytes("mock code"));
        livenft.mintTo{value: 0.08 ether}(address(1));
    }

    function testWithdrawalWorksAsOwner() public {
        // Mint an LiveNFT, sending eth to the contract
        Receiver receiver = new Receiver();
        address payable payee = payable(address(0x1337));
        uint256 priorPayeeBalance = payee.balance;
        livenft.mintTo{value: livenft.MINT_PRICE()}(address(receiver));
        // Check that the balance of the contract is correct
        assertEq(address(livenft).balance, livenft.MINT_PRICE());
        uint256 nftBalance = address(livenft).balance;
        // Withdraw the balance and assert it was transferred
        livenft.withdrawPayments(payee);
        assertEq(payee.balance, priorPayeeBalance + nftBalance);
    }

    function testWithdrawalFailsAsNotOwner() public {
        // Mint an LiveNFT, sending eth to the contract
        Receiver receiver = new Receiver();
        livenft.mintTo{value: livenft.MINT_PRICE()}(address(receiver));
        // Check that the balance of the contract is correct
        assertEq(address(livenft).balance, livenft.MINT_PRICE());
        // Confirm that a non-owner cannot withdraw
        vm.expectRevert("Ownable: caller is not the owner");
        vm.startPrank(address(0xd3ad));
        livenft.withdrawPayments(payable(address(0xd3ad)));
        vm.stopPrank();
    }
}

contract Receiver is ERC721TokenReceiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 id,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

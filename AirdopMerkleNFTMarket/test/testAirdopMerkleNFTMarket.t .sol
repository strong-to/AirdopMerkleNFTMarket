// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import { AirdopMerkleNFTMarket } from "../src/AirdopMerkleNFTMarket.sol";
import { MyERC721 } from "../src/modules/MyERC721.sol";
import { PermitERC20 } from "../src/modules/PermitERC20.sol";
import { SigUtil } from "../src/modules/SigUtils.sol";
import { ECDSA } from "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
// /Users/strong/Desktop/OpenSpace/bank/lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol

import {Counter} from "../src/Counter.sol";


contract AirdopMerkleNFTMarketTEST is Test {

    MyERC721  nft;
    PermitERC20  token;
    AirdopMerkleNFTMarket market;
    SigUtil  sigutil;
    address admin;
    uint256 adminKey;

    function setUp() public {

        // adminKey = vm.envUint("ab3d1b407a98ff5109eef7094c44e9f24841326fe95f6c27d04a774d5a510ab1");
        adminKey = 1;
        // admin = vm.envAddress("ADDRESS");
        admin = makeAddr("1");

        nft = new MyERC721();
        token = new PermitERC20();
        sigutil = new SigUtil(token.DOMAIN_SEPARATOR());
        market = new AirdopMerkleNFTMarket(
            address(token), address(nft), 0x8ba2796aab0dd4398c0a79034d31b5fcf841014222d284b2fc2ab86155d79957
        );
        token.transfer(admin, 50);
        address alice = makeAddr("alice");
        vm.startPrank(alice);
        nft.mint(alice ,"");
        nft.approve(address(market),1);
        market.list(1,100);
        // vm.startPrank(admin);   
    }

    function test_Increment() public {
         vm.startPrank(admin);   
        SigUtil.Permit memory permit = SigUtil.Permit({
            owner: admin,
            spender: address(market),
            value: 50,
            nonce: token.nonces(admin),
            deadline: 1 hours
        });

        bytes32 digest = sigutil.getTypedDataHash(permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(adminKey, digest);
        market.permitPrePay(50, 1 hours, v, r, s);
        // assertEq(token.allowance(admin, address(market)), 50);
        // assertEq(counter.number(), 1);
    }
}

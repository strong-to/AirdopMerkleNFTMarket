// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "./modules/NftMarket.sol";
import "./modules/PermitERC20.sol";

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract AirdopMerkleNFTMarket is NftMarket {
    PermitERC20 permitERC20;

    bytes32 immutable merkleRoot;

    constructor(address _token, address _nft, bytes32 _merkleRoot) NftMarket(_token, _nft) {
        permitERC20 = PermitERC20(_token);
        merkleRoot = _merkleRoot;
    }

    // 计算出叶子节点是否 在 数组中  地址是否在Merkle树白名单中
    // _merkleProof 是 Merkle树数组，addr判断的地址，
    // MerkleProof.verify(_merkleProof, merkleRoot, node);   merkleRoot 是 Merkle树的hash值，
    function _isWhite(bytes32[] calldata _merkleProof, address addr) private view returns (bool) {
    bytes32 node = keccak256(abi.encodePacked(addr));  
    return MerkleProof.verify(_merkleProof, merkleRoot, node);  // 判断 node 是否在_merkleProof中，如果在返回true 
    }

    // 使用permit授权，
    function permitPrePay(uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {

        permitERC20.permit(msg.sender, address(this),amount,deadline, v,  r, s);

    }

    // 先验证白名单 半价买 授权，转入token 转出nft    用户使用token 购买nft
    // 1.判断是否在白名单中 2.检验id地址是否是合约地址 3.检验该nft是否在售卖的列表中 4.检查金额，只要大于等于售价的一半即可
     // 5.处理token 和nft ，用户

     function claimNFT (uint256 amount, uint256 tokenId , bytes32[] calldata merkleProof) public {

        require(_isWhite(merkleProof,msg.sender),"error : not merkleProof"); // 白名单内
        require(nft.ownerOf(tokenId) == address(this),"error : tokenId != address(this)" ); // tokenId 对应的nft属于该合约
        require(listing[tokenId] != address(0), "error : listing[tokenId] == address(0)"); // tokenId 对应的nft在出售
        require(amount >= prices[tokenId]/2 , "error:  amount < prices/2 ");
        // listing 卖家地址   token转给卖家， 价格是售价的一半
        token.transferFrom(msg.sender , listing[tokenId] , prices[tokenId]/2); // token转给卖家，
        nft.safeTransferFrom (address(this),msg.sender,tokenId);
         delete listing[tokenId];
         delete prices[tokenId];

     }

     //要求使用 multicall( delegateCall 方式) 一次性调用两个方法：
     // 1. 循环数组 datas ，使用Address.functionDelegateCall处理 
     // 两个参数，第一个是调用的目标合约的地址，第二个是循环拿到 address(this)合约中的方法依次传入调用，并返回到数组results中

     function multicall ( bytes[] calldata datas ) public returns(bytes[] memory results )  {

        results =  new bytes[](datas.length);

        for(uint256 i = 0 ; i < datas.length;i++) {

            results[i] = Address.functionDelegateCall(address(this),datas[i]);

        }
            return results;
     }

    //   function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
    //     (bool success, bytes memory returndata) = target.delegatecall(data);
    //     return verifyCallResultFromTarget(target, success, returndata);
    // }
    
}
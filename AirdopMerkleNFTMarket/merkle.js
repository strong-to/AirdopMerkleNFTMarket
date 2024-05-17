const { MerkleTree } = require('merkletreejs');
const keccak256 = require("keccak256");
// 生成有资格的白名单和金额列表
const users = [
    { address: "0x11840afa3983516d28b459c547906cfc63dc88a0" },
    { address: "0x4deb6351805215b1c1240d9f9ad0545006d6ddb0" },
    { address: "0xa96d98bfacbb2188edd91ec772f28d90d3fabbc3" },
    { address: "0xff07eA54B66De1774054Ce8B5a084A7943F2B532" }, 
];
// 编码数据结构
const elements = users.map((x) => keccak256(x.address));
const merkleTree = new MerkleTree(elements, keccak256, { sort: true });
// 生成Merkle根
const root = merkleTree.getHexRoot();

console.log(merkleTree.getHexProof(elements[3]));
// ['0x79a574c4cf104c7028a98deaee7999a9e44ed137ff63dd4fe63e7847a98d8f32','0xf1d0b1cf153a456431509512addf1686becc79f62fe4d32f95c78fa6975c2e91']

console.log(root);
//0x8ba2796aab0dd4398c0a79034d31b5fcf841014222d284b2fc2ab86155d79957

// merkletreejs 用法教程
// const { MerkleTree } = require('merkletreejs')
// const SHA256 = require('crypto-js/sha256')

// // 创建Merkle树
// const leaves = ['a', 'b', 'c'].map(x => SHA256(x))
// const tree = new MerkleTree(leaves, SHA256)

// // 获取Merkle树的根
// const roots = tree.getRoot().toString('hex')

// // 计算叶子节点'a'的哈希值
// const leaf = SHA256('a')

// // 获取叶子节点'a'的证明
// const proof = tree.getProof(leaf)

// // 验证叶子节点'a'是否在Merkle树中
// console.log(tree.verify(proof, leaf, roots)) // 输出: true


// // 创建一个新的Merkle树，包含不同的叶子节点
// const badLeaves = ['a', 'x', 'c'].map(x => SHA256(x))
// const badTree = new MerkleTree(badLeaves, SHA256)

// // 计算叶子节点'x'的哈希值
// const badLeaf = SHA256('x')

// // 获取叶子节点'x'的证明
// const badProof = badTree.getProof(badLeaf)

// // 验证叶子节点'x'是否在原始Merkle树中
// console.log(badTree.verify(badProof, badLeaf, root)) // 输出: false

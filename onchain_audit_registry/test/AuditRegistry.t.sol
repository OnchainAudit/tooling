// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {AuditRegistry} from "../src/AuditRegistry.sol";
import {ECDSA} from "openzeppelin/utils/cryptography/ECDSA.sol";

contract CounterTest is Test {
    AuditRegistry public auditRegistry;
    address public addr1 = vm.addr(1);
    address public addr2 = vm.addr(2);
    address public addr3 = vm.addr(3);
    AuditRegistry.AuditSummary auditSummary;

    function setUp() public {
        auditRegistry = new AuditRegistry(addr1);
        address[] memory addrs = new address[](1);
        addrs[0] = addr1;
        bool[] memory isWhitelisted = new bool[](1);
        isWhitelisted[0] = true;
        vm.prank(addr1);
        auditRegistry.updateAuditorsWhitelist(addrs, isWhitelisted);

        string[] memory authors = new string[](2);
        authors[0] = "author1";
        authors[1] = "author2";

        uint256[] memory ercs = new uint256[](2);
        ercs[0] = 123;
        ercs[1] = 456;

        auditSummary = AuditRegistry.AuditSummary({
            auditor: AuditRegistry.Auditor({
                name: "Name",
                uri: "URI",
                authors: authors
            }),
            issuedAt: 100,
            ercs: ercs,
            chainId: 1,
            contractAddress: address(this),
            auditHash: "auditHash",
            auditUri: "auditUri"
        });
    }

    function testUpdateAuditorsWhitelist() public {
        address[] memory addrs = new address[](2);
        addrs[0] = addr1;
        addrs[1] = addr2;
        bool[] memory isWhitelisted = new bool[](2);
        isWhitelisted[0] = false;
        isWhitelisted[1] = true;
        vm.prank(addr1);
        auditRegistry.updateAuditorsWhitelist(addrs, isWhitelisted);
        assertFalse(auditRegistry.auditorsWhitelist(addr1));
        assertTrue(auditRegistry.auditorsWhitelist(addr2));
        isWhitelisted[0] = true;
        isWhitelisted[1] = false;
        vm.prank(addr1);
        auditRegistry.updateAuditorsWhitelist(addrs, isWhitelisted);
        assertTrue(auditRegistry.auditorsWhitelist(addr1));
        assertFalse(auditRegistry.auditorsWhitelist(addr2));

        bool[] memory isWhitelistedWrongLength = new bool[](3);
        isWhitelistedWrongLength[0] = true;
        isWhitelistedWrongLength[1] = false;
        isWhitelistedWrongLength[2] = false;

        vm.expectRevert(abi.encodeWithSignature("ArraysLengthMismatched()"));
        vm.prank(addr1);
        auditRegistry.updateAuditorsWhitelist(addrs, isWhitelistedWrongLength);

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(addr2);
        auditRegistry.updateAuditorsWhitelist(addrs, isWhitelisted);
    }

    function testVerifyAuditSummaryBadSignatureLength() public {
        vm.expectRevert(abi.encodeWithSignature("BadSignatureLength()"));
        auditRegistry.verifyAuditSummary(auditSummary, "badLength");
    }

    function testVerifyAuditSummaryBadSignatureVersion() public {        
        bytes32 txHash = _getTxHash(auditSummary);
        (, bytes32 r, bytes32 s) = vm.sign(1, txHash);
        uint8 v = 3;
        bytes memory sig = abi.encodePacked(r, s, v);

        vm.expectRevert(abi.encodeWithSignature("BadSignatureVersion()"));
        auditRegistry.verifyAuditSummary(auditSummary, sig);
    }

    function testVerifyAuditSummarySignature() public {        
        bytes32 txHash = _getTxHash(auditSummary);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, txHash);
        bytes memory sig = abi.encodePacked(r, s, v);

        assertTrue(auditRegistry.verifyAuditSummary(auditSummary, sig));

        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(2, txHash);
        bytes memory badSig = abi.encodePacked(r2, s2, v2);

        assertFalse(auditRegistry.verifyAuditSummary(auditSummary, badSig));
    }

    function testVerifyAuditSummaryRSV() public {        
        bytes32 txHash = _getTxHash(auditSummary);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, txHash);

        assertTrue(auditRegistry.verifyAuditSummary(auditSummary, r, s, v));

        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(2, txHash);

        assertFalse(auditRegistry.verifyAuditSummary(auditSummary, r2, s2, v2));
    }

    function _getTxHash(AuditRegistry.AuditSummary memory _auditSummary) internal view returns (bytes32) {
        bytes32 structHash = keccak256(abi.encode(
            auditRegistry.AUDIT_SUMMARY_TYPEHASH(),
            _hashAuditor(_auditSummary.auditor),
            _auditSummary.issuedAt,
            keccak256(abi.encodePacked(_auditSummary.ercs)),
            _auditSummary.chainId,
            _auditSummary.contractAddress,
            _auditSummary.auditHash,
            keccak256(bytes(_auditSummary.auditUri))
        ));

        return ECDSA.toTypedDataHash(auditRegistry.DOMAIN_SEPARATOR(), structHash);
    }

    function _hashAuditor(AuditRegistry.Auditor memory _auditor) internal view returns (bytes32) {
        bytes32[] memory authors = new bytes32[](_auditor.authors.length);
        for (uint256 i = 0; i < _auditor.authors.length; ++i) {
            authors[i] = keccak256(bytes(_auditor.authors[i]));
        }
        return keccak256(abi.encode(
            auditRegistry.AUDITOR_TYPEHASH(),
            keccak256(bytes(_auditor.name)),
            keccak256(bytes(_auditor.uri)),
            keccak256(abi.encodePacked(authors))
        ));
    }


}

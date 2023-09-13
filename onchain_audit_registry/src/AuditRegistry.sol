// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {EIP712} from "openzeppelin/utils/cryptography/EIP712.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

contract AuditRegistry is Ownable, EIP712 {
    error ArraysLengthMismatched();
    error BadSignatureLength();
    error BadSignatureVersion();

    bytes32 public constant AUDIT_SUMMARY_TYPEHASH =
        keccak256("AuditSummary(Auditor auditor,uint256 issuedAt,uint256[] ercs,uint256 chainId,address contractAddress,bytes32 auditHash,string auditUri)");
    bytes32 public constant AUDITOR_TYPEHASH = keccak256("Auditor(string name,string uri,string[] authors)");
        
    struct Auditor {
        string name;
        string uri;
        string[] authors;
    }

    struct AuditSummary {
        Auditor auditor;
        uint256 issuedAt;
        uint256[] ercs;
        uint256 chainId;
        address contractAddress;
        bytes32 auditHash;
        string auditUri;
    }

    string public constant NAME = "ERC-7652: Onchain Audit Representation";
    string public constant VERSION = "1.0";

    mapping(address => bool) public auditorsWhitelist;

    event AuditorsWhitelistUpdated(address[] indexed _auditors, bool[] _isWhitelisted);

    constructor(address _owner) EIP712(NAME, VERSION) {
        _transferOwnership(_owner);
    }

    function updateAuditorsWhitelist(address[] calldata _auditors, bool[] calldata _isWhitelisted) external onlyOwner {
        if (_auditors.length != _isWhitelisted.length) {
            revert ArraysLengthMismatched();
        }

        for (uint256 i = 0; i < _auditors.length;) {
            auditorsWhitelist[_auditors[i]] = _isWhitelisted[i];
            unchecked {
                ++i;
            }
        }

        emit AuditorsWhitelistUpdated(_auditors, _isWhitelisted);
    }

    function verifyAuditSummary(AuditSummary calldata _auditSummary, bytes calldata _sig) external view returns(bool) {
        bytes32 txHash = _getTxHash(_auditSummary);

        address recoveredAddress = _recover(txHash, _sig);

        return auditorsWhitelist[recoveredAddress];
    }

    function verifyAuditSummary(AuditSummary calldata _auditSummary, bytes32 r, bytes32 s, uint8 v) external view returns(bool) {
        bytes32 txHash = _getTxHash(_auditSummary);

        address recoveredAddress = ecrecover(txHash, v, r, s);

        return auditorsWhitelist[recoveredAddress];
    }

    function _getTxHash(AuditSummary calldata _auditSummary) internal view returns (bytes32) {
        bytes32 structHash = keccak256(abi.encode(
            AUDIT_SUMMARY_TYPEHASH,
            _hashAuditor(_auditSummary.auditor),
            _auditSummary.issuedAt,
            keccak256(abi.encodePacked(_auditSummary.ercs)),
            _auditSummary.chainId,
            _auditSummary.contractAddress,
            _auditSummary.auditHash,
            keccak256(bytes(_auditSummary.auditUri))
        ));

        return _hashTypedDataV4(structHash);
    }

    function _hashAuditor(Auditor calldata _auditor) internal pure returns (bytes32) {
        bytes32[] memory authors = new bytes32[](_auditor.authors.length);
        for (uint256 i = 0; i < _auditor.authors.length; ++i) {
            authors[i] = keccak256(bytes(_auditor.authors[i]));
        }
        return keccak256(abi.encode(
            AUDITOR_TYPEHASH,
            keccak256(bytes(_auditor.name)),
            keccak256(bytes(_auditor.uri)),
            keccak256(abi.encodePacked(authors))
        ));
    }

    function _recover(
        bytes32 hash,
        bytes memory signature
    ) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            revert BadSignatureLength();
        }

        // Divide the signature in r, s and v variables
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            revert BadSignatureVersion();
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }

}

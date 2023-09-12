// index.ts

import * as dotenv from 'dotenv';
import { ethers } from 'ethers';
dotenv.config();
type EIP712Domain = {
    name: string;
    version: string;
};

// Define the EIP-712 Domain
const domain:EIP712Domain = {
    name: "ERC-7652: Onchain Audit Representation",
    version: "1.0"
};


// Define the EIP-712 Types
const types: any = {
    AuditSummary: [
        { name: "auditor", type: "Auditor" },
        { name: "issuedAt", type: "uint256" },
        { name: "ercs", type: "uint256[]" },
        { name: "contract", type: "Contract" },
        { name: "auditHash", type: "bytes32" },
        { name: "auditUri", type: "string" }
    ],
    Auditor: [
        { name: "name", type: "string" },
        { name: "uri", type: "string" },
        { name: "authors", type: "string[]" }
    ],
    Contract: [
        { name: "chainId", type: "uint256" },
        { name: "address", type: "address" }
    ]
};

// Convert chain ID to bytes32 format
function toBytes32(num: number): string {
    let hex = num.toString(16);
    return "0x" + ("0".repeat(64 - hex.length) + hex);
}

// Sample Audit Summary Data
const auditSummaryData = {
    auditor: {
        name: "Auditor Name",
        uri: "https://auditorwebsite.com",
        authors: ["Author1", "Author2"]
    },
    issuedAt: Date.now(),
    ercs: [20, 721],
    contract: {
        chainId: 1,
        address: "0x0bc529c00c6401aef6d220be8c6ea1667f6ad93e"
    },
    auditHash: toBytes32(23),
    auditUri: "https://auditwebsite.com/report"
};

const privateKey: string = process.env.YOUR_PRIVATE_KEY!;
const wallet = new ethers.Wallet(privateKey);


async function signAndPrint() {
    try {
        // Await the result of the Promise
        const signature = await wallet.signTypedData(domain, types, auditSummaryData);
        console.log("Signature:", signature);
    } catch (error) {
        console.error("Error signing data:", error);
    }
}

signAndPrint();

// Constants
const DOMAIN = {
    name: "ERC-7512: Onchain Audit Representation",
    version: "1.0"
};

const TYPES = {
    EIP712Domain: [
        { name: "name", type: "string" },
        { name: "version", type: "string" },
    ],
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

let authorCount = 0;
let ercCount = 0;

// Utility Functions
function displayError(input, message) {
    let errorElement = input.parentNode.querySelector('.error-message');
    if (!errorElement) {
        errorElement = createErrorMessageElement();
        input.parentNode.appendChild(errorElement);
    }
    errorElement.textContent = message;
}

function createErrorMessageElement() {
    const errorElement = document.createElement('span');
    errorElement.className = 'error-message';
    errorElement.style.color = 'red';
    errorElement.style.marginLeft = '10px';
    return errorElement;
}

// Validation Functions
function validateForm() {
    const form = document.getElementById('auditForm');
    let isValid = true;

    validateInputs(form, isValid);
    validateURIs(form, isValid);
    const ethAddressInput = document.getElementById('contractAddress');
    if (!validateEthereumAddress(ethAddressInput)) {
        isValid = false;
    }
    if (!isValid) {
        alert('Please fill out all required fields correctly.');
    }

    return isValid;
}

function validateInputs(form, isValid) {
    const inputs = form.querySelectorAll('input:not([readonly])'); 
    inputs.forEach(input => {
        if (!input.validity.valid || input.value.trim() === '') {
            input.style.border = '2px solid red';
            isValid = false;
        } else {
            resetInputStyle(input);
        }
    });
}

function resetInputStyle(input) {
    input.style.border = '';
    const errorElement = input.parentNode.querySelector('.error-message');
    if (errorElement) {
        errorElement.remove();
    }
}

function validateURIs(form, isValid) {
    const uriPattern = /^(https?:\/\/)?([\da-z.-]+)\.([a-z.]{2,6})([/\w .-]*)*\/?$/;
    const uriInputs = form.querySelectorAll('input[type="text"][placeholder*="URI"]');
    uriInputs.forEach(uriInput => {
        if (!uriPattern.test(uriInput.value)) {
            uriInput.style.border = '2px solid red';
            displayError(uriInput, 'Invalid URI');
            isValid = false;
        }
    });
}

function validateEthereumAddress(addressInput) {
    if (!ethers.utils.isAddress(addressInput.value)) {
        addressInput.style.border = '2px solid red';
        displayError(addressInput, 'Invalid Ethereum Address');
        return false;
    } else {
        addressInput.style.border = ''; // Reset border for valid inputs
        const errorElement = addressInput.parentNode.querySelector('.error-message');
        if (errorElement) {
            errorElement.remove();
        }
        return true;
    }
}


// Author and ERC Field Functions
function addAuthorField(event) {
    event.preventDefault();
    const authorsContainer = document.getElementById('authorsContainer');
    const authorDiv = createFieldGroup('Author', authorCount);
    authorsContainer.appendChild(authorDiv);
    authorCount++;
}

function addErcField() {
    const ercContainer = document.getElementById('ercContainer');
    const ercDiv = createFieldGroup('ERC', ercCount);
    ercContainer.appendChild(ercDiv);
    ercCount++;
}

function createFieldGroup(type, count) {
    const groupDiv = document.createElement('div');
    groupDiv.className = `${type.toLowerCase()}-group field-group`;

    const input = document.createElement('input');
    input.type = 'text';
    input.className = `${type.toLowerCase()}-input`;
    input.placeholder = `${type} ${count}`;

    const removeButton = document.createElement('button');
    removeButton.innerText = 'Remove';
    removeButton.onclick = function () {
        groupDiv.remove();
    };

    groupDiv.appendChild(input);
    groupDiv.appendChild(removeButton);

    return groupDiv;
}

// Signing and Hashing Functions
async function signData() {
    if (!validateForm()) return;
    if (typeof window.ethereum !== 'undefined') {
        const signer = await getSigner();
        const typedData = await constructTypedData();
        const signature = await requestSignature(signer, typedData);
        document.getElementById('signatureField').value = signature;
    } else {
        alert('Please install MetaMask!');
    }
}

async function getSigner() {
    const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
    return accounts[0];
}

async function constructTypedData() {
    return {
        types: TYPES,
        domain: DOMAIN,
        primaryType: 'AuditSummary',
        message: {
            auditor: {
                name: document.getElementById('auditorName').value,
                uri: document.getElementById('auditorUri').value,
                authors: Array.from(document.querySelectorAll('.author-input')).map(input => input.value)
            },
            issuedAt: Date.now(),
            ercs: Array.from(document.querySelectorAll('.erc-input')).map(input => parseInt(input.value)),
            contract: {
                chainId: parseInt(document.getElementById('chainId').value),
                address: document.getElementById('contractAddress').value
            },
            auditHash: await computePdfHash(),
            auditUri: document.getElementById('auditUri').value
        }
    };
}

async function requestSignature(signer, typedData) {
    return await ethereum.request({
        method: 'eth_signTypedData_v4',
        params: [signer, JSON.stringify(typedData)],
        from: signer,
    });
}

async function computePdfHash() {
    const fileInput = document.getElementById('pdfFile');
    const file = fileInput.files[0];
    const fileBuffer = await file.arrayBuffer();
    const fileHash = ethers.utils.keccak256(new Uint8Array(fileBuffer));
    return fileHash;
}


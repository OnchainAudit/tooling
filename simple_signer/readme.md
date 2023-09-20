# ERC-7512 Node Signer Script

This repository contains a Node.js script to sign typed data according to the ERC-7512 standard. The script is written in TypeScript and uses the Ethers.js library to interact with the Ethereum blockchain.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Environment Setup](#environment-setup)
- [Running the Script](#running-the-script)

## Prerequisites

- [Node.js](https://nodejs.org/)
- [npm](https://www.npmjs.com/) (comes bundled with Node.js) or [Yarn](https://yarnpkg.com/)

## Installation

1. Clone this repository:

   ```bash
   git clone git@github.com:OnchainAudit/tooling.git
   ```

2. Navigate to the project directory:

   ```bash
   cd tooling/simple_signer
   ```

3. Install the required dependencies:

   ```bash
   npm install
   ```

   or if you're using Yarn:

   ```bash
   yarn install
   ```

## Environment Setup

1. Rename the `.env.template` file to `.env`.
2. Open the `.env` file and paste your Ethereum private key next to `YOUR_PRIVATE_KEY=`. Ensure there are no spaces between the `=` sign and your private key.

   Example:
   ```
   YOUR_PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE
   ```

3. Save the `.env` file.

## Running the Script

With the environment set up, you can run the script using the following command:

```bash
npm start
```

or if you're using Yarn:

```bash
yarn start
```

---

**Note**: Always ensure that your `.env` file is added to your `.gitignore` to prevent accidentally pushing sensitive information to public repositories. The `.env.template` serves as a placeholder to guide users on how to set up their environment variables without exposing any sensitive data.
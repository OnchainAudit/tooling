# MetaMask Typed Data Signer

This project provides a simple HTML interface to interact with MetaMask for signing typed data according to the EIP-712 standard.

## Features

- Input fields for all necessary data types.
- Dynamic addition and removal of ERC and Author fields.
- File input for PDFs to compute a hash.
- Validation for all fields, including URI and Ethereum address validation.
- Integration with MetaMask for signing the typed data.

## How to Run

You can run this HTML file using a local server. Here are two methods to do so:

### Using Python

If you have Python installed on your machine, you can use its built-in HTTP server:

1. Navigate to the directory containing the HTML file in your terminal.
2. Run the following command:

   - For Python 2.x:
     ```bash
     python -m SimpleHTTPServer 8000
     ```

   - For Python 3.x:
     ```bash
     python -m http.server 8000
     ```

3. Open your browser and go to `http://localhost:8000/`.

### Using `http-server`

If you prefer using Node.js, you can use the `http-server` package:

1. Install `http-server` globally:
   ```bash
   npm install -g http-server
   ```

2. Navigate to the directory containing the HTML file in your terminal.
3. Run the following command:
   ```bash
   http-server
   ```

4. Open your browser and go to the displayed address (usually `http://127.0.0.1:8080`).

## Usage

1. Fill out all the required fields in the form.
2. Add or remove ERC and Author fields as needed.
3. Upload a PDF file.
4. Click the "Sign Data" button to initiate the MetaMask signing process.
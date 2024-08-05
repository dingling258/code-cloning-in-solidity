// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * Liebe Rebecca, ich wünsche dir alles Gute für deine Zukunft. Der Text ist mit der Vigenere-Chiffre verschlüsselt.
 * Wenn du den korrekt entschlüsselten Text als Input für die withdraw-Funktion verwendest, wird das Ether auf deinen Account übertragen.
 * Viel Spaß!
 */
contract Storage {
 
    address payable owner;
    bytes32 constant secret_hash = 0x47a71f56a208913252ccdc975dd117b4e0d586fba8c42b9975cc703bd6537164;
    string public constant encrypted_test = 'ucakqiyamqcabsojktmdxvbtyhgmikgnlvwprhtjovneglsaqsvxbuqrycfprhftvuqrglseufnkblzdwmfyssojcepdxzprccasmetebbhvwcgmmle';

    constructor(){
        owner = payable(msg.sender);        
    }
    
    function get_encrypted_text() public pure returns (string memory) {
        return encrypted_test;
    }

    function withdraw(string memory _secret) public {
        require(owner == msg.sender);
        require(keccak256(abi.encodePacked(_secret)) == secret_hash);
        payable(msg.sender).transfer(payable(address(this)).balance);
    }

    function deposit(uint256 amount) public payable {
        // amount in Gwei
        require(msg.value == (amount * 1000000000));
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

}
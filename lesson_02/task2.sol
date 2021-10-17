pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract task2 {

	uint public total = 1;

	constructor() public {
		require(tvm.pubkey() != 0, 101);
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
	}

	modifier checkOwnerAndAccept {
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

	// Функция умножения
    function mult(uint value) public checkOwnerAndAccept {
        require(value > 0 && value < 10, 103, "Wrong value, should be between 0 and 10");
        total *= value;
    }
}
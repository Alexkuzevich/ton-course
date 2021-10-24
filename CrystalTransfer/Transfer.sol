
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract Transfer {

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    modifier checkOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey(), 100);
		tvm.accept();
		_;
	}

    // Отправить без оплаты комиссии за свой счет
    function sendWithoutFee(address dest, uint128 value) public pure checkOwnerAndAccept {
        dest.transfer(value, false, 0);
    }

    // Отправить с оплатой комиссии за свой счет
    function sendWithFee(address dest, uint128 value) public pure checkOwnerAndAccept {
        dest.transfer(value, false, 1);
    }

    // Отправить все деньги и уничтожить кошелек
    function sendAllAndDelete(address dest, uint128 value) public pure checkOwnerAndAccept {
        dest.transfer(value, false, 160);
    }


}
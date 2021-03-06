
/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract task3_1 {

    string[] public queue;

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

    //1. Встать в очередь
    function getIn(string name) public checkOwnerAndAccept {
        
        queue.push(name);
    }

    // 2. Вызвать следующего
    function getOut() public checkOwnerAndAccept {

        string[] tempArray;
        uint range = queue.length;
        // реверс этого массива запишем во временный
        for (uint256 i = range; i > 0; i--){
            tempArray.push(queue[i - 1]);  
        }
        // теперь удаляем требуемый элемент
        // в данный момент это последний элемент временного массива, поэтому можно воспользоваться pop()
        tempArray.pop();
        uint tempRange = tempArray.length;
        // теперь реверсируем массив обратно в исходный (уже без удаленного элемента)
        for (uint256 i = tempRange; i > 0; i--){
            queue[tempRange - i] = tempArray[i - 1]; 
        }
        // удаляем лишний по количеству элемент (это костыль)
        queue.pop();
    }
}


/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import 'InterfaceGameObject.sol';
import 'GameObject.sol';

contract BaseStation is GameObject{

    uint private unitDefense;
    uint private unitAttack;
    uint private unitHealth = 10;
    address private ownerAddress;
    mapping(address => bool) stationUnits;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    // Добавить юнит
    function addUnit(address unit) virtual public {
        tvm.accept();
        stationUnits[unit] = true;
    }

    // Убрать юнит
    function kickUnit(address unit) virtual public{
        if(stationUnits.exists(unit)) {
            tvm.accept();
            delete stationUnits[unit];
        }   
    }

    // Получить список юнитов
    function listUnits() virtual public view returns(mapping(address => bool)) {
        for((address unit, bool status) : stationUnits){
            return stationUnits;
        }
    }

    // Получить силу защиты
    function getDefense() virtual public view override returns (uint){
        tvm.accept();
        return unitDefense;
    }
    
    // Получить силу атаки
    function getAttack() virtual public view override returns (uint){
        tvm.accept();
        return unitAttack;
    }

    // Получить текущее здоровье
    function getCurrentHealth() virtual public view override returns (uint){
        tvm.accept();
        return unitHealth;
    }

    // Обработка гибели
    function deathHandling(address dest) virtual external {
        tvm.accept();
        for((address unit, bool status) : stationUnits){
            kickUnit(unit);
        }
        sendAllAndDelete(dest);
    }

    // Отправка всех денег по адресу и уничтожение
    function sendAllAndDelete(address dest) public pure override checkOwnerAndAccept {
        tvm.accept();
        dest.transfer(1, false, 160);
    }

}
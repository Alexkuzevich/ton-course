
/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

interface InterfaceGameObject {

    function getAttacked() external;
    function getDefense() external view returns (uint);
    function getAttack() external view returns (uint);
    function getCurrentHealth() external view returns (uint);
}
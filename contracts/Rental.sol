pragma solidity >=0.5.0 <0.6.0;

import {DeviceLib} from "./DeviceLib.sol";

contract Rental {
    
    bool private stopped = false;
    address private manager;
    address payable nulladdress = address(0x0);
    mapping(address => uint256) public balances;
     //The constructor. We assign the manager to be the creator of the contract.It could be enhanced to support passing maangement off.
    constructor() public  
    {
        manager = msg.sender;
    }

    //Check if sender isAdmin, this function alone could be added to multiple functions for manager only method calls
    modifier isAdmin() {
        assert(msg.sender == manager);
        _;
    }
    
    
    event Rent(
       string __make,
       uint256 __fee,
       address __leasee
    );
    
    
    //Check if the contracts features are deactivated
    function getStopped() public view returns(bool) { return stopped; }

    
    function toggleContractActive() isAdmin public {
        // You can add an additional modifier that restricts stopping a contract to be based on another action, such as a vote of users
        stopped = !stopped;
    }


    //Number of Devices available for rent
    DeviceLib.Device[] public rentals;

    //Return Total Number of Devices
    function getDeviceCount() public view returns(uint) {
        return rentals.length;
    }
    
    function getDeviceOwner(uint deviceId) public view returns(address){
        
        return rentals[deviceId].owner;
    }
    
   //function register(address user) public returns(bool){
        //address account = msg.sender;
    //    address account = user;
     //   balances[account] = 0;
//   }

   //function getUserBalance(address user) public view returns (uint256) {
   //     uint balance_user = balances[user];
   //     return balance_user;
   // }


    //function deposit(uint256 amount) payable public returns(bool){
    //  uint256 amount_inwei = amount*10**18;
    //  require (msg.value == amount_inwei);
    //  balances[msg.sender]+=amount;
     // return true;
    //}

    //function withdraw(uint256 amount) payable external returns(bool){
    //  uint256 balances_inwei = balances[msg.sender]*10**18;
    //  require (msg.value<=balances_inwei);
    //  uint256 amount_inwei = amount*10**18;
     // msg.sender.transfer(amount_inwei);
    //  balances[msg.sender]-=amount;
    //  return true;
   // }
  
    function () payable external {

    }

    //Renting a device 
    function rent(uint deviceId, uint rentday) public payable returns (bool) {
      //Never Ever want to be false, therefore we use assert
      assert(!stopped);   
      uint totalDevices = getDeviceCount();

      require(deviceId >= 0 && deviceId < totalDevices);
      //Reference to the device that will be rented 
      DeviceLib.Device storage deviceToBeRented = rentals[deviceId];
    
      require(deviceToBeRented.isAvailable == true); 
     // uint256 totalfee = rentday * deviceToBeRented.dailyrent + deviceToBeRented.deposit;
      deviceToBeRented.leasee = msg.sender;
      deviceToBeRented.isAvailable = false;
      deviceToBeRented.leaseterm = rentday;
      emit Rent(deviceToBeRented.model, deviceToBeRented.dailyrent, deviceToBeRented.leasee);
      
      return true;
    
    }

    // Retrieving the device data necessary for user
    function getRentalDeviceInfo(uint deviceId) public view returns (string memory _make, bool, address, address, uint, uint, uint, uint, uint) {
      
      uint totalDevices = getDeviceCount();
      require(deviceId >= 0 && deviceId < totalDevices);
      DeviceLib.Device memory specificDevice = rentals[deviceId];
      return (specificDevice.model, specificDevice.isAvailable, specificDevice.leasee, specificDevice.owner, specificDevice.year, specificDevice.dailyrent, specificDevice.deposit, specificDevice.leaseterm, specificDevice.deviceId);
    }
    
    
    
    //Add RentableDevice
    function addNewDevice(string memory model, address payable owner, uint year,uint dailyrent, uint deposit) public returns (uint) {
        assert(!stopped); 
        uint count = getDeviceCount();
        DeviceLib.Device memory newDevice = DeviceLib.Device(model, true, address(0x0), owner, year, dailyrent, deposit, 0, count);
        rentals.push(newDevice);
        
         return count;
    }
    
    //Allow device Owner to Mark device as returned
    function returnDevice(uint deviceId) public returns (bool) {
        assert(!stopped); 
        DeviceLib.Device storage specificDevice = rentals[deviceId];
        address payable leasee = address(uint160(specificDevice.leasee));
        // cast the addreess to address payable in 0.5.0//in 0.6.0 address payable newadrr = payable(addr)
        require(specificDevice.owner == msg.sender);
        uint256 totalfee_inwei = specificDevice.dailyrent * specificDevice.leaseterm *10**18;
        uint256 deposit_inwei = specificDevice.deposit *10**18; 
        //balances[msg.sender]+=totalfee;
        msg.sender.transfer(totalfee_inwei);
        leasee.transfer(deposit_inwei);
        specificDevice.isAvailable = true;
        specificDevice.leasee = address(0x0);
        specificDevice.leaseterm = 0;
        return true;
    }

}
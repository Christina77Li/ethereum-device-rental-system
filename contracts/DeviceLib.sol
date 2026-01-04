pragma solidity >=0.5.0 <0.6.0;

library DeviceLib {
    //This library contains helps create Car Objects for Rental Contracts
    struct Device {
        string model; // device Model
        bool isAvailable;  // if true, this car can be rented out
        address leasee; // person delegated to
        address owner; //Owner of device
        uint year;   // the acquisition year of this device
        uint dailyrent; //rent fee of device
        uint deposit; //owner requires renter to make deposit
        uint leaseterm; // total days for leasing
        uint deviceId; // index of device to be rented 
        
    }
}

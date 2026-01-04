pragma solidity >=0.5.0 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Rental.sol";

//This Contract tests the rental contract
contract TestRental {

    //This is a persisting contract instance we can persist throughout the testing lifecycle to validate various aspects    
    Rental rental = Rental(DeployedAddresses.Rental());

    //Test instantiation of contract
    function testContractCreation () public {

        //Initialize New Contract 
        Rental newContract = Rental(DeployedAddresses.Rental());

        //Check Device Count
        uint count = newContract.getDeviceCount();

        //Verify Registry is empty
        Assert.equal(count,0,"Registry Should be empty");   
    }
    


    //Verify A Device can be added to registry
    function testAddDeviceForRent() public{

        //Verify Registry is empty
        Assert.equal(rental.getDeviceCount(),0,"Registry Should be empty");

        //Add Device to registry 
        rental.addNewDevice("NintendoSwitch",0x1A2991d462185d568e21C12bc17087c76ED92500,2018,1,5);

        //Verify Registry contains a device now
        Assert.equal(rental.getDeviceCount(),1,"Device Not Added To Rental Registry");
        Assert.equal(rental.getDeviceOwner(0),0x1A2991d462185d568e21C12bc17087c76ED92500,"Device Not Added To Rental Registry");
    }

    //Test retrieval of device info 
    function testGetRentalDeviceInfo()  public {
        //Ensure info matches the info added upon submission of first device 
         (string memory model, bool  availability, , , uint  year, uint dailyrent, uint deposit, uint leaseterm, uint  deviceID) =  rental.getRentalDeviceInfo(0);

         //Validate Make was accurately provided
        Assert.equal(model,"NintendoSwitch","Model information was not stored properly");

        //Validate that the device is available
        Assert.equal(availability, true ,"Availability was not stored properly");

        //Validate the year is correct
        Assert.equal(year,2018 ,"Acqusition year was not stored properly");

        //Validate the fee and deposit are correct
        Assert.equal(dailyrent,1,"Daily rent was not stored properly");
        Assert.equal(deposit,5,"Required deposit was not stored properly");
        //Validate the ID is correct
        Assert.equal(leaseterm,0,"Leaseterm should be initialized as 0");
        Assert.equal(deviceID,0,"DeviceId was not stored properly");
    }

    //Verify the count of the devices is accurate 
    function testGetDeviceCount() public {
        //Verify Registry has one device 
        Assert.equal(rental.getDeviceCount(),1,"Registry Should Contain A Single Device");

        //Add Device to registry 
        rental.addNewDevice("NDS",0x1A2991d462185d568e21C12bc17087c76ED92500,2018,1,5);

        //Add Device to registry 
        rental.addNewDevice("3DS",0x1A2991d462185d568e21C12bc17087c76ED92500,2018,2,6);

        //Add Device to registry 
        rental.addNewDevice("PS3",0x1A2991d462185d568e21C12bc17087c76ED92500,2015,3,7);

        //Verify Registry contains 4 devices now
        Assert.equal(rental.getDeviceCount(),4,"Device Not Added To Rental Registry");
    }

    //Verify that upon renting a device, rental funtion returns true 
    function testRentDevice() public {
        //Rent Device Currently available
        bool result = rental.rent(0,1);

        //Verify true was returned as successfully rented 
        Assert.equal(result,true ,"Device Rented successfully");
    }
    

    //Verify that after device was rented, it is no longer available
    function testAvailabilityBool() public {
        //Ensure bool indicates device is no longer available  
        (, bool  availability, , , , , , ,) =  rental.getRentalDeviceInfo(0);

        //Validate that the device is not available
        Assert.equal(availability, false ,"Availability was not stored properly");
    }

}

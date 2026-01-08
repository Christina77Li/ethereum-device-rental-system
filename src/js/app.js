// app.js
// Front-end logic for a decentralized electronic device rental DApp.
// - Loads device metadata from devices.json for initial display
// - Connects to Ethereum via MetaMask or Ganache
// - Interacts with the Rental smart contract to add devices, rent, and return them
App = {
  web3Provider: null,
  contracts: {},

  init: function() {
     // Load devices.
     $.getJSON('../devices.json', function(data) {
       var devicesRow = $('#devicesRow');
       var deviceTemplate = $('#deviceTemplate');

       for (i = 0; i < data.length; i ++) {
         deviceTemplate.find('.panel-title').text(data[i].model);
         deviceTemplate.find('.device-model').text(data[i].model);
         deviceTemplate.find('img').attr('src', data[i].picture);
         deviceTemplate.find('.device-isAvailable').text(data[i].isAvailable);
         deviceTemplate.find('.device-year').text(data[i].year);
         deviceTemplate.find('.device-dailyrent').text(data[i].dailyrent);
         deviceTemplate.find('.device-leaseterm').text(data[i].leaseterm);
         deviceTemplate.find('.btn-rent').attr('data-id', data[i].id);

         devicesRow.append(deviceTemplate.html());
       }
     });
    return App.initWeb3();
  },

  // Initialize Web3:
  // - Try MetaMask (window.ethereum / window.web3)
  // - Fallback to local Ganache at http://localhost:7545
  initWeb3: async function() {

    //if (typeof web3 !== 'undefined') {
    //  App.web3Provider = web3.currentProvider;
    //  console.log("Connected to Metamask")

    if (window.ethereum){
      App.web3Provider = window.ethereum;
      try{
        await window.ethereum.enable();
        console.log("Try to connect with Metamask.")
      } catch(error){
        console.error("User denied account access")
      }
    }
    else if (window.web3){
      App.web3Provider = window.web3.currentProvider;
      console.log("Inject the instance into Metamask")
    }
    else {
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      console.log("Metamask is not installed. Fall back to Ganache.")
    }
    web3 = new Web3(App.web3Provider);
    console.log("Web3 init")
    return App.initContract();
  },

  // Load Rental contract
  initContract: function() {
    $.getJSON('Rental.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var RentalArtifact = data;
      App.contracts.Rental = TruffleContract(RentalArtifact);

      // Set the provider for our contract
      App.contracts.Rental.setProvider(App.web3Provider);

      // Use our contract to retrieve and mark the rented devices
      return App.markRented();
    });

    //App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    return App.bindEvents();
  },


  markRented: function(rentals, account) {
    var rentalInstance;
    App.contracts.Rental.deployed().then(function(instance) {
      rentalInstance = instance;
      return rentalInstance;   
    }).then(function(rentalInstance) {

      rentalInstance.getDeviceCount().then(function(count){
         App.getAllDevices(rentalInstance, account, Number(count));
      });

     }).catch(function(err) {
       console.log(err.message);   
   });    
  },


  getAllDevices: function(rentalInstance, account, count) {

      var devicesRow = $('#devicesRow');
      var deviceTemplate = $('#deviceTemplate');

      devicesRow.empty();
      for (i = 0; i < count; i ++) {
        App.getDeviceInfo(rentalInstance,i).then(function(info) {

            
            var model = info[0];
            var isAvailable = info[1];
            deviceTemplate.find('.panel-title').text(model);
            deviceTemplate.find('.device-model').text(model);
            deviceTemplate.find('.device-isAvailable').text(info[1]);
            deviceTemplate.find('.device-year').text(info[4]);
            deviceTemplate.find('.device-dailyrent').text(info[5]);
            deviceTemplate.find('.device-deposit').text(info[6]);
            deviceTemplate.find('.device-leaseterm').text(info[7]);
            deviceTemplate.find('.btn-rent').attr('data-id', info[8]);
            deviceTemplate.find('.btn-return').attr('data-id', info[8]);
            deviceTemplate.find('.btn-rent').attr('disabled', !isAvailable);
            devicesRow.append(deviceTemplate.html());
        });
      }
  },


  getDeviceInfo: async function (rentalInstance, i) {
    return await rentalInstance.getRentalDeviceInfo(i);
  },

  
  
  handleRent: function(event) {
    event.preventDefault();

    var deviceId = parseInt($(event.target).data('id'));    
    var rentalInstance;

    web3.eth.getAccounts(function(error, accounts) {

      if (error) {
        console.log(error);
      }
      var account = web3.eth.accounts[0];
      var accountInterval = setInterval(function() {
        if (web3.eth.accounts[0] !== account) {
          account = web3.eth.accounts[0];
          //Dectecting whether the account interacts with contracts is changed.
        }
      }, 100);
      window.ethereum.on('accountsChanged', function (accounts) {
      // Reload interface with new accounts[0]!
      })
      console.info('current account -->'+account);


      App.contracts.Rental.deployed().then(function(instance) {

        rentalInstance = instance;
        var rentday = document.getElementById("input_term").value;

        App.getDeviceInfo(rentalInstance,deviceId).then(function(info) {

          var dailyrent =  Number(info[5]);
          var _deposit = Number(info[6]);
          var totalpayment = (dailyrent* rentday) + _deposit;
          var owner = info[3];
          console.info("Owner: "+owner+"__dailyrent: "+info[5]+"__leaseterm: "+rentday+"__totalpayments: "+totalpayment+"__leasee: "+account)
          
          return rentalInstance.rent(deviceId, rentday, {from: account, value: web3.toWei(totalpayment,'ether'), gas:3000000});
        
      }).then(function(result, account) {
        
        return App.markRented(account);
      
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  });
  },




  handleAddDevice: function(event) {
    event.preventDefault();
      
    var deviceId = parseInt($(event.target).data('id'));
    var rentalInstance;
    
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
     }
   
      var account = accounts[0];
      console.log("Your account:"+account)

      App.contracts.Rental.deployed().then(function(instance) {
        rentalInstance = instance;

        var model = document.getElementById("model").value;
        var owner = document.getElementById("owner").value;
        var year = document.getElementById("year").value;
        var dailyrent = document.getElementById("dailyrent").value;
        var deposit = document.getElementById("deposit").value;
        console.log("model:"+model+"__owner:"+owner+"__year:"+year+"__dailyrent:"+dailyrent+"__deposit:"+deposit)

        return rentalInstance.addNewDevice(model,owner,year,dailyrent,deposit, {from: account, gas:3000000});
      }).then(function(result) {
        return App.markRented();
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },


  handleReturnDevice: function(event) {
    event.preventDefault();

    var deviceId = parseInt($(event.target).data('id'));
    var rentalInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];
      
      App.contracts.Rental.deployed().then(function(instance) {
        rentalInstance = instance;
        console.log(deviceId);
        return rentalInstance.returnDevice(deviceId, {from: account, gas:3000000});
      }).then(function(result) {
        return App.markRented();
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  bindEvents: function() {
    $(document).on('click', '.btn-rent', App.handleRent);
    $(document).on('click', '.btn-return', App.handleReturnDevice);
    $(document).on('click', '.btn-addDevice', App.handleAddDevice);
  }


};

$(function() {
  $(window).load(function() {
    App.init();
  });
});

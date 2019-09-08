 App = {
  
  wweb3Provider: null,
  contracts: {},
  account: '0x0',

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

  initContract: function() {
    $.getJSON("Manager.json", function(manager) {
      // Instantiate a new truffle contract from the artifact
      App.contracts.Manager = TruffleContract(manager);
      // Connect provider to interact with contract
      App.contracts.Manager.setProvider(App.web3Provider);
      App.listenForEvents();
      return App.render();
    });
  },

  render: function() {
    var managerInstance;

    // Load account data
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        console.log("Your account is :", account);
      }
    });

    App.contracts.Manager.deployed().then(function(instance) {
      managerInstance = instance;
      return managerInstance.getBorrowListLength();
    }).then(function(totalNumber){
      showResultInSequence(0,Number(totalNumber),managerInstance);
    }).catch(function(error){
      console.warn(error);
    });
  },

  postBorrow: function(){
    // var amount = $('#postBorrow_amount').val();

    var amount = $('#input_borrowAmount').val();
    var rate_type_string = $('#input_rateType').val();
    var rate_type = 0;
    var interest_Rate = $('#input_interestRate').val();

    if(rate_type_string=="daily"){
      rate_type=1;
    }else if(rate_type_string=="monthly"){
      rate_type=2;
    }else if(rate_type_string=="annually"){
      rate_type=3;
    }

    if(amount<=0){
      alert("Borrow amount should greater than 0");
    }else if(rate_type != 1 && rate_type != 2 && rate_type != 3){
      alert("Please select a valid rate type");
    }else if(interest_Rate<=0 || interest_Rate>=100){
      alert("Interest rate should within 0 to 100");
    }else{
      App.contracts.Manager.deployed().then(function(instance){
        return instance.postBorrow(amount,rate_type,{from: App.account});
      }).then(function(result){
        App.render();
      }).catch(function(err){
        console.error(err);
      });
    }
  },

  listenForEvents: function() {
    // App.contracts.Manager.deployed().then(function(instance) {
    //   console.log("I am listening");
    //   instance.generalEvent({}, {
    //     fromBlock: 0,
    //     toBlock: 'latest'
    //   }).watch(function(error, event) {
    //     console.log("event triggered", event)
    //     // App.render();
    //   });
    // });
  },
};



function showResultInSequence (index, end, instance){
  if(index>end){return;}
  instance.borrow_list(index).then(function(record){

    // console.log("Borrow len:",borrow_list);
    console.log("The list record: i - ",index," ; record - ",record[0],Number(record[1]),Number(record[2]),Number(record[3]));
    showResultInSequence(index+1,end,instance);
  });
};

$(function() {
  $(window).on('load',function() {
    App.init();
  });
});

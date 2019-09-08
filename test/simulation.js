var Manager = artifacts.require("./Manager.sol");

// // For reading .txt file code block
// var fs = require("fs");
// var text = fs.readFileSync("loan_request.txt").toString().split("\n");
// for (var i =0; i < text.length; i++) {
//   // console.log(text[i]);
// }

// var names = read("loan_request.txt").split("\n");

contract("Manager", function(){
  var managerInstance;
  var accounts = ["0x89F40fEC36e5F82f9A23e05375CAC6caCA4535fD","0xd8c699DDC0974969FDD9D428923EC1a13Cf3Cbc1","0x684CD17Aa918373F1EA2B5A6a80D8cBD16578565"];
  var fs = require("fs");
  var loan_request = fs.readFileSync("loan_request.txt").toString().split("\n");
  var lend_issued = fs.readFileSync("lend_issued.txt").toString().split("\n");
  var loan_term = fs.readFileSync("loan_term.txt").toString().split("\n");
  var interest_rate = fs.readFileSync("interest_rate.txt").toString().split("\n");
  var user_grade = fs.readFileSync("user_grade.txt").toString().split("\n");



  it("Check - deployed", function(){
    return Manager.deployed().then(function(instance){
      assert.equal(1,1);
    });
  });





  it("Check - Post Borrow Request 1", function(){
    return Manager.deployed().then(async function(instance){
      managerInstance = instance;
      for (var i =0; i < loan_request.length/10; i++) {
        // console.log(Math.floor(Number(loan_request[i])/166));
        // console.log(typeof(Math.floor(Number(loan_request[i])/166)));
        await managerInstance.postBorrow(Math.ceil(Number(loan_request[i])/166)*Math.pow(10,13),{from: accounts[0]});
      }
    }).then(async function(){

    }).then(function(flag){
      assert.equal(1,1);
    });
  });


  it("Check - get Borrow Record 1", function(){
    return Manager.deployed().then(async function(instance){
      managerInstance = instance;
      for (var i =0; i < loan_request.length/10; i++) {
        await managerInstance.getBorrowInfoFromBorrowList(i,{from: accounts[0]});
      }
    }).then(async function(){

    }).then(function(flag){
      assert.equal(1,1);
    });
  });


  it("Check - Lend Money Request 1", function(){
    return Manager.deployed().then(async function(instance){
      managerInstance = instance;
      for (var i =0; i < lend_issued.length/10; i++) {
        // console.log(Math.floor(Number(loan_request[i])/166));
        // console.log(typeof(Math.floor(Number(loan_request[i])/166)));
        await managerInstance.lendMoney(i,{from: accounts[1], value: Math.ceil(Number(lend_issued[i])/166)*Math.pow(10,13)});
      }
    }).then(async function(){

    }).then(function(flag){
      assert.equal(1,1);
    });
  });

  it("Check - Lend Money Request 1", function(){
    return Manager.deployed().then(async function(instance){
      managerInstance = instance;
      // for (var i =0; i < lend_issued.length/10; i++) {
        // console.log(Math.floor(Number(loan_request[i])/166));
        // console.log(typeof(Math.floor(Number(loan_request[i])/166)));
        await managerInstance.adminFunc({from: "0xCE8A5A4777d88aA0461bce51D166A1b75b3E31a8"});
      // }
    }).then(async function(){

    }).then(function(flag){
      assert.equal(1,1);
    });
  });

  it("Check - get Debt Record 1", function(){
    return Manager.deployed().then(async function(instance){
      managerInstance = instance;
      for (var i =0; i < lend_issued.length/100; i++) {
        await managerInstance.getDebtInfoFromDebtsList(i,{from: accounts[0]});
      }
    }).then(async function(){

    }).then(function(flag){
      assert.equal(1,1);
    });
  });

  it("Check - get Debt Record 1", function(){
    return Manager.deployed().then(async function(instance){
      managerInstance = instance;
      for (var i =0; i < lend_issued.length/10; i++) {
        await managerInstance.getDebtInfoFromDebtsList(i,{from: accounts[1]});
      }
    }).then(async function(){

    }).then(function(flag){
      assert.equal(1,1);
    });
  });

  it("Check - Pay Funded Loan 1", function(){
    return Manager.deployed().then(async function(instance){
      managerInstance = instance;
      for (var i =0; i < loan_request.length/100; i++) {
        // console.log(Math.floor(Number(loan_request[i])/166));
        // console.log(typeof(Math.floor(Number(loan_request[i])/166)));
        await managerInstance.payLoan(i,{from: accounts[0],value: Math.ceil(Number(loan_request[i])/166)*Math.pow(10,13)});
      }
    }).then(async function(){

    }).then(function(flag){
      assert.equal(1,1);
    });
  });

  it("Check - User Deposit Money 1", function(){
    return Manager.deployed().then(async function(instance){
      managerInstance = instance;
      for (var i =0; i < loan_request.length/100; i++) {
        // console.log(Math.floor(Number(loan_request[i])/166));
        // console.log(typeof(Math.floor(Number(loan_request[i])/166)));
        await managerInstance.deposit({from: accounts[2],value: 1*Math.pow(10,13)});
      }
    }).then(async function(){

    }).then(function(flag){
      assert.equal(1,1);
    });
  });

  it("Check - Get User Balance 1", function(){
    return Manager.deployed().then(async function(instance){
      managerInstance = instance;
      for (var i =0; i < loan_request.length/100; i++) {
        // console.log(Math.floor(Number(loan_request[i])/166));
        // console.log(typeof(Math.floor(Number(loan_request[i])/166)));
        await managerInstance.getBalance({from: accounts[0]});
      }
    }).then(async function(){

    }).then(function(flag){
      assert.equal(1,1);
    });
  });

  it("Check - Withdrawl Money 1", function(){
    return Manager.deployed().then(async function(instance){
      managerInstance = instance;
      for (var i =0; i < loan_request.length/100; i++) {
        // console.log(Math.floor(Number(loan_request[i])/166));
        // console.log(typeof(Math.floor(Number(loan_request[i])/166)));
        await managerInstance.withdrawl(Math.ceil(Number(loan_request[i])/166)*Math.pow(10,13),{from: accounts[0]});
      }
    }).then(async function(){

    }).then(function(flag){
      assert.equal(1,1);
    });
  });


  it("Check - Get User Balance 1", function(){
    return Manager.deployed().then(async function(instance){
      managerInstance = instance;
      for (var i =0; i < loan_request.length/100; i++) {
        // console.log(Math.floor(Number(loan_request[i])/166));
        // console.log(typeof(Math.floor(Number(loan_request[i])/166)));
        await managerInstance.getBalance({from: accounts[0]});
      }
    }).then(async function(){

    }).then(function(flag){
      assert.equal(1,1);
    });
  });






});



// it("allows a voter to cast a vote", function() {
//     return Election.deployed().then(function(instance) {
//       electionInstance = instance;
//       candidateId = 1;
//       return electionInstance.vote(candidateId, { from: accounts[0] });
//     }).then(function(receipt) {
//       return electionInstance.voters(accounts[0]);
//     }).then(function(voted) {
//       assert(voted, "the voter was marked as voted");
//       return electionInstance.candidates(candidateId);
//     }).then(function(candidate) {
//       var voteCount = candidate[2];
//       assert.equal(voteCount, 1, "increments the candidate's vote count");
//     })
//   });
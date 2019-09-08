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



  for (var trail = 0; trail <= 5; trail++) {
    start_index = trail*loan_request.length/10;
    end_index = (trail+1)*loan_request.length/10;

    it("Check - Post Borrow Request 1", function(){
      return Manager.deployed().then(async function(instance){
        managerInstance = instance;
        for (var i = start_index; i < end_index; i++) {
          await managerInstance.postBorrow(Math.ceil(Number(loan_request[i])/166)*Math.pow(10,13),{from: accounts[0]});
        }
      }).then(function(flag){
        assert.equal(1,1);
      });
    });
  }


});





const Manager = artifacts.require("Manager");

const ProfileManager = artifacts.require("UserProfile");

// deploy the contract
module.exports = function(deployer) {
  deployer.deploy(Manager);
  deployer.deploy(ProfileManager);
};

// // deploy the contract
// module.exports = function(deployer) {
//   deployer.deploy(ProfileManager);
// };

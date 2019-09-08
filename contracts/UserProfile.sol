pragma solidity ^0.5.0;

contract UserProfile {

	string userName = "1234";

	mapping(address => string []) user_name;
	mapping(string => string []) user_name_public;

	mapping(address => string []) email_contact;
	mapping(string => string []) email_contact_public;

	mapping(address => string []) profile_pic;
	mapping(string => string []) profile_pic_public;

	// mapping(address => string []) public proposals;
	// mapping(string => string []) public proposals_public;

	mapping(address => string []) income_proof;
	mapping(string => string []) income_proof_public;

	// function getUserInfo() public view returns(string memory profile_pic, string memory user_name, string memory email, string memory income_proof, uint256 profile_length, uint256 name_length, uint256 email_length, uint256 proposals_length, uint256 income_length ){
		
	// }

	function updateUserName(string memory addr,string memory name) public returns(bool){
	    user_name[msg.sender].push(name);
	    user_name_public[addr].push(name);
	    // userName = name;
	    return(true);
	}
	function getUserName(string memory addr) public view returns(string memory){
	    return user_name_public[addr][user_name_public[addr].length-1];
	    // return user_name[msg.sender][user_name[msg.sender].length-1];
	}
	// function getUserNameByOthers(string memory addr) public view returns(string memory){
	//     return user_name[addr][user_name[addr].length-1];
	// }


	function updateEmail(string memory addr,string memory email) public returns(bool){
	    email_contact[msg.sender].push(email);
	    email_contact_public[addr].push(email);
	    return(true);
	}
	function getEmail(string memory addr) public view returns(string memory){
		return email_contact_public[addr][email_contact_public[addr].length-1];
	    // return email_contact[msg.sender][email_contact[msg.sender].length-1];
	}
	// function getEmailByOthers(string memory addr) public view returns(string memory){
	//     return email_contact[addr][email_contact[addr].length-1];
	// }


	function updateProfilePic(string memory addr,string memory ipfsHash) public returns(bool){
	    profile_pic[msg.sender].push(ipfsHash);
	    profile_pic_public[addr].push(ipfsHash);
	    return(true);
	}
	function getProfilePic(string memory addr) public view returns(string memory){
	    return profile_pic_public[addr][profile_pic_public[addr].length-1];
	    // return profile_pic[msg.sender][profile_pic[msg.sender].length-1];
	}
	// function getProfilePicByOthers(string memory addr) public view returns(string memory){
	//     return profile_pic[addr][profile_pic[addr].length-1];
	// }


	// function addProposal(string memory addr,string memory ipfsHash) public returns(bool){
	//     proposals[msg.sender].push(ipfsHash);
	//     return(true);
	// }
	// function getProposalsLength(string memory addr,string memory addr) public view returns(uint256){
	//     return(proposals[msg.sender].length);
	// }


	function updateIncomeProof(string memory addr,string memory ipfsHash) public returns(bool){
	    income_proof[msg.sender].push(ipfsHash);
	    income_proof_public[addr].push(ipfsHash);
	    return(true);
	}
	function getIncomeProof(string memory addr) public view returns(string memory){
		return income_proof_public[addr][income_proof_public[addr].length-1];
	    // return income_proof[msg.sender][income_proof[msg.sender].length-1];
	}
	// function getIncomeProofByOthers(string memory addr) public view returns(string memory){
	//     return income_proof[addr][income_proof[addr].length-1];
	// }
}
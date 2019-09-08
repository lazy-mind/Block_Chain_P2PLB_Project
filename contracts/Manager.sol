pragma solidity ^0.5.0;

contract Manager {
    
    /*
    Struct of a Borrow
    When user want to borrow money from other user
    Manager will create a Borrow struct for him
    Other user can lend money according to Borrow struct
    */
    struct Borrow{
    	uint256 index;			//Index of this Borrow in borrow_list
    	uint256 debtIndex;		//Index of the Debt (contain this Borrow) in debts_list

    	uint256 lenderNumber;	//Number of lender, maximum 100

        uint256 interestRate;   //Interest rate of this Borrow, if 30 means 30%, if 1 means 1%

        address borrowerAddress;//Borrower address

        uint256 amountRequest;	//The request amount for borrower, initial amount
        uint256 amountToPay;	//The amount remains to be paid after the borrower get money from lenders

        uint256 lastRepayTime;	//Last repay time of this Borrow, it is timestamp
        uint256 nextRepayTime;	//Next repay time of this Borrow, it is timestamp
        
        bool isLend;			//default is false, after lenderNumber == 100 or amountRequest == 0, it becomes true
        bool isPayOff;			//If user has paid off the amountToPay in this Borrow, which means amountToPay == 0, then isPayOff = true

        uint256 initialRequest;
    }
    
    
    /*
    Struct of a Lend
    When user want to lend money to a specific Borrow
    Manager will create a Lend struct for him
    */
    struct Lend{
    	uint256 index;			//Index of this Lend in lend_list
    	uint256 debtIndex;		//Index of the Debt (contain this Lend) in debts_list

        address lenderAddress;	//Lender address

        uint256 lendAmount;		//The amount that Lender initially lend to borrower
        uint256 amountRemain;	//The remain amount that the borrow should repay to the lender

        bool isPayOff;			//If borrower has paid off thi Lend's amountRemain, which means amountRemain == 0, then isPayOff = true

        uint256 initialLend;
    }
    
    
    /* 
    Struct of a Debt
    When both Lend and Borrow struct are created
    Manager will create a Debt struct
    Then bind the Lends index and Borrow index together into a Debt struct
    */
    struct Debt{
	    uint256 index;			//Index of this Debt in debts_list
	    uint256 borrowIndex;	//Index of the Borrow in this Debt in borrow_list
	    uint256[] lendIndex;	//Index list, which contains all the index of Lends in lend_list
    }


    Debt[] debts_list;		//An array to store all the Debt
    Borrow[] borrow_list;	//An array to store all the Borrow
	Lend[] lend_list;		//An array to store all the Lend
    

    //A mapper to stroe all the indexs of debts_list which are connected to this user address
	mapping(address => uint256 []) user_debts_index; 
	

	//A mapper to stroe balances of this user address
	mapping(address => uint256) balances;
	

	//A mapper to stroe user credit of this user address
	mapping(address => uint256) credit;


	//A list to save the user who has credit
	address[] hasCreditUser;


	//This variable is used to count the number of times that user's credit > INCREASE_LINE
	mapping(address => uint256) above_increase_times;
	mapping(address => uint256) below_standard_times;


	//Constant value of deposit that will increase user's credit
	uint256 constant INCREASE_LINE = 10**19;
	uint256 constant STANDARD_LINE = 5**18;


	//Constant value of day of month
	uint256 constant DAY_OF_MONTH = 30;


	//Constant value of one month
	// uint256 constant ONE_MONTH = 60 * 60 * 24 * DAY_OF_MONTH;
	uint256 constant ONE_MONTH = 1 * 1 * 1 * DAY_OF_MONTH;



	/*
	Description:
	Admin function, just call it every day from admin account.
	Modify the codes to make sure it is admin who call this function.
	 */
	function adminFunc() public returns(bool){

		//Check if it is admin who calls this function from here:

		//User credit management from here:
		for(uint256 i = 0; i < hasCreditUser.length; i ++){
			address user = hasCreditUser[i];

			if(balances[user] >= INCREASE_LINE){
				below_standard_times[user] = 0;
				above_increase_times[user] += 1;
				if(above_increase_times[user] == 30){
					increaseUserCredit(user);
					above_increase_times[user] = 0;
				}
			}
			else{
				above_increase_times[user] = 0;
				if(balances[user] < STANDARD_LINE){
					below_standard_times[user] += 1;
					if(below_standard_times[user] == 30){
						if(credit[user] > 11){
							decreaseUserCredit(user);
						}
						below_standard_times[user] = 0;
					}
				}
				else{
					below_standard_times[user] = 0;
				}
			}
		}


		//Auto repay from here:
		for(uint256 i = 0; i < debts_list.length; i ++){
			//Get the Debt and corresponding Borrow
			Debt storage debt = debts_list[i];
			Borrow storage borrow = borrow_list[debt.borrowIndex];

			//Jump to next index if this Borrow is already payoff or It has not reached the next repay time
			if(borrow.isPayOff || (borrow.nextRepayTime > block.timestamp)){
				continue;
			}

			//Now current Borrow exceeds the next repayment time
			uint256 accumulatedValue = calculateAccumulatedValue(borrow.amountToPay, borrow.interestRate, borrow.lastRepayTime, block.timestamp);
			uint256 repayAmount = ((accumulatedValue / 10) == 0) ? accumulatedValue : (accumulatedValue / 10);
			if(balances[borrow.borrowerAddress] < repayAmount){
				decreaseUserCredit(borrow.borrowerAddress);
			}
			else{
				autoPayLoanByDeposit(repayAmount, i);
			}
		}
	}
	

	/*
	Description:
	When a user want to borrow money
	They could call this function and input the require amount
	Manager will store the new Borrow to borrow_list
	
	Input:
	require_amount: Amount that user wants to borrow, unit is Wei

	Return:
	bool: success -> true; fail -> false
	*/
	function postBorrow(uint256 require_amount) public returns(bool){
		//Check if this user has the user credit
		updateUserCredit(msg.sender);
	    //Get the interest rate according to user's credit
	    uint256 interest_rate = calculateInterestRate(msg.sender);
	    
	    //We require user has a credit >= 3, if not satisfy, this user is banned to borrow money
	    require(credit[msg.sender] >= 3);
	    //We require the amount that user input should > 0  
	    require(require_amount > 0);
	    //We require the amount that user input should <= maximum amount that he can borrow
	    //require(require_amount <= getUserMaximumBorrowAmount());

	    //Create the borrow
	    Borrow memory borrow = Borrow(borrow_list.length, 0, 0, interest_rate, msg.sender, require_amount, 0, 0, 0, false, false, require_amount);
	    
	    //Put the borrow into borrow_list
	    borrow_list.push(borrow);
	    
	    return(true);
	}


	/*
	Description:
	User lend money to borrower from his wallet
	When user find a specific Borrow to lend
	Firstly he should write down the index of that Borrow
	Then he can call this function to lend money from the user's wallet
	Note: when calling this function, remember to put the amount of transfer value(in user's wallet)
	
	Input:
	index: Index of the Borrow in borrow_list

	Return:
	bool: success -> true; fail -> false
	*/
	function lendMoney(uint256 index) payable public returns(bool){
		//Get the Borrow from borrow_list
	    Borrow storage borrow = borrow_list[index];
	    
	    //Require this user and borrower are not the same
	    require(msg.sender != borrow.borrowerAddress);
	    //Require the money that this user lend is > 0
	    require(msg.value > 0);
	    //Require the money that this user lend is <= the money thay the borrower request
	    require(msg.value <= borrow.amountRequest);
	    
	    borrow.amountRequest -= msg.value;
	    borrow.amountToPay += msg.value;


	    if(borrow.lenderNumber > 0){
	        Debt storage debt_exist = debts_list[borrow.debtIndex];
	        
	        debt_exist.lendIndex[borrow.lenderNumber] = lend_list.length;
	        Lend memory lend = Lend(lend_list.length, borrow.debtIndex, msg.sender, msg.value, msg.value, false, msg.value);
	        user_debts_index[lend.lenderAddress].push(borrow.debtIndex);

	        lend_list.push(lend);

	        borrow.lenderNumber += 1;
	    }
	    else{
	    	borrow.lastRepayTime = block.timestamp;
	    	borrow.nextRepayTime = borrow.lastRepayTime + ONE_MONTH;

	        uint256[] memory lend_index_list = new uint256[](100);

	        Debt memory debt = Debt(debts_list.length, index, lend_index_list);
	        debt.lendIndex[borrow.lenderNumber] = lend_list.length;
	        
	        user_debts_index[borrow.borrowerAddress].push(debts_list.length );
	        user_debts_index[msg.sender].push(debts_list.length);

	        Lend memory lend = Lend(lend_list.length, debts_list.length, msg.sender, msg.value, msg.value, false, msg.value);
	        borrow.debtIndex = debts_list.length;

	        debts_list.push(debt);
	        lend_list.push(lend);

	        borrow.lenderNumber += 1;
	    }
	    
	    
	    if((borrow.lenderNumber == 100) || (borrow.amountRequest == 0)){
	        borrow.isLend = true;
	    }    
	    
	    //Add the balances of borrower
	    balances[borrow.borrowerAddress] += msg.value;
	    
	    return(true);
	}


	/*
	Description:
	User lend money to a borrower from his balance
	When user find a specific Borrow to lend
	Firstly he should write down the index of that Borrow
	Then he can call this function to lend money from the user's balances
	Note: when calling this function, remember to put the amount as an input variable
	
	Input:
	amount:	Amount that the user wants to lend (unit: Wei)
	index:	Index of the Borrow in borrow_list

	Return:
	bool: success -> true; fail -> false
	*/
	function lendMoneyByDeposit(uint256 amount, uint256 index) public returns(bool){
		//Get the Borrow from borrow_list
	    Borrow storage borrow = borrow_list[index];
	    
	    //Require this user and borrower are not the same
	    require(msg.sender != borrow.borrowerAddress);
	    //Require the money that this user lend is > 0
	    require(amount > 0);
	    //Require the money that this user lend is <= the money thay the borrower request
	    require(amount <= borrow.amountRequest);
	    //Require the money that this user lend is <= the balance of this user
	    require(amount <= balances[msg.sender]);

	    
	    borrow.amountRequest -= amount;
	    borrow.amountToPay += amount;


	    if(borrow.lenderNumber > 0){

	    	Debt storage debt_exist = debts_list[borrow.debtIndex];
	        
	        debt_exist.lendIndex[borrow.lenderNumber] = lend_list.length;
	        Lend memory lend = Lend(lend_list.length, borrow.debtIndex, msg.sender, amount, amount, false, amount);
	        user_debts_index[lend.lenderAddress].push(borrow.debtIndex);

	        lend_list.push(lend);

	        borrow.lenderNumber += 1;
	        
	    }
	    else{

	    	borrow.lastRepayTime = block.timestamp;
	    	borrow.nextRepayTime = borrow.lastRepayTime + ONE_MONTH;

	    	uint256[] memory lend_index_list = new uint256[](100);

	        Debt memory debt = Debt(debts_list.length, index, lend_index_list);
	        debt.lendIndex[borrow.lenderNumber] = lend_list.length;
	        
	        user_debts_index[borrow.borrowerAddress].push(debts_list.length );
	        user_debts_index[msg.sender].push(debts_list.length);

	        Lend memory lend = Lend(lend_list.length, debts_list.length, msg.sender, amount, amount, false, amount);
	        borrow.debtIndex = debts_list.length;

	        debts_list.push(debt);
	        lend_list.push(lend);

	        borrow.lenderNumber += 1;

	    }
	    
	    
	    if((borrow.lenderNumber == 100) || (borrow.amountRequest == 0)){
	        borrow.isLend = true;
	    }    
	    
	    //Add the balances of borrower
	    balances[borrow.borrowerAddress] += amount;
	    //Deduce the balances of lender
	    balances[msg.sender] -= amount;
	    
	    return(true);
	}


	/*
	Description:
	Use this function to calculate the accumulated value of this time stampe
	You should call this function to show the user the accumulated value of a Borrow before he repays money
	
	Input:
	amount_to_pay:		amount to pay of a Borrow, which is borrow.amountToPay
	interest_rate:		interest rate of a Borrow, which is borrow.interestRate
	last_repay_time:	last repay time of a Borrow, which is borrow.lastRepayTime
	current_timestamp:	current time stamp

	Return:
	accumulatedValue: the accumulatedValue of current timestamp
	*/
	function calculateAccumulatedValue(uint256 amount_to_pay, uint256 interest_rate, uint256 last_repay_time, uint256 current_timestamp) public pure returns(uint256 accumulatedValue){
		uint256 number_of_month = (current_timestamp - last_repay_time) / ONE_MONTH;
		uint256 interest = ((number_of_month * (((amount_to_pay * interest_rate) / 100) / 12)) == 0) ? 1 : (number_of_month * (((amount_to_pay * interest_rate) / 100) / 12));
		return(amount_to_pay + interest);
	}


	/*
	Description:
	User can call this function to repay the debt
	The money is deduced from his wallet
	Note: before calling this function, you should call the calculateAccumulatedValue function to get the new amount_to_pay that the user needs to repay
		  show the new amount_to_pay to the user, and require him to repay minimum 10% of the new amount_to_pay, if new amount_to_pay is < 10,
		  then user should pay the value of new amount_to_pay.
	Note: when calling this function, remember to put the amount of transfer value(in user's wallet)
	
	Input:
	debtIndex: Index of the Debt in debt_list

	Return:
	bool: success -> true; fail -> false
	*/
	function payLoan(uint256 debtIndex) payable public returns(bool){
	    
	    Debt storage debt = debts_list[debtIndex]; //Get the debt
	    
	    Borrow storage borrow = borrow_list[debt.borrowIndex];

	    address borrower = borrow.borrowerAddress;
	    
	    require(borrower == msg.sender); //We require the borrower is msg.sender here

	    uint256 newAmountToPay = calculateAccumulatedValue(borrow.amountToPay, borrow.interestRate, borrow.lastRepayTime, block.timestamp);
	    uint256 oldAmount = borrow.amountToPay;
	    borrow.amountToPay = newAmountToPay;

	    require(msg.value <= borrow.amountToPay); //We also require the msg.value should be less than owed money
	    //Require minimum repay amount = new amount_to_pay * 10%
	    uint256 minimumAmount = ((newAmountToPay / 10) == 0) ? newAmountToPay : (newAmountToPay / 10);
	    require(msg.value >= minimumAmount);
	    
	    borrow.amountToPay -= msg.value;
	    for(uint256 i = 0; i < borrow.lenderNumber; i ++){
	    	Lend storage lend = lend_list[debt.lendIndex[i]];
	    	if(!lend.isPayOff){
	    		lend.amountRemain = division(lend.amountRemain, oldAmount, 3) * newAmountToPay / 1000;
	    		uint256 repayValue = (lend.amountRemain == 0) ? 0 : (msg.value * division(lend.amountRemain, newAmountToPay, 3) / 1000);
	    		if(repayValue >= lend.amountRemain){
	    			lend.amountRemain = 0;
	    		}
	    		else{
	    			lend.amountRemain -= repayValue;
	    		}
	    		balances[lend.lenderAddress] += repayValue;
	    		if(lend.amountRemain == 0){
	    			lend.isPayOff = true;
	    		}
	    	}
	    }
	    
	    borrow.lastRepayTime = block.timestamp;

	    //If the debt is paid off
	    if(borrow.amountToPay == 0){
	        borrow.isPayOff = true;
	        borrow.nextRepayTime = 0;
	    }
	    else{
	    	borrow.nextRepayTime +=  ONE_MONTH;
	    }
	    
	    return(true);
	}


	/*
	Description:
	User can call this function to repay the debt
	The money is deduced from his balance
	Note: before calling this function, you should call the calculateAccumulatedValue function to get the new amount_to_pay that the user needs to repay
		  show the new amount_to_pay to the user, and require him to repay minimum 10% of the new amount_to_pay, if new amount_to_pay is < 10,
		  then user should pay the value of new amount_to_pay.
	Note: when calling this function, remember to put the amount as an input variable
	
	Input:
	amount:		amount that the user wants to repay (require >= 10% of the new amountToPay)
	debtIndex:	Index of the Debt in debt_list

	Return:
	bool: success -> true; fail -> false
	*/
	function payLoanByDeposit(uint256 amount, uint256 debtIndex) public returns(bool){
		
		Debt storage debt = debts_list[debtIndex]; //Get the debt
	    
	    Borrow storage borrow = borrow_list[debt.borrowIndex];

	    address borrower = borrow.borrowerAddress;
	    
	    require(borrower == msg.sender); //We require the borrower is msg.sender here
	    require(balances[msg.sender] >= amount); //Require caller has enough balances

	    uint256 newAmountToPay = calculateAccumulatedValue(borrow.amountToPay, borrow.interestRate, borrow.lastRepayTime, block.timestamp);
	    uint256 oldAmount = borrow.amountToPay;
	    borrow.amountToPay = newAmountToPay;

	    require(amount <= borrow.amountToPay); //We also require the msg.value should be less than owed money
	    //Require minimum repay amount = new amount_to_pay * 10%
	    uint256 minimumAmount = ((newAmountToPay / 10) == 0) ? newAmountToPay : (newAmountToPay / 10);
	    require(amount >= minimumAmount);
	    
	    borrow.amountToPay -= amount;
	    for(uint256 i = 0; i < borrow.lenderNumber; i ++){
	    	Lend storage lend = lend_list[debt.lendIndex[i]];
	    	if(!lend.isPayOff){
	    		lend.amountRemain = division(lend.amountRemain, oldAmount, 3) * newAmountToPay / 1000;
	    		uint256 repayValue = (lend.amountRemain == 0) ? 0 : (amount * division(lend.amountRemain, newAmountToPay, 3) / 1000);
	    		if(repayValue > lend.amountRemain){
	    			lend.amountRemain = 0;
	    		}
	    		else{
	    			lend.amountRemain -= repayValue;
	    		}
	    		balances[lend.lenderAddress] += repayValue;
	    		if(lend.amountRemain == 0){
	    			lend.isPayOff = true;
	    		}
	    	}
	    }

	    borrow.lastRepayTime = block.timestamp;

	    //If the debt is paid off
	    if(borrow.amountToPay == 0){
	        borrow.isPayOff = true;
	        borrow.nextRepayTime = 0;
	    }
	    else{
	    	borrow.nextRepayTime += ONE_MONTH;
	    }

	    balances[msg.sender] -= amount;
	    
	    return(true);
	}


	/*
	Description:
	Deposit money to contract, after successfully deposit, money value will be shown in user's balance

	Return:
	bool: success -> true; fail -> false
	*/
	function deposit() payable public returns(bool){

		updateUserCredit(msg.sender);

        balances[msg.sender] += msg.value;

        return(true);
    }


    /*
    Description:
    Get the user's balance

    Return:
    user's balance value
	*/
	function getBalance() public view returns(uint256){
	    return balances[msg.sender];
	} 


	/*
	Description:
	Withdraw money from smart contract to current user's wallet

	Input:
	amount: amount that the user wants to withdraw, we require amount <= value in user's balance

	Return:
	bool: success -> true; fail -> false
	*/
	function withdrawl(uint256 amount) public returns(bool){
	    address payable caller = msg.sender;
	    require(amount <= balances[msg.sender]);
		caller.transfer(amount);
		balances[msg.sender] -= amount;
		
		return(true);
	}


	/*
	Description:
	Get the maximum amount that the user can borrow

	Return:
	uint256: maximum amount
	*/
	function getUserMaximumBorrowAmount() public view returns(uint256){
		return((credit[msg.sender] == 0) ? (10**19) : (credit[msg.sender] * (10**18)));
	}


	/*
	Description:
	Only with those users that posted a Borrow before or deposit money before will return a correct credit
	Otherwise it will return 0, if it returns 0, just show 10 (initial credit) to user

	Return:
	uint256: credit of user
	*/
	function getUserCredit() public view returns(uint256){
		return((credit[msg.sender] == 0) ? 10 : credit[msg.sender]);
	}
	

	/*
	Description:
	Get the length of the borrow_list

	Return:
	length: length of borrow_list
	*/
	function getBorrowListLength() public view returns(uint256 length){
		return(borrow_list.length);
	}


	/*
	Description:
	Get the information of a Borrow in borrow_list

	Input:
	index: index of a Borrow in borrow_list

	Return:
	All fields of a Borrow
	*/
	function getBorrowInfoFromBorrowList(uint256 index) public view 
		returns(uint256 borrow_index, uint256 debt_index, uint256 lenderNumber, uint256 interest_rate, address borrower, 
				uint256 amount_request, uint256 amount_to_pay, uint256 last_repay_time, uint256 next_repay_time,
				bool is_lend, bool is_pay_off, uint256 initial_request){

	    //We require index is less than the length of borrow_list here
	    require(index < borrow_list.length);
	    
	    //Get the required Borrow from borrow_list
	    Borrow storage borrow = borrow_list[index];
	    
	    //Return the information
	    return(borrow.index, borrow.debtIndex, borrow.lenderNumber, borrow.interestRate, borrow.borrowerAddress,
	    	borrow.amountRequest, borrow.amountToPay, borrow.lastRepayTime, borrow.nextRepayTime, borrow.isLend, borrow.isPayOff, borrow.initialRequest);
	}


	/*
	Description:
	Get the length of the lend_list

	Return:
	length: length of lend_list
	*/
	function getLendListLength() public view returns(uint256 length){
		return(lend_list.length);
	}


	/*
	Description:
	Get the information of a Lend in lend_list

	Input:
	index: index of a Lend in lend_list

	Return:
	All fields of a Lend
	*/
	function getLendInfoFromBorrowList(uint256 index) public view
		returns(uint256 lend_index, uint256 debt_index, address lenderAddress, uint256 lend_amount, uint256 amount_remain, bool is_pay_off, uint256 initial_lend){

		//We require index is less than the length of lend_list here
	    require(index < lend_list.length);

	    //Get the required Lend from lend_list
		Lend storage lend = lend_list[index];

		//Return the information
		return(lend.index, lend.debtIndex, lend.lenderAddress, lend.lendAmount, lend.amountRemain, lend.isPayOff, lend.initialLend);
	}


	/*
	Description:
	Get the length of the debts_list

	Return:
	length: length of debts_list
	*/
	function getDebtListLength() public view returns(uint256 length){
		return(debts_list.length);
	}


	/*
	Description:
	Get the information of a Debt in debts_list

	Input:
	index: index of a Debt in debts_list

	Return:
	borrow_index: index of the corresponding Borrow in borrow_list
	lend_index: index list of all the corresponding Lend in lend_list
	lender_number: number of the lenders (length of the lend_index)
	*/
	function getDebtInfoFromDebtsList(uint256 index) public view returns(uint256 borrow_index, uint256[] memory lend_index, uint256 lender_number){

		//We require index is less than the length of debts_list here
	    require(index < debts_list.length);

	    //Get the required Debt from debts_list
		Debt storage debt = debts_list[index];

		//Get the corresponding Borrow from borrow_list
		Borrow storage borrow = borrow_list[debt.borrowIndex];

    	uint256 count = borrow.lenderNumber;
    	uint256[] memory index_list = new uint256[](count);

    	//Put all the indexs into index_list
	    for(uint256 i = 0; i < count; i ++){
	        index_list[i] = debt.lendIndex[i];
	    }

	    return(debt.borrowIndex, index_list, count);
	}


	/*
	Description:
	Get an array of all the Debt's index in debts_list of this user

	Return:
	debts_index_list: a list that contains all the Debt's index of this user
	length: length of debts_index_list 
	*/
	function getUserDebtIndexList() public view returns(uint256[] memory debts_index_list, uint256 length){
	    uint256 count = user_debts_index[msg.sender].length;
	    uint256[] memory index_list = new uint256[](count);
	    
	    //Put all the indexs that belong to msg.sender into index_list
	    for(uint256 i = 0; i < count; i ++){
	        index_list[i] = user_debts_index[msg.sender][i];
	    }
	    
	    return(index_list, index_list.length);
	}
	
	
	/*
	Description:
	Get the user role of a Debt.
	
	Input:
	debtIndex: index of a Debt in debts_list

	Return:
	user_role: 1 -> this user is borrower in this Debt
			   2 -> this user is lender in this Debt
	 */
	function getUserDebtRole(uint256 debtIndex) public view returns(uint256 user_role){
	    Borrow storage borrow = borrow_list[debts_list[debtIndex].borrowIndex];
	    
	    uint256 role = 2;
	    if(borrow.borrowerAddress == msg.sender){
	        role = 1;
	    }
	    
	    return(role);
	}
	
	
	function updateUserCredit(address user) private{
	    if(credit[user] == 0){
	    	hasCreditUser.push(user);
	        credit[user] = 10;
	    }
	}
	
	function decreaseUserCredit(address user) private{
	    if(credit[user] > 1){
	        credit[user] -= 1;
	    }
	}
	
	function increaseUserCredit(address user) private{
	    credit[user] += 1;
	}
	

	function calculateInterestRate(address user) public view returns(uint256 interest_rate){
		// updateUserCredit(user);
	    uint256 user_credit = credit[user];
	    uint256 rate = 0;

	    if(user_credit > 10){
            if(12 - (user_credit - 10) <= 1){
                rate = 1;
            }
            else{
                rate = 12 - (user_credit - 10);
            }
        }
        else if(user_credit == 10){
            rate = 12;
        }
        else{
            rate = 12 + (10 - user_credit);
        }
	    
	    if(user_credit==0){
	    	rate = 12;
	    	return(rate);
	    }

	    return(rate);
	}


	function autoPayLoanByDeposit(uint256 amount, uint256 debtIndex) private returns(bool){
		
		Debt storage debt = debts_list[debtIndex]; //Get the debt
	    
	    Borrow storage borrow = borrow_list[debt.borrowIndex];

	    uint256 newAmountToPay = calculateAccumulatedValue(borrow.amountToPay, borrow.interestRate, borrow.lastRepayTime, block.timestamp);
	    uint256 oldAmount = borrow.amountToPay;
	    borrow.amountToPay = newAmountToPay;

	    borrow.amountToPay -= amount;

	    for(uint256 i = 0; i < borrow.lenderNumber; i ++){
	    	Lend storage lend = lend_list[debt.lendIndex[i]];
	    	if(!lend.isPayOff){
	    		lend.amountRemain = division(lend.amountRemain, oldAmount, 3) * newAmountToPay / 1000;
	    		uint256 repayValue = (lend.amountRemain == 0) ? 0 : (amount * division(lend.amountRemain, newAmountToPay, 3) / 1000);
	    		if(repayValue > lend.amountRemain){
	    			lend.amountRemain = 0;
	    		}
	    		else{
	    			lend.amountRemain -= repayValue;
	    		}
	    		balances[lend.lenderAddress] += repayValue;
	    		if(lend.amountRemain == 0){
	    			lend.isPayOff = true;
	    		}
	    	}
	    }

	    borrow.lastRepayTime = block.timestamp;

	    //If the debt is paid off
	    if(borrow.amountToPay == 0){
	        borrow.isPayOff = true;
	        borrow.nextRepayTime = 0;
	    }
	    else{
	    	borrow.nextRepayTime += ONE_MONTH;
	    }

	    balances[borrow.borrowerAddress] -= amount;
	    
	    return(true);
	}

	
	/*
	Description:
	This function is used to achieve division in solidity

	Return:
	quotient: the division result.
	 */
	function division(uint256 numerator, uint256 denominator, uint256 precision) private pure returns(uint256 quotient) {
         return numerator * ( 10**precision ) / denominator;
	}

}

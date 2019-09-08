
header_str = `
	<header class="header">
		<div class="container">
			<div class="row">
				<div class="col">
					<div class="header_content d-flex flex-row align-items-center justify-content-start">
						<div class="logo">
							<a href="index.html"><img src="images/trust_lend_logo.png" alt=""></a>
						</div>
						<nav class="main_nav">
							<ul>
								<li id="header_tab_1"><a href="index.html">Home</a></li>
								<li id="header_tab_2"><a href="borrow.html">Borrow</a></li>
								<li id="header_tab_3"><a href="lend.html">Lend</a></li>
								<li id="header_tab_4"><a href="wallet.html">My Wallet</a></li>
								<li id="header_tab_5"><a href="contact.html">Setting</a></li>
							</ul>
						</nav>
						<div class="phone_num ml-auto">
							<div class="phone_num_inner">
								<img src="images/icon_5.png" alt=""><span id="header_user_address">User: ...</span>
							</div>
						</div>
						<div class="hamburger ml-auto"><i class="fa fa-bars" aria-hidden="true"></i></div>
					</div>
				</div>
			</div>
		</div>
	</header>
`;

logo_str = `
	<div><img src="images/trust_lend_logo.png" alt=""></div>
`;

menu_item_str = `
	<li class="menu_item"><a href="index.html">Home</a></li>
	<li class="menu_item"><a href="borrow.html">Borrow</a></li>
	<li class="menu_item"><a href="lend.html">Lend</a></li>
	<li class="menu_item"><a href="wallet.html">My Wallet</a></li>
	<li class="menu_item"><a href="contact.html">Contact</a></li>
`;

menu_str = `
	<div class="menu trans_500">
		<div class="menu_content d-flex flex-column align-items-center justify-content-center text-center">
			<div class="menu_close_container"><div class="menu_close"></div></div>
			<div class="logo menu_logo">
				<a href="#">
					<div class="logo_container d-flex flex-row align-items-start justify-content-start">
						<div class="logo_image"><div><img src="images/trust_lend_logo.png" alt=""></div></div>
					</div>
				</a>
			</div>
			<ul>
				<li><a href="index.html">Home</a></li>
				<li><a href="borrow.html">Borrow</a></li>
				<li><a href="lend.html">Lend</a></li>
				<li><a href="wallet.html">My Wallet</a></li>
				<li><a href="contact.html">Setting</a></li>
			</ul>
		</div>
		<div class="menu_phone"><span>call us: </span>9604 2093</div>
	</div>
`;

footter_str = `
	<div class="cr"><!-- Link back to Colorlib can't be removed. Template is licensed under CC BY 3.0. -->
	Copyright &copy;<script>document.write(new Date().getFullYear());</script> All rights reserved | This template is made with <i class="fa fa-heart-o" aria-hidden="true"></i> by <a href="https://colorlib.com" target="_blank">Colorlib</a>
	<!-- Link back to Colorlib can't be removed. Template is licensed under CC BY 3.0. -->
	</div>

	<div class="footer_nav">
		<ul>
			<li><a href="index.html">Home</a></li>
				<li><a href="borrow.html">Borrow</a></li>
				<li><a href="lend.html">Lend</a></li>
				<li><a href="wallet.html">My Wallet</a></li>
				<li><a href="contact.html">Setting</a></li>
		</ul>
	</div>
	<div class="footer_phone ml-auto"><span>call us: </span>9604 2093</div>
`;

document.write(header_str);

// App_header = {
// 	  wweb3Provider: null,
// 	  contracts: {},
// 	  account: '0x0',

// 	  init: function() {
// 	    return App_header.initWeb3();
// 	  },

// 	  initWeb3: function() {
// 	    if (typeof web3 !== 'undefined') {
// 	      // If a web3 instance is already provided by Meta Mask.
// 	      App_header.web3Provider = web3.currentProvider;
// 	      web3 = new Web3(web3.currentProvider);
// 	    } else {
// 	      // Specify default instance if no web3 instance provided
// 	      App_header.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
// 	      web3 = new Web3(App_header.web3Provider);
// 	    }
// 	    return App_header.initContract();
// 	  },

// 	  initContract: function() {
// 	    $.getJSON("Manager.json", function(manager) {
// 	      // Instantiate a new truffle contract from the artifact
// 	      App_header.contracts.Manager = TruffleContract(manager);
// 	      // Connect provider to interact with contract
// 	      App_header.contracts.Manager.setProvider(App_header.web3Provider);
// 	      return App_header.render();
// 	    });
// 	  },

// 	  render: function() {
// 	    var managerInstance;

// 	    // Load account data
// 	    web3.eth.getCoinbase(function(err, account) {
// 	      if (err === null) {
// 	        App_header.account = account;
// 	        console.log("Current ccount is :", account);
// 	        $('#header_user_address').html("User : "+account.substring(0,4)+` ... `+account.substring(account.length-5,account.length));
// 	      }
// 	    });
// 	  },
// };

// App_header.init();
// document.write(menu_str);

// $('#logo_js_fill_div').html(logo_str);
// $('#menu_item_js_fill_ul').html(menu_item_str);







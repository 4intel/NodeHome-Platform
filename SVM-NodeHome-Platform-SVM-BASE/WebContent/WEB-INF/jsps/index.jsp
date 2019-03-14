<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="net.fourintel.svm.common.biz.CoinListVO"%>
<%@ page import="net.fourintel.svm.common.CoinUtil"%>

<%@ include file="/inc/alertMessage.jsp" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

// WID
String strAWID = request.getParameter("wid");
if (strAWID == null) strAWID = "";
System.out.println("wid : "+strAWID);
%>
<!DOCTYPE html>
<html>
  <head>
    <title></title>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta content="width=device-width, initial-scale=1.0; maximum-scale=1.0; minimum-scale=1.0; user-scalable=no;" name="viewport" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />

    <!--     Fonts and icons     -->
    <link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Roboto:300,400,500,700|Roboto+Slab:400,700|Material+Icons" />
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/latest/css/font-awesome.min.css" />

    <!-- Material Dashboard CSS -->
    <link rel="stylesheet" href="/bootstrap/assets/css/material-dashboard.css">
    
    <!-- CSS Just for demo purpose, don't include it in your project -->
    <link href="/bootstrap/assets/demo/demo.css" rel="stylesheet" />
    
    <!-- Platform JS -->    
    <script src="/js/loader.js"></script>
    <script src="/js/common.js"></script>
    <script src="/js/tapp_interface.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    
    <script type="text/javascript">
    	//window.locale = '${pageContext.request.locale}';
  		$.ajaxSetup({ async:false }); // AJAX calls in order
  	
		// Script to run as soon as loaded from the web
		$(function() {
		});

		var j_curANM = "";
		var j_curWID = "";
		var j_curWNM = ""; // Default Wallet ID selected

		// Function to call as soon as it is loaded from the App
		function AWI_OnLoadFromApp(dtype) {
			 // Activate AWI_XXX method
			 AWI_ENABLE = true;
			 AWI_DEVICE = dtype;

			 j_curANM = AWI_getConfig("ACCOUNT_NM");
			 j_curWID = AWI_getConfig("CUR_WID");
			 j_curWNM = AWI_getConfig(j_curWID);
			 
			 if(j_curWID=="") {
				 location.href="/svm/wallet/myWalletList";
			 } else {
				 $('#my_name').html(j_curANM);
				 $('#my_wallet_name').html(j_curWNM);
				 var myBalance = getBalance(j_curWID);
				 var dBalance = (parseInt(myBalance)/<%=CoinUtil.DISPLAY_COIN_UNIT%>);
				 $('#my_wallet_balance').html(gfnAddComma(dBalance) + " <%=CoinListVO.getCoinCou()%>");
			 }
		}

		function getBalance(pWalletId) {
			var sNonce = "";	// nonce string
			var sSig = "";		// signature string
			var sNpid = "";		// NA connect id
			var rtnBalance = 0;	// Balance
			
			// ************ step1 : get Nonce / SVM API
			var sQuery = {"pid":"PID", "ver":"10000", "nType":"query"};
			var retData = callJsonAPI("/svm/common/getNonce", sQuery);
			if(retData['result'] == "OK") {
				sNonce = retData['nonce'];
				sNpid = retData['npid'];
			} else {
				return false;
			}
			
			// ************ step2 : get Signature / S-T API
			sQuery = ["PID","10000",sNonce];
			var sigRes = AWI_getSignature(pWalletId, sQuery);
			if(sigRes['result']=="OK") {
				sSig = sigRes['signature_key'];	
				
				// ************ step3 : get Balance / SVM API
				sQuery = {"npid":sNpid, "parameterArgs" : ["PID","10000",sNonce,sSig,pWalletId]};
				retData = callJsonAPI("/svm/wallet/getBalance", sQuery);
				if(retData['result'] == "OK") {
					rtnBalance = retData['balance'];
				} else {
					return '';
				}
			}
			return rtnBalance;
		}
		
		// Wallet chain registration
	    function setWalletInfo() {	    	
			var result = confirm ('<spring:message code="wallet.msg.addchain" />');
			if (result) {
				var sWNM = j_curWNM;
				var pWalletId = j_curWID;
				var sNonce = "";	// nonce string
				var sSig = "";		// signature string
				var sNpid = "";		// NA connect id
				var rtnBalance = 0;	// Balance
				
				// ************ step1 : get Nonce / SVM API
				var sQuery = {"pid":"PID", "ver":"10000", "nType":"query"};
				var retData = callJsonAPI("/svm/common/getNonce", sQuery);
				if(retData['result'] == "OK") {
					sNonce = retData['nonce'];
					sNpid = retData['npid'];
				} else {
					return false;
				}
				
				// ************ step2 : get Signature / S-T API
				sQuery = ["PID","10000",sNonce];
				var sigRes = AWI_getSignature(pWalletId, sQuery);
				if(sigRes['result']=="OK") {
					sSig = sigRes['signature_key'];	
					
					// ************ step3 : setWalletInfo / SVM API
					sQuery = {"npid":sNpid, "parameterArgs" : ["PID","10000",sWNM,"100000000000","wallet memo",sNonce,sSig,pWalletId]};
					retData = callJsonAPI("/svm/wallet/setWalletInfo", sQuery);
					alert(retData['result']);
					if(retData['result'] == "OK") {
						//rtnBalance = retData['balance'];
					} else {
						return '';
					}
				}
				return rtnBalance;
			} else {
				
			}			
		}
		
	    // backup
	    function setBackUpFunc() {
			var pWalletId = j_curWID;			
			sReturn = AWI_setBackup(pWalletId);
			/* var joReturn = JSON.parse(sReturn);
			if (joReturn['result'] == 'OK') {
			} */			
		}
	    
	    // restore
	    function setRestoreFunc() {
			sReturn = AWI_setRestore();
			/* var joReturn = JSON.parse(sReturn);
			if (joReturn['result'] == 'OK') {
			} */		
		}
	    
	 	// showQRCode
	    function showQRCode() {
	    	var pWalletId = j_curWID;
	    	var pWalletName = j_curWNM;
	    	AWI_showQRCode(pWalletId, pWalletName);
	    	/* var joReturn = JSON.parse(sReturn);
			if (joReturn['result'] == 'OK') {
			} */
		}
	    
	 	// App To Web
	    function AWI_CallFromApp(strJson) {
	    	var joRoot = JSON.parse(strJson);  
	    	var joFunc = joRoot.func;
    		if(joFunc.cmd == 'backup') {
    			// '{ "func" : { "cmd" : "backup", "result" : "OK", "walletId" : "Wallet Id" }}'
        		//alert("backup complete");
    			//location.reload();
	    	}
    		
    		if(joFunc.cmd == 'restore') {
    			// '{ "func" : { "cmd" : "restore", "result" : "OK", "walletId" : "Wallet Id" }}'
    			if (joFunc.result == 'OK') {
	    			var pWalletId = joFunc.walletId;
	        		AWI_setConfig("CUR_WID",pWalletId);
	        		location.href="/svm/wallet/createWalletRestore?wid="+pWalletId;
	    			//location.href="/index?wid="+pWalletId;
        		}
	    	}
	    }

		// Create Wallet
	    function createWallet() {
	    	location.href="/svm/wallet/createWalletForm";
		}
	    
		// My Wallet List
	    function myWalletList() {
	    	location.href="/svm/wallet/myWalletList";
		}

		// remittance
	    function sendCoin() {
	    	location.href="/svm/wallet/sendCoinForm";
		}	

		// Transaction history
	    function myTransHistory() {
	    	location.href="/svm/wallet/myTransHistory";
		}	
		
		// List of sources
	    function musicList() {
	    	location.href="/sapp/music/musicList";
		}	

		// Purchase List
	    function myList() {
	    	location.href="/sapp/music/myList";
		}	
		
	</script>
  </head>

<body>
    
  <!-- Content : S -->
  <div class=" ">     
    <div class="content">
      <div class="container-fluid">          
          <div class="row" style="margin-top:30px;">
            <div class="col-md-12">
              <div class="card card-profile">
                <div class="card-avatar" style="width: 130px; height: 130px; background-color: #2c3e50; padding-top: 50px; font-size: 30px; color: #ffffff; font-weight: bold;">
                  <span id="my_name"></span>
                  <a href="#pablo">
                    <!-- <img class="img" src="/bootstrap/assets/img/faces/profile.png" /> -->            
                  </a>
                </div>
                <div>
                  <!-- <h6 class="card-category text-gray"><span id="my_name"></span></h6> -->
                  <h5 class="card-title">
                  <spring:message code="wallet.text.walletname" /> : <span id="my_wallet_name"></span><br />
                  <spring:message code="wallet.text.balance" /> : <span id="my_wallet_balance"></span><br />
                  <button type="button" class="btn btn-primary btn-sm" onclick="javascript:showQRCode();"><spring:message code="user.text.qrzoom" /></button>
                  <!-- <button type="button" class="btn btn-primary btn-sm" onclick="javascript:setWalletInfo();"><spring:message code="user.button.addWallet" /></button> -->
                  <button type="button" class="btn btn-primary btn-sm" onclick="javascript:setBackUpFunc();"><spring:message code="user.text.backup" /></button>
                  <button type="button" class="btn btn-primary btn-sm" onclick="javascript:setRestoreFunc();"><spring:message code="user.text.restore" /></button>
                  </h4>
                  <!-- <p class="card-description">
                   	Contents
                  </p>  -->
                </div>
              </div>
            </div>
          </div>
          
          <div class="row">            
            <div class="col-lg-6 col-md-6 col-sm-6 col-6">
              <div class="card card-stats" onclick="createWallet();">
                <div class="card-header card-header-success card-header-icon">
                  <div class="card-icon">
                    <i class="material-icons">&#xE02E;</i> <!-- library_add -->
                  </div>
                  <!-- <p class="card-category"><spring:message code="user.button.createWallet" /></p>
                  <h3 class="card-title">49/50
                    <small>GB</small>
                  </h3> -->
                </div>
                <div class="card-footer">
                  <div class="stats">
                   	<i class="material-icons">&#xE02E;</i> <spring:message code="user.button.createWallet" />
                  </div>
                </div>
              </div>
            </div>            
            <div class="col-lg-6 col-md-6 col-sm-6 col-6">
              <div class="card card-stats" onclick="myWalletList();">
                <div class="card-header card-header-warning card-header-icon">
                  <div class="card-icon">
                    <i class="material-icons">&#xE850;</i> <!-- account_balance_wallet -->
                  </div>
                  <!-- <p class="card-category"><spring:message code="user.button.selectWallet" /></p>
                  <h3 class="card-title">49/50
                    <small>GB</small>
                  </h3> -->
                </div>
                <div class="card-footer">
                  <div class="stats">
                    <i class="material-icons">&#xE850;</i> <spring:message code="user.button.selectWallet" />
                  </div>
                </div>
              </div>
            </div>
            <div class="col-lg-6 col-md-6 col-sm-6 col-6">
              <div class="card card-stats" onclick="sendCoin();">
                <div class="card-header card-header-danger card-header-icon">
                  <div class="card-icon">
                    <i class="material-icons">&#xE263;</i> <!-- monetization_on -->
                  </div>
                  <!-- <p class="card-category"><spring:message code="user.button.sendCoin" /></p>
                  <h3 class="card-title">49/50
                    <small>GB</small>
                  </h3> -->
                </div>
                <div class="card-footer">
                  <div class="stats">
                    <i class="material-icons">&#xE263;</i> <spring:message code="user.button.sendCoin" />
                  </div>
                </div>
              </div>
            </div>
            <div class="col-lg-6 col-md-6 col-sm-6 col-6">
              <div class="card card-stats" onclick="myTransHistory();">
                <div class="card-header card-header-info card-header-icon">
                  <div class="card-icon">
                    <i class="material-icons">&#xE889;</i> <!-- history -->
                  </div>
                  <!-- <p class="card-category"><spring:message code="user.button.transHistory" /></p>
                  <h3 class="card-title">49/50
                    <small>GB</small>
                  </h3> -->
                </div>
                <div class="card-footer">
                  <div class="stats">
                    <i class="material-icons">&#xE889;</i> <spring:message code="user.button.transHistory" />
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          
      </div>
    </div>
  </div>
  <!-- Content : E -->
    

    <!--   Core JS Files   -->    
    <script src="/bootstrap/assets/js/core/jquery.min.js"></script>
    <script src="/bootstrap/assets/js/core/popper.min.js"></script>
    <script src="/bootstrap/assets/js/bootstrap-material-design.js"></script>

    <!--  Notifications Plugin, full documentation here: http://bootstrap-notify.remabledesigns.com/    -->
    <script src="/bootstrap/assets/js/plugins/bootstrap-notify.js"></script>

    <!--  Charts Plugin, full documentation here: https://gionkunz.github.io/chartist-js/ -->
    <script src="/bootstrap/assets/js/core/chartist.min.js"></script>

    <!-- Plugin for Scrollbar documentation here: https://github.com/utatti/perfect-scrollbar -->
    <script src="/bootstrap/assets/js/plugins/perfect-scrollbar.jquery.min.js"></script>

    <!-- Demo init -->
    <script src="/bootstrap/assets/js/plugins/demo.js"></script>

    <!-- Material Dashboard Core initialisations of plugins and Bootstrap Material Design Library -->
    <script src="/bootstrap/assets/js/material-dashboard.js?v=2.1.0"></script>
  
</body>
</html>
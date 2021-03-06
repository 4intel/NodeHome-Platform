<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="org.json.simple.JSONArray"%>
<%@ page import="org.json.simple.JSONObject"%>
<%@ page import="org.json.simple.parser.JSONParser"%>
<%@ page import="org.json.simple.parser.ParseException"%>
<%@ page import="net.fourintel.svm.common.CPWalletUtil"%>
<%@ page import="net.fourintel.svm.common.biz.CoinListVO" %>
<%@ page import="net.fourintel.svm.common.util.StringUtil"%>
<%@ page import="net.fourintel.svm.common.CoinUtil"%>
<%@ page import="net.fourintel.svm.common.biz.ServiceWalletVO"%>

<%@ page import="java.text.*" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.TimeZone" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%@ include file="/inc/alertMessage.jsp" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

// WID
String strAWID = request.getParameter("wid");
if (strAWID == null) strAWID = "";

String minRemittance = CoinUtil.calcDisplayCoin(Double.parseDouble(CoinListVO.getMinRemittanceAmount()));
%>
<!DOCTYPE html>
<html>
	<head>
    <title></title>
    <!-- Required meta tags -->
    <meta http-equiv="content-type" content="text/html;charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <meta content="width=device-width, initial-scale=1.0; maximum-scale=1.0; minimum-scale=1.0; user-scalable=no;" name="viewport" />    
    
    <!-- bootstrap 3.3.7 -->
    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet" id="bootstrap-css">
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    <link href="/bootstrap/assets/css/material-common.css" rel="stylesheet">
    
    <link href="/css/loading.css" rel="stylesheet" />
    
    <!-- Platform JS -->
    <script src="/js/loader.js"></script>
    <script src="/js/tapp_interface.js"></script>
    <script src="/js/common.js"></script>
	<script>
	$.ajaxSetup({ async:false }); // AJAX calls in order
	
	// Script to run as soon as loaded from the web
	$(function() {
	});

	var j_curANM = "";
	var j_curWID = "";
	var j_curWNM = "";

	// Function to call as soon as it is loaded from the App
	var myBalance = 0;
	// Minimum remittance amount
	var minRemittance = "<%=minRemittance%>";
	
	function AWI_OnLoadFromApp(dtype) {
		// Activate AWI_XXX method
		AWI_ENABLE = true;
		AWI_DEVICE = dtype;

		j_curANM = AWI_getConfig("ACCOUNT_NM");
		j_curWID = AWI_getConfig("CUR_WID");
		j_curWNM = AWI_getConfig(j_curWID);	
	
		// document.getElementById("s_account_name").innerHTML = "<spring:message code="body.msg.RimitName" /> : " + j_curANM;
		document.getElementById("s_account_name").value = j_curANM;

		var elmtTBody = $('#id_walletlist_selectbox_option'); //Withdrawal wallet
		var sHTML="";
		// sHTML += '<input type="hidden" id="wallet_id" name="wallet_id" value="'+j_curWID+'"/>';
		// sHTML += j_curWNM;
		// elmtTBody.html(sHTML);
		document.getElementById("wallet_id").value = j_curWID;
		document.getElementById("id_walletlist_selectbox_option").value = j_curWNM;
		 
		// getNonce
		myBalance = getBalance(j_curWID);
		<%-- $("#myPageUserAmt").value(gfnAddComma(myBalance)+" <%=CoinListVO.getCoinCou()%>"); --%>
		document.getElementById("myPageUserAmt").value = ""+gfnAddComma(myBalance/<%=CoinUtil.DISPLAY_COIN_UNIT%>)+" <%=CoinListVO.getCoinCou()%>";
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
	
	function FnScanQRCode() {
		var joCmd = null;
		var params = new Object();
		params['cmd'] = "getQRCodeByScan";
		params['callbackFunc'] = "FnScanQRCodeCallBack";
		params['param'] = "";
		joCmd = {func:params};
		if(AWI_DEVICE == 'ios') {
			sReturn =  prompt(JSON.stringify(joCmd));	
		} else if(AWI_DEVICE == 'android') {
			sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
		} else { // windows
			sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
		}
	}
	var j_qrCodeValue = "";
	function FnScanQRCodeCallBack(strJson) {
		var joRoot = JSON.parse(strJson);  
		var joFunc = joRoot.func;
		
		j_qrCodeValue = joFunc.value;
		joResNm = loadWalletName(j_qrCodeValue);
		if(joResNm!='')
			userWalletRimitFom.walletName2.value = joResNm;
		else 
			userWalletRimitFom.walletName2.value = j_qrCodeValue;
	}
	
	// qr reading default call back function
	function AWI_CallFromApp(strJson) {
		var joRoot = JSON.parse(strJson);
		var joFunc = joRoot.func;
		if(joFunc.cmd == 'qrCodeReader') {
			j_qrCodeValue = joFunc.value;
			joResNm = loadWalletName(j_qrCodeValue);
			if(joResNm!='')
				userWalletRimitFom.walletName2.value = joResNm;
			else 
				userWalletRimitFom.walletName2.value = j_qrCodeValue;
		}
	}

	function loadWalletName(pWalletId) {
		var rtnNm;

		var sQuery = {"walletId" : pWalletId};
		retData = callJsonAPI("/svm/wallet/queryWalletInfo", sQuery);

		if(retData['result'] == "OK") {
			rtnNm = retData['nm'];
		} else {
			return '';
		}
		
		return rtnNm;
	}
	
	// submit send coin 
	// When you send money from SApp
	// Function for web direct payment processing test. I am not going to use the transfer for this.
	function FnTransferCoinSApp() {
		var sNonce = "";
		var sNpid = "";
		
		var pWalletId = j_curWID;
	    if(j_qrCodeValue == "") {
	    	alertMassage('<spring:message code="body.msg.nowallet" />'); // error
	    	return false;
	    }

	    var transferContent = "coin transaction"; // Transaction content
	    var remittanceAmount = ($("#id_RemittanceAmount").val()) * ("<%=CoinUtil.DISPLAY_COIN_UNIT%>"); // Remittance amount
	    var withdrawMemo = document.getElementById ("id_withdrawMemo"). value; // Withdrawal note
	    var depositMemo = document.getElementById ("id_depositMemo"). value; // deposit note
	    
	    if (eval(remittanceAmount) > eval(myBalance)) {
	    	alertMassage('<spring:message code="body.msg.nobalance" />'); // error
	    	return false;
	    }
	    
	    // createTrans : s
	    var result = confirm("<spring:message code="body.msg.remitSubmit" />");
		if (result) {
		    $("#publish_btn").attr("disabled",true); //Can not enter

			// ************ step1 : get Nonce / SVM API
			var sQuery = {"pid":"PID", "ver":"10000", "nType":"query"};
			var retData = callJsonAPI("/svm/common/getNonce", sQuery);
			if(retData['result'] == "OK") {
				sNonce = retData['nonce'];
			} else {
				return false;
			}

			// ************ step2 : get Signature / S-T API
			sQuery = ["PID","10000","1",sNonce];
			var sigRes = AWI_getSignature(pWalletId, sQuery);
			
			if(sigRes['result']=="OK") {
				sSig = sigRes['signature_key'];	
				// ************ step3 : get TransHistory / SVM API
				sQuery = {"parameterArgs" : ["PID","10000","1",sNonce,sSig,pWalletId]};
				retData = callJsonAPI("/svm/common/getOwnerNonce", sQuery);	// Generate nonce for remittance
				sNonce = "";
				if(retData['result'] == "OK") {
					sNonce = retData['nonce'];
				} else {
					return '';
				}
			}

			
			// ************ step3 : get Nonce / SVM API
			var iNonce = sNonce;

			if(iNonce=="") {
				alert('error');
				return false;
			}
			
			// ************ step4 : get Signature / S-T API
			sQuery = ["PID", "10000", j_qrCodeValue,"R",remittanceAmount,transferContent,withdrawMemo,depositMemo,iNonce];
			var sigRes = AWI_getSignature(pWalletId, sQuery);

			if(sigRes['result']=="OK") {
				sSig = sigRes['signature_key'];	
				
				// ************ step5 : create transaction / SVM API
				var sArgs = ["PID","10000",j_qrCodeValue,"R",remittanceAmount,transferContent,withdrawMemo,depositMemo,iNonce,sSig,pWalletId];
					 
				sQuery = {"parameterArgs" : sArgs};
				retData = callJsonAPI("/svm/wallet/createTrans", sQuery);
				if (retData['ec'] == "0") {
					alert("success");
	            	location.href="/index";
	            } else {
	            	alertMassage("<spring:message code="gtoken.msg.writeError" />("+joRes['strValue']+")");
	            	$("#publish_btn").attr("disabled",false); //Input available
	            	return false;
	            }
			}
		} else {
			return false;
		}
		
	}
	
	// submit send coin 
	// When you send money from Terminal
	function FnTransferCoin() {
		$('#loading').css('display','block');

		setTimeout(function () {
		    var transferContent = "coin transaction"; // Transaction content
		    var remittanceAmount = ($("#id_RemittanceAmount").val()) * ("<%=CoinUtil.DISPLAY_COIN_UNIT%>"); // Remittance amount
		    var withdrawMemo = document.getElementById ("id_withdrawMemo"). value; // Withdrawal note
		    var depositMemo = document.getElementById ("id_depositMemo"). value; // deposit note
		    
		    if (eval(minRemittance) > eval($("#id_RemittanceAmount").val())) {
		    	alertMassage('error 1'); // error
		    	$('#loading').css('display','none');
		    	return false;
		    }
		    
			var pWalletId = j_curWID;
		    if(j_qrCodeValue == "" && userWalletRimitFom.walletName2.value=="") {
		    	alertMassage('<spring:message code="body.msg.nowallet" />'); // error
		    	$('#loading').css('display','none');
		    	return false;
		    }
		    
		    if(j_qrCodeValue == "") {
		    	j_qrCodeValue = userWalletRimitFom.walletName2.value;
		    }

		    if (eval(remittanceAmount) > eval(myBalance)) {
		    	alertMassage('error'); // error
		    	$('#loading').css('display','none');
		    	return false;
		    }
		    
		    // node 운영자 지갑 id 파라메터에 추가 예정 : <%=ServiceWalletVO.getWalletId() %>
		    
			var sArgs = ["PID","10000",pWalletId,j_qrCodeValue,"R",remittanceAmount,transferContent,withdrawMemo,depositMemo];
		    AWI_sendConfirm(sArgs, "/svm/wallet/sendCoinConfirm", "/svm/wallet/sendCoinComplete","");
		}, 10);
	}
	
	function FnMainGo() {
		location.href = "/index?wid="+j_curWID;
	}
	</script>
  	</head>
  
  
<body>

	<div class="container">
		
		<div id="loading" class="loading" style="display:none;"><img id="loading_img" alt="loading" src="/images/viewLoading.gif" /></div>
		
		<div class="row">
		    <div class="col-xs-12 col-sm-8 col-md-6 col-sm-offset-2 col-md-offset-3">
				
				<form name="userWalletRimitFom" id="userWalletRimitFom" method="post" onsubmit="return false;">
				<input type="hidden" name="nonce" id="nonce" />
		        <input type="hidden" name="npid" id="npid" />
		        <input type="hidden" id="wallet_id" name="wallet_id" />		        
				<h2><spring:message code="body.button.Rimit" /> <br /><small>Please enter your remittance</small></h2>
				<hr class="colorgraph">
				
				<%-- <div class="form-group form-inline">
  			    	<span class="input-group-addon" style="font-weight:bold; height:50px;" id="s_account_name"><spring:message code="body.msg.RimitName" /> : </span>
			    </div> --%>
			    
			    <div class="form-group">
					<div class="input-group">
				      <div class="input-group-addon"><spring:message code="body.text.my.account" /></div>
				      <input type="text" class="form-control input-lg" id="s_account_name" readonly />
				    </div>
				</div>
				
				<div class="form-group">
					<div class="input-group">
				      <div class="input-group-addon"><spring:message code="body.text.walletName" /></div>
				      <input type="text" class="form-control input-lg" id="id_walletlist_selectbox_option" readonly />
				    </div>
				</div>
                
                <div class="form-group">
					<div class="input-group">
				      <div class="input-group-addon"><spring:message code="user.text.Balance" /></div>
				      <input type="text" class="form-control input-lg" id="myPageUserAmt" readonly />
				    </div>
				</div>
			        
			    
			    <div class="form-group">
					<input type="text" name="id_withdrawMemo" id="id_withdrawMemo" class="form-control input-lg" placeholder="<spring:message code="body.text.walletMemo" />" tabindex="1" />
					<%-- <div class="input-group">
				      <div class="input-group-addon"><spring:message code="body.text.walletMemo" /></div>
				      <input type="text" name="id_withdrawMemo" id="id_withdrawMemo" class="form-control input-lg" placeholder="<spring:message code="body.text.walletMemo" />" tabindex="1" />
				    </div> --%>
				</div>
				
				<div class="form-group">
					<div class="input-group">
				      <%-- <div class="input-group-addon"><spring:message code="body.text.walletNameDeposit" /></div> --%>
				      <input type="text" name="walletName2" id="walletName2" class="form-control input-lg" placeholder="<spring:message code="body.text.walletNameDeposit" />" tabindex="2" />
				      <div class="input-group-addon"><input type="button" class="btn btn-warning btn-sm pull-center" value="<spring:message code="body.text.qrcode" />" onclick="FnScanQRCode();"></div>
				    </div>
				</div>
				
				<div class="form-group">
					<input type="text" name="id_depositMemo" id="id_depositMemo" class="form-control input-lg" placeholder="<spring:message code="body.text.walletMemoDeposit" />" tabindex="3" />
					<%-- <div class="input-group">
				      <div class="input-group-addon"><spring:message code="body.text.walletMemoDeposit" /></div>
				      <input type="text" name="id_depositMemo" id="id_depositMemo" class="form-control input-lg" placeholder="<spring:message code="body.text.walletMemoDeposit" />" tabindex="3" />
				    </div> --%>
				</div>
				
				<div class="form-group">
					<spring:message code="body.text.min.send.amount" /> : <%=minRemittance %> <%=CoinListVO.getCoinCou()%><br/>
					<%
					String maxc = CoinListVO.getMaxRemittanceAmount();
					if(!maxc.equals("0")) {
						%><spring:message code="body.text.max.send.amount" /> : <%=CoinUtil.calcDisplayCoin(Double.parseDouble(CoinListVO.getMaxRemittanceAmount())) %> <%=CoinListVO.getCoinCou()%><br/><%
					}
					%>
					<input type="text" name="id_RemittanceAmount" id="id_RemittanceAmount" class="form-control input-lg" placeholder="<spring:message code="body.text.walletAmountDeposit" />" tabindex="4" />
					<%-- <div class="input-group">
				      <div class="input-group-addon"><spring:message code="body.text.walletAmountDeposit" /></div>
				      <input type="text" name="id_RemittanceAmount" id="id_RemittanceAmount" class="form-control input-lg" placeholder="<spring:message code="body.text.walletAmountDeposit" />" tabindex="4" />
				    </div> --%>
				</div>
				
				<hr class="colorgraph">
				<div class="row">
					<div class="col-xs-6"><input type="button" value="<spring:message code="body.button.Rimit" />" class="btn btn-success btn-lg btn-block" onclick="FnTransferCoin();" tabindex="5" /></div>
					<div class="col-xs-6"><input type="button" value="<spring:message code="body.button.RimitCancel" />" class="btn btn-primary btn-lg btn-block" onclick="FnMainGo();" tabindex="6" /></div>
				</div>
				<div style="padding-bottom:20px;"></div>
				</form>
			</div>
		</div>
				
	</div>
	
</body>

</html>
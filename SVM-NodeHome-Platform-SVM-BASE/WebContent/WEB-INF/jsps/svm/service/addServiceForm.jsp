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
<%@ page import="net.fourintel.cmm.service.GlobalProperties"%>
<%@ page import="net.fourintel.svm.common.biz.ApiHelper"%>

<%@ include file="/inc/alertMessage.jsp" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

String serviceFeeB = CoinListVO.getServiceRegFee();
String serviceFee = CoinUtil.calcDisplayCoin(Double.parseDouble(serviceFeeB));
String projectServiceid = GlobalProperties.getProperty("project_serviceid");

String localServiceHost = request.getRequestURL().toString();
localServiceHost = localServiceHost.replaceAll(request.getRequestURI(),"");
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
	
	function AWI_OnLoadFromApp(dtype) {
		// Activate AWI_XXX method
		AWI_ENABLE = true;
		AWI_DEVICE = dtype;

		j_curANM = AWI_getConfig("ACCOUNT_NM");
		j_curWID = AWI_getConfig("CUR_WID");
		j_curWNM = AWI_getConfig(j_curWID);	
		 
		myBalance = getBalance(j_curWID);
		document.getElementById("s_account_name").value = j_curANM;
	}

	function getBalance(pWalletId) {
		var sNonce = "";	// nonce string
		var sSig = "";		// signature string
		var sNpid = "";		// NA connect id
		var rtnBalance = 0;	// Balance
		
		// ************ step1 : get Nonce / SVM API
		var sQuery = {"pid":"PID", "ver":"10000", "serviceId":"<%=projectServiceid%>"};
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
			sQuery = {"npid":sNpid, "serviceId":"<%=projectServiceid%>", "parameterArgs" : ["PID","10000",sNonce,sSig,pWalletId]};
			retData = callJsonAPI("/svm/wallet/getBalance", sQuery);
			if(retData['result'] == "OK") {
				rtnBalance = retData['balance'];
			} else {
				return '';
			}
		}
		return rtnBalance;
	}
	
	function FnAddService() {
		var sNonce = "";
		var sNpid = "";
		
		var pWalletId = j_curWID;

	    var transferContent = "add service";
	    var serviceRegFee =  "<%=serviceFeeB%>";
	    var sServiceName = document.getElementById ("s_service_name").value;
	    var sServiceMemo = document.getElementById ("s_service_memo").value;
	    sServiceMemo = sServiceMemo.replace(/(?:\r\n|\r|\n)/g, '<br/>');

	    if(sServiceName=="") {alert('<spring:message code="service.require.alert1" />');return;}
	    if(sServiceHost=="") {alert('<spring:message code="service.require.alert2" />');return;}
	    if(sServiceIp=="") {alert('<spring:message code="service.require.alert3" />');return;}
	    if(sServiceMemo=="") {alert('<spring:message code="service.require.alert4" />');return;}
	    
	    if (eval(serviceRegFee) > eval(myBalance)) {
	    	alertMassage('<spring:message code="service.msg.nobalance" /> '+serviceRegFee+' <%=CoinListVO.getCoinCou()%>'); // error
	    	return false;
	    }
	    
	    var result = confirm("<spring:message code="service.msg.remitSubmit" /> " +serviceRegFee+ " <%=CoinListVO.getCoinCou()%>");
		$('#loading').css('display','block');

		setTimeout(function () {
			if (result) {
				// ************ step1 : get Nonce / SVM API
				var sQuery = {"pid":"PID", "ver":"10000", "cType":"<%=ApiHelper.CONTENT_CHAIN%>", "serviceId":"<%=projectServiceid%>"};
				var retData = callJsonAPI("/svm/common/getNonce", sQuery);
				if(retData['result'] == "OK") {
					sNonce = retData['nonce'];
					sNpid = retData['npid'];
				} else {
					$('#loading').css('display','none');
					return false;
				}
				
				// ************ step2 : get Signature / S-T API
				// The input data is user defined and designed.
				sQuery = ["PID","10000","{\"sOwner\":\""+pWalletId+"\",\"ServiceName\":\""+sServiceName+"\",\"ServiceMemo\":\""+sServiceMemo+"\"}",sNonce];
				var sigRes = AWI_getSignature(pWalletId, sQuery);
				
				if(sigRes['result']=="OK") {
					sSig = sigRes['signature_key'];	
				}

				var serviceId = "";
				var reserveId = "";
				var fee = "";
				// ************ step3 : get TransHistory / SVM API
				sQuery = {"npid":sNpid, "serviceId":"<%=projectServiceid%>", "parameterArgs" : ["PID","10000","{\"sOwner\":\""+pWalletId+"\",\"ServiceName\":\""+sServiceName+"\",\"ServiceMemo\":\""+sServiceMemo+"\"}",sNonce,sSig,pWalletId]};
				retData = callJsonAPI("/svm/service/reserveRegisterService", sQuery);	// Generate nonce for remittance
				sNonce = "";
				if(retData['result'] == "OK") {
					serviceId = retData['service_id'];
					reserveId = retData['reserve_id'];
					fee = retData['fee'];

					// ************ step1 : get Nonce / SVM API
					var sQuery = {"pid":"PID", "ver":"10000", "cType":"<%=ApiHelper.COIN_CHAIN%>", "serviceId":"<%=projectServiceid%>"};
					var retData = callJsonAPI("/svm/common/getNonce", sQuery);
					if(retData['result'] == "OK") {
						sNonce = retData['nonce'];
					} else {
						$('#loading').css('display','none');
						return false;
					}

					// ************ step2 : get Signature / S-T API
					// The input data is user defined and designed.
					sQuery = ["PID","10000","1",sNonce];
					var sigRes = AWI_getSignature(pWalletId, sQuery);
					
					if(sigRes['result']=="OK") {
						sSig = sigRes['signature_key'];	

						// ************ step3 : get TransHistory / SVM API
						sQuery = {"npid":sNpid, "serviceId":"<%=projectServiceid%>", "parameterArgs" : ["PID","10000","1",sNonce,sSig,pWalletId]};
						retData = callJsonAPI("/svm/common/getOwnerNonce", sQuery);	// Generate nonce for remittance
						sNonce = "";
						if(retData['result'] == "OK") {
							sNonce = retData['nonce'];
							sNpid = retData['npid'];
						} else {
							$('#loading').css('display','none');
							return false;
						}

						// ************ step4 : get Signature / S-T API
						sQuery = ["PID", "10000", fee, reserveId, "Add New Service", sNonce];
						var sigRes = AWI_getSignature(pWalletId, sQuery);

						if(sigRes['result']=="OK") {
							sSig = sigRes['signature_key'];	

							// ************ step5 : create transaction / SVM API
							var sArgs = ["PID","10000",fee, reserveId, "Add New Service",sNonce,sSig,pWalletId];
							sQuery = {"requestUrl":"<%=GlobalProperties.getProperty("project_seedHost")%>/createService", "npid":sNpid, "addServiceId":serviceId, "addServiceName":sServiceName, "serviceId":"<%=projectServiceid%>", "parameterArgs" : sArgs};
							retData = callCorsJsonAPI(sQuery);
							if (retData['result'] == "OK") {
								alert('<spring:message code="service.msg.add.complete" /> '+retData['serviceId']);
								history.back();
				            } else {
								$('#loading').css('display','none');
				            	alertMassage("<spring:message code="gtoken.msg.writeError" />("+joRes['strValue']+")");
				            	return false;
				            }
						}
					}
				} else {
					return false;
				}
				
			} else {
				return false;
			}
		},10);
		
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
				
				<form name="frm" id="frm" method="post" onsubmit="return false;">
				<input type="hidden" name="nonce" id="nonce" />
		        <input type="hidden" name="npid" id="npid" />
		        <input type="hidden" id="wallet_id" name="wallet_id" />		        
				<h2><spring:message code="service.page.title" /> <br /><small></small></h2>
				<hr class="colorgraph">
				
			    <div class="form-group">
					<div class="input-group">
				      <div class="input-group-addon"><spring:message code="service.text.ownername" /></div>
				      <input type="text" class="form-control input-lg" id="s_account_name" readonly/>
				    </div>
				</div>
				
			    <div class="form-group">
					<div class="input-group">
				      <div class="input-group-addon"><spring:message code="service.text.servicename" /></div>
				      <input type="text" class="form-control input-lg" id="s_service_name" />
				    </div>
				</div>
				
			    <div class="form-group">
					<textarea name="s_service_memo" id="s_service_memo" class="form-control input-lg" placeholder="<spring:message code="service.text.servicedesc" />" rows="5"></textarea>
				</div>
				
				<hr class="colorgraph">
				<div class="row">
					<div class="col-xs-6"><input type="button" value="<spring:message code="service.text.btn.add" />" class="btn btn-success btn-lg btn-block" onclick="FnAddService();" /></div>
					<div class="col-xs-6"><input type="button" value="<spring:message code="service.text.btn.cancel" />" class="btn btn-primary btn-lg btn-block" onclick="FnMainGo();" /></div>
					<!-- <spring:message code="body.button.RimitCancel" /> -->
				</div>
				<div style="padding-bottom:20px;"></div>
				</form>
			</div>
		</div>
				
	</div>
	
</body>

</html>
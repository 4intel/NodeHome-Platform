<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="net.fourintel.cmm.service.GlobalProperties"%>
<%@ include file="/inc/alertMessage.jsp" %>
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
    <link href="/bootstrap/assets/css/material-login.css" rel="stylesheet">
    
    <!-- Platform JS -->   
    <script src="/js/loader.js"></script>
    <script src="/js/tapp_interface.js"></script>  
	<script>
		// Script to run as soon as loaded from the web
		$(function() {
		});
		
		// Function to call as soon as it is loaded from the App
		function AWI_OnLoadFromApp(dtype) {
			 // Activate AWI_XXX method
			 AWI_ENABLE = true;
	         AWI_DEVICE = dtype;
			 if (AWI_getConfig("ACCOUNT_NM") == "") {
				 location.href="/user/join"; // join
			 }

			 var sReturn = AWI_isAbleFingerprint();
			 var sRes = JSON.parse(sReturn);
			 if(sRes['result']=="OK") {
				 $('#FingerC').show();
			 }

			 AWI_setAppTitle("NODEHOME");
			 
			 // background color Gradient parameter option
			 // https://developer.android.com/reference/android/graphics/drawable/GradientDrawable.Orientation
		}
	</script>
    <script type="text/javascript">	
    	// NULL Compare
		function checkNull(string) {
			if (string==null || string=='') {
				return true;
			} else {
				return false;
			}
		}
		
    	// 지문인증 call
    	function Fingerprint() {
    		 var joCmd = null;
    		 var params = new Object();
    		 params['cmd'] = "showFingerprint";
    		 joCmd = {func:params};
    			if(AWI_DEVICE == 'ios') {
    				sReturn =  prompt(JSON.stringify(joCmd));	
    			} else if(AWI_DEVICE == 'android') {
    				sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
    			} else { // windows
    				sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
    			}
			 var sRes = JSON.parse(sReturn);
    	}
    	
    	// 지문인증 콜백
    	function AWI_CallFromApp(strJson) {
    		var joRoot = JSON.parse(strJson);
    		var joFunc = joRoot.func;
    		if(joFunc.cmd == 'fingerprint' && joFunc.result == 'OK') {
    			location.href="/index";
    		}
    	}
    	
	    function chkForm() {
	    	var objForm = document.loginform;
	    	
	    	if (checkNull(objForm.txt_MemName.value)==true) {
	    		alertMassage("<spring:message code="user.msg.name" />");
				objForm.txt_MemName.value="";
				return false;
			}
			
			if (checkNull(objForm.txt_MemPwd.value)==true) {
				alertMassage("<spring:message code="user.msg.password" />");
				objForm.txt_MemPwd.value="";
				return false;
			}
			
			// Name check
			var sANM = AWI_getConfig("ACCOUNT_NM"); // Account_NAME		
			if(sANM != objForm.txt_MemName.value) {
				alertMassage("<spring:message code="user.msg.namedifferent" />");
				return false;
			}
			
			// checkPassword call
			if (AWI_checkPassword(document.getElementById('txt_MemPwd').value) == 'OK') {	
				location.href="/index";				
			} else {
				alert("<spring:message code="user.msg.loginfail" />");
				return false;
			}
			
		}		
		
		// Call loading script when loading time : S
		$(document).ready(function() {
			var loading = $('<div id="loading" class="loading"></div><img id="loading_img" alt="loading" src="/images/viewLoading.gif" />').appendTo(document.body).hide();
			$( document ).ajaxStart( function() {
				loading.show();
			} );
			$( document ).ajaxStop( function() {
				loading.hide();
			} );
		});
		// Call loading script when loading time : E
    </script>
  	</head>
  
  
<body>

	<section style="height: 100vh;">
    <div style="background-image: url(images/arka.jpg); background-attachment: fixed; background-size: cover; width: 100%; height: 100vh; position: relative;"  >
    <div class="baslik">
        <b style="font-size: 50px; text-align: center; margin-bottom: -21px; display: block;">NodeHome</b>
    </div>
    <section>
    <form name="loginform" id="loginform" method="post">
        <div class="arkalogin">
            <div class="loginbaslik">User Login</div>
            <hr style="border: 1px solid #ccc;">
            <input type="text" class="giris" name="txt_MemName" id="txt_MemName" placeholder="Username" maxlength="30" tabindex="1" />
            <input type="password" class="giris" name="txt_MemPwd" id="txt_MemPwd" placeholder="Password" maxlength="30" tabindex="2" />
            <input class="butonlogin" type="button" name="" value="Login" onclick="chkForm();" />
            <input class="butonlogin" type="button" name="" id="FingerC" value="Fingerprint authentication" onclick="Fingerprint();" style="display:none;"/>
        </div>
    </form>
    </section><br>
    <span style="font-size: 23px; text-align: center; display: block; color: #888888;">Welcome To The User Panel</span>
    <span style="font-size: 24px; text-align: center; display: block; color: #888888; font-weight: bold; margin-bottom: 34px;">LOGİN</span>
    </div>
    </section>
	
</body>

</html>

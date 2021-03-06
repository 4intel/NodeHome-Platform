var AWI_ENABLE = false;
var AWI_DEVICE = 'ios';

//-----------------------------------------------------
// iphone interface 
// IPHONE callback response function control
var  _timeIOSCallbackWaitEnd = Date.now();  // Response timeout time
var  _boolNeedIOSCallbackWait = false;       // Need to wait
var  _strIOSCallbackValue = "";                  // Returned string

// Calling ajax url with JSON request value
function callJsonAPI(pUrl, psQuery) {
	var retData = null;
	$.ajax({
	    url: pUrl, 
	    type: 'POST',
	    data: JSON.stringify(psQuery),
	    dataType: 'json', 
	    async:false,
		contentType:"application/json;charset=UTF-8",
	    success: function(data) { 
	    	retData = data;
	    },
	    error:function(data,status,er) { 
	        alert("error: "+data.responseText+" status: "+status+" er:"+er);
	    }
	});
	return retData;
}

// Calling other domain json object request, response
/*
 * Example
		var sQuery = {"requestUrl" : "<%=GlobalProperties.getProperty("music_site_url")%>/api/fimusic/music_list","listId":"1","pageSize":"10","pageIndex":pageIndex};
		var data = callCorsJsonAPI(sQuery);
 */
function callCorsJsonAPI(psQuery) {
	var retData = null;
	$.ajax({
	    url: "/svm/common/callCorsUrl", 
	    type: 'POST',
	    data: JSON.stringify(psQuery),
	    dataType: 'json',
	    async:false,
		contentType:"application/json;charset=UTF-8",
	    success: function(data) { 
			if(data['result'] != "FAIL") {
				retData = data;
			} else {
				alert('error');
				return false;
			}
	    },
	    error:function(data,status,er) { 
	        alert("error: "+data.responseText+" status: "+status+" er:"+er);
	    }
	});
	return retData;
}

//Information setting
function AWI_setConfig(strName,strValue) {
	if(!AWI_ENABLE) return;
	var joCmd = null;
	var params = new Object();
	params['cmd'] = "setConfig";
	params['key'] = strName;
	params['value'] = strValue;
	joCmd = {func:params};
	if(AWI_DEVICE == 'ios') {
		sReturn =  prompt(JSON.stringify(joCmd));	
	} else if(AWI_DEVICE == 'android') {
		sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
	} else { // windows
		sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
	}
	var joReturn = JSON.parse(sReturn);
	return joReturn['result'];
}

//And inquires the setting information value set in the phone.
function AWI_getConfig(strName) {
	var sReturn = "{ \"result\":\"FAIL\", \"value\":\"\" }"
	if(!AWI_ENABLE) return "";
	var joCmd = null;
	var params = new Object();
	params['cmd'] = "getConfig";
	params['key'] = strName;
	joCmd = {func:params};
	if(AWI_DEVICE == 'ios') {
		sReturn =  prompt(JSON.stringify(joCmd));	
	} else if(AWI_DEVICE == 'android') {
		sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
	} else { // windows
		sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
	}
	var joReturn = JSON.parse(sReturn);
	return joReturn['value'];
}

//Verify the password set on the phone.
function AWI_checkPassword(strPW) {
	var joReturn = null;
	if(!AWI_ENABLE) return "";
	var joCmd = null;
	var params = new Object();
	params['cmd'] = "checkPassword";
	params['password'] = strPW;
	joCmd = {func:params};
	if(AWI_DEVICE == 'ios') {
		sReturn =  prompt(JSON.stringify(joCmd));	
	} else if(AWI_DEVICE == 'android') {
		sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
	} else { // windows
		sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
	}
	joReturn = JSON.parse(sReturn);
	return joReturn['result'];
}

// Save your new password to phone
function AWI_setPassword(strPW) {
	var sReturn = "{ \"result\":\"FAIL\", \"value\":\"\" }"
	if(!AWI_ENABLE) return "";
	var joCmd = null;
	var params = new Object();
	params['cmd'] = "setPassword";
	params['password'] = strPW;
	joCmd = {func:params};
	if(AWI_DEVICE == 'ios') {
		sReturn =  prompt(JSON.stringify(joCmd));	
	} else if(AWI_DEVICE == 'android') {
		sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
	} else { // windows
		sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
	}
	var joReturn = JSON.parse(sReturn); // { "result":"OK", "value":true }
	return joReturn['result'];
}

// Request to check data in terminal node.
function AWI_isSetPassword() {
	if(!AWI_ENABLE) return;
	var joCmd = null;
	var params = new Object();
	params['cmd'] = "isSetPassword";
	joCmd = {func:params};
	if(AWI_DEVICE == 'ios') {
		sReturn =  prompt(JSON.stringify(joCmd));	
	} else if(AWI_DEVICE == 'android') {
		sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
	} else { // windows
		sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
	}
	var joReturn = JSON.parse(sReturn);
	return joReturn['result'];
}

//Create a new account
//sOwner: owner name, same as account name, later account name can be changed
//By default, 100 coins are created.
function AWI_newWallet() {
	var sReturn = "{ \"result\":\"FAIL\" }"
	if(!AWI_ENABLE) return;
    var joCmd = null;
    var params = new Object();
    params['cmd'] = "newWallet";
    joCmd = {func:params};
	if(AWI_DEVICE == 'ios') {
		sReturn =  prompt(JSON.stringify(joCmd));	
	} else if(AWI_DEVICE == 'android') {
		sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
	} else { // windows
		sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
	}
	return sReturn;
}

// Request to delete wallet in terminal node. Call backup wallet activtiy to save paper wallet if need it.
function AWI_deleteWallet(walletId) {
	var sReturn = "{ \"result\":\"FAIL\" }"
	if(!AWI_ENABLE) return;
    var joCmd = null;
    var params = new Object();
    params['cmd'] = "deleteWallet";
    params['walletId'] = walletId;
    joCmd = {func:params};
	if(AWI_DEVICE == 'ios') {
		sReturn =  prompt(JSON.stringify(joCmd));	
	} else if(AWI_DEVICE == 'android') {
		sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
	} else { // windows
		sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
	}
	return sReturn;
}

//Save account information on mobile phone
function AWI_notiAccount(aid, wid, cid, pname) {
	var sReturn = "{ \"result\":\"FAIL\" }"
	if(!AWI_ENABLE) return;
    var joCmd = null;
    var params = new Object();
    params['result'] = "OK";
    params['cmd'] = "notiAccount";
    params['aid'] = aid;
    params['wid'] = wid;
    params['cid'] = cid;
    params['wname'] = pname;
    joCmd = {func:params};
	if(AWI_DEVICE == 'ios') {
		sReturn =  prompt(JSON.stringify(joCmd));	
	} else if(AWI_DEVICE == 'android') {
		sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
	} else { // windows
		sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
	}
	return sReturn;
}

// Create Signature
function AWI_getSignature(walletId, pArgs) {
	var sReturn = "{ \"result\":\"FAIL\" , \"value\":{} }"

	var joCmd = null;
	var params = new Object();
	params['cmd'] = "getSignature";
	params['walletId'] = walletId;
	params['args'] = pArgs;
	joCmd = {func:params};
	 
	if(!AWI_ENABLE) return;
	if(AWI_DEVICE == 'ios') {
		sReturn =  prompt(JSON.stringify(joCmd));	
	} else if(AWI_DEVICE == 'android') {
		sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
	} else { // windows
		sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
	}
	 var joReturn = JSON.parse(sReturn);
	return joReturn;
}

//Create Signature
function AWI_getWalletList() {
	var sReturn = "{ \"result\":\"FAIL\" , \"value\":{} }"

	if(!AWI_ENABLE) return;
	 var joCmd = null;
	 var params = new Object();
	 params['cmd'] = "getWalletList";
	 joCmd = {func:params};
		if(AWI_DEVICE == 'ios') {
			sReturn =  prompt(JSON.stringify(joCmd));	
		} else if(AWI_DEVICE == 'android') {
			sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
		} else { // windows
			sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
		}
	return sReturn;
}

// Select the service list and save the settings to the terminal.
function AWI_setServiceList(serviceIds) {
	var sReturn = "{ \"result\":\"FAIL\" , \"value\":{} }"

	 var jsonObj = $.parseJSON('[' + serviceIds + ']');
	 var joCmd = null;
	 var params = new Object();
	 params['cmd'] = "setServiceList";
	 params['list'] = jsonObj;
	 joCmd = {func:params};
	 
	if(!AWI_ENABLE) return;
	if(AWI_DEVICE == 'ios') {
		sReturn =  prompt(JSON.stringify(joCmd));	
	} else if(AWI_DEVICE == 'android') {
		sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
	} else { // windows
		sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
	}
	 var joReturn = JSON.parse(sReturn);
	return joReturn;
}

//Send coin check call and send
//It transfers coin to coin-wallet belong current account and confirm.
// When transferring money from the terminal
function AWI_sendConfirm(jaArgs, sCallbackUrl1, sCallbackUrl2, callbackParam) {
	var sReturn = "{ \"result\":\"FAIL\" , \"value\":{} }"
	if(!AWI_ENABLE) return;
	var joCmd = null;
	var params =  new Object();
	params['cmd'] = "sendCoinConfirm";
	params['confirmPath'] = sCallbackUrl1;
	params['completePath'] = sCallbackUrl2;
	params['callbackParam'] = callbackParam;
	params['args'] = jaArgs;
	joCmd = {func:params};
	if(AWI_DEVICE == 'ios') {
		sReturn =  prompt(JSON.stringify(joCmd));	
	} else if(AWI_DEVICE == 'android') {
		sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
	} else { // windows
		sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
	}
}

function AWI_sendCoin() {
	var sReturn = "{ \"result\":\"FAIL\" , \"value\":{} }"
	if(!AWI_ENABLE) return;
	var joCmd = null;
	var params =  new Object();
	params['cmd'] = "sendCoin";
	joCmd = {func:params};
	if(AWI_DEVICE == 'ios') {
		sReturn =  prompt(JSON.stringify(joCmd));	
	} else if(AWI_DEVICE == 'android') {
		sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
	} else { // windows
		sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
	}
}

//backup
function AWI_setBackup(walletId) {
	var sReturn = "{ \"result\":\"FAIL\" }"
	if(!AWI_ENABLE) return;
	var joCmd = null;
	var params = new Object();
	params['cmd'] = "backup";
	params['walletId'] = walletId;
	joCmd = {func:params};
	if(AWI_DEVICE == 'ios') {
		sReturn =  prompt(JSON.stringify(joCmd));	
	} else if(AWI_DEVICE == 'android') {
		sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
	} else { // windows
		sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
	}
	return sReturn;
}

//restore
function AWI_setRestore(walletId) {
	var sReturn = "{ \"result\":\"FAIL\" }"
	if(!AWI_ENABLE) return;
	var joCmd = null;
	var params = new Object();
	params['cmd'] = "restore";
	joCmd = {func:params};
	if(AWI_DEVICE == 'ios') {
		sReturn =  prompt(JSON.stringify(joCmd));	
	} else if(AWI_DEVICE == 'android') {
		sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
	} else { // windows
		sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
	}
	return sReturn;
}

//showQRCode
function AWI_showQRCode(walletId, walletName) {
	var sReturn = "{ \"result\":\"FAIL\" }"
	if(!AWI_ENABLE) return;
	var joCmd = null;
	var params = new Object();
	params['cmd'] = "showQRCode";
	params['walletId'] = walletId;
	params['walletName'] = walletName;
	joCmd = {func:params};
	if(AWI_DEVICE == 'ios') {
		sReturn =  prompt(JSON.stringify(joCmd));	
	} else if(AWI_DEVICE == 'android') {
		sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
	} else { // windows
		sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
	}
	return sReturn;
}

/* Request to encrypt text via wallet id.
 * 
 * Example - 
		var aaa = "테스트지갑";
		var aaa2 = AWI_getEncryptedText(j_curWID, aaa);
		gg = JSON.parse(aaa2);
		alert(gg.value);
		bhbh = gg.value;
		var kjkji = AWI_getDecryptedText(j_curWID,bhbh);
		gg = JSON.parse(kjkji);
		alert(gg.value);
 */
function AWI_getEncryptedText(walletId, plainText) {
	var sReturn = "{ \"result\":\"FAIL\" }"
	if(!AWI_ENABLE) return;
	var joCmd = null;
	var params = new Object();
	params['cmd'] = "getEncryptedText";
	params['walletId'] = walletId;
	params['plainText'] = plainText;
	joCmd = {func:params};
	if(AWI_DEVICE == 'ios') {
		sReturn =  prompt(JSON.stringify(joCmd));	
	} else if(AWI_DEVICE == 'android') {
		sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
	} else { // windows
		sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
	}
	return sReturn;
}

// Request to decrypt text via wallet id.
function AWI_getDecryptedText(walletId, encryptedText) {
	var sReturn = "{ \"result\":\"FAIL\" }"
	if(!AWI_ENABLE) return;
	var joCmd = null;
	var params = new Object();
	params['cmd'] = "getDecryptedText";
	params['walletId'] = walletId;
	params['encryptedText'] = encryptedText;
	joCmd = {func:params};
	if(AWI_DEVICE == 'ios') {
		sReturn =  prompt(JSON.stringify(joCmd));	
	} else if(AWI_DEVICE == 'android') {
		sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
	} else { // windows
		sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
	}
	return sReturn;
}

// return boolean, test to pass the password
function AWI_isCheckPassword()
{
	var sReturn = "{ \"result\":\"FAIL\", \"value\":false }"
	if(!AWI_ENABLE) return false;

	if(AWI_DEVICE == 'ios') {
		var args = "cmd=isCheckPassword";
		_boolNeedIOSCallbackWait = true;
		_timeIOSCallbackWaitEnd = Date.now() + 2000; // Respond in 2 seconds
		_strIOSCallbackValue = "";
		awi_calliOSFunction("callAppFunc",args 	,"awi_callbackSuccess" ,"awi_callbackError" );
		sReturn = awi_waitIPhoneCallback();
	} else if(AWI_DEVICE == 'android') {
		var joCmd = null;
		var params = new Object();
		params['cmd'] = "isCheckPassword";
		joCmd = {func:params};
		sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));
	} else { // windows
		var joCmd = null;
		var params = new Object();
		params['cmd'] = "isCheckPassword";
		joCmd = {func:params};
		sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
	}
	var joReturn = JSON.parse(sReturn); // { "result":"OK", "value":true }
	return joReturn['value'];
}

function AWI_isAbleFingerprint() {
	var sReturn = "{ \"result\":\"FAIL\" , \"value\":{} }"

	if(!AWI_ENABLE) return;
	 var joCmd = null;
	 var params = new Object();
	 params['cmd'] = "isAbleFingerprint";
	 joCmd = {func:params};
		if(AWI_DEVICE == 'ios') {
			sReturn =  prompt(JSON.stringify(joCmd));	
		} else if(AWI_DEVICE == 'android') {
			sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
		} else { // windows
			sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
		}
	return sReturn;
}
function AWI_showFingerprint() {
	var sReturn = "{ \"result\":\"FAIL\" , \"value\":{} }"

	if(!AWI_ENABLE) return;
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
	return sReturn;
}
function AWI_setAppTitle(title) {
	var sReturn = "{ \"result\":\"FAIL\" , \"value\":{} }"

	if(!AWI_ENABLE) return;
	 var joCmd = null;
	 var params = new Object();
	 params['cmd'] = "setAppTitle";
	 params['title'] = title;
	 joCmd = {func:params};
		if(AWI_DEVICE == 'ios') {
			sReturn =  prompt(JSON.stringify(joCmd));	
		} else if(AWI_DEVICE == 'android') {
			sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
		} else { // windows
			sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
		}
}
function AWI_setAppTitleColor(color1, color2, orientation) {
	var sReturn = "{ \"result\":\"FAIL\" , \"value\":{} }"

	if(!AWI_ENABLE) return;
	 var joCmd = null;
	 var params = new Object();
	 params['cmd'] = "setAppTitleColor";
	 params['startColor'] = color1;
	 params['endColor'] = color2;
	 params['orientation'] = orientation;
	 joCmd = {func:params};
		if(AWI_DEVICE == 'ios') {
			sReturn =  prompt(JSON.stringify(joCmd));	
		} else if(AWI_DEVICE == 'android') {
			sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
		} else { // windows
			sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
		}
}
package net.fourintel.svm.platform.web;

import java.io.IOException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import net.fourintel.cmm.service.GlobalProperties;
import net.fourintel.svm.common.CPWalletUtil;
import net.fourintel.svm.common.biz.ApiHelper;
import net.fourintel.svm.common.util.KeyManager;
import net.fourintel.svm.common.util.StringUtil;

@Controller
public class SvmWalletController {

	private static final Logger LOGGER = LoggerFactory.getLogger(SvmWalletController.class);

	/*
	 * View your Wallet Balance.
	 */
	@RequestMapping("/svm/wallet/getBalance")
	@ResponseBody
	public String getBalance(HttpServletRequest request, @RequestBody HashMap<Object,Object> map, ModelMap model, HttpServletResponse servletResponse) throws UnknownHostException, IOException {
		String strOK = "{ \"result\":\"OK\" }";

		String npid= (String)map.get("npid");
		String serviceId = StringUtil.nvl(map.get("serviceId"),GlobalProperties.getProperty("project_serviceid"));
		List<String> arrArgs=(ArrayList<String>)map.get("parameterArgs");
		
		if(arrArgs!=null) {
			JSONObject joResult = null;

			joResult = CPWalletUtil.getValue(serviceId, ApiHelper.COIN_CHAIN, "getBalance", npid, arrArgs.toArray(new String[0]) );

			long nCode = (Long)joResult.getOrDefault("ec",-1L);

			if (nCode == 0) { // successful
				// values to pass to the web
				String strValue = joResult.get("value").toString();
				System.out.println("strValue : "+strValue);

				JSONParser jpTemp = new JSONParser();
				JSONObject joInfo;
				try {
					joInfo = (JSONObject)jpTemp.parse(strValue);
					if(strValue!=null) {
						strValue = (String)joInfo.get("balance");
					}
				} catch (ParseException e) {
					e.printStackTrace();
				}
				System.out.println("strValue : "+strValue);
				
				strOK = "{ \"result\":\"OK\", \"nCode\":\""+nCode+"\", \"balance\":\""+strValue+"\" }";
			} else { // fail
				// values to pass to the web
				String strValue = "";
				strOK = "{ \"result\":\"FAIL\", \"nCode\":\""+nCode+"\", \"balance\":\""+strValue+"\" }";
			}
		}
		
		System.out.println("strOK : "+strOK);
		servletResponse.setHeader("Access-Control-Allow-Origin", "*");
		
		return strOK;
	}

	/*
	 * View your Wallet Balance.
	 */
	@RequestMapping("/svm/wallet/getWalletInfo")
	@ResponseBody
	public String getWalletInfo(HttpServletRequest request, @RequestBody HashMap<Object,Object> map, ModelMap model, HttpServletResponse servletResponse) throws UnknownHostException, IOException {
		String strOK = "{ \"result\":\"OK\" }";

		//String strPID = null;
		String strPID = "PID";
		String strVER = "10000";	
		String walletId= (String)map.get("walletId");
		String serviceId = StringUtil.nvl(map.get("serviceId"),GlobalProperties.getProperty("project_serviceid"));

		JSONObject joResult = null;
		if(strPID.equals("")) strPID = KeyManager.PID;
		if(strVER.equals("")) strVER = KeyManager.VERSION;

		joResult = CPWalletUtil.getValueManager(serviceId, ApiHelper.COIN_CHAIN, "queryWalletInfo", new String[] {strPID, strVER, walletId, "", "", ""});

		long nCode = (Long)joResult.getOrDefault("ec",-1L);

		if (nCode == 0) { // successful
			// values to pass to the web
			String strValue = joResult.get("value").toString();
			String nm = "";
			Long mvd = 0L;	// Daily transfer limits

			JSONParser jpTemp = new JSONParser();
			JSONObject joInfo;
			try {
				joInfo = (JSONObject)jpTemp.parse(strValue);
				if(joInfo!=null) {
					nm = (String)joInfo.get("nm");
					mvd = (Long)joInfo.get("mvd");
				}
			} catch (ParseException e) {
				e.printStackTrace();
			}
			
			strOK = "{ \"result\":\"OK\", \"nCode\":\""+nCode+"\", \"nm\":\""+nm+"\", \"mvd\":\""+mvd+"\" }";
		} else { // fail
			// values to pass to the web
			strOK = "{ \"result\":\"FAIL\", \"nCode\":\""+nCode+"\", \"nm\":\"\", \"mvd\":\"\" }";
		}
		
		servletResponse.setHeader("Access-Control-Allow-Origin", "*");
		
		return strOK;
	}

	/*
	 * View your Wallet Balance.
	 */
	@RequestMapping("/svm/wallet/queryWalletInfo")
	@ResponseBody
	public String queryWalletInfo(HttpServletRequest request, @RequestBody HashMap<Object,Object> map, ModelMap model, HttpServletResponse servletResponse) throws UnknownHostException, IOException {
		String strOK = "{ \"result\":\"OK\" }";

		//String strPID = null;
		String strPID = "PID";
		String strVER = "10000";	
		String walletId= (String)map.get("walletId");
		String serviceId = StringUtil.nvl(map.get("serviceId"),GlobalProperties.getProperty("project_serviceid"));

		JSONObject joResult = null;
		if(strPID.equals("")) strPID = KeyManager.PID;
		if(strVER.equals("")) strVER = KeyManager.VERSION;

		joResult = CPWalletUtil.getValueManager(serviceId, ApiHelper.COIN_CHAIN, "queryWalletInfo", new String[] {strPID, strVER, walletId, "", "", ""});

		long nCode = (Long)joResult.getOrDefault("ec",-1L);

		if (nCode == 0) { // successful
			// values to pass to the web
			String strValue = joResult.get("value").toString();
			String nm = "";		// wallet name
			String owner = "";	// nick name
			String mno = "";	// Registration note
			Long mvd = 0L;		// Daily transfer limits

			JSONParser jpTemp = new JSONParser();
			JSONObject joInfo;
			try {
				joInfo = (JSONObject)jpTemp.parse(strValue);
				if(joInfo!=null) {
					owner = (String)joInfo.get("owner");
					nm = (String)joInfo.get("nm");
					mvd = (Long)joInfo.get("mvd");
					mno = (String)joInfo.get("mno");
				}
			} catch (ParseException e) {
				e.printStackTrace();
			}
			
			strOK = "{ \"result\":\"OK\", \"owner\":\""+owner+"\", \"nm\":\""+nm+"\", \"mvd\":\""+mvd+"\", \"mno\":\""+mno+"\", \"ec\":\""+nCode+"\" }";
		} else { // fail
			// values to pass to the web
			strOK = "{ \"result\":\"FAIL\", \"ref\":\""+joResult.get("ref").toString()+"\", \"ec\":\""+nCode+"\" }";
		}
		
		servletResponse.setHeader("Access-Control-Allow-Origin", "*");
		
		return strOK;
	}
	
	/*
	 * Wallet chain registration
	 */
	@RequestMapping("/svm/wallet/setWalletInfo")
	@ResponseBody
	public String setWalletInfo(HttpServletRequest request, @RequestBody HashMap<Object,Object> map, ModelMap model, HttpServletResponse servletResponse) throws UnknownHostException, IOException {
		String strOK = "{ \"result\":\"OK\" }";

		String npid= (String)map.get("npid");
		List<String> arrArgs=(ArrayList<String>)map.get("parameterArgs");
		String serviceId = StringUtil.nvl(map.get("serviceId"),GlobalProperties.getProperty("project_serviceid"));
		
		if(arrArgs!=null) {
			JSONObject joResult = null;

			joResult = CPWalletUtil.getValue(serviceId, ApiHelper.COIN_CHAIN, "setWalletInfo", npid, arrArgs.toArray(new String[0]) );

			long nCode = (Long)joResult.getOrDefault("ec",-1L);

			if (nCode == 0) { // successful
				// values to pass to the web
				String strValue = joResult.get("value").toString();
				System.out.println("strValue : "+strValue);

				JSONParser jpTemp = new JSONParser();
				JSONObject joInfo;
				try {
					joInfo = (JSONObject)jpTemp.parse(strValue);
					if(strValue!=null) {
						strValue = (String)joInfo.get("balance");
					}
				} catch (ParseException e) {
					e.printStackTrace();
				}
				System.out.println("strValue : "+strValue);
				
				strOK = "{ \"result\":\"OK\", \"nCode\":\""+nCode+"\", \"balance\":\""+strValue+"\" }";
			} else { // fail
				// values to pass to the web
				String strValue = "";
				strOK = "{ \"result\":\"FAIL\", \"nCode\":\""+nCode+"\", \"balance\":\""+strValue+"\" }";
			}
		}
		
		System.out.println("strOK : "+strOK);
		servletResponse.setHeader("Access-Control-Allow-Origin", "*");
		
		return strOK;
	}

	/*
	 * Coin Trading Registration
	 */
	@RequestMapping("/svm/wallet/createTrans")
	@ResponseBody
	public String createTrans(HttpServletRequest request, @RequestBody HashMap<Object,Object> map, ModelMap model, HttpServletResponse servletResponse) throws UnknownHostException, IOException {
		String strOK = "{ \"result\":\"OK\" }";

		//String strPID = null;
		String npid= StringUtil.nvl((String)map.get("npid"));
		String serviceId = StringUtil.nvl(map.get("serviceId"),GlobalProperties.getProperty("project_serviceid"));
		List<String> arrArgs=(ArrayList<String>)map.get("parameterArgs");

		JSONObject joResult = null;
		if(arrArgs!=null) {
			joResult = CPWalletUtil.putValue(serviceId, ApiHelper.COIN_CHAIN, "createTrans", npid, arrArgs.toArray(new String[0]) );

			long nCode = (Long)joResult.getOrDefault("ec",-1L);
		}
		
		System.out.println("joResult : "+joResult);
		servletResponse.setHeader("Access-Control-Allow-Origin", "*");
		
		return joResult.toString();
	}

	/*
	 * Owner View recent transaction history
	 */
	@RequestMapping("/svm/wallet/getNTransHistory")
	@ResponseBody
	public String getNTransHistory(HttpServletRequest request, @RequestBody HashMap<Object,Object> map, ModelMap model, HttpServletResponse servletResponse) throws UnknownHostException, IOException {
		String strOK = "{ \"result\":\"OK\" }";

		String npid= (String)map.get("npid");
		String serviceId = StringUtil.nvl(map.get("serviceId"),GlobalProperties.getProperty("project_serviceid"));
		List<String> arrArgs=(ArrayList<String>)map.get("parameterArgs");

		if(arrArgs!=null) {
			JSONObject joResult = null;

			joResult = CPWalletUtil.getValue(serviceId, ApiHelper.COIN_CHAIN, "getNTransHistory", npid, arrArgs.toArray(new String[0]) );

			long nCode = (Long)joResult.getOrDefault("ec",-1L);

			if (nCode == 0) { // successful
				// values to pass to the web
				String strValue = joResult.get("value").toString();

				strOK = "{ \"result\":\"OK\", \"nCode\":\""+nCode+"\", \"value\":"+strValue+" }";
			} else { // fail
				// values to pass to the web
				String strValue = "";
				strOK = "{ \"result\":\"FAIL\", \"nCode\":\""+nCode+"\", \"value\":\"\" }";
			}
		}

		System.out.println("strOK : "+strOK);

		return strOK;
	}

	/*
	 * manager Wallet balance check.
	 */
	@RequestMapping("/svm/wallet/queryNTransHistory")
	@ResponseBody
	public String queryNTransHistory(HttpServletRequest request, @RequestBody HashMap<Object,Object> map, ModelMap model, HttpServletResponse servletResponse) throws UnknownHostException, IOException {
		String strOK = "{ \"result\":\"OK\" }";

		//String strPID = null;
		String strPID = KeyManager.PID;
		String strVER = KeyManager.VERSION;
		String serviceId = StringUtil.nvl(map.get("serviceId"),GlobalProperties.getProperty("project_serviceid"));
		List<String> arrArgs=(ArrayList<String>)map.get("parameterArgs");
		arrArgs.add("");
		arrArgs.add("");
		arrArgs.add("");

		JSONObject joResult = null;
		if(strPID.equals("")) strPID = KeyManager.PID;
		if(strVER.equals("")) strVER = KeyManager.VERSION;

		joResult = CPWalletUtil.getValueManager(serviceId, ApiHelper.COIN_CHAIN, "queryNTransHistory", arrArgs.toArray(new String[0]));

		long nCode = (Long)joResult.getOrDefault("ec",-1L);

		if (nCode == 0) { // successful
			// values to pass to the web
			String strValue = joResult.get("value").toString();
			
			strOK = "{ \"result\":\"OK\", \"value\":"+strValue+" }";
		} else { // fail
			// values to pass to the web
			strOK = "{ \"result\":\"FAIL\", \"value\":{} }";
		}
		
		return strOK;
	}

	/*
	 * Search transaction history display
	 */
	@RequestMapping("/svm/wallet/getTransHistory")
	@ResponseBody
	public String getTransHistory(HttpServletRequest request, @RequestBody HashMap<Object,Object> map, ModelMap model, HttpServletResponse servletResponse) throws UnknownHostException, IOException {
		String strOK = "{ \"result\":\"OK\" }";

		String npid= (String)map.get("npid");
		String serviceId = StringUtil.nvl(map.get("serviceId"),GlobalProperties.getProperty("project_serviceid"));
		List<String> arrArgs=(ArrayList<String>)map.get("parameterArgs");

		if(arrArgs!=null) {
			JSONObject joResult = null;

			joResult = CPWalletUtil.getValue(serviceId, ApiHelper.COIN_CHAIN, "getTransHistory", npid, arrArgs.toArray(new String[0]) );

			long nCode = (Long)joResult.getOrDefault("ec",-1L);

			if (nCode == 0) { // successful
				// values to pass to the web
				String strValue = joResult.get("value").toString();

				strOK = "{ \"result\":\"OK\", \"nCode\":\""+nCode+"\", \"value\":"+strValue+" }";
			} else { // fail
				// values to pass to the web
				String strValue = "";
				strOK = "{ \"result\":\"FAIL\", \"nCode\":\""+nCode+"\", \"value\":\"\" }";
			}
		}

		System.out.println("strOK : "+strOK);

		return strOK;
	}

	/*
	 * Register wallet information in the block chain.
	 */
	@RequestMapping("/svm/wallet/reserveRegisterWallet")
	@ResponseBody
	public String reserveRegisterWallet(HttpServletRequest request, @RequestBody HashMap<Object,Object> map, ModelMap model, HttpServletResponse servletResponse) throws UnknownHostException, IOException {
		String strOK = "{ \"result\":\"OK\" }";

		//String strPID = null;
		String npid= StringUtil.nvl((String)map.get("npid"));
		String serviceId = StringUtil.nvl(map.get("serviceId"),GlobalProperties.getProperty("project_serviceid"));
		List<String> arrArgs=(ArrayList<String>)map.get("parameterArgs");

		JSONObject joResult = null;
		if(arrArgs!=null) {
			joResult = CPWalletUtil.putValue(serviceId, ApiHelper.COIN_CHAIN, "reserveRegisterWallet", npid, arrArgs.toArray(new String[0]) );

			long nCode = (Long)joResult.getOrDefault("ec",-1L);
			if (nCode == 0) { // successful
				// values to pass to the web
				String strValue = joResult.get("value").toString();
				npid = joResult.get("npid").toString();
				String reserve_id = "";
				String fee = "";

				JSONParser jpTemp = new JSONParser();
				JSONObject joInfo;
				try {
					joInfo = (JSONObject)jpTemp.parse(strValue);
					if(strValue!=null) {
						reserve_id = (String)joInfo.get("reserve_id");
						fee = (String)joInfo.get("fee");
					}
				} catch (ParseException e) {
					e.printStackTrace();
				}
				System.out.println("strValue : "+strValue);
				
				strOK = "{ \"result\":\"OK\", \"fee\":\""+fee+"\", \"reserve_id\":\""+reserve_id+"\", \"ec\":\""+nCode+"\", \"npid\":\""+npid+"\" }";
			} else { // fail
				strOK = "{ \"result\":\"FAIL\", \"fee\":\"\", \"reserve_id\":\"\", \"ec\":\""+nCode+"\", \"npid\":\""+npid+"\" }";
			}
		}
		
		System.out.println("strOK : "+strOK);
		
		return strOK.toString();
	}

	/*
	 * Payment of Fees
	 * API for final storage in chain after registering wallet
	 */
	@RequestMapping("/svm/wallet/payFeeForReserve")
	@ResponseBody
	public String payFeeForReserve(HttpServletRequest request, @RequestBody HashMap<Object,Object> map, ModelMap model, HttpServletResponse servletResponse) throws UnknownHostException, IOException {
		String strOK = "{ \"result\":\"OK\" }";

		//String strPID = null;
		String npid= StringUtil.nvl((String)map.get("npid"));
		String serviceId = StringUtil.nvl(map.get("serviceId"),GlobalProperties.getProperty("project_serviceid"));
		List<String> arrArgs=(ArrayList<String>)map.get("parameterArgs");

		JSONObject joResult = null;
		if(arrArgs!=null) {
			joResult = CPWalletUtil.putValue(serviceId, ApiHelper.COIN_CHAIN, "payFeeForReserve", npid, arrArgs.toArray(new String[0]) );

			long nCode = (Long)joResult.getOrDefault("ec",-1L);
			if (nCode == 0) { // successful
				strOK = "{ \"result\":\"OK\", \"ref\":\"Success\", \"ec\":\""+nCode+"\"}";
			} else { // fail
				strOK = "{ \"result\":\"FAIL\", \"ref\":\""+joResult.get("ref").toString()+"\", \"ec\":\""+nCode+"\"}";
			}
		}
		
		System.out.println("joResult : "+joResult);
		servletResponse.setHeader("Access-Control-Allow-Origin", "*");
		
		return joResult.toString();
	}

	 /*
	  * Cancel add Data 
	  */
	@RequestMapping("/svm/wallet/removeReserve")
	@ResponseBody
	public String removeReserve(HttpServletRequest request, @RequestBody HashMap<Object,Object> map, ModelMap model, HttpServletResponse servletResponse) throws UnknownHostException, IOException {
		String strOK = "{ \"result\":\"OK\" }";

		String npid= StringUtil.nvl((String)map.get("npid"));
		String serviceId = StringUtil.nvl(map.get("serviceId"),GlobalProperties.getProperty("project_serviceid"));
		List<String> arrArgs=(ArrayList<String>)map.get("parameterArgs");
		
		if(arrArgs!=null) {
			JSONObject joResult = null;

			joResult = CPWalletUtil.putValue(serviceId, ApiHelper.COIN_CHAIN, "removeReserve", npid, arrArgs.toArray(new String[0]) );

			long nCode = (Long)joResult.getOrDefault("ec",-1L);

			if (nCode == 0) { // successful
				strOK = "{ \"result\":\"OK\" }";
			} else { // fail
				// values to pass to the web
				strOK = "{ \"result\":\"FAIL\" }";
			}
		}
		
		System.out.println("strOK : "+strOK);
		
		return strOK;
	}

	/*
	 * Wallet disable registration
	 */
	@RequestMapping("/svm/wallet/walletDisableRegist")
	@ResponseBody
	public String walletDisableRegist(HttpServletRequest request, @RequestBody HashMap<Object,Object> map, ModelMap model, HttpServletResponse servletResponse) throws UnknownHostException, IOException {
		String strOK = "{ \"result\":\"OK\" }";

		String npid= StringUtil.nvl((String)map.get("npid"));
		String serviceId = StringUtil.nvl(map.get("serviceId"),GlobalProperties.getProperty("project_serviceid"));
		List<String> arrArgs=(ArrayList<String>)map.get("parameterArgs");

		JSONObject joResult = null;
		if(arrArgs!=null) {
			joResult = CPWalletUtil.putValue(serviceId, ApiHelper.COIN_CHAIN, "registerBlacklistUser", npid, arrArgs.toArray(new String[0]) );

			long nCode = (Long)joResult.getOrDefault("ec",-1L);
			if (nCode == 0) { // successful
				strOK = "{ \"result\":\"OK\", \"ref\":\"Success\", \"ec\":\""+nCode+"\"}";
			} else { // fail
				strOK = "{ \"result\":\"FAIL\", \"ref\":\""+joResult.get("ref").toString()+"\", \"ec\":\""+nCode+"\"}";
			}
		}
		
		System.out.println("joResult : "+joResult);
		
		return joResult.toString();
	}
}


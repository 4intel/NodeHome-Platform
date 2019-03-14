<%@page import="net.fourintel.cmm.service.GlobalProperties"%>
<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="net.fourintel.cmm.service.GlobalProperties"%>

<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>
<!DOCTYPE html>
<html>
	<head>
    <meta http-equiv="content-type" content="text/html;charset=utf-8" />
    <title></title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta content="width=device-width, initial-scale=1.0; maximum-scale=1.0; minimum-scale=1.0; user-scalable=no;" name="viewport" />    
    
    <!-- bootstrap 3.3.7 -->
    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet" id="bootstrap-css">
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    <link href="/bootstrap/assets/css/material-common.css" rel="stylesheet">
    <script src="/js/tapp_interface.js"></script>

	<link href="/css/loading.css" rel="stylesheet" />

	<script>
	$.ajaxSetup({ async:false }); // AJAX calls in order

	var serviceList = null;
	var myServices = "${serviceIds }";
	
	function searchSubmit() {
		frm.action="/svm/common/serviceSelection";
		frm.target="_self";
		frm.submit();
	}
	
	// Function to call as soon as it is loaded from the App
	function AWI_OnLoadFromApp(dtype) {
		 // Activate AWI_XXX method
		 AWI_ENABLE = true;
		 AWI_DEVICE = dtype;
	}
	
	// Script to run as soon as loaded from the web
	$(function() {

		$('#loading').css('display','block');

		setTimeout(function () {
			var sQuery = {"requestUrl" : "<%=GlobalProperties.getProperty("project_seedHost")%>/getServiceList?searchText=${param.searchText}&searchType=${param.searchType}&searchOrder=${param.searchOrder}"};
			var data = callCorsJsonAPI(sQuery);
			
	    	if(data['result']=="LIST" && data['list']!="") {
	    			serviceList = data['list'];
	    			var sHTML='<tr style="background-color:#ffffff;" >'
				  		      + '<td style="text-align:center;vertical-align:middle;" width="20%"><spring:message code="title.select.service" /></td>'
				  		      + '<td style="text-align:center;vertical-align:middle;" width="20%"><spring:message code="title.default.service" /></td>'
				  		      + '<td style="text-align:left;vertical-align:middle;word-break:break-all;" width="60%"><spring:message code="title.service.name" /></td></tr>';
	    			var elmtTBody = $('#id_servicelist_table_tbody');
	    			for(var i=0; i < serviceList.length ; i ++) {
	    				sHTML += '<tr style="background-color:#ffffff;" >'
				  		      + '<td style="text-align:center;vertical-align:middle;"><input type="checkbox" id="cur'+i+'" name="svr" value="' + serviceList[i]['serviceId'] + '" onclick="chkRadio('+i+')"><input type="hidden" name="svrnm" value="' + serviceList[i]['serviceName'] + '" /></td>'
				  		      + '<td style="text-align:center;vertical-align:middle;"><input type="radio" id="cur_svr'+i+'" name="cur_svr" value="' + serviceList[i]['serviceId'] + '" disabled="disabled"></td>'
	    			  		      + '<td style="text-align:left;vertical-align:middle;word-break:break-all;">' + serviceList[i]['serviceName'] + '</td></tr>';
	    			}
	    			elmtTBody.html(sHTML);
	    	}
	    	if(serviceList!=null && serviceList.length>0 && myServices!="") {
	    		if(serviceList.length==1) {
	    			if(myServices.indexOf((frm.svr.value))>-1) {
	    				frm.svr.checked = true;
	    				frm.cur_svr.disabled = true;
	    			}
	    		} else {
		    		for(var i=0; i<frm.svr.length; i++) {
		    			if(myServices.indexOf((frm.svr[i].value))>-1) {
		    				frm.svr[i].checked = true;
		    				frm.cur_svr[i].disabled = false;
		    			}
		    		}	
	    		}
	    	}
		},10);
		$('#loading').css('display','none');
	});
	
	function chkRadio(pno) {
		if($('#cur'+pno).is(':checked')) {
			$('#cur_svr'+pno).attr("disabled",false);
		} else {
			$('#cur_svr'+pno).attr("disabled",true);
		}
	}
	
	function selectionSubmit() {
		var saveStr = null;
		var curService = "";
		var tempStr = "";
		
		var chk = false;
		
		if(frm.svr.length) {
			for(var i=0; i<frm.svr.length; i++) {
				if(frm.svr[i].checked) chk = true;
			}	
		} else {
			if(frm.svr.checked) chk = true;
		}
		if(!chk) {
			alert('<spring:message code="common.choice.service" />');
			return;
		}

		if(frm.cur_svr.length) {
			for(var i=0; i<frm.cur_svr.length; i++) {
				if(frm.cur_svr[i].checked) {
					curService = frm.cur_svr[i].value;
				}
			}
		} else {
			if(frm.cur_svr.checked) {
				curService = frm.cur_svr.value;	
			}
		}
		if(curService=="") {
			alert('<spring:message code="common.choice.default.service" />');
			return;
		}

		$('#loading').css('display','block');

		setTimeout(function () {
			if(frm.svr.length) {
				for(var i=0; i<frm.svr.length; i++) {
					if(frm.svr[i].checked) { 
						tempStr += "{\"serviceId\":\""+frm.svr[i].value+"\",\"serviceName\":\""+frm.svrnm[i].value+"\",\"active\":";
						if(frm.svr[i].value==curService)
							tempStr += "\"Y\"";
						else 
							tempStr += "\"N\"";
						tempStr += "},";
					}
				}
			} else {
				if(frm.svr.checked) { 
					tempStr += "{\"serviceId\":\""+frm.svr.value+"\",\"serviceName\":\""+frm.svrnm.value+"\",\"active\":";
					if(frm.svr.value==curService)
						tempStr += "\"Y\"";
					else 
						tempStr += "\"N\"";
					tempStr += "},";
				}
			}
			if(tempStr.length>0) tempStr = tempStr.substring(0,tempStr.length-1);
			saveStr = tempStr;

			// Save to service terminal
			joReturn = AWI_setServiceList(saveStr);
		},10);
	}

	</script>
</head>
<body>
	<div id="loading" class="loading" style="display:none;"><img id="loading_img" alt="loading" src="/images/viewLoading.gif" /></div>

	<div class="container">
		
		<div class="row">
		    <div class="col-xs-12 col-sm-8 col-md-6 col-sm-offset-2 col-md-offset-3">
				
				<form name="frm" id="frm" method="post" onsubmit="return false;" class="form-horizontal">
				<input type="hidden" name="serviceIds" value="${serviceIds }" />
				
				<h2><spring:message code="button.service.list" /> <br /><small>Select Platform Services.</small></h2>
				<hr class="colorgraph">
				
				<div class="row">
					<div class="col-xs-6" style="margin-bottom:5px;">
						<select name="searchType" id="searchType" class="form-control input-lg">
							<option value="1" <c:if test="${param.searchType=='1'}">selected="selected"</c:if>><spring:message code="title.service.name" /></option>
							<option value="2" <c:if test="${empty param.searchType || param.searchType=='' || param.searchType=='2'}">selected="selected"</c:if>><spring:message code="table.regdate" /></option>
						</select>
					</div>
					<div class="col-xs-6" style="margin-bottom:5px;">
						<select name="searchOrder" id="searchOrder" class="form-control input-lg">
							<option value="0" <c:if test="${empty param.searchOrder || param.searchOrder=='' || param.searchOrder=='0'}">selected="selected"</c:if>><spring:message code="title.sort.asc" /></option>
							<option value="1" <c:if test="${param.searchOrder=='1'}">selected="selected"</c:if>><spring:message code="title.sort.desc" /></option>
						</select>
					</div>
					<div class="col-xs-12" style="margin-top:5px;padding:0 30px 0 30px;">
					    <div class="form-group">
							<div class="input-group">
						      <div class="input-group-addon"><spring:message code="title.search" /></div>
						      <input type="text" class="form-control input-lg" value="${param.searchText}" id="searchText" name="searchText"  />
						    </div>
						</div> 
					</div>
				</div>
				<div class="row">
					<div class="col-xs-12"><input type="button" value="<spring:message code="button.search" />" class="btn btn-success btn-lg btn-block" onclick="searchSubmit();" tabindex="5" /></div>
				</div>

              	<div class="card">
	                <div class="card-body table-responsive">		    	
						<table class="table table-hover" style="text-align:center;">
						    <thead class="thead-light">
						    </thead>
							<tbody id='id_servicelist_table_tbody'>
							</tbody>
						</table>
	                </div>
              	</div>
                
				<hr class="colorgraph">
				<div class="row">
					<div class="col-xs-12"><input type="button" value="<spring:message code="button.create" />" class="btn btn-success btn-lg btn-block" onclick="selectionSubmit();" tabindex="5" /></div>
				</div>
				<div style="padding-bottom:20px;"></div>
				</form>
			</div>
		</div>
				
	</div>
	
</body>
</html>
package net.fourintel.cmm.config;

import javax.servlet.FilterRegistration;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletRegistration;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.WebApplicationInitializer;
import org.springframework.web.context.ContextLoaderListener;
import org.springframework.web.context.support.XmlWebApplicationContext;
import org.springframework.web.servlet.DispatcherServlet;

import net.fouri.libs.bitutil.model.NetConfig;
import net.fouri.libs.bitutil.model.NetConfig.NetworkType;
import net.fourintel.cmm.service.GlobalProperties;
import net.fourintel.svm.common.biz.CoinListVO;
import net.fourintel.svm.common.biz.NAHostVO;
import net.fourintel.svm.common.biz.ServiceWalletVO;
import net.fourintel.svm.common.util.KeyManager;

public class InitWebApplicationInitializer implements WebApplicationInitializer {

	private static final Logger LOGGER = LoggerFactory.getLogger(InitWebApplicationInitializer.class);
	
	@Override
	public void onStartup(ServletContext servletContext) throws ServletException {
		LOGGER.debug("WebApplicationInitializer START-============================================");
		
		//-------------------------------------------------------------
		// ServletContextListener Condif
		//-------------------------------------------------------------
		servletContext.addListener(new net.fourintel.cmm.context.WebServletContextListener());
				
		//-------------------------------------------------------------
		// Spring CharacterEncodingFilter setup
		//-------------------------------------------------------------
		FilterRegistration.Dynamic characterEncoding = servletContext.addFilter("encodingFilter", new org.springframework.web.filter.CharacterEncodingFilter());
		characterEncoding.setInitParameter("encoding", "UTF-8");
		characterEncoding.setInitParameter("forceEncoding", "true");
		characterEncoding.addMappingForUrlPatterns(null, false, "/*");
		//characterEncoding.addMappingForUrlPatterns(EnumSet.of(DispatcherType.REQUEST), true, "*.do");
		
		//-------------------------------------------------------------
		// Spring ServletContextListener setup
		//-------------------------------------------------------------
		XmlWebApplicationContext rootContext = new XmlWebApplicationContext();
		rootContext.setConfigLocations(new String[] { "classpath*:resources/spring/com/**/context-*.xml" });
		rootContext.refresh();
		rootContext.start();
		
		servletContext.addListener(new ContextLoaderListener(rootContext));
		
		//-------------------------------------------------------------
		// Spring ServletContextListener setup
		//-------------------------------------------------------------
		XmlWebApplicationContext xmlWebApplicationContext = new XmlWebApplicationContext();
		xmlWebApplicationContext.setConfigLocation("/WEB-INF/config/fouri/springmvc/fouri-com-*.xml");
		ServletRegistration.Dynamic dispatcher = servletContext.addServlet("dispatcher", new DispatcherServlet(xmlWebApplicationContext));
		dispatcher.setLoadOnStartup(1);
		dispatcher.addMapping("/");
		dispatcher.addMapping("*.do");
		
		//-------------------------------------------------------------
		// Spring RequestContextListener setup
		//-------------------------------------------------------------
		servletContext.addListener(new org.springframework.web.context.request.RequestContextListener());
		
		LOGGER.debug("WebApplicationInitializer END-============================================");

		//----------------------------------
		// set default net type
		String strValue = GlobalProperties.getProjectNet();
		NetworkType emType = NetworkType.TESTNET; 
		if(strValue.equalsIgnoreCase("MAINNET"))
			emType = NetworkType.MAINNET;
		else if(strValue.equals("DEBUGNET"))
			emType = NetworkType.DEBUGNET;
		NetConfig.setDefaultNet(emType);

		//----------------------------------
		KeyManager.reloadManagerKey();
		CoinListVO.reloadCoinInfo();	// load coin info
		CoinListVO.reloadCoinPolicy();	// load coin policy
		ServiceWalletVO.reloadWalletInfo();	// load service node wallet info
		NAHostVO.reloadNAHosts();	// load NA host list
		//----------------------------------
		
	}
	
}

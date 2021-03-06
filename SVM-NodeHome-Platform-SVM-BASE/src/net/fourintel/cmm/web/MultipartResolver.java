package net.fourintel.cmm.web;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletContext;

import org.apache.commons.fileupload.FileItem;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartException;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.commons.CommonsMultipartFile;
import org.springframework.web.multipart.commons.CommonsMultipartResolver;

public class MultipartResolver extends CommonsMultipartResolver {

	private static final Logger LOGGER = LoggerFactory.getLogger(MultipartResolver.class);

	public MultipartResolver() {}

    public MultipartResolver(ServletContext servletContext) {
	super(servletContext);
    }

    @SuppressWarnings("rawtypes")
	@Override
    protected MultipartParsingResult parseFileItems(List fileItems, String encoding) {

    MultiValueMap<String, MultipartFile> multipartFiles = new LinkedMultiValueMap<String, MultipartFile>();
	Map<String, String[]> multipartParameters = new HashMap<String, String[]>();

	// Extract multipart files and multipart parameters.
	for (Iterator<?> it = fileItems.iterator(); it.hasNext();) {
	    FileItem fileItem = (FileItem)it.next();

	    if (fileItem.isFormField()) {

		String value = null;
		if (encoding != null) {
		    try {
			value = fileItem.getString(encoding);
		    } catch (UnsupportedEncodingException ex) {
		    	LOGGER.warn("Could not decode multipart item '{}' with encoding '{}': using platform default"
		    			, fileItem.getFieldName(), encoding);
			value = fileItem.getString();
		    }
		} else {
		    value = fileItem.getString();
		}
		String[] curParam = (String[])multipartParameters.get(fileItem.getFieldName());
		if (curParam == null) {
		    // simple form field
		    multipartParameters.put(fileItem.getFieldName(), new String[] { value });
		} else {
		    // array of simple form fields
		    String[] newParam = StringUtils.addStringToArray(curParam, value);
		    multipartParameters.put(fileItem.getFieldName(), newParam);
		}
	    } else {

		if (fileItem.getSize() > 0) {
		    // multipart file field
		    CommonsMultipartFile file = new CommonsMultipartFile(fileItem);

		    List<MultipartFile> fileList = new ArrayList<MultipartFile>();
		    fileList.add(file);

		    if (multipartFiles.put(fileItem.getName(), fileList) != null) { // CHANGED!!
		    	throw new MultipartException("Multiple files for field name [" + file.getName() + "] found - not supported by MultipartResolver");
		    }
			LOGGER.debug("Found multipart file [{"+file.getName()+"}] of size {"+file.getSize()+"} bytes with original filename [{"+ file.getOriginalFilename()+"}], stored {"+file.getStorageDescription()+"}");

		}

	    }
	}

	return new MultipartParsingResult(multipartFiles, multipartParameters, null);
    }
}

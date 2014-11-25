/**
 *	@author: Andrey Gavrikov (westbrook)
 *	@date: 2013-10-25
 *	@description:
 *		Main Javascript code for OpportunityPitch.page
 *		Displays a VF page for Opportunity entry used on Account Chatter Publisher
 *
 *		see Jira: Gl-10 for detailed requriements
 *
 *	Version History :   
 *		
 */
var jq = jQuery.noConflict();


//override standard lookupPick() function
(function() {
  // 
  var originalLookupPick = window.lookupPick;
  window.lookupPick = function() {
	//["j_id0:j_id4", "j_id0:j_id4:AdvertiserInput_lkid", "j_id0:j_id4:AdvertiserInput", "", "001L000000JdcMt", "Advertiser Test 2", "null", ""] 

    var retVal = originalLookupPick.apply( this, arguments );
	//call custom logic
	onLookupChange(arguments[2], arguments[4], arguments[5]);
	return retVal;
  };
})();

var lookupChangeHandlers = [];
function onLookupChange(inputId, newId, newText) {
	//alert("inputId=" + inputId + "; newId=" + newId + "; newText=" + newText);
	var handler = lookupChangeHandlers[inputId];
	if (handler) {
		handler(newId, newText);
	}
}
function selectOrAdd(selectElementId, optionValue, optionText, hiddenInputId) {
	var elem = jq('select[id="'+selectElementId+'"]');
	var hasId = elem.children('option').filter('[value="'+optionValue +'"]').length > 0;

	if (!hasId) {
		//append new option
		elem.append("<option value='"+optionValue+"'>"+optionText+"</option>");
	}
	elem.val(optionValue);
	jq('[id="'+hiddenInputId+'"]').val(optionValue);
	//call onchange of select element
	jq(elem).change();
}


/** Date Handler **/
var dateHandler = (function(jq) {
	var pub = {};
	var formatByLocale = [];
	formatByLocale['default'] = {"format":"dd/mm/yyyy", "separator":"/"};
	formatByLocale['en_US'] = {"format":"mm/dd/yyyy", "separator":"/"};
	formatByLocale['en_GB'] = {"format":"dd/mm/yyyy", "separator":"/"};

	var getFormatObj = function () {
		var formatEntry = formatByLocale[MERGE_FIELDS.getUserLocale()];
		if (!formatEntry) {
			//default
			formatEntry = formatByLocale['default'];
		}
		return formatEntry;
	};
	pub.getFormat = function () {
		return getFormatObj().format;
	};
	pub.validate = function (val) {
		return null !== pub.parse(val);
	};
	pub.parse = function (val) {
		if (!val) {
			return null;
		}
		var formatObj = getFormatObj();
		var format = formatObj.format;
		var separator = formatObj.separator;
		var tokens = format.split(separator);
		var day, month, year;
		var resDate = null;
		try {
			var values = val.split(separator);
			if (tokens[0].indexOf('d') >=0) {
				day = values[0];
				month = values[1];
			} else {
				month = values[0];
				day = values[1];
			}
			year = values[2];
			if (!day || !month || !year) {
				return null;
			}
			resDate = new Date(year, month-1, day);
			if (jq.type(resDate) !== "date" || resDate == "Invalid Date") {
				return null;
			}
		} catch (ex) {
			return null;
		}
		return resDate;
	};
	return pub;

})(jQuery);		

/** Number Handler **/
var numberHandler = (function(jq) {
	var pub = {};
	pub.validate = function (val) {
		return isNumber(val);
	};
	function isNumber(n) {
		//return !isNaN(parseFloat(n)) && isFinite(n);
		return jq.isNumeric(n);
	}
	return pub;

})(jQuery);		

var currencyKMB_Handler = (function(jq) {
	var pub = {};
	var endsWithPattern = /\d+[mMkKbB]{1}$/;

	pub.validate = function (val) {
		
		if (endsWithPattern.test(val)) {
			return numberHandler.validate(val.substring(0, val.length-1));
		}
		return numberHandler.validate(val);
	};

	pub.expand = function (val) {

		if (endsWithPattern.test(val)) {
			var multipliers = [];
			multipliers["K"] = 1000;
			multipliers["M"] = 1000000;
			multipliers["B"] = 1000000000;
			var multiplier = val.substring(val.length-1).toUpperCase();

			return val.substring(0, val.length-1) * multipliers[multiplier];
		}
		//no K or B or M,return as is
		return val;
	};

	return pub;

})(jQuery);		

var handlerByXType = [];
handlerByXType["date"] = dateHandler;
handlerByXType["number"] = numberHandler;
handlerByXType["currencyKMB"] = currencyKMB_Handler;


/** Some unctions which do not belong to any specific part of the app **/
var Utils = (function(jq) {
	var pub = {};
	/**
	 * execute function using its name as string
	 * e.g.: 
	 * validate -> validate()
	 * pager.canFinish -> pager.canFinish()
	 * only supports single level namespace
	 */
	pub.exec = function(val, param) {
		if (val) {
			try {
				//check if namespace is used
				var parts = val.split(".");
				if (parts.length > 1) {
					//namespace
					return window[parts[0]][parts[1]](param);
				} else {
					//no namespace
					return window[parts[0]](param);
				}
			} catch (eIgnore) {}
		}
	};

	return pub;
})(jQuery);		

/* control with isEnabled attribute */
(function(jq){
	// Store a reference to the original show method.
	var originalShowMethod = jq.fn.show;
 
	// Define overriding method.
	jq.fn.show = function(){
		var jqElem = jq(this);
		var validator = jqElem.attr("isEnabled");
		if (validator) {
			if (Utils.exec(validator)) {
				jqElem.removeClass("disabled");
				jqElem.prop("disabled", false);
			} else {
				jqElem.addClass("disabled");
				jqElem.prop("disabled", true);
			}
		}

		// Execute the original method.
		return originalShowMethod.apply( this, arguments );
	};
})(jQuery);

/** Main Pagination Control **/
var pager = (function(jq) {
	var pub = {};
	
	var currentPage = 1;
	var MIN_PAGE = 1;
	var MAX_PAGE = 3;
	var longIdByShortId = [];//Advertiser -> "j_id0:j_id4:Advertiser

	pub.registerControl = function (shortId, longId) {
		longIdByShortId[shortId] = longId;
	};

	pub.getLongId = function(shortId) {
		return longIdByShortId[shortId];
	};
	pub.pageChange = function(step) {
		if (step > 0 && !validate()) {
			return;
		}
		var newPageNum = currentPage + step;
		if (newPageNum >= MIN_PAGE && newPageNum <= MAX_PAGE) {
			currentPage = newPageNum;
		}

		pub.onPageChange();
	};

	pub.onPageChange = function() {
		
		jq('#stepNum').text(currentPage);

		beforePageShown();

		//switch page
		for (var i = MIN_PAGE; i<= MAX_PAGE; i++) {
			if (currentPage != i) {
				jq('#page' + i).hide();
				jq('input.page' + i).hide();
			} else {
				//jq('#page' + i).show();
			}
		}
		//display new page and buttons
		jq('#page' + currentPage + ", .pitchBtn.page" + currentPage).show({"duration":600, "easing": "linear", "complete": afterPageShown});
	};

	/**
	 * if there is preparation to be done BEFORE page is shown, put it here
	 */
	function beforePageShown() {
		if (3 === currentPage) {
			setupPage3();
		}
	}
	/**
	 * if there is post processing to be done AFTER page is shown, put it here
	 */
	function afterPageShown() {
		if (2 === currentPage) {
			//resize icons div to take max available vertical space and leave the rest to scroll bar
			var h = jq('#tdIcons').height();
			jq('#iconsDiv').height(h);
		}
	}


	/**
	 * only allow to save or finish if at least one product is added
	 */
	pub.canFinish = function () {
		//DEBUG START
		if (isDebug) {
			return true;
		}
		return productHandler.hasProducts();
	};

	function validate () {
		//DEBUG START
		if (isDebug) {
			return true;
		}
		//DEBUG END
		var valid = true;
		var requiredTitles = [];
		var dataErrorTitles = [];
		jq('#page' + currentPage).find('[isRequired=true]').each (function () {
					if ('' === jq(this).val()) {
						valid = false;
						requiredTitles.push(jq(this).prop('title'));
						jq(this).addClass('error');
					} else {
						jq(this).removeClass('error');
					}
				});
		jq('#page' + currentPage).find('[xtype=date]').each (function () {
					if (!dateHandler.validate(jq(this).val())) {
						valid = false;
						dataErrorTitles.push(jq(this).prop('title'));
						jq(this).addClass('error');
					} else {
						jq(this).removeClass('error');
					}
				});

		if (requiredTitles.length > 0) {
			alert('Please complete required field(s): ' + requiredTitles.join('; ') + '.');
		} else {
			//now check if entered values are valid
			if (dataErrorTitles.length > 0) {
				alert('Invalid value: ' + dataErrorTitles.join('; ') + '.');
			}
		}
		return valid;
	}
	/**
	 * prepare data to display on Summary page
	 */
	function setupPage3() {
		//display Pitch Name
		//display Sales Price, Advertiser and Agency Name
		var shortIds = ['Advertiser', 'Agency', 'PitchName'];
		for (var i=0; i < shortIds.length; i++) {
			var shortId = shortIds[i];
			var sourceLongId = pub.getLongId(shortId);
			var jqSourceElem = jq('[id="'+sourceLongId+'"]');
			var valToCopy = jqSourceElem.val();
			if (jqSourceElem.is('select')) {
				valToCopy = jq('[id="'+sourceLongId+'"] option:selected').text();
			}
			var jqRecipient = jq('#summary' + shortId);
			if (jqRecipient.is('input')) {
				jqRecipient.val(valToCopy);
			} else {
				jqRecipient.text(valToCopy);
			}
		}
		//sales price
		var total = productHandler.getTotalPrice();
		jq('#summarySalesPrice').val(total);
		drawProductChart();
	}

	function getProductChartData() {
		var data = [];
		var products = productHandler.getAllProducts();
		//addProductDataForChart(data, "product '1", 10);
		for (var i=0; i < products.length; i++) {
			var product = products[i];
			if (product) {
				addProductDataForChart(data, product.name, product.amount);
			}
		}

		return data;
	}
	function jsonSafe(str) {
		return str.replace(/'/g, '\'');
	}
	function addProductDataForChart(data, name, value) {
		data.push({'name': jsonSafe(name) , 'value':value});
	}
	function drawProductChart() {
		var data = new google.visualization.DataTable();
		data.addColumn('string', 'Icon');
		data.addColumn('number', 'Value');
		var result = getProductChartData();
		for (var i=0; i < result.length; i++){
			var row = result[i];
			if (row) {
				//res = res.replace(/'/g, '"');
				//var row = jQuery.parseJSON(res);
				data.addRow( [row.name, row.value]);
			}
		}
		var options = {
			/*title: "",*/
			width: jq('#pagesTable').outerWidth()-20,
			height: PRODUCT_CHART_HEIGHT,
			is3D: true,
			chartArea: {width: '50%', height:"90%", left: 0},
			legend: {position:'right', alignment:'center'},
			pieSliceText: 'value',
			pieSliceTextStyle: {color: 'black'}
		};
		var chart = new google.visualization.PieChart(document.getElementById('piechart'));
        chart.draw(data, options);

	}

	pub.openProduct = function(icon) {
		jq('tr.pageIcons').hide();
		jq('#mainButtons').hide();
		productHandler.loadProductsByIcon(icon);

	};

	pub.closeProduct = function() {
		jq('tr.pageIcons').show();
		jq('#mainButtons').show();
		jq('#btnFinish').show();
		jq('#pageProduct').hide();

	};

	return pub;
})(jQuery);



/** Team Member selection control **/
var pitchTeamDialogue = (function(jq) {
	var pub = {};
	var divElementId;
	var teamMemberLookupElementId;
	pub.init = function(elementId, teamMemberLookupId) {
		divElementId = elementId;
		teamMemberLookupElementId = teamMemberLookupId;

		jq(function() {
			var isFirefox = navigator.userAgent.indexOf("Firefox") > -1;
			var dialogWidth = "auto";//automatic width does not always work in firefox
			if (isFirefox) {
				dialogWidth = 280;
				jq('#teamMemberLookup').width(180);
			}
			jq( "#" + divElementId ).dialog({
				autoOpen: false,
				resizable: false,
				show: {effect: 'drop', duration: 500, direction: 'up'},
				hide: {effect: 'drop', duration: 500, direction: 'up'},
				modal: true,
				width: dialogWidth,
				height: "auto",
				position: "center top",
				buttons: {
					"Close": function() {
						jq( this ).dialog( "close" );
					}
					/*
					,"Show Ids": function() {
						alert(pitchTeamDialogue.getUserIds());
					}
					*/
				}
			});
			//loadUsers();
		});

		jq( "#" + divElementId ).keypress(function(e) { if(e.which == 13) { pub.memberAdd(); }});
	};

	//load map of all team member candidates
	var availableUsersMap;//{'user a': '005L0000000aIaE', 'user b':'005L0000000abcE'}
	function loadUsers(callback) {
		//load product information
		Visualforce.remoting.Manager.invokeAction(
				MERGE_FIELDS.getAction('getAvailableUserMap'),
				function (result, event) {
					if (event.status) {
						userLoadCallback(result, callback);
					} else if (event.type === 'exception') {
						alert("Error loading data: " + event.message);
					} else {
						//document.getElementById("responseErrors").innerHTML = event.message;
						alert("Error loading data: " + event.message);
					} 
				}, 
				{escape:false}
				);

	}
	function userLoadCallback(data, callback) {
		availableUsersMap = [];
		var availableUsers = [];
		for (var i=0; i < data.length; i++) {
			var row = data[i];
			availableUsersMap[row[0]] = row[1];
			availableUsers.push(row[0]);

		}
		//availableUsersMap = jq.parseJSON(data);
		//autocomplete
		jq('[id="'+teamMemberLookupElementId+'"]').autocomplete({
				source: availableUsers
			});
		if (callback) {
			callback();
		}
	}
	pub.show = function() {
		if (!availableUsersMap) {
			loadUsers(function () {jq('#' + divElementId).dialog('open');});
		} else {
			jq('#' + divElementId).dialog('open');
		}
	};
	pub.close = function() {
		jq('#' + divElementId).dialog('close');
	};

	var selectedUserIds = [];
	var getSelectedUserId = function () {
		var userName = jq('[id="'+teamMemberLookupElementId+'"]').val();
		if (userName) {
			return availableUsersMap[userName];
		}
		return undefined;
	};

	pub.memberAdd = function () {
		var userName = jq('[id="'+teamMemberLookupElementId+'"]').val();
		var userId = getSelectedUserId();
		if (userId) {
			if (!pub.isMemberAdded(userId)) {
				var innerHref = '<input type="button" class="pitchBtn pitchBtn-white" value="X" title="remove" onclick="pitchTeamDialogue.memberRemove(\''+userId+'\')">';
				var outerDiv = '<div id="member_'+userId+'" class="memberDiv">'+innerHref+'&nbsp;' + userName + '</div>';
				jq('#selectedTeamMembers').append(outerDiv);
				//clear search box
				jq('[id="'+teamMemberLookupElementId+'"]').val('');
			}
			updateNoOfOthersIndicator();

		} else {
			alert('Please double check user name');
		}
	};

	pub.memberRemove = function (userId) {
		jq('#member_' + userId).remove();
		updateNoOfOthersIndicator();
	};

	pub.isMemberAdded = function (userId) {
		return jq('#member_' + userId).length > 0;
	};

	var MAX_VISIBLE = 3;//max number of visible members, before we wrap them under "+ N others"
	function updateNoOfOthersIndicator() {
		var memberDivs = jq('.memberDiv');
		//hide extra and display as number
		for(var i = 0; i < memberDivs.length; i++) {
			if (i < MAX_VISIBLE)
				jq(memberDivs[i]).show();
			else
				jq(memberDivs[i]).hide();
		}
		if (memberDivs.length > MAX_VISIBLE) {
			jq('#numOfOthers').text(memberDivs.length - MAX_VISIBLE);
			jq('#numOfOthersDiv').show();
		} else {
			jq('#numOfOthersDiv').hide();
		}
		//update main member count
		if (memberDivs.length > 0) {
			jq('#teamCountMessage').show();
			jq('#teamCount').text(memberDivs.length);
		} else {
			jq('#teamCountMessage').hide();
		}
	}

	/**
	 * return array of User Ids of all selected Pitch Team Members
	 */
	pub.getUserIds = function () {

		var allIds = [];
		jq('.memberDiv').each(function () { 
					allIds.push(jq(this).prop("id").replace("member_", ""));
				});
		return allIds;
	};

	pub.save = function() {
		//validate and save
		var allTemMemberIds = pitchTeamDialogue.getUserIds();
		var allTemMemberIdsStr = '';
		//productData = $Component.Id of the hidden input which passes added product data to controller in JSON String format
		var productDataElementId = pager.getLongId("productData");
		//teamMemberIds - hidden input which passes comma separated ids to controller
		var teamMemberIdsElementId = pager.getLongId("teamMemberIds");
		if (allTemMemberIds.length > 0 && teamMemberIdsElementId) {
			allTemMemberIdsStr = allTemMemberIds.join(",");
		}
		jq('[id="'+teamMemberIdsElementId+'"]').val(allTemMemberIdsStr);
		jq('[id="'+productDataElementId+'"]').val(productHandler.getAllProductsJSON());
		//disable Save button
		jq('#btnSave').addClass('btnProgress');
		saveAll();

	};

	return pub;
})(jQuery);

/** Data Table handler */
var DataTable = function (jq, tId, fieldArray, xOnClickFun, xOnDisplayModeChange, fieldFormatterFun) {
	var attrPrefix = "dt";
	var tableId = tId;
	var fields = fieldArray;
	var xOnClick =xOnClickFun;
	var onDisplayModeChange = xOnDisplayModeChange;//called when display mode changes
	var formatField = fieldFormatterFun || function (f) {};
	var displayMode = 'preview';//preview/all

	//init
	this.init = function() {
		jq('#'+tableId+'NumOfOtherProductsA').click(this.showAllProducts);
		jq('#'+tableId+'BtnBack').click(this.backToPreview);
	};

	this.getTableId = function () {
		return tableId;
	};

	function getJqTable () {
		return jq('[id="'+tableId+'"]');
	}


	/**
	 * {"key":"12345", "name":"Product 1", "amount":"0.5", startDate:"10/11/2000, 11/11/2000", endDate:"10/11/2000"}
	 */
	this.addRows = function(rows) {
		var jqTable = getJqTable();
		var tableId = this.getTableId();

		var existingRowCount = jqTable.children('tbody').find('tr').length;
		for (var i=0; i < rows.length; i++) {
			var row = rows[i];
			var rowId = row["key"];
			var rowHtml = '<tr class="dataRow" id="'+tableId + rowId +'">';
			rowHtml = rowHtml + '<td class="remove"><input type="button" class="pitchBtn pitchBtn-white" '+attrPrefix+'-rowId="'+rowId+'" value="X" title="Delete Product"/></td>';
			for (var j=0; j<fields.length; j++) {
				var fName = fields[j];
				var fVal = row[fName];
				rowHtml = rowHtml + '<td class="field-'+fName+' dataCell" title="'+escapeDoubleQuotes(fVal)+'">' + formatField(fName, fVal) + '</td>';
			}

			rowHtml = rowHtml + "</tr>";
			var jqRow = jq(rowHtml);
			//add X.click event
			jqRow.find('input['+attrPrefix +'-rowId]').click(this.removeRowOnClick);
			jqTable.children('tbody').append(jqRow);
		}
		//make sure that table is visible
		if (rows && rows.length > 0) {
			jqTable.show();
		}
		refreshPreview();
		
	};
	function escapeDoubleQuotes(val) {
		if ("string" === jq.type(val)) {
			return val.replace(/"/g, '\"');
		}
		return val;
	}

	var refreshPreview = function() {
		if ('all' == displayMode) {
			//large table with scroll
			jq('#' + tableId + 'Div').css('overflow','scroll');
			var btnHeight = jq('#' + tableId + 'BtnBack').outerHeight() + 20;
			var tableHeight = PUBLISHER_HEIGHT - Math.max(30, btnHeight);//leave room for button Back and horisontal scroll bar area
			jq('#' + tableId + 'Div').css('height',tableHeight + 'px');
		} else {
			//small table, top N rows
			jq('#' + tableId + 'Div').css('overflow','');
			jq('#' + tableId + 'Div').css('height','');

		}

		var jqTable = getJqTable();
		var existingRows = jqTable.children('tbody').find('tr.dataRow');
		var needWrap = false;
		//hide all rows
		existingRows.hide();
		var visibleRows = 0;

		for	(var i=0; i < existingRows.length; i++) {
			if ('all' == displayMode || !needWrap) {
				jq(existingRows[i]).show();
				visibleRows = visibleRows + 1;

				if ('preview' == displayMode && !needWrap) {
					//check if "+ N other products" will fit with last displayed line
					var jqOthersDiv = jq('#'+tableId+'NumOfOtherProductsDiv');
					jqOthersDiv.show();//temporary display, to calculate dimensions and offset
					var offset = jqOthersDiv.offset();
					var bottomCoordinate = offset.top + jqOthersDiv.outerHeight() + 5;
					if (bottomCoordinate >= PUBLISHER_HEIGHT) {
						//keep jqOthersDiv displayed
						needWrap = true;
						visibleRows = visibleRows - 1;
					} else {
						jqOthersDiv.hide();
					}
				}
			}
			if (needWrap) {
				//hide row
				jq(existingRows[i]).hide();
			}
		}
		var numOfExtraProducts = existingRows.length - visibleRows;
		if (numOfExtraProducts > 0 && 'preview' == displayMode) {
			//display "+ N other products"
			jq('#' + tableId + 'NumOfOtherProducts').text(numOfExtraProducts);
			jq('#'+tableId+'NumOfOtherProductsDiv').show();
		} else {
			jq('#'+tableId+'NumOfOtherProductsDiv').hide();
		}

	};

	this.showAllProducts = function() {
		//show all rows
		displayMode = 'all';
		//hide product entry table
		onDisplayModeChange(displayMode);
		jq('#' + tableId + 'BtnBack').show();
		refreshPreview();
	};

	this.backToPreview = function() {
		jq('#' + tableId + 'BtnBack').hide();
		//show all rows
		displayMode = 'preview';
		//show product entry table
		onDisplayModeChange(displayMode);
		refreshPreview();
	};

	this.removeRowOnClick = function(evt) {
		var rowId = jq(this).attr(attrPrefix + "-rowId");
		removeRowById(rowId);
		if ('preview' == displayMode) {
			refreshPreview();
		}
		//finally call on-delete handler
		xOnClick(rowId);
	};
	var removeRowById = function(rowId) {
		var jqTable = getJqTable();
		var tableId = jqTable.attr("id");
		jqTable.find('tr[id="'+tableId + rowId+'"]').remove();
		//check if we need to display table at all
		if (jqTable.children('tbody').find('tr.dataRow').length < 1 ) {
			jqTable.hide();
			if ('all' == displayMode) {
				//force preview mode
				jq('#' + tableId + 'BtnBack').click();
			}
		}

	};

	this.removeRow = function(rowId) {
		removeRowById(rowId, displayMode);
	};
	
	this.removeAllRows = function() {
		var jqTable = getJqTable();
		jqTable.find('tr.dataRow').remove();
		jqTable.hide();
	};
};


/** PRODUCT Handler **/
var productHandler = (function (jq) {
	var keysByIcon = [];
	var productByKey = [];
	var uniqueCounter = 0;
	var pub = {};
	var currentIcon;

	
	pub.setCurrentIcon = function (icon) {
		currentIcon = icon;
		if (!keysByIcon[icon]) {
			keysByIcon[icon] = [];
		}
		//on Icon change rerender product table
		productTable.removeAllRows();
		//var products = getProductsByIcon(icon);
		var products = pub.getAllProducts();
		productTable.addRows(products);
		pub.onProductSelect();

	};
	/*
	function getProductsByIcon(icon) {
		var products = [];
		var keys = keysByIcon[icon];
		for (var i=0; i < keys.length; i++) {
			var product = productByKey[keys[i]];
			if (product) {
				products.push(product);
			}
		}
		return products;
	}
	*/

	pub.getAllProducts = function () {
		var keys = Object.keys(productByKey);
		var allProducts = [];
		for (var i=0; i < keys.length; i++) {
			var product = productByKey[keys[i]];
			if (product) {
				allProducts.push(product);
			}
		}
		return allProducts;
	};
	pub.getAllProductsJSON = function () {
		return JSON.stringify(pub.getAllProducts());
	};

	pub.hasProducts = function () {
		return Object.keys(productByKey).length > 0;

	};

	pub.getTotalPrice = function() {
		var products = pub.getAllProducts();
		var total = 0;
		for(var i=0; i < products.length; i++) {
			var amount = products[i].amount;
			if (numberHandler.validate(amount)) {
				total += amount;
			}
		}
		return total.toFixed(2);
	};

	// add current product details
	function addProduct() {
		if (!validate()) {
			return false;
		}

		var product = getProductData();
		product.key = uniqueCounter;
		productByKey[product.key] = product;
		keysByIcon[currentIcon].push(product.key);
		uniqueCounter = uniqueCounter +1;

		productTable.addRows([product]);
		//clear entered values
		pub.onProductSelect();
		return true;
	}

	pub.addProductAndBack = function () {
		if (addProduct()) {
			pager.closeProduct();
		}
	};
	/**
	 * if product info entered then try to add product first, otherwise go to next page
	 */
	pub.addProductAndForward = function () {
		var isSingleProductList = jq('#productSelect option').length <= 1;
		//do we need to add product?
		var tryToAddProduct = false;
		if (isSingleProductList) {
			tryToAddProduct = "" !== jq('#Amount').val();
		} else {
			var productId = jq('#productSelect').val();
			tryToAddProduct = "" !== productId && "--None--" !== productId;
		}
		
		if (tryToAddProduct) {
			if (!addProduct()) {
				return false;
			}
		}
		if (!pager.canFinish()) {
			alert('Please add at least one product');
			return false;
		}

		pager.closeProduct();
		pager.pageChange(+1);
	};
	// remove product from list of added
	pub.removeProduct = function (productKey) {
		//productTable.removeRow(productId);
		delete productByKey[productKey];
	};

	/**
	 * @return data of current product
	 * {"id": "product-id", "amount": "number", "startDate": "date1, date2, dateN", "endDate": "dd/mm/yyyy"}
	 */
	function getProductData() {
		var product = {};
		product.id = jq('#productSelect').val();
		product.name = jq('#productSelect option:selected').text();
		product.amountDisplay = jq('#Amount').val();
		product.amount = currencyKMB_Handler.expand(jq('#Amount').val()) * 1;
		product.startDate = jq('input[id$="StartDate"]').val();
		product.endDate = jq('input[id$="EndDate"]').val();
		//also add some stored values
		var prod = currentIconData[product.id];
		if (prod) {
			product.pbeId = prod.pbeId;
		}
		return product;

	}

	function validate() {
		var messages = [];
		var requiredTitles = [];
		var dataErrorTitles = [];
		var isValid = true;
		var productId = jq('#productSelect').val();
		if ("" === productId || "--None--" == productId) {
			messages.push("Please select product");
		} else {
			//required fields
			jq('#productEntry').find('[isRequired=true]').each(function () {
						if ('' === jq(this).val()) {
							requiredTitles.push(jq(this).prop('title'));
							jq(this).addClass('error');
						} else {
							jq(this).removeClass('error');
						}
					});
		}
		if (requiredTitles.length < 1) {
			//data validation
			jq('#productEntry').find('[xtype]').each(function () {
						var xType = jq(this).attr("xtype");
						var handler = handlerByXType[xType];
						var fieldVal = jq(this).val();
						if ("" !== fieldVal && handler && !handler.validate(fieldVal)) {
							dataErrorTitles.push(jq(this).prop('title'));
							jq(this).addClass('error');
						} else {
							jq(this).removeClass('error');
						}
					});
		}
		//field specific validations
		//EndDate is sometimes required
		var prod = currentIconData[productId];
		if (prod) {
			var endDateStr = jq('[id$="EndDate"]').val();
			var endDate = dateHandler.parse(endDateStr);
			if (true === prod.isEndDateRequired) {
				if (null === endDate) {
					requiredTitles.push('End Date');
				}
			}
			//Start Date must be greater than or equal to the Pitch Close Date
			var startDates = jq('[id$="StartDate"]').val().split(',');
			var closeDateStr =  jq('[id$="CloseDate"]').val(); 
			try {
				var closeDate = dateHandler.parse(closeDateStr);
				for (var i=0; i < startDates.length; i++) {
					var dateStr = startDates[i];
					if (dateStr) {
						var dateVal = dateHandler.parse(dateStr);
						if (null === dateVal) {
							dataErrorTitles.push('Start date: ' + dateStr);
							break;
						} else if (closeDate > dateVal) {
							messages.push('Start Date must be greater than or equal to the Pitch Close Date');
							break;
						} else if (null !== endDate && endDate < dateVal) {
							messages.push('End Date must be greater than or equal to the Start Date');
							break;
						}
					}
				}
			} catch (eIgnore) {}
		}

		if (messages.length > 0) {
			alert(messages.join(';\n '));
		} else if (requiredTitles.length > 0) {
			alert('Please complete required field(s): ' + requiredTitles.join('; ') + '.');
		} else {
			//now check if entered values are valid
			if (dataErrorTitles.length > 0) {
				alert('Invalid value: ' + dataErrorTitles.join('; ') + '.');
			}

		}
		return messages.length < 1 && requiredTitles.length < 1 && dataErrorTitles.length < 1;
	}
	/**
	 * when Product drop-down selection changes, init product entry fields
	 */
	pub.onProductSelect = function() {
		var jqSelect = jq('#productSelect');
		//clear old values
		jq('#Amount').val('');
		if (!isDebug) {
			//GI-62 - do not reset start date once set
			//jq('input[id$="StartDate"]').val('');
			jq('input[id$="EndDate"]').val('');
		}
		if ("" !== jqSelect.val()) {
			var prod = currentIconData[jqSelect.val()];
			if (prod && prod.unitPrice) {
				jq('#Amount').val(prod.unitPrice);
			}
		}
	};

	var currentIconData = [];//product2id -> product info
	var productSelectOnChangeSet = false;

	pub.loadProductsByIcon = function (icon) {
		//load product information
		Visualforce.remoting.Manager.invokeAction(
				MERGE_FIELDS.getAction('getProductsByIcon'),
				icon,
				function (result, event) {
					if (event.status) {
						productLoadCallback(icon, result);
					} else if (event.type === 'exception') {
						alert("Error loading data: " + event.message);
					} else {
						//document.getElementById("responseErrors").innerHTML = event.message;
						alert("Error loading data: " + event.message);
					} 
				});
	};
	/**
	 * @param: data - array
	 * each element is object with following fields: id, name, unitPrice
	 */
	function productLoadCallback(icon, data) {
		jq('#pageProduct').show();
		jq('#btnAddFinish').show();
		//populate picklist
		var jqSelect = jq('#productSelect');
		jqSelect.val('');//clear old drop-down value
		//remove all values except -None-
		while (jqSelect.children('option').length > 1) {
			jq('#productSelect option:last').remove();

		}
		currentIconData = [];
		if (data.length > 0) {
			//add product list
			for(var i=0; i< data.length; i++) {
				var prod = data[i];
				jqSelect.append("<option value='"+prod.id+"'>"+prod.name+"</option>");
				currentIconData[prod.id] = prod;
			}
			if (2 == jqSelect.children('option').length) {
				//only 1 product in the selected category, select it by default
				jqSelect.val(data[0].id);
			}
		}
		if (!productSelectOnChangeSet) {
			jqSelect.change(productHandler.onProductSelect);
			productSelectOnChangeSet = true;
		}
		productHandler.setCurrentIcon(icon);

	}
	
	pub.onDisplayModeChange = function(displayMode) {
		if ('all' == displayMode) {
			jq('#productEntry').hide();
		} else {
			jq('#productEntry').show();
		}
	};

	pub.formatField = function(fName, fVal) {
		if (!fVal) {
			return fVal;
		}
		if ("startDate" == fName) {
			//insert spaces after each comma, to let browser break line if required
			return fVal.replace(/,/g, ", ");
		}
		if ("amountDisplay" == fName) {
			//insert currency symbol
			return MERGE_FIELDS.getCurrencySymbol() + fVal;
		}
		return fVal;
	};

	return pub;
})(jQuery);

var productTable = new DataTable(jQuery, "productList", ["name", "amountDisplay", "startDate", "endDate"], 
									productHandler.removeProduct, productHandler.onDisplayModeChange, 
									productHandler.formatField);
jq( document ).ready(function() {
	productTable.init();
});
/* vim: set filetype=javascript: */

// https://stackoverflow.com/questions/17929356/html-datalist-values-from-array-in-javascript
// https://stackoverflow.com/questions/46014167/how-i-can-get-the-value-from-datalist
// https://www.w3schools.com/jsref/met_win_settimeout.asp
// https://www.w3schools.com/cssref/pr_class_display.asp

function updateInfo() {
	getAllToptimesInfo (
		function (value) {
			var options = '';
			var mapListElement = document.getElementById("mapList");
			for (var i=0; i<value.length-1; i++) {
				options += '<option value="' + value[i] + '"></option>';
			}
			mapListElement.innerHTML = options;
			if (options == "")
				document.getElementById("mapInput").value = "There are no toptimes on any map on the server!";
			else
				document.getElementById("mapInput").value = mapListElement.options[0].value;
			document.getElementById("mapCountLabel").innerHTML = "Total map count: " + value[value.length-1];
			getMapInfo();
			setTimeout(function(){document.getElementById("container").style.display = "inherit";}, 150);
		}
	);
}

function getMapInfo() {
	var mapInputElement = document.getElementById("mapInput");
	getMapToptimesInfo (mapInputElement.value,
		function (value) {
			// Map author label
			var mapAuthorLabelElement = document.getElementById("mapAuthorLabel");
			mapAuthorLabelElement.innerHTML = "Map author: " + value[10]["mapAuthor"];
			
			// Total top times label
			var totalTopsLabelElement = document.getElementById("totalTopsLabel");
			totalTopsLabelElement.innerHTML = "Total toptimes: " + value[11]["totalTops"];
			
			// First toptime
			var firstPosElement = document.getElementById("firstPos");
			firstPosElement.innerHTML = 1;
			/*var firstCountryElement = document.getElementById("firstCountry");
			firstCountryElement.innerHTML = "BG"; // value[0].playerCountry;*/
			var firstNameElement = document.getElementById("firstName");
			firstNameElement.innerHTML = value[0].playerName;
			var firstTimeElement = document.getElementById("firstTime");
			firstTimeElement.innerHTML = value[0].timeText;
			var firstDiffElement = document.getElementById("firstDiff");
			firstDiffElement.innerHTML = calcDiff(value[0].timeText, value[0].timeText);
			var firstDateElement = document.getElementById("firstDate");
			firstDateElement.innerHTML = convertDate(value[0].dateRecorded);
			
			// Second toptime
			var secondPosElement = document.getElementById("secondPos");
			secondPosElement.innerHTML = 2;
			/*var secondCountryElement = document.getElementById("secondCountry");
			secondCountryElement.innerHTML = "BG"; // value[1].playerCountry;*/
			var secondNameElement = document.getElementById("secondName");
			secondNameElement.innerHTML = value[1].playerName;
			var secondTimeElement = document.getElementById("secondTime");
			secondTimeElement.innerHTML = value[1].timeText;
			var secondDiffElement = document.getElementById("secondDiff");
			secondDiffElement.innerHTML = calcDiff(value[0].timeText, value[1].timeText);
			var secondDateElement = document.getElementById("secondDate");
			secondDateElement.innerHTML = convertDate(value[1].dateRecorded);
			
			// Third toptime
			var thirdPosElement = document.getElementById("thirdPos");
			thirdPosElement.innerHTML = 3;
			/*var thirdCountryElement = document.getElementById("thirdCountry");
			thirdCountryElement.innerHTML = "BG"; // value[2].playerCountry;*/
			var thirdNameElement = document.getElementById("thirdName");
			thirdNameElement.innerHTML = value[2].playerName;
			var thirdTimeElement = document.getElementById("thirdTime");
			thirdTimeElement.innerHTML = value[2].timeText;
			var thirdDiffElement = document.getElementById("thirdDiff");
			thirdDiffElement.innerHTML = calcDiff(value[0].timeText, value[2].timeText);
			var thirdDateElement = document.getElementById("thirdDate");
			thirdDateElement.innerHTML = convertDate(value[2].dateRecorded);
			
			// Fourth toptime
			var fourthPosElement = document.getElementById("fourthPos");
			fourthPosElement.innerHTML = 4;
			/*var fourthCountryElement = document.getElementById("fourthCountry");
			fourthCountryElement.innerHTML = "BG"; // value[3].playerCountry;*/
			var fourthNameElement = document.getElementById("fourthName");
			fourthNameElement.innerHTML = value[3].playerName;
			var fourthTimeElement = document.getElementById("fourthTime");
			fourthTimeElement.innerHTML = value[3].timeText;
			var fourthDiffElement = document.getElementById("fourthDiff");
			fourthDiffElement.innerHTML = calcDiff(value[0].timeText, value[3].timeText);
			var fourthDateElement = document.getElementById("fourthDate");
			fourthDateElement.innerHTML = convertDate(value[3].dateRecorded);
			
			// Fifth toptime
			var fifthPosElement = document.getElementById("fifthPos");
			fifthPosElement.innerHTML = 5;
			/*var fifthCountryElement = document.getElementById("fifthCountry");
			fifthCountryElement.innerHTML = "BG"; // value[4].playerCountry;*/
			var fifthNameElement = document.getElementById("fifthName");
			fifthNameElement.innerHTML = value[4].playerName;
			var fifthTimeElement = document.getElementById("fifthTime");
			fifthTimeElement.innerHTML = value[4].timeText;
			var fifthDiffElement = document.getElementById("fifthDiff");
			fifthDiffElement.innerHTML = calcDiff(value[0].timeText, value[4].timeText);
			var fifthDateElement = document.getElementById("fifthDate");
			fifthDateElement.innerHTML = convertDate(value[4].dateRecorded);
			
			// Sixth toptime
			var sixthPosElement = document.getElementById("sixthPos");
			sixthPosElement.innerHTML = 6;
			/*var sixthCountryElement = document.getElementById("sixthCountry");
			sixthCountryElement.innerHTML = "BG"; // value[5].playerCountry;*/
			var sixthNameElement = document.getElementById("sixthName");
			sixthNameElement.innerHTML = value[5].playerName;
			var sixthTimeElement = document.getElementById("sixthTime");
			sixthTimeElement.innerHTML = value[5].timeText;
			var sixthDiffElement = document.getElementById("sixthDiff");
			sixthDiffElement.innerHTML = calcDiff(value[0].timeText, value[5].timeText);
			var sixthDateElement = document.getElementById("sixthDate");
			sixthDateElement.innerHTML = convertDate(value[5].dateRecorded);
			
			// Seventh toptime
			var seventhPosElement = document.getElementById("seventhPos");
			seventhPosElement.innerHTML = 7;
			/*var seventhCountryElement = document.getElementById("seventhCountry");
			seventhCountryElement.innerHTML = "BG"; // value[6].playerCountry;*/
			var seventhNameElement = document.getElementById("seventhName");
			seventhNameElement.innerHTML = value[6].playerName;
			var seventhTimeElement = document.getElementById("seventhTime");
			seventhTimeElement.innerHTML = value[6].timeText;
			var seventhDiffElement = document.getElementById("seventhDiff");
			seventhDiffElement.innerHTML = calcDiff(value[0].timeText, value[6].timeText);
			var seventhDateElement = document.getElementById("seventhDate");
			seventhDateElement.innerHTML = convertDate(value[6].dateRecorded);
			
			// Eighth toptime
			var eighthPosElement = document.getElementById("eighthPos");
			eighthPosElement.innerHTML = 8;
			/*var eighthCountryElement = document.getElementById("eighthCountry");
			eighthCountryElement.innerHTML = "BG"; // value[7].playerCountry;*/
			var eighthNameElement = document.getElementById("eighthName");
			eighthNameElement.innerHTML = value[7].playerName;
			var eighthTimeElement = document.getElementById("eighthTime");
			eighthTimeElement.innerHTML = value[7].timeText;
			var eighthDiffElement = document.getElementById("eighthDiff");
			eighthDiffElement.innerHTML = calcDiff(value[0].timeText, value[7].timeText);
			var eighthDateElement = document.getElementById("eighthDate");
			eighthDateElement.innerHTML = convertDate(value[7].dateRecorded);
			
			// Ninth toptime
			var ninthPosElement = document.getElementById("ninthPos");
			ninthPosElement.innerHTML = 9;
			/*var ninthCountryElement = document.getElementById("ninthCountry");
			ninthCountryElement.innerHTML = "BG"; // value[8].playerCountry;*/
			var ninthNameElement = document.getElementById("ninthName");
			ninthNameElement.innerHTML = value[8].playerName;
			var ninthTimeElement = document.getElementById("ninthTime");
			ninthTimeElement.innerHTML = value[8].timeText;
			var ninthDiffElement = document.getElementById("ninthDiff");
			ninthDiffElement.innerHTML = calcDiff(value[0].timeText, value[8].timeText);
			var ninthDateElement = document.getElementById("ninthDate");
			ninthDateElement.innerHTML = convertDate(value[8].dateRecorded);
			
			// Tenth toptime
			var tenthPosElement = document.getElementById("tenthPos");
			tenthPosElement.innerHTML = 10;
			/*var tenthCountryElement = document.getElementById("tenthCountry");
			tenthCountryElement.innerHTML = "BG"; // value[9].playerCountry;*/
			var tenthNameElement = document.getElementById("tenthName");
			tenthNameElement.innerHTML = value[9].playerName;
			var tenthTimeElement = document.getElementById("tenthTime");
			tenthTimeElement.innerHTML = value[9].timeText;
			var tenthDiffElement = document.getElementById("tenthDiff");
			tenthDiffElement.innerHTML = calcDiff(value[0].timeText, value[9].timeText);
			var tenthDateElement = document.getElementById("tenthDate");
			tenthDateElement.innerHTML = convertDate(value[9].dateRecorded);
		}
	);
}

function clearInputField() {
	document.getElementById("mapInput").value = "";
	document.getElementById("mapInput").focus();
	getMapInfo();
}

// Format Date Function: https://stackoverflow.com/questions/13459866/javascript-change-date-into-format-of-dd-mm-yyyy/13460045
function convertDate(inputFormat) {
	if ((!inputFormat) || (inputFormat == "")) return "";
	return inputFormat.substring(0,10);
}

// Calculate MTA Time Difference: https://pastebin.com/E0NFUCNc
function calcDiff(time1, time2) {
	if ((!time1) || (!time2)) return "";
	// Expected format: minutes:seconds:milliseconds
	var time1 = time1.split(":");
	var time2 = time2.split(":");
	for (var i=0; i<3; i++) {
		time1[i] = Number(time1[i]);
		time2[i] = Number(time2[i]);
	}
	time1 = time1[0] * 60000 + time1[1] * 1000 + time1[2];
	time2 = time2[0] * 60000 + time2[1] * 1000 + time2[2];
	var deltaTime = time2 - time1;
	deltaTime = deltaTime < 0 ? -deltaTime : deltaTime;
	var ms = deltaTime % 1000;
	var sec = Math.floor(deltaTime / 1000) % 60;
	var min = Math.floor(deltaTime / 60000);
	ms = ms < 10 ? "00" + ms : ms < 100 ? ms = "0" + ms : ms = ms;
	sec = sec < 10 ? "0" + sec : sec;
	min = min < 10 ? "0" + min : min;
	return "+" + min + ":" + sec + ":" + ms;
}
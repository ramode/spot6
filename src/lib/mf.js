import Vue from "vue"

Vue.filter("mf_time_human_duration", (time_sec) => {

	// Need seconds

	if ( time_sec === undefined ) {
	  return;
	};

	var res;

	if ( time_sec < 60 ) {

	  res = `${time_sec} сек.`;

	} else if ( time_sec < 3600 ) {

	  var _sec = time_sec % 60;
	  var _min = (time_sec - _sec) / 60;

	  res = `${_min} мин`;

	  if ( _sec > 0 ) {
	    res = `${res} ${_sec} сек`;
	  }

	} else {

	  var _sec = time_sec % 3600 % 60;
	  var _min = ( time_sec - _sec ) / 60 % 60;
	  var _hour = ( time_sec - time_sec % 3600 ) / 3600;
	  
	  res = `${_hour} ч. ${_min} мин.`;

	  if ( _sec > 0 ) {
	    res = `${res} ${_sec} сек`;
	  }

	};

	return res;

});
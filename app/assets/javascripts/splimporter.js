$(document).ready( function() {
    var calendarString = "<iframe id=\"hosted-calendar\" class=\"hosted-calendar\" src=\"https://www.google.com/calendar/embed?mode=WEEK&amp;showTitle=0&amp;showPrint=0&amp;showTabs=1&amp;showCalendars=1&amp;showTz=1&amp;wkst=1&amp;bgcolor=%23F1F1F2&amp;src=hhlra37v3ok5968in4lui1a9i0%40group.calendar.google.com&amp;color=%230D9DDA";

    var timezoneName = jstz.determine().name();
    timezoneName = timezoneName.replace(/\//, "%2F");

    calendarString += "&amp;ctz=" + timezoneName;

    calendarString += "\" style=\" border-width:0 \" frameborder=\"0\" scrolling=\"no\"></iframe>"

    $( "#calendar-container" ).append( calendarString );
});

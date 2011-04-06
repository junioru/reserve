// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


function addLoadEvent(func) {
  var oldonload = window.onload;
  if (typeof window.onload != 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      if (oldonload) {
        oldonload();
      }
      func();
    }
  }
}

function colourChange(element, colour, reservedColour){
  if (element.style.backgroundColor != reservedColour)
    element.style.backgroundColor = colour;
}
                                  
function toggleAllCells(colour, reservedColour){
  var cells;
  for (i = 0; i < rows.length ; i++){
    cells = rows[i].getElementsByTagName("td");
    for (j = 1 ; j < cells.length ; j++) {
      colourChange(cells[j], colour, reservedColour);
    }
  }
}

function disableElement(element){
  document.getElementById(element).disabled = true;
  document.getElementById(element).style.display = 'none';
}

function enableElement(element){
  document.getElementById(element).disabled = false;
  document.getElementById(element).style.display = 'block';
}

// Used in System Reservation page
function toggleDiv(val) { 
  if (val == ("Weekly"))
  {
    enableElement("weekSelect");
    disableElement("dateSelect");
  }
  else
  {
    enableElement("dateSelect");
    disableElement("weekSelect");
  }
}

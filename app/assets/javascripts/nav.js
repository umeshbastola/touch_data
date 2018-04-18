$(function() {
/* Set the width of the side navigation to 250px */
$('.open_navslide').bind("click touchstart", function(){
	var width = window.screen.width;
	width = width/3;
	width = width+"px";
    document.getElementById("mySidenav").style.width = "500px";
    document.getElementById("mySidenav").style.left = "0px";    
                
});
/* Set the width of the side navigation to 0 */
$('.closebtn').bind("click touchstart", function(){
    document.getElementById("mySidenav").style.width = "0";
    document.getElementById("mySidenav").style.left = "-100px";
});
});
$.touch.triggerMouseEvents = true;
$.touch.orientationChanged(function () {
    initializeCanvas();
});

function addLineSubPath(ctx, y, width) {
    ctx.moveTo(0, y);
    ctx.lineTo(width, y);
}
function addLinePath(ctx, x, height) {
    ctx.moveTo(x, 0);
    ctx.lineTo(x, height);
}

function plotData(dataSet) {
	initializeCanvas();
	var colors = ["AliceBlue",'green', 'blue','red', 'purple','black',"Aqua","Aquamarine","Azure","Beige","Bisque","BlanchedAlmond","BlueViolet","Brown"];
    dataSet.forEach(function(stroke) {
    	var canvas = document.getElementById("canvas");
		var context = canvas.getContext("2d");
		context.beginPath();
    	var num = parseInt(stroke.exec_num);
    	stroke.points.forEach(function(point) {
	    	context.lineCap = "round";
	        context.lineWidth = 10;
	        context.strokeStyle = colors[num];
	  		context.moveTo(parseInt(point[0])+200,parseInt(point[1])+100);
	        context.lineTo(parseInt(point[0])+200,parseInt(point[1])+100);    
		});
		context.stroke();
	});
}

function initializeCanvas(){
	$touch_data = [];
	$time_start = 0;
	$base_id = -1;
	$num_touchDown = 0;
	var width = $(window).width(),
            height = $(window).height();
            $('#canvas').attr({
                width: width,
                height: height,
            });
            var c = document.getElementById('canvas');
            var ctx = c.getContext('2d');
            ctx.translate(0.5, 0.5);
            ctx.lineWidth = 1;

            ctx.strokeStyle = 'white';

            ctx.beginPath();
            for (var y = 100; y < height; y += 100) {
                addLineSubPath(ctx, y, width);
            }
            for (var x = 100; x < width; x += 100) {
                addLinePath(ctx, x, height);
            }
            ctx.stroke();
}
$.touch.ready(function () {
    $touch_data = [];
    $time_start = 0;
    
    function getColor() {
        $base_id+=1;
        var colors = ['green', 'blue','red', 'purple','black'];
        return colors[$base_id];
    }
    
    function handleTouch2(e, touchHistory) {
        if($time_start == 0){
            $time_start = touchHistory.get(0).time;
        }

        var time_diff = touchHistory.get(0).time - $time_start;
        
        if (!$.touch.allTouches[e.touch.id].color) $.touch.allTouches[e.touch.id].color = getColor();
        $touch_data.push({id:e.touch.id,x:touchHistory.get(0).clientX,y:touchHistory.get(0).clientY,time:time_diff,color:$.touch.allTouches[e.touch.id].color});
        var ctx = this.getContext('2d');
        ctx.beginPath();
        ctx.moveTo(touchHistory.get(0).clientX, touchHistory.get(0).clientY);
        ctx.lineTo(e.clientX, e.clientY);
        ctx.lineCap = "round";
        ctx.lineWidth = 10;
        ctx.strokeStyle = $.touch.allTouches[e.touch.id].color;
        ctx.stroke();
    }
    $('#canvas').touchable({
        touchDown: function () {
            $num_touchDown +=1;
            if($num_touchDown > 5){
                $('#canvas').unbind('touchmove');
                alert("Max number of touch down reached");
                return false;
            }
            return true;
        },
        touchMove: handleTouch2
    });

    var $canvas = $('#canvas');
    var storedEvent = $canvas;
    $('.clear_canvas').bind("click touchstart", function(){
    	location.reload();
    });

    $('.plot_ges').bind("click touchstart", function(){
        var gesture_id = $("#gesture_all").val();
        if(gesture_id != 0){
	        var user_id = $("#users_all").val();
	        $.ajax({
	            type: "GET",
	            url: "/get_gesture/"+user_id+"/"+gesture_id,
	            success: function(data){
	                plotData(data.result)},
	            failure: function(errMsg) {
	                alert(errMsg);
	            }
	        });
    	}else{
    		alert("Please select a gesture from dropdown!")
    	}
    });

	$('.data_json').bind("click touchstart", function(){
		var gesture_id = $("#gesture_all").val();
        if(gesture_id != 0 && $touch_data.length){
	        $.ajax({
	            type: "POST",
	            url: "/data_post",
	            data: {finger_data:$touch_data,password_gesture:0,gesture_id:gesture_id},
	            success: function(data){
	                alert("Data successfully uploaded.");
	                location.reload();},
	            failure: function(errMsg) {
	                alert(errMsg);
	            }
	      	});
	    }else{
		alert("Please select a gesture from dropdown and draw!")
	}
    });
});
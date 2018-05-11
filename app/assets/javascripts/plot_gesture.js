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

function plotData(dataSet, opacity) {
	initializeCanvas();
	var colors = ['green', 'blue','red', 'purple','black',"Aqua","Aquamarine","Azure","Beige","Bisque","BlanchedAlmond","BlueViolet","Brown"];
    dataSet.forEach(function(stroke) {
    	var canvas = document.getElementById("canvas");
		var context = canvas.getContext("2d");
		context.beginPath();
    	var num = parseInt(stroke.stroke_seq);
        if(opacity == 1)
            context.globalAlpha = 0.2 
        context.lineCap = "round";
        context.lineWidth = 10;
        context.strokeStyle = colors[num];
    	stroke.points.forEach(function(point) {
	  		context.moveTo(parseInt(point[0])+200,parseInt(point[1])+100);
	        context.lineTo(parseInt(point[0])+200,parseInt(point[1])+100); 

		});
		context.stroke();
	});
}

function plotDataTime(dataSet, opacity){
    var colors = ['green', 'blue','red', 'purple','black',"Aqua","Aquamarine","Azure","Beige","Bisque","BlanchedAlmond","BlueViolet","Brown"];
    var canvas = document.getElementById("canvas");
    context = canvas.getContext("2d");
    if(opacity == 1)
        context.globalAlpha = 0.2 
    context.lineCap = "round";
    context.lineWidth = 10;
    dataSet.forEach(function(stroke) {
        context.beginPath();
        var num = parseInt(stroke.stroke_seq);       
        stroke.points.forEach(function(point) {
            setTimeout(function() {
            context.strokeStyle = colors[num];
            context.moveTo(parseInt(point[0])+200,parseInt(point[1])+100);
            context.lineTo(parseInt(point[0])+200,parseInt(point[1])+100); 
            context.stroke();
            }, 1000);
        });
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
        var colors = ['green', 'blue','red', 'purple','black',"Aqua","Aquamarine","Azure","Beige","Bisque","BlanchedAlmond","BlueViolet","Brown"];
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
        ctx.globalAlpha = 1;
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
            return true;
        },
        touchMove: handleTouch2
    });

    var $canvas = $('#canvas');
    var storedEvent = $canvas;
    $('.clear_canvas').bind("click touchstart", function(){
    	//location.reload();
        initializeCanvas();
    });

    $('.plot_ges').bind("click", function(){
        var gesture_id = $("#gesture_all").val();
        if(gesture_id != 0){
        	$('.closebtn').trigger('click');
	        var user_id = $("#users_all").val();
	        $.ajax({
	            type: "GET",
	            url: "/get_gesture/"+user_id+"/"+gesture_id,
	            success: function(data){
	                plotData(data.result,0)},
	            failure: function(errMsg) {
	                alert(errMsg);
	            }
	        });
    	}else{
    		alert("Please select a gesture from dropdown!")
    	}
    });

    var in_progress = false;
	$('.data_json').bind("click", function(){    
		var gesture_id = $("#gesture_all").val();
        var strokes = $('option:selected', "#gesture_all").data('strokes');
        if(!in_progress && gesture_id != 0 && $touch_data.length){
            in_progress = true;
	        $.ajax({
	            type: "POST",
	            url: "/data_post",
	            data: {finger_data:$touch_data,password_gesture:0,gesture_id:gesture_id,num_stroke:strokes},
	            success: function(data){
	            	alert(data.result);
                    initializeCanvas();
                    in_progress = false;
	            },
	            failure: function(errMsg) {
	                alert(errMsg);
                    in_progress = false;
	            }
	      	});
	    }else{
		alert("Please select a gesture from dropdown and draw!")
	}
    });
    $('.delete_gesture').bind("click", function(){
        var gesture_id = $("#gesture_all").val();
        if(gesture_id != 0 && confirm("Are you sure you want to delete the gesture?")){
            $.ajax({
                type: "GET",
                url: "/delete_gesture",
                data: {gesture_id:gesture_id},
                success: function(data){
                    alert("Gesture Sucessfully Deleted");
                },
                failure: function(errMsg) {
                    alert(errMsg);
                }
            });
        }else{
        alert("Please select a gesture from dropdown!")
    }
    });
    $('.delete_gesture_part').bind("click", function(){
        var gesture_id = $("#gesture_all").val();
        if(gesture_id != 0 && confirm("Are you sure you want to delete the last execution of this gesture?")){
            $.ajax({
                type: "GET",
                url: "/delete_gesture_exec",
                data: {gesture_id:gesture_id},
                success: function(data){
                    alert("Gesture Sucessfully Deleted");
                },
                failure: function(errMsg) {
                    alert(errMsg);
                }
            });
        }else{
        alert("Please select a gesture from dropdown!")
    }
    });

    $("#gesture_all,#users_all").change(function(){
        var gesture_id = $("#gesture_all").val();
        var option = $('option:selected', "#gesture_all").data('count');
        var user_id = $("#users_all").val();
        $(".desc").html($("."+option).html());
        if(gesture_id != 0){
            $.ajax({
                type: "GET",
                url: "/get_last/"+user_id+"/"+gesture_id,
                success: function(data){
                if(data.result.length>1){
                    console.log(data)
                    plotData(data.result, 1);
                    $(".plot_ges").val("Plot Data ["+data.last_exec+"] ");}
                else{
                    initializeCanvas();
                    $(".plot_ges").val("No Data");
                }
            },
                failure: function(errMsg) {
                    alert(errMsg);
                }
            });
        }
    })
});
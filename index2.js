const LINE = 0, BEZEIR = 1;
const Points = [2, 4];
var tool = LINE;


var ps = [];
function changeTool(toolId){
	tool = toolId;
	ps = [];
}

// <path d="M 200 100 C 100 200 400 300 200 400" stroke="#f00" fill="none"/>
var Line = function(){
	var t = this;
	t.p1 = new Point();
	t.p2 = new Point();
	t.waitMouse = function(callback){
		t.p1.waitMouse(function(){
			t.p2.waitMouse(callback);
		});
		return this;
	};
	t.create = function(){
	};
}

$(function(){
	$('#canvas').mousemove(function(ev){
		$('#mouse-info').text(ev.pageX + ', ' + ev.pageY);
	});
	$('#canvas').click(function(ev){
		$("#mouse-info").text(ev.pageX + ' ' + ev.pageY);
		ps.push([ev.pageX, ev.pageY]);
		if(ps.length == Points[tool]){
			switch(tool){
				case LINE:
					$('#canvas svg').append(
						'<path d="M ' + ps[0][0] + ' ' + ps[0][1] + ' L ' + ps[1][0] + ' ' + ps[1][1] + '" stroke="#f00" fill="none"/>');
					break;
				case BEZEIR:
					$('#canvas svg').append(
						'<path d="M ' + ps[0][0] + ' ' + ps[0][1] + ' C ' + ps[1][0] + ' ' + ps[1][1]
							+ ' ' + ps[2][0] + ' ' + ps[2][1] + ' ' + ps[3][0] + ' ' + ps[3][1] + '" stroke="#f00" fill="none"/>');
					break;
				default: return;
			}
			ps = [];
			$("#canvas").html($("#canvas").html());
		}
	});
	$('#draw-line').click(function(){
		changeTool(LINE);
	});
	$('#draw-bezeir').click(function(){
		changeTool(BEZEIR);
	});
});
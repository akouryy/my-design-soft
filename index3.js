var MDS = {
	selectedScalar: null,
	shapeList: [],
	html_id: 0,
	mode: 'none',
	handleShape: null,
	handleIndex: null,
	add: function(shape){
		MDS.shapeList.push(shape);
		var $s = $(shape.toSvg()).attr('id', 'shape-' + shape.html_id);
		$('#canvas svg').append($s);
		if(shape.children.length == 0)
			$('#objects table').append($(shape.toTr()).attr('id', 'prop-' + shape.html_id));
		else
			$('#prop-' + shape.children[0].html_id).before($(shape.toTr()).attr('id', 'prop-' + shape.html_id));
		var r = shape.coverRect();
		$('<rect fill="none" stroke="#333" stroke-dasharray="5,10"/>').attr({
				x: r[0][0],
				y: r[0][1],
				width: r[1][0] - r[0][0],
				height: r[1][1] - r[0][1],
				id: 'select-' + shape.html_id,
			}).css('display', 'none').appendTo('#canvas svg');
		shape.children.forEach(MDS.hide);
		$('#prop-' + shape.html_id).click(function(){
			MDS.toggleSelect(shape);
			return false;
		});
		if(shape.children.length != 0) MDS.select(shape);
	},
	refresh: function(){
		$('#canvas').html($('#canvas').html());
	},
	select: function(shape){
		$('#canvas svg').unbind('click');
		MDS.unselectAll(shape.parent);
		shape.selected = true;
		if(shape.isScalar) MDS.selectedScalar = shape;
		$('#prop-' + shape.html_id).addClass('prop-selected');
		$('#select-' + shape.html_id).css('display', 'block');
		shape.children.forEach(MDS.show);
	},
	unselect: function(shape){
		shape.selected = false;
		if(MDS.selectedScalar != null && !MDS.selectedScalar.selected) MDS.selectedScalar = null;
		$('#prop-' + shape.html_id).removeClass('prop-selected');
		$('#select-' + shape.html_id).css('display', 'none');
		shape.children.forEach(MDS.hide);
	},
	toggleSelect: function(shape){
		if(shape.selected)
			MDS.unselect(shape);
		else
			MDS.select(shape);
	},
	unselectAll: function(select){
		MDS.shapeList.forEach(function(shape){
			if(shape.selected && shape != select)
				MDS.unselect(shape);
		});
	},
	show: function(shape){
		shape.visible = true;
		$('#shape-' + shape.html_id + ', #prop-' + shape.html_id).css('display', 'table-row');
	},
	hide: function(shape){
		shape.visible = false;
		$('#shape-' + shape.html_id + ', #prop-' + shape.html_id).css('display', 'none');
	},
	onClick: function(ev){
		MDS['onClick_' + MDS.mode](ev);
	},
	onClick_none: function(ev){
	},
	onClick_point: function(ev){
		MDS.unselectAll();
		var p = new Point();
		p.x = ev.pageX;
		p.y = ev.pageY;
		MDS.add(p);
		MDS.refresh();
	},
	onClick_line: function(ev){
		MDS.unselectAll();
		if(!MDS.handleShape){
			MDS.handleShape = new Line();
			MDS.handleShape.s.x = ev.pageX;
			MDS.handleShape.s.y = ev.pageY;
			MDS.add(MDS.handleShape.s);
			MDS.refresh();
		}else{
			MDS.handleShape.e.x = ev.pageX;
			MDS.handleShape.e.y = ev.pageY;
			MDS.add(MDS.handleShape.e);
			MDS.add(MDS.handleShape);
			MDS.refresh();
			MDS.handleShape = null;
		}
	},
	onClick_bezeir: function(ev){
		MDS.unselectAll();
		if(!MDS.handleShape){
			MDS.handleShape = new Bezeir();
			MDS.handleShape.s.x = ev.pageX;
			MDS.handleShape.s.y = ev.pageY;
			MDS.add(MDS.handleShape.s);
			MDS.refresh();
			MDS.handleIndex = 1;
		}else if(MDS.handleIndex == 1){
			MDS.handleShape.c1.x = ev.pageX;
			MDS.handleShape.c1.y = ev.pageY;
			MDS.add(MDS.handleShape.c1);
			MDS.refresh();
			MDS.handleIndex++;
		}else if(MDS.handleIndex == 2){
			MDS.handleShape.c2.x = ev.pageX;
			MDS.handleShape.c2.y = ev.pageY;
			MDS.add(MDS.handleShape.c2);
			MDS.refresh();
			MDS.handleIndex++;
		}else if(MDS.handleIndex == 3){
			MDS.handleShape.e.x = ev.pageX;
			MDS.handleShape.e.y = ev.pageY;
			MDS.add(MDS.handleShape.e);
			MDS.add(MDS.handleShape);
			MDS.refresh();
			MDS.handleShape = null;
			MDS.handleIndex = null;
		}
	},
	setMode: function(mode){
		MDS.mode = mode;
		MDS.unselect(MDS.handleShape);
		MDS.handleShape = null;
		MDS.handleIndex = null;
	}
};

var Point = function(parent, index){
	this.x = this.y = null;
	this.visible = false;
	this.selected = false;
	this.isScalar = true;
	this.children = [];
	if(parent){
		this.html_id = parent.html_id + '-' + index;
		this.parent = parent;
		this.parent.children.push(this);
	}else{
		this.html_id = MDS.html_id++;
		this.parent = null;
	}
};
Point.prototype.toSvg = function(){
	if(this.parent)
		return '<circle cx="' + this.x + '" cy="' + this.y + '" r="5" fill="transparent" stroke="#00f"/>';
	else
		return '<circle cx="' + this.x + '" cy="' + this.y + '" r="2" fill="#f00"/>';
};
Point.prototype.toTr = function(){
	return '<tr><td>' + this.html_id + '</td><td>Point</td></tr>';
};
Point.prototype.coverRect = function(){
	if(this.parent)
		return [[this.x - 6, this.y - 6], [this.x + 6, this.y + 6]];
	else
		return [[this.x - 3, this.y - 3], [this.x + 3, this.y + 3]];
}
Point.prototype.moveTo = function(x, y){
	this.x = x;
	this.y = y;
}

var Line = function(parent, index){
	this.s = this.e = null;
	this.visible = false;
	this.selected = false;
	this.isScalar = false;
	this.children = [];
	if(parent){
		this.html_id = parent.html_id + '-' + index;
		this.parent = parent;
		this.parent.children.push(this);
	}else{
		this.html_id = MDS.html_id++;
		this.parent = null;
	}
	this.s = new Point(this, 0);
	this.e = new Point(this, 1);
};
// Line.prototype.handleClick = function(callback){
// 	var t = this;
// 	t.s = new Point(t, 0);
// 	t.s.handleClick(function(){
// 		t.e = new Point(t, 1);
// 		t.e.handleClick(function(){
// 			MDS.add(t);
// 			MDS.refresh();
// 			callback();
// 		});
// 	});
// };
Line.prototype.toSvg = function(){
	return '<line x1="' + this.s.x + '" y1="' + this.s.y + '" x2="' + this.e.x + '" y2="' + this.e.y + '" fill="none" stroke="#f00"/>';
};
Line.prototype.toTr = function(){
	return '<tr><td>' + this.html_id + '</td><td>Line</td></tr>';
};
Line.prototype.coverRect = function(){
	return [[Math.min(this.s.x, this.e.x), Math.min(this.s.y, this.e.y)], [Math.max(this.s.x, this.e.x), Math.max(this.s.y, this.e.y)]];
}

var Bezeir = function(parent, index){
	this.s = this.c1 = this.c2 = this.e = null;
	this.visible = false;
	this.selected = false;
	this.isScalar = false;
	this.children = [];
	if(parent){
		this.html_id = parent.html_id + '-' + index;
		this.parent = parent;
		this.parent.children.push(this);
	}else{
		this.html_id = MDS.html_id++;
		this.parent = null;
	}
	this.s = new Point(this, 0);
	this.c1 = new Point(this, 1);
	this.c2 = new Point(this, 2);
	this.e = new Point(this, 3);
};
// Bezeir.prototype.handleClick = function(callback){
// 	var t = this;
// 	t.s = new Point(t, 0);
// 	t.s.handleClick(function(){
// 		t.c1 = new Point(t, 1);
// 		t.c1.handleClick(function(){
// 			t.c2 = new Point(t, 2);
// 			t.c2.handleClick(function(){
// 				t.e = new Point(t, 3);
// 				t.e.handleClick(function(){
// 					MDS.add(t);
// 					t.children.forEach(MDS.hide);
// 					MDS.refresh();
// 					callback();
// 				});
// 			});
// 		});
// 	});
// };
Bezeir.prototype.toSvg = function(){
	return '<path d="M ' + this.s.x + ' ' + this.s.y + ' C ' + this.c1.x + ' ' + this.c1.y + ' '
			 + this.c2.x + ' ' + this.c2.y + ' ' + this.e.x + ' ' + this.e.y + '" fill="none" stroke="#f00"/>';
};
Bezeir.prototype.toTr = function(){
	return '<tr><td>' + this.html_id + '</td><td>Bezeir</td></tr>';
};
Bezeir.prototype.coverRect = function(){
	return [[Math.min(this.s.x, this.c1.x, this.c2.x, this.e.x), Math.min(this.s.y, this.c1.y, this.c2.y, this.e.y)],
			[Math.max(this.s.x, this.c1.x, this.c2.x, this.e.x), Math.max(this.s.y, this.c1.y, this.c2.y, this.e.y)]];
}

function waitMove(){
	$('#canvas svg').click(function(ev){
		MDS.selectedScalar.moveTo(ev.pageX, ev.pageY);
		MDS.refresh();
		waitMove();
	});
}

$(function(){
	$('#draw-point').click(function(){
		MDS.setMode('point');
	});
	$('#draw-line').click(function(){
		MDS.setMode('line');
	});
	$('#draw-bezeir').click(function(){
		MDS.setMode('bezeir');
	});
	$('#move-point').click(function(){
		MDS.setMode('move');
	});
	$('#objects').click(function(){
		MDS.unselectAll();
	});
	$('#canvas').click(MDS.onClick);
});

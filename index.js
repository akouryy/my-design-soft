// Generated by CoffeeScript 1.7.1
(function() {
  var Bezeir, FPS, Line, MDS, Point, Pointlike, Shape, debug, pass, view_sec,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  debug = function(x) {
    alert(x);
    return console.log(x);
  };

  pass = void 0;

  FPS = 10;

  view_sec = 10;

  MDS = {
    shapeTypes: {},
    selectedMainly: null,
    selectedTop: null,
    shapeList: [],
    html_id: 0,
    mode: 'none',
    handlingShape: null,
    nextIndex: 0,
    editFrame: 0,
    AnimeGridSize: 1,
    add: function(shape) {
      var $s, animeTr, propTr, s, x1, x2, y1, y2, _i, _len, _ref, _ref1, _ref2, _ref3;
      this.shapeList.push(shape);
      $s = $(shape.toSvg(this.editFrame)).attr('id', "shape-" + shape.html_id);
      $('#canvas svg').append($s);
      propTr = this.prepareTr(shape, false);
      animeTr = this.prepareTr(shape, true);
      if (shape.children.length === 0) {
        $('#objects table').append(propTr);
        $('#animations table').append(animeTr);
      } else {
        $("#prop-" + shape.children[0].html_id).before(propTr);
        $("#anime-" + shape.children[0].html_id).before(animeTr);
      }
      _ref = shape.coverRect(this.editFrame), (_ref1 = _ref[0], x1 = _ref1[0], y1 = _ref1[1]), (_ref2 = _ref[1], x2 = _ref2[0], y2 = _ref2[1]);
      $('<rect fill="none" stroke="#333" stroke-dasharray="5,10"/>').attr({
        x: x1,
        y: y1,
        width: x2 - x1,
        height: y2 - y1,
        id: "select-" + shape.html_id
      }).css('display', 'none').appendTo('#canvas svg');
      _ref3 = shape.children;
      for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
        s = _ref3[_i];
        this.hide(s);
      }
      if (shape.parent == null) {
        return this.select(shape);
      }
    },
    prepareTr: function(shape, isAnime) {
      var i, tr, _, _fn, _i, _ref, _ref1;
      tr = $(shape.toTr(this.editFrame));
      if (isAnime) {
        tr.attr('id', "anime-" + shape.html_id);
        _fn = (function(_this) {
          return function(i, td) {
            td.css({
              width: "" + (92 / (view_sec * FPS)) + "%"
            });
            if (i === _this.editFrame) {
              td.addClass('anime-grid-editing');
            }
            if (i % FPS === 0) {
              td.addClass('bold-grid-line');
            } else if (i % (FPS / 2) === 0) {
              td.addClass('thin-grid-line');
            }
            td.click(function() {
              return _this.setFrame(i);
            }).contextMenu('control-point-menu', {
              bindings: {
                'select-object-frame': function(t) {
                  _this.select(shape);
                  return _this.setFrame(i);
                },
                'select-object': function(t) {
                  return _this.select(shape);
                },
                'select-frame': function(t) {
                  return _this.setFrame(i);
                },
                'delete-object': function(t) {
                  return _this.remove(shape);
                },
                'delete-control-point': function(t) {
                  delete shape.ps[i];
                  return td.removeClass('grid-control-point');
                }
              },
              menuStyle: {
                'border-radius': '1px',
                'background-color': '#eee',
                width: '150px'
              }
            });
            return tr.append(td);
          };
        })(this);
        for (i = _i = 0, _ref = view_sec * FPS; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          _fn(i, $("<td class='anime-grid' data-frame='" + i + "'>　</td>"));
        }
        if (shape.ps != null) {
          _ref1 = shape.ps;
          for (i in _ref1) {
            _ = _ref1[i];
            tr.children("[data-frame=" + i + "]").addClass('grid-control-point');
          }
        }
      } else {
        tr.attr('id', "prop-" + shape.html_id);
        tr.append($('<td/>'));
      }
      tr.children('.html-id, .shape-type').contextMenu('object-menu', {
        bindings: {
          'delete-object': (function(_this) {
            return function(t) {
              return _this.remove(shape);
            };
          })(this),
          'select-object': (function(_this) {
            return function(t) {
              return _this.toggleSelect(shape);
            };
          })(this)
        },
        menuStyle: {
          'border-radius': '1px',
          'background-color': '#eee',
          width: '150px'
        }
      }).click((function(_this) {
        return function() {
          _this.toggleSelect(shape);
          return false;
        };
      })(this));
      return tr;
    },
    remove: function(shape, parentDone) {
      var s, _i, _len, _ref;
      this.shapeList = (function() {
        var _i, _len, _ref, _results;
        _ref = this.shapeList;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          s = _ref[_i];
          if (s !== shape) {
            _results.push(s);
          }
        }
        return _results;
      }).call(this);
      $("#prop-" + shape.html_id + ", #anime-" + shape.html_id + ", #shape-" + shape.html_id + ", #select-" + shape.html_id).remove();
      _ref = shape.children;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        s = _ref[_i];
        this.remove(s, true);
      }
      if (shape.parent != null) {
        if (parentDone == null) {
          return this.remove(shape.parent);
        }
      }
    },
    reload: function(shape) {
      var animeTr, propTr, r, x1, x2, y1, y2, _ref, _ref1, _ref2;
      $("#shape-" + shape.html_id).replaceWith($(shape.toSvg(this.editFrame)).attr('id', "shape-" + shape.html_id));
      r = shape.coverRect(this.editFrame);
      _ref = shape.coverRect(this.editFrame), (_ref1 = _ref[0], x1 = _ref1[0], y1 = _ref1[1]), (_ref2 = _ref[1], x2 = _ref2[0], y2 = _ref2[1]);
      $("#select-" + shape.html_id).attr({
        x: x1,
        y: y1,
        width: x2 - x1,
        height: y2 - y1
      });
      propTr = this.prepareTr(shape, false);
      animeTr = this.prepareTr(shape, true);
      if (shape.selected) {
        propTr.addClass('prop-selected');
        animeTr.addClass('prop-selected');
      }
      $("#prop-" + shape.html_id).replaceWith(propTr);
      $("#anime-" + shape.html_id).replaceWith(animeTr);
      if (shape.parent != null) {
        this.reload(shape.parent);
      }
      return this.refresh();
    },
    refresh: function() {
      return $('#canvas').html($('#canvas').html());
    },
    select: function(shape) {
      var err, s, _i, _len, _ref, _results;
      try {
        this.unselectAll(shape.parent);
        this.selectedMainly = shape;
        if (shape.parent == null) {
          this.selectedTop = shape;
        }
        shape.selected = true;
        $("#prop-" + shape.html_id + ", #anime-" + shape.html_id).addClass('prop-selected');
        $("#select-" + shape.html_id).css('display', 'inline');
        $('#change-color').ColorPickerSetColor(shape.cs[this.editFrame]);
        _ref = shape.children;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          s = _ref[_i];
          _results.push(this.show(s));
        }
        return _results;
      } catch (_error) {
        err = _error;
        return debug(err);
      }
    },
    unselect: function(shape) {
      var err, s, _i, _j, _len, _len1, _ref, _ref1, _ref2, _results;
      try {
        if (shape === this.selectedMainly) {
          this.selectedMainly = (_ref = shape.parent) != null ? _ref : null;
        } else {
          this.selectedMainly = null;
        }
        if (shape === this.selectedTop) {
          this.selectedTop = null;
        }
        shape.selected = false;
        $("#prop-" + shape.html_id + ", #anime-" + shape.html_id).removeClass('prop-selected');
        $("#select-" + shape.html_id).css('display', 'none');
        _ref1 = shape.children;
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          s = _ref1[_i];
          this.unselect(s);
        }
        _ref2 = shape.children;
        _results = [];
        for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
          s = _ref2[_j];
          _results.push(this.hide(s));
        }
        return _results;
      } catch (_error) {
        err = _error;
        return debug(err);
      }
    },
    toggleSelect: function(shape) {
      if (shape.selected) {
        return this.unselect(shape);
      } else {
        return this.select(shape);
      }
    },
    unselectAll: function(select) {
      var err, shape, _i, _len, _ref, _results;
      try {
        _ref = this.shapeList;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          shape = _ref[_i];
          if (shape.selected && shape !== select) {
            _results.push(this.unselect(shape));
          }
        }
        return _results;
      } catch (_error) {
        err = _error;
        return debug(err);
      }
    },
    show: function(shape) {
      shape.visible = true;
      return $("#shape-" + shape.html_id + ", #prop-" + shape.html_id + ", #anime-" + shape.html_id).css('display', 'table-row');
    },
    hide: function(shape) {
      shape.visible = false;
      return $("#shape-" + shape.html_id + ", #prop-" + shape.html_id + ", #anime-" + shape.html_id).css('display', 'none');
    },
    onClick: function(ev) {
      var err, p;
      try {
        switch (this.mode) {
          case 'none':
            return pass;
          case 'point':
            this.unselectAll();
            p = new Point();
            p.set(0, ev.pageX, ev.pageY);
            this.add(p);
            return this.refresh();
          case 'line':
          case 'bezeir':
            this.unselectAll();
            if (this.handlingShape == null) {
              this.nextIndex = 0;
              this.handlingShape = new this.shapeTypes[this.mode]();
            }
            this.handlingShape.children[this.nextIndex].set(0, ev.pageX, ev.pageY);
            this.add(this.handlingShape.children[this.nextIndex]);
            this.refresh();
            this.nextIndex++;
            if (this.nextIndex === this.handlingShape.children.length) {
              this.add(this.handlingShape);
              this.handlingShape = null;
              return this.refresh();
            }
            break;
          case 'move':
            if (!(this.selectedMainly instanceof Pointlike)) {
              alert("" + this.selectedMainly.constructor.name + "は動かせません");
              return;
            }
            this.selectedMainly.set(this.editFrame, ev.pageX, ev.pageY);
            this.reload(this.selectedMainly);
            return this.refresh();
        }
      } catch (_error) {
        err = _error;
        return debug(err);
      }
    },
    setMode: function(mode) {
      switch (this.mode) {
        case 'none':
          pass;
          break;
        case 'point':
        case 'line':
        case 'bezeir':
          pass;
          break;
        case 'anime':
          $('#animations').hide(100);
      }
      this.mode = mode;
      if (this.handlingShape != null) {
        this.remove(this.handlingShape);
      }
      this.handlingShape = null;
      this.nextIndex = 0;
      switch (this.mode) {
        case 'none':
          return pass;
        case 'point':
        case 'line':
        case 'bezeir':
          return pass;
        case 'anime':
          return $('#animations').show(1000);
      }
    },
    setFrame: function(frame) {
      var s, x1, x2, y1, y2, _i, _len, _ref, _ref1, _ref2, _ref3, _results;
      this.editFrame = frame;
      $('#animation-range').val(frame);
      $('.anime-grid-editing').removeClass('anime-grid-editing');
      $("#animations [data-frame=" + frame + "]").addClass('anime-grid-editing');
      _ref = this.shapeList;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        s = _ref[_i];
        s.updateSvg($("#shape-" + s.html_id), frame);
        s.updateTr($("#prop-" + s.html_id + ", #anime-" + s.html_id), frame);
        _ref1 = s.coverRect(frame), (_ref2 = _ref1[0], x1 = _ref2[0], y1 = _ref2[1]), (_ref3 = _ref1[1], x2 = _ref3[0], y2 = _ref3[1]);
        _results.push($("#select-" + s.html_id).attr({
          x: x1,
          y: y1,
          width: x2 - x1,
          height: y2 - y1
        }));
      }
      return _results;
    }
  };

  Shape = (function() {
    Shape.prototype.visible = false;

    Shape.prototype.selected = false;

    function Shape(parent, index) {
      var _ref;
      this.children = [];
      this.cs = {
        0: [255, 0, 0]
      };
      this.parent = parent != null ? parent : null;
      this.html_id = parent != null ? "" + parent.html_id + "-" + index : MDS.html_id++;
      if ((_ref = this.parent) != null) {
        _ref.children.push(this);
      }
    }

    Shape.prototype.setColor = function(f, r, g, b) {
      return this.cs[f] = [r, g, b];
    };

    Shape.prototype.getColor = function(f) {
      var newB, newF, newG, newR, oldB, oldF, oldG, oldR, _ref, _ref1, _ref2;
      oldF = -1;
      _ref = this.cs[0], oldR = _ref[0], oldG = _ref[1], oldB = _ref[2];
      _ref1 = this.cs;
      for (newF in _ref1) {
        _ref2 = _ref1[newF], newR = _ref2[0], newG = _ref2[1], newB = _ref2[2];
        if (newF >= f) {
          return [Math.floor(oldR + (newR - oldR) / (newF - oldF) * (f - oldF)), Math.floor(oldG + (newG - oldG) / (newF - oldF) * (f - oldF)), Math.floor(oldB + (newB - oldB) / (newF - oldF) * (f - oldF))];
        }
        oldF = newF;
        oldR = newR;
        oldG = newG;
        oldB = newB;
      }
      return [Math.floor(oldR), Math.floor(oldG), Math.floor(oldB)];
    };

    Shape.prototype.toSvg = function(f) {
      return pass;
    };

    Shape.prototype.updateSvg = function(svg, f) {
      return pass;
    };

    Shape.prototype.toTr = function(f) {
      return pass;
    };

    Shape.prototype.updateTr = function(tr, f) {
      return pass;
    };

    Shape.prototype.coverRect = function(f) {
      return pass;
    };

    return Shape;

  })();

  Pointlike = (function(_super) {
    __extends(Pointlike, _super);

    function Pointlike(parent, index) {
      Pointlike.__super__.constructor.call(this, parent, index);
    }

    return Pointlike;

  })(Shape);

  Point = (function(_super) {
    __extends(Point, _super);

    MDS.shapeTypes['point'] = Point;

    function Point(parent, index) {
      this.ps = {};
      Point.__super__.constructor.call(this, parent, index);
    }

    Point.prototype.set = function(f, x, y) {
      return this.ps[f] = [x, y];
    };

    Point.prototype.get = function(f) {
      var newF, newX, newY, oldF, oldX, oldY, _ref, _ref1, _ref2;
      oldF = -1;
      _ref = this.ps[0], oldX = _ref[0], oldY = _ref[1];
      _ref1 = this.ps;
      for (newF in _ref1) {
        _ref2 = _ref1[newF], newX = _ref2[0], newY = _ref2[1];
        if (newF >= f) {
          return [Math.floor(oldX + (newX - oldX) / (newF - oldF) * (f - oldF)), Math.floor(oldY + (newY - oldY) / (newF - oldF) * (f - oldF))];
        }
        oldF = newF;
        oldX = newX;
        oldY = newY;
      }
      return [Math.floor(oldX), Math.floor(oldY)];
    };

    Point.prototype.toSvg = function(f) {
      var x, y, _ref;
      _ref = this.get(f), x = _ref[0], y = _ref[1];
      if (this.parent != null) {
        return "<circle cx='" + x + "' cy='" + y + "' r='5' fill='transparent' stroke='#00f'/>";
      } else {
        return "<circle cx='" + x + "' cy='" + y + "' r='2' fill='#f00'/>";
      }
    };

    Point.prototype.updateSvg = function(svg, f) {
      var x, y, _ref;
      _ref = this.get(f), x = _ref[0], y = _ref[1];
      return svg.attr({
        cx: x,
        cy: y
      });
    };

    Point.prototype.toTr = function(f) {
      var x, y, _ref;
      _ref = this.get(f), x = _ref[0], y = _ref[1];
      return "<tr><td class='html-id' title='点(" + x + ", " + y + ")'>" + this.html_id + "</td> <td class='shape-type' title='(" + x + ", " + y + ")'>Point</td></tr>";
    };

    Point.prototype.updateTr = function(tr, f) {
      var x, y, _ref;
      _ref = this.get(f), x = _ref[0], y = _ref[1];
      tr.children('.html-id').attr({
        title: "点(" + x + ", " + y + ")"
      });
      return tr.children('.shape-type').attr({
        title: "(" + x + ", " + y + ")"
      });
    };

    Point.prototype.coverRect = function(f) {
      var x, y, _ref;
      _ref = this.get(f), x = _ref[0], y = _ref[1];
      if (this.parent != null) {
        return [[x - 6, y - 6], [x + 6, y + 6]];
      } else {
        return [[x - 3, y - 3], [x + 3, y + 3]];
      }
    };

    return Point;

  })(Pointlike);

  Line = (function(_super) {
    __extends(Line, _super);

    MDS.shapeTypes['line'] = Line;

    function Line(parent, index) {
      Line.__super__.constructor.call(this, parent, index);
      this.s = new Point(this, 0);
      this.e = new Point(this, 1);
    }

    Line.prototype.toSvg = function(f) {
      var ex, ey, sx, sy, _ref, _ref1;
      _ref = this.s.get(f), sx = _ref[0], sy = _ref[1];
      _ref1 = this.e.get(f), ex = _ref1[0], ey = _ref1[1];
      return "<line x1='" + sx + "' y1='" + sy + "' x2='" + ex + "' y2='" + ey + "' fill='none' stroke='#f00'/>";
    };

    Line.prototype.updateSvg = function(svg, f) {
      var b, ex, ey, g, r, sx, sy, _ref, _ref1, _ref2;
      _ref = this.s.get(f), sx = _ref[0], sy = _ref[1];
      _ref1 = this.e.get(f), ex = _ref1[0], ey = _ref1[1];
      _ref2 = this.getColor(f), r = _ref2[0], g = _ref2[1], b = _ref2[2];
      return svg.attr({
        x1: sx,
        y1: sy,
        x2: ex,
        y2: ey,
        stroke: "#" + ('0' + r.toString(16)).slice(-2) + ('0' + g.toString(16)).slice(-2) + ('0' + b.toString(16)).slice(-2)
      });
    };

    Line.prototype.toTr = function(f) {
      var ex, ey, sx, sy, _ref, _ref1;
      _ref = this.s.get(f), sx = _ref[0], sy = _ref[1];
      _ref1 = this.e.get(f), ex = _ref1[0], ey = _ref1[1];
      return "<tr><td class='html-id' title='直線((" + sx + ", " + sy + ") (" + ex + ", " + ey + "))'>" + this.html_id + "</td> <td class='shape-type' title='(" + sx + ", " + sy + ") (" + ex + ", " + ey + ")'>Line</td></tr>";
    };

    Line.prototype.updateTr = function(tr, f) {
      var ex, ey, sx, sy, _ref, _ref1;
      _ref = this.s.get(f), sx = _ref[0], sy = _ref[1];
      _ref1 = this.e.get(f), ex = _ref1[0], ey = _ref1[1];
      tr.children('.html-id').attr({
        title: "直線((" + sx + ", " + sy + ") (" + ex + ", " + ey + "))"
      });
      return tr.children('.shape-type').attr({
        title: "((" + sx + ", " + sy + ") (" + ex + ", " + ey + "))"
      });
    };

    Line.prototype.coverRect = function(f) {
      var ex, ey, sx, sy, _ref, _ref1;
      _ref = this.s.get(f), sx = _ref[0], sy = _ref[1];
      _ref1 = this.e.get(f), ex = _ref1[0], ey = _ref1[1];
      return [[Math.min(sx, ex), Math.min(sy, ey)], [Math.max(sx, ex), Math.max(sy, ey)]];
    };

    return Line;

  })(Shape);

  Bezeir = (function(_super) {
    __extends(Bezeir, _super);

    MDS.shapeTypes['bezeir'] = Bezeir;

    function Bezeir(parent, index) {
      Bezeir.__super__.constructor.call(this, parent, index);
      this.s = new Point(this, 0);
      this.c1 = new Point(this, 1);
      this.c2 = new Point(this, 2);
      this.e = new Point(this, 3);
    }

    Bezeir.prototype.toSvg = function(f) {
      var c1x, c1y, c2x, c2y, ex, ey, sx, sy, _ref, _ref1, _ref2, _ref3;
      _ref = this.s.get(f), sx = _ref[0], sy = _ref[1];
      _ref1 = this.c1.get(f), c1x = _ref1[0], c1y = _ref1[1];
      _ref2 = this.c2.get(f), c2x = _ref2[0], c2y = _ref2[1];
      _ref3 = this.e.get(f), ex = _ref3[0], ey = _ref3[1];
      return "<path d='M " + sx + " " + sy + " C " + c1x + " " + c1y + " " + c2x + " " + c2y + " " + ex + " " + ey + "' fill='none' stroke='#f00'/>";
    };

    Bezeir.prototype.updateSvg = function(svg, f) {
      var b, c1x, c1y, c2x, c2y, ex, ey, g, r, sx, sy, _ref, _ref1, _ref2, _ref3, _ref4;
      _ref = this.s.get(f), sx = _ref[0], sy = _ref[1];
      _ref1 = this.c1.get(f), c1x = _ref1[0], c1y = _ref1[1];
      _ref2 = this.c2.get(f), c2x = _ref2[0], c2y = _ref2[1];
      _ref3 = this.e.get(f), ex = _ref3[0], ey = _ref3[1];
      _ref4 = this.getColor(f), r = _ref4[0], g = _ref4[1], b = _ref4[2];
      return svg.attr({
        d: "M " + sx + " " + sy + " C " + c1x + " " + c1y + " " + c2x + " " + c2y + " " + ex + " " + ey,
        stroke: "#" + ('0' + r.toString(16)).slice(-2) + ('0' + g.toString(16)).slice(-2) + ('0' + b.toString(16)).slice(-2)
      });
    };

    Bezeir.prototype.toTr = function(f) {
      var c1x, c1y, c2x, c2y, ex, ey, sx, sy, _ref, _ref1, _ref2, _ref3;
      _ref = this.s.get(f), sx = _ref[0], sy = _ref[1];
      _ref1 = this.c1.get(f), c1x = _ref1[0], c1y = _ref1[1];
      _ref2 = this.c2.get(f), c2x = _ref2[0], c2y = _ref2[1];
      _ref3 = this.e.get(f), ex = _ref3[0], ey = _ref3[1];
      return "<tr><td class='html-id' title='3次ベジェ曲線((" + sx + ", " + sy + ") (" + c1x + ", " + c1y + ") (" + c2x + ", " + c2y + ") (" + ex + ", " + ey + "))'>" + this.html_id + "</td> <td class='shape-type' title='(" + sx + ", " + sy + ") (" + c1x + ", " + c1y + ") (" + c2x + ", " + c2y + ") (" + ex + ", " + ey + ")'>Bezeir</td></tr>";
    };

    Bezeir.prototype.updateTr = function(tr, f) {
      var c1x, c1y, c2x, c2y, ex, ey, sx, sy, _ref, _ref1, _ref2, _ref3;
      _ref = this.s.get(f), sx = _ref[0], sy = _ref[1];
      _ref1 = this.c1.get(f), c1x = _ref1[0], c1y = _ref1[1];
      _ref2 = this.c2.get(f), c2x = _ref2[0], c2y = _ref2[1];
      _ref3 = this.e.get(f), ex = _ref3[0], ey = _ref3[1];
      tr.children('.html-id').attr({
        title: "3次ベジェ曲線((" + sx + ", " + sy + ") (" + c1x + ", " + c1y + ") (" + c2x + ", " + c2y + ") (" + ex + ", " + ey + "))"
      });
      return tr.children('.shape-type').attr({
        title: "(" + sx + ", " + sy + ") (" + c1x + ", " + c1y + ") (" + c2x + ", " + c2y + ") (" + ex + ", " + ey + ")"
      });
    };

    Bezeir.prototype.coverRect = function(f) {
      var c1x, c1y, c2x, c2y, ex, ey, minmax, sx, sy, xmax, xmin, ymax, ymin, _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
      minmax = function(p0, p1, p2, p3) {
        var D_, a, b, c, d, max, min, t, α, β, _ref;
        _ref = [-(p0 - 3 * p1 + 3 * p2 - p3), 3 * p0 - 6 * p1 + 3 * p2, -(3 * p0 - 3 * p1), p0], a = _ref[0], b = _ref[1], c = _ref[2], d = _ref[3];
        f = function(k) {
          return (a * k * k * k) + (b * k * k) + (c * k) + d;
        };
        max = Math.max(f(0), f(1));
        min = Math.min(f(0), f(1));
        if (a !== 0) {
          D_ = b * b - 3 * a * c;
          if (D_ > 0) {
            α = (-b - Math.sqrt(b * b - 3 * a * c)) / (3 * a);
            β = (-b + Math.sqrt(b * b - 3 * a * c)) / (3 * a);
            if ((0 <= α && α <= 1)) {
              max = Math.max(max, f(α));
              min = Math.min(min, f(α));
            }
            if ((0 <= β && β <= 1)) {
              max = Math.max(max, f(β));
              min = Math.min(min, f(β));
            }
          }
        } else {
          if (b !== 0) {
            t = c / (2 * b);
            if ((0 <= t && t <= 1)) {
              max = Math.max(max, f(t));
              min = Math.min(min, f(t));
            }
          }
        }
        return [min, max];
      };
      _ref = this.s.get(f), sx = _ref[0], sy = _ref[1];
      _ref1 = this.c1.get(f), c1x = _ref1[0], c1y = _ref1[1];
      _ref2 = this.c2.get(f), c2x = _ref2[0], c2y = _ref2[1];
      _ref3 = this.e.get(f), ex = _ref3[0], ey = _ref3[1];
      _ref4 = minmax(sx, c1x, c2x, ex), xmin = _ref4[0], xmax = _ref4[1];
      _ref5 = minmax(sy, c1y, c2y, ey), ymin = _ref5[0], ymax = _ref5[1];
      return [[xmin, ymin], [xmax, ymax]];
    };

    return Bezeir;

  })(Shape);

  $(function() {
    var frame, i, interval, isLooping, _i, _ref, _results;
    frame = 0;
    interval = null;
    isLooping = false;
    $('#mode-none').click(function() {
      MDS.setMode('none');
      $('.mode-tool').removeClass('tool-selected');
      return $(this).addClass('tool-selected');
    });
    $('#draw-point').click(function() {
      MDS.setMode('point');
      $('.mode-tool').removeClass('tool-selected');
      return $(this).addClass('tool-selected');
    });
    $('#draw-line').click(function() {
      MDS.setMode('line');
      $('.mode-tool').removeClass('tool-selected');
      return $(this).addClass('tool-selected');
    });
    $('#draw-bezeir').click(function() {
      MDS.setMode('bezeir');
      $('.mode-tool').removeClass('tool-selected');
      return $(this).addClass('tool-selected');
    });
    $('#change-color').ColorPicker({
      color: '#f00',
      onSubmit: function(hsb, hex, rgb) {
        return MDS.selectedTop.setColor(MDS.editFrame, rgb.r, rgb.g, rgb.b);
      }
    });
    $('#move-point').click(function() {
      MDS.setMode('move');
      $('.mode-tool').removeClass('tool-selected');
      return $(this).addClass('tool-selected');
    });
    $('#animation-mode').click(function() {
      MDS.setMode('anime');
      $('.mode-tool').removeClass('tool-selected');
      return $(this).addClass('tool-selected');
    });
    $('#animation-range').attr({
      max: view_sec * FPS - 1
    }).change(function() {
      return MDS.setFrame(frame = $(this).val());
    });
    $('#animation-start').click(function() {
      $('.anime-tool').removeClass('tool-selected');
      $('#animation-start').css({
        display: 'none'
      });
      $('#animation-pause').css({
        display: 'inline-block'
      });
      return interval = setInterval((function(_this) {
        return function() {
          frame++;
          if (frame >= view_sec * FPS) {
            frame = 0;
            MDS.setFrame(0);
            if (!isLooping) {
              clearInterval(interval);
              $(_this).removeClass('tool-selected');
              return $('#animation-pause').addClass('tool-selected');
            }
          } else {
            return MDS.setFrame(frame);
          }
        };
      })(this), 1000 / FPS);
    });
    $('#animation-pause').click(function() {
      $('.anime-tool').removeClass('tool-selected');
      $('#animation-start').css({
        display: 'inline-block'
      });
      $('#animation-pause').css({
        display: 'none'
      });
      return clearInterval(interval);
    });
    $('#animation-stop').click(function() {
      $(this).addClass('tool-selected');
      $('#animation-start').css({
        display: 'inline-block'
      });
      $('#animation-pause').css({
        display: 'none'
      });
      clearInterval(interval);
      frame = 0;
      return MDS.setFrame(0);
    });
    $('#animation-loop').click(function() {
      isLooping = !isLooping;
      if (isLooping) {
        return $(this).addClass('tool-selected');
      } else {
        return $(this).removeClass('tool-selected');
      }
    });
    $('#show-mds-info').click(function() {
      $('#mds-info').css('display', $('#mds-info').css('display') === 'none' ? 'block' : 'none');
      return $(this).toggleClass('tool-selected');
    });
    $('#unselect').click(function() {
      return MDS.unselectAll();
    });
    $('#remove').click(function() {
      return MDS.remove(MDS.selectedMainly);
    });
    $('#canvas').click(function(ev) {
      return MDS.onClick(ev);
    });
    _results = [];
    for (i = _i = 0, _ref = view_sec * FPS; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      _results.push($("<th data-frame=" + i + " " + (i === MDS.editFrame ? "class='anime-grid-editing'" : void 0) + " " + (i % FPS === 0 ? "class='bold-grid-line'>" + i : i % (FPS / 2) === 0 ? "class='thin-grid-line'>" + i : ">") + "</th>").css({
        width: "" + (92 / (view_sec * FPS)) + "%"
      }).appendTo($('#animations .header')));
    }
    return _results;
  });

}).call(this);

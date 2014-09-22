// Generated by CoffeeScript 1.7.1
(function() {
  var defaults, extend,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  defaults = {
    width: 480,
    height: 400,
    margin: {
      top: 20,
      right: 30,
      bottom: 30,
      left: 40
    },
    lineheight: 20
  };

  extend = function(destination, source) {
    var property, _i, _len, _ref;
    _ref = Object.keys(source);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      property = _ref[_i];
      destination[property] = source[property];
    }
    return destination;
  };

  this.RoadmapD3 = (function() {
    function RoadmapD3(target, options) {
      var self;
      this.target = target;
      if (options == null) {
        options = {};
      }
      this.options = extend(defaults, options);
      self = this;
      window.onresize = function(e) {
        return self.update_window(e, self);
      };
    }

    RoadmapD3.prototype.update_window = function(e, self) {
      var x;
      x = $(".chart").parent().parent().width();
      self.options.width = x;
      $(self.target).empty();
      return self.draw(self.lastdata);
    };

    RoadmapD3.prototype.zoomed = function() {
      this.svg.select(".x.axis").call(this.xAxis);
      d3.event.translate[1] = 0;
      console.log(d3.event.translate);
      return this.graph.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ", 1)");
    };

    RoadmapD3.prototype.move_to = function(x, node) {
      var scale;
      scale = this.zoom.scale();
      this.zoom.translate([x * scale, 0]);
      return this.zoom.event(node);
    };

    RoadmapD3.prototype.resize = function(width, height) {
      return this.graph.attr("transform", "translate(" + width + ", " + height + ")");
    };

    RoadmapD3.prototype.get_data_range = function(data) {
      return [
        d3.min(data, function(d) {
          return new Date(d.startdate);
        }), d3.max(data, function(d) {
          return new Date(d.enddate);
        })
      ];
    };

    RoadmapD3.prototype.get_current_time_range = function(back, forward) {
      var backtime, forwardtime;
      if (back == null) {
        back = 7;
      }
      if (forward == null) {
        forward = 7;
      }
      backtime = new Date;
      forwardtime = new Date;
      backtime.setDate(backtime.getDate() - back);
      forwardtime.setDate(forwardtime.getDate() + forward);
      return [backtime, forwardtime];
    };

    RoadmapD3.prototype.get_groups = function(data) {
      var group, groupdicts, groupname, grouppos, groups, item, _i, _j, _len, _len1, _ref;
      groups = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        item = data[_i];
        if (_ref = item.group, __indexOf.call(groups, _ref) < 0) {
          groups.push(item.group);
        }
      }
      groups.sort();
      this.groupheight = this.height / groups.length;
      grouppos = 0;
      groupdicts = [];
      for (_j = 0, _len1 = groups.length; _j < _len1; _j++) {
        groupname = groups[_j];
        group = {
          name: groupname,
          index: grouppos,
          ypos: grouppos * this.groupheight,
          height: this.groupheight
        };
        groupdicts.push(group);
        grouppos++;
      }
      return groupdicts;
    };

    RoadmapD3.prototype.validate_data = function(data) {
      var item, _i, _len, _results;
      this.lastdata = data;
      _results = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        item = data[_i];
        if (typeof item.startdate === 'string') {
          item.startdate = new Date(item.startdate);
        }
        if (typeof item.enddate === 'string') {
          item.enddate = new Date(item.enddate);
        }
        if (item.startdate == null) {
          console.log("Item '" + item.name + "' has no startdate!");
        }
        if (item.enddate == null) {
          console.log("Item '" + item.name + "' has no enddate!");
          item.enddate = new Date(item.startdate);
          _results.push(item.enddate.setDate(item.enddate.getDate() + 7));
        } else if (item.enddate < item.startdate) {
          console.log("Item '" + item.name + "' enddate < startdate!");
          item.enddate = new Date(item.startdate);
          _results.push(item.enddate.setDate(item.enddate.getDate() + 7));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    RoadmapD3.prototype.draw = function(data) {
      var self;
      self = this;
      this.validate_data(data);
      this.width = this.options.width;
      this.height = this.options.height;
      this.rangex = this.get_current_time_range();
      this.groups = this.get_groups(data);
      console.log(this.groups);
      this.create_axis(this.rangex);
      this.zoom = d3.behavior.zoom().x(this.x).scaleExtent([0, 10]).on("zoom", function() {
        return self.zoomed();
      });
      this.svg = d3.select(self.target).append("svg").attr("width", this.width).attr("height", this.height).call(this.zoom);
      this.draw_groups(this.groups);
      this.graph = this.svg.append("g");
      this.svg.append("g").attr("class", "x axis").attr("stroke-dasharray", "2,2").call(this.xAxis);
      this.graph.append("g").attr("transform", "translate(" + 0 + "," + 0 + ")");
      this.graph.attr("class", "chart");
      return this.draw_blocks(data);
    };

    RoadmapD3.prototype.create_axis = function(rangex) {
      var formatWeek;
      this.x = d3.time.scale().range([0, this.width]);
      formatWeek = function(d) {
        var format;
        format = d3.time.format("%U.%w");
        return "Week " + (format(d));
      };
      this.xAxis = d3.svg.axis().scale(this.x).orient("bottom").tickSize(this.height - this.options.margin.bottom).tickFormat(formatWeek);
      rangex[0] = rangex[0].setDate(rangex[0].getDate() - 7);
      rangex[1] = rangex[1].setDate(rangex[1].getDate() + 7);
      return this.x.domain(rangex);
    };

    RoadmapD3.prototype.draw_groups = function(groups) {
      var groupnodes;
      groupnodes = this.svg.selectAll("g").data(groups).enter().append("g").attr("transform", function(d) {
        return "translate(" + 0 + "," + d.ypos + ")";
      });
      groupnodes.append("rect").attr("class", function(d) {
        if (d.index % 2 === 0) {
          return "group even";
        } else {
          return "group odd";
        }
      }).attr("width", this.width).attr("height", function(d) {
        return d.height;
      });
      return groupnodes.append("text").attr("class", "group").attr("dy", "1em").attr("dx", "1em").attr("font-size", "2em").text(function(d) {
        return d.name;
      });
    };

    RoadmapD3.prototype.get_group = function(name) {
      var group, _i, _len, _ref;
      _ref = this.groups;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        group = _ref[_i];
        if (group.name === name) {
          return group;
        }
      }
      return null;
    };

    RoadmapD3.prototype.draw_blocks = function(data) {
      var block, blocks, bpos, item, now, nowx, self, x1, x2, ylane, yoffset, ypos, _i, _j, _len, _len1;
      self = this;
      now = new Date;
      blocks = [];
      ylane = 0;
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        item = data[_i];
        x1 = this.x(item.startdate);
        x2 = this.x(item.enddate);
        ypos = this.get_group(item.group).ypos;
        bpos = 0;
        for (_j = 0, _len1 = blocks.length; _j < _len1; _j++) {
          block = blocks[_j];
          if (block.item.group === item.group) {
            if (block.item.startdate <= item.startdate && item.startdate <= block.item.enddate || block.item.startdate <= item.enddate && item.enddate <= block.item.enddate) {
              bpos++;
            }
          }
        }
        yoffset = (this.options.lineheight + 10) * bpos;
        block = {
          name: item.name,
          x: x1,
          y: ypos + yoffset,
          index: bpos,
          height: this.options.lineheight,
          width: x2 - x1,
          item: item
        };
        blocks.push(block);
      }
      nowx = this.x(now);
      this.graph.append("line").attr("x1", nowx).attr("y1", 0).attr("x2", nowx).attr("y2", this.height - this.options.margin.bottom).attr("stroke", "red");
      this.nodes = this.graph.selectAll("rect").data(blocks).enter().append("g").attr("class", "node").attr("transform", function(d) {
        return "translate(" + d.x + "," + d.y + ")";
      });
      this.nodes.append("title").text(function(d) {
        return d.name;
      });
      this.nodes.append("rect").attr("class", "block").attr("width", function(d) {
        return d.width;
      }).attr("height", function(d) {
        return d.height;
      }).attr("rx", "10");
      this.nodes.append("text").attr("class", "block").attr("dx", "1em").attr("dy", "1em").style("text-anchor", "start").text(function(d) {
        return d.name;
      });
      this.nodes.on("mouseover", function(d, i) {
        return d3.select(this).select('rect').classed("highlight", true);
      });
      this.nodes.on("mouseout", function(d, i) {
        return d3.select(this).select('rect').classed("highlight", false);
      });
      this.nodes.on("click", function(d, i) {
        var node;
        node = self.nodes[0][i];
        return $(self).trigger("select", {
          data: d,
          node: node
        });
      });
    };

    return RoadmapD3;

  })();

}).call(this);

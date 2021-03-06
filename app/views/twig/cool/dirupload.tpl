{% extends "layouts/cool.tpl" %}

{% block simple_content %}
	<h1>Directory API</h1>
	<section>
		<input type="file" class="hidden-input" webkitdirectory>
		<button id="directory-upload">Select a directory</button>

		View as: <a href="" onclick="javascript:toggleTree(this);" data-next="LIST">TREE</a>
		<textarea id="directory-list"></textarea>
		<ul id="dir-tree" class="hidden"></ul>
	</section>
{% endblock %}

{% block inline_scripts %}
 window.URL = window.URL || window.webkitURL;

  function toggleTree(a) {
    document.querySelector('#dir-tree').classList.toggle('hidden');
    document.querySelector('#directory-list').classList.toggle('hidden');

    var next = a.dataset.next;
    a.dataset.next = a.textContent;
    a.textContent = next;

    window.event.preventDefault();
    return false;
  }

  function Tree(selector) {
    this.$el = $(selector);
    this.fileList = [];
    var html_ = [];
    var tree_ = {};
    var pathList_ = [];
    var self = this;

    this.render = function(object) {
      if (object) {
        for (var folder in object) {
          if (!object[folder]) { // file's will have a null value
            html_.push('<li><a href="#" data-type="file">', folder, '</a></li>');
          } else {
            html_.push('<li><a href="#">', folder, '</a>');
            html_.push('<ul>');
            self.render(object[folder]);
            html_.push('</ul>');
          }
        }
      }
    };

    this.buildFromPathList = function(paths) {
      for (var i = 0, path; path = paths[i]; ++i) {
        var pathParts = path.split('/');
        var subObj = tree_;
        for (var j = 0, folderName; folderName = pathParts[j]; ++j) {
          if (!subObj[folderName] && folderName != '.') {
            subObj[folderName] = j < pathParts.length - 1 ? {} : null;
          }
          subObj = subObj[folderName];
        }
      }
      return tree_;
    }

    this.init = function(e) {
      // Reset
      html_ = [];
      tree_ = {};
      pathList_ = [];
      self.fileList = e.target.files;

      // TODO: optimize this so we're not going through the file list twice
      // (here and in buildFromPathList).
      var output = [];
      for (var i = 0, file; file = self.fileList[i]; ++i) {
        pathList_.push(file.webkitRelativePath);
        output.push(file.webkitRelativePath);
      }

      document.querySelector('#directory-list').value = output.join('\n');

      self.render(self.buildFromPathList(pathList_));

      self.$el.html(html_.join('')).tree({
        expanded: 'li:first'
      });

      // Add full file path to each DOM element.
      var fileNodes = self.$el.get(0).querySelectorAll("[data-type='file']");
      for (var i = 0, fileNode; fileNode = fileNodes[i]; ++i) {
        fileNode.dataset['index'] = i;
      }
    }
  };

  var tree = new Tree('#dir-tree');

  var fileInput = document.querySelector('input[webkitdirectory]');

  document.querySelector('#directory-upload').addEventListener('click', function(e) {
    fileInput.click();
  }, false);


  $(fileInput).change(function(e) {
    tree.init(e);
  });
{% endblock %}
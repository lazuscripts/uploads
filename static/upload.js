function upload() {
  var label = document.getElementById('file-label');
  var file = document.getElementById('file').files[0];

  label.innerHTML = 'File (uploading...)';

  var formData = new FormData();
  formData.append('file_name', file.name);
  formData.append('file_size', file.size);

  var xhr = new XMLHttpRequest();
  xhr.open('POST', '/upload/prepare', true);
  xhr.onload = function() {
    if (xhr.status == 200) {
      var uri = JSON.parse(xhr.responseText).uri;
      var r = new Resumable({
        target: uri,
        chunkSize: 8*1024 // 8 kilobytes ?
      });
      r.assignBrowse(document.getElementById('browseButton'));
      r.assignDrop(document.getElementById('dropTarget')); // use a span
      r.on('fileAdded', function(file){
          // ...
        });
      r.on('fileSuccess', function(file,message){
          // ...
        });
      r.on('fileError', function(file, message){
          // ...
        });
      // var data = new FormData();
      // data.append('file', file, file.name);
      // var upload = new XMLHttpRequest();
      // upload.open('POST', uri, true);
      // upload.onload = function() {
      //   // TEMPORARY (should update label and notify user)
      //   console.log(upload.responseText);
      // }
      // upload.send(data);
    } else {
      // TODO do something about the error (btw status should be 500 but idgaf)
    }
  }
  xhr.send(formData);
}

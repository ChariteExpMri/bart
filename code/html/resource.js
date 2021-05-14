//
// jQuery Plugin
//
;(function($) {
    $.fn.toJSON = function() {
        var $elements = {};
        var $form = $(this);
        $form.find('input, select, textarea').each(function(){
          var name = $(this).attr('name')
          var type = $(this).attr('type')
          if(name){
            var $value;
            if(type == 'radio'){
              $value = $('input[name='+name+']:checked', $form).val()
            } else if(type == 'checkbox'){
              $value = $(this).is(':checked')
            } else {
              $value = $(this).val()
            }
            $elements[$(this).attr('name')] = $value
          }
        });
        return JSON.stringify( $elements )
    };
    $.fn.fromJSON = function(json_string) {
        var $form = $(this)
        var data = JSON.parse(json_string)
        $.each(data, function(key, value) {
          var $elem = $('[name="'+key+'"]', $form)
          var type = $elem.first().attr('type')
          if(type == 'radio'){
            $('[name="'+key+'"][value="'+value+'"]').prop('checked', true)
          } else if(type == 'checkbox' && (value == true || value == 'true')){
            $('[name="'+key+'"]').prop('checked', true)
          } else {
            $elem.val(value)
          }
        })
    };
}( jQuery ));

//
// DEMO CODE
// 
$(document).ready(function(){
   $("#_save").on('click', function(){
     console.log("Saving form data...")
     var data = $("form#myForm").toJSON()
     console.log(data);
     localStorage['form_data'] = data;
     
     return false;
   })
   
   $("#_load").on('click', function(){
     if(localStorage['form_data']){
       console.log("Loading form data...")
       console.log(JSON.parse(localStorage['form_data']))
       $("form#myForm").fromJSON(localStorage['form_data'])
     } else {
       console.log("Error: Save some data first")
     }
     
     return false;
   })
});



    function saveTXTfile() {
    	
       console.log("Saving form data...")
     var data = $("form#myForm").toJSON()
     console.log(data);
     localStorage['form_data'] = data;
        
        // This variable stores all the data.
        data=JSON.stringify(localStorage)
        
        // Convert the text to BLOB.
        const textToBLOB = new Blob([data], { type: 'text/plain' });
        const sFileName = 'formData.txt';	   // The file to save the data.

        let newLink = document.createElement("a");
        newLink.download = sFileName;

        if (window.webkitURL != null) {
            newLink.href = window.webkitURL.createObjectURL(textToBLOB);
        }
        else {
            newLink.href = window.URL.createObjectURL(textToBLOB);
            newLink.style.display = "none";
            document.body.appendChild(newLink);
        }

        newLink.click(); 
    }







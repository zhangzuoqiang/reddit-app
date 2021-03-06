<html>
<head>

<title>Schedule to Reddit</title>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css"/>
<link rel="stylesheet" th:href="@{/resources/datetime-picker.css}" />
<link rel="stylesheet" th:href="@{/resources/autocomplete.css}"/>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.11.2/jquery-ui.min.js"></script>
<script th:src="@{/resources/datetime-picker.js}"></script>
<script th:src="@{/resources/validator.js}"></script>
<style type="text/css">
.btn.disabled{
background-color: #ddd;
border-color: #ddd;
}

.btn.disabled:hover{
background-color: #ddd;
border-color: #ddd;
}
</style>
</head>
<body>
<div th:include="header"/>

<div class="container">
<h1>Edit Scheduled Post</h1>
<form th:action="@{/api/scheduledPosts/{id}(id=${post.getId()})}" method="post" role="form" data-toggle="validator">
<div class="row">
<input type="hidden" name="id" th:value="${post.getId()}"/>
<input type="hidden" name="submissionResponse" th:value="${post.getSubmissionResponse()}"/>
<input type="hidden" name="redditID" th:value="${post.getRedditID()}"/>
<input type="hidden" name="Sent" th:value="${post.isSent()}"/>

<div class="form-group">
    <label class="col-sm-3">Title</label>
    <span class="col-sm-9"><input name="title" placeholder="title" class="form-control" th:value="${post.getTitle()}" required="required" data-minlength="3"/></span>
</div>
<br/><br/>
<div class="form-group">
    <label class="col-sm-3">Url</label>
    <span class="col-sm-9"><input name="url" type="url" placeholder="url" class="form-control" th:value="${post.getUrl()}" required="required" data-minlength="3"/></span>
</div>
<br/><br/>  
<div class="form-group">
    <label class="col-sm-3">Subreddit</label>
    <span class="col-sm-9"><input id="sr" name="subreddit" placeholder="Subreddit" class="form-control" th:value="${post.getSubreddit()}" required="required" data-minlength="3"/></span>
</div>
<br/><br/>
<div>
<label  class="col-sm-3">Send replies to my inbox</label>  
<span class="col-sm-9"> 
<input th:if="${post.isSendReplies()}" type="checkbox" name="sendReplies" value="true" checked="checked"/>
<input th:if="${!post.isSendReplies()}" type="checkbox" name="sendReplies"/>
</span> 
</div>
<br/><br/>
<div>
<span class="col-sm-2"><a href="#" class="btn btn-default" onclick="checkIfAlreadySubmitted()">Check if already submitted</a></span>
<span class="col-sm-1"></span>
<span class="col-sm-9"><span id="checkResult" class="alert alert-info" style="display:none"></span></span>
</div>
<br/><br/>
<hr/>
<br/>
<div class="form-group">
    <label class="col-sm-3">Resubmit If:</label>
    
    <span class="col-sm-2">Votes didn't exceed </span>
    <span class="col-sm-1">
    <input type="number" class="form-control input-sm" th:value="${post.getMinScoreRequired()}" name="minScoreRequired" required="required"/>
    </span>
    
    <span class="col-sm-3">within &nbsp;&nbsp;
    <select name="timeInterval">
        <option value="0" th:selected="${post.getTimeInterval() == 0}">None</option>
        <option value="45" th:selected="${post.getTimeInterval() == 45}">45 minutes</option>
        <option value="60" th:selected="${post.getTimeInterval() == 60}">1 hour</option>
        <option value="120" th:selected="${post.getTimeInterval() == 120}">2 hours</option>
      </select>
    </span>
    
    <span class="col-sm-3">try resubmitting &nbsp;&nbsp;
    <select name="noOfAttempts">
        <option value="0" th:selected="${post.getNoOfAttempts() == 0}">No</option>
        <option value="1" th:selected="${post.getNoOfAttempts() == 1}">1</option>
        <option value="2" th:selected="${post.getNoOfAttempts() == 2}">2</option>
        <option value="3" th:selected="${post.getNoOfAttempts() == 3}">3</option>
        <option value="4" th:selected="${post.getNoOfAttempts() == 4}">4</option>
        <option value="5" th:selected="${post.getNoOfAttempts() == 5}">5</option>
      </select>
      &nbsp;&nbsp; times.
    </span>
    
    
</div>
<br/><br/>
<label class="col-sm-3">Submission Date (<span th:text="${#dates.format(#calendars.createToday(), 'z')}">UTC</span>)</label>
<span class="col-sm-9"><input name="submissionDate" class="form-control" th:value="${dateValue}" readonly="readonly"/></span>
    <script type="text/javascript">
        $(function(){
            $('*[name=submissionDate]').appendDtpicker({"inline": true});
        });
    </script>

    <br/><br/>
    
    <button id="submitBut" type="submit" class="btn btn-primary">Save Changes</button>
   </div>
</form>
</div>
</body>
<script>
  $(function() {
    $( "#sr" ).autocomplete({
      source: "../api/subredditAutoComplete"
    });
    
    $("input[name='url'],input[name='sr']").focus(function (){
        $("#checkResult").hide();
    });
    
  });
</script>
<script>
/*<![CDATA[*/
function checkIfAlreadySubmitted(){
    var url = $("input[name='url']").val();
    var sr = $("input[name='sr']").val();
    console.log(url);
    if(url.length >3 && sr.length > 3){
        $.post("../api/checkIfAlreadySubmitted",{url: url, sr: sr}, function(data){
            var result = JSON.parse(data);
            if(result.length == 0){
                $("#checkResult").show().html("Not submitted before");
            }else{
                $("#checkResult").show().html('Already submitted <b><a target="_blank" href="http://www.reddit.com'+result[0].data.permalink+'">here</a></b>');
            }
        });
    }
    else{
        $("#checkResult").show().html("Too short url and/or subreddit");
    }
}           
/*]]>*/          
</script>

<script>
/*<![CDATA[*/
$("#submitBut").click(function(event) {
    event.preventDefault();
    editPost();
});

function editPost(){
    var data = {};
	$('form').serializeArray().map(function(x){data[x.name] = x.value;});
    console.log(JSON.stringify(data));
	$.ajax({
        url: $('form').attr('action'),
        data: JSON.stringify(data),
        type: 'PUT',
        contentType:'application/json'
        	
    }).done(function() {
    	window.location.href="../scheduledPosts";
    })
    .fail(function(error) {
    	alert(error.responseText);
    }); 
}
/*]]>*/  
</script>
</html>
$(document).ready(function(){
    $(function(){
        $("#eightballDateTimePicker").dxDateBox({
            type: 'datetime',
            onValueChanged: function(data) {
                var start_date = data.value.getFullYear()+'-'+(data.value.getMonth()+1)+'-'+data.value.getDate();
                var timestamp = Math.floor(data.value.getTime()/1000);
                var link = '/magic_ball/api?full=1&start_date='+start_date+'&timestamp='+timestamp;
                $.ajax({
                    url: link,
                    success: function(data){
                        $('#eightballOutput').html(JSON.stringify(data,null,4));
                    }
                });
            }
        });
        $("#eightballSelectionDTP").dxCalendar({
            firstDayOfWeek: 0,
            zoomLevel: 'month',
            onValueChanged: function(data) {
                var link = '/magic_ball/' + data.value.getFullYear() + '-'+(data.value.getMonth()+1) + '-' + data.value.getDate();
                window.open(link,'_blank')
            }
        });
    });


  $('.ball-img img').on('click',function(){
    if($('.ball-img h3').hasClass('zoomIn')) {
      $('.ball-img h3').removeClass('zoomIn');
      $(this).effect( "shake", {times:4}, 1000);
      $.ajax({
        url: '/magic_ball/api',
        success: function(data){
          $('#magicBallField').html(data['data']);
          $('.ball-img h3').addClass('zoomIn');
        }
      });
    } else {
      $('.ball-text').fadeOut();
      $(this).effect( "shake", {times:4}, 1000);
      $.ajax({
        url: '/magic_ball/api',
        success: function(data){
          $('#magicBallField').html(data['data']);
          $('.ball-img h3').addClass('zoomIn');
        }
      });
    }
  });
});

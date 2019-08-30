var load_daily_tracks = function(state_id){
    var group = $('#daily_tracks');
    $.ajax({
        url: '/daily_tips/tracks',
        data: {state_id:state_id},
        success: function(data){
            group.html(data);
            $('.btn-daily-track').first().click();
        }
    });
};

var load_daily_races = function(track_id){
    var group = $('#daily_data');
    $.ajax({
        url: '/daily_tips/races',
        data: {track_id:track_id},
        success: function(data){
            group.html(data);
        }
    });
};

var process_dutch = function(){
    $('.dutch-result-td').html('');
    var total = parseFloat($('#dutchTotal').val()) || 0;
    if (!total) return;
    var odds_total_reversed = 0;
    var inputs = $('.dutch-odd-input');
    inputs.each(function(){
        var val = parseFloat($(this).val()) || 0;
        if (val){
            odds_total_reversed += 1/val;
        }
    });
    if (!odds_total_reversed) return;
    var reward = 0;
    inputs.each(function(){
        var elem = $(this);
        var val = parseFloat(elem.val()) || 0;
        if (val){
            var result = Math.round(total / val / odds_total_reversed);
            elem.closest('td').next('td').html('$'+result);
            reward = result * val;
        }
    });
    var warning_label = $('#dutchWarning');
    var return_elem = $('#dutchReturn');
    var profit_elem = $('#dutchProfit');
    if (reward>0 && reward < total) {
        warning_label.show();
        return_elem.val('');
        profit_elem.val('');
    } else {
        warning_label.hide();
        profit_elem.val((reward-total).toFixed(2));
        return_elem.val(reward.toFixed(2));
    }
};

$(document).ready(function(){
    $(document).on('click','.btn-daily-state',function(){
        $('.btn-daily-state').removeClass('active');
        var elem = $(this);
        elem.addClass('active');
        load_daily_tracks(elem.data('id'));
    });
    $('.btn-daily-state').first().click();
    $(document).on('click','.btn-daily-track',function(){
        $('.btn-daily-track').removeClass('active');
        var elem = $(this);
        elem.addClass('active');
        load_daily_races(elem.data('id'));
    });
    $(document).on('click','.daily-tip-row',function(){
        var daily_row = $(this);
        var store = $('#betList');
        var id = daily_row.data('id');
        if (store.data('runners-keys').indexOf(id)<0){
            store.data('runners-keys').push(id);
            var details = {};
            var tr = $('<tr>');
            ['race','runner','rank','win','place'].forEach(function(field){
                details[field] = daily_row.data(field);
                tr.append($('<td>'+daily_row.data(field)+'</td>'));
            });
            store.data('runners').push(details);
            store.find('tbody').append(tr);
        }
        daily_row.addClass('daily-tip-row-selected');
        $('#printBetBlock').show();
    });
    $(document).on('click','.daily-tip-button',function(){
        $(this).closest('tr').click();
    });
    var dutch_interval;
    $(document).on('focus','.dutch-odd-input, #dutchTotal',function(){
        dutch_interval = setInterval(
            process_dutch, 200
       );
    });
    $(document).on('blur','.dutch-odd-input, #dutchTotal',function(){
        clearInterval(dutch_interval);
    });
    $('#daily_toggle_raw').click(function(){
       var elem = $(this);
        elem.toggleClass('active');
        if (elem.hasClass('active')){
            $('.daily-interactive-elem').hide();
            $('.daily-raw-elem').show();
        } else
        {
            $('.daily-interactive-elem').show();
            $('.daily-raw-elem').hide();
        }
    });
    $('.daily_toggle_dutch').click(function(){
        var elem = $('#daily_toggle_dutch');
        elem.toggleClass('active');
        if (elem.hasClass('active')) $('#dutchBlock').show();
        else $('#dutchBlock').hide();
    });

    $('#daily_print_raw').click(function(){
        window.print();
    });
    $('#dutchClear').click(function(){
        $('.dutch-odd-input, #dutchTotal, #dutchReturn').val('');
        process_dutch();
    });

    $('.daily_toggle_tips').click(function(){
        var elem = $('#daily_toggle_tips');
        elem.toggleClass('active');
        if (elem.hasClass('active')) $('#dailyTipsBlock').show();
        else $('#dailyTipsBlock').hide();
    });

    var datepicker = $('#dailyTipsDatepicker');
    datepicker.datepicker({'autoclose':true,'daysOfWeekHighlighted':[0,6],format:'dd-mm-yyyy',todayHighlight:true,weekStart:1}).
        on('changeDate',function(){
            var selected_date = datepicker.datepicker('getDate');
            if (selected_date){
                var result = format_date(selected_date);
                datepicker.addClass('dateSelected');
                $.ajax({
                    url: '/daily_tips/tips',
                    data: {date:result},
                    success: function(data){
                        $('#dailyTipsData').html(data);
                    }
                });
            }
        });
    $('.horse_race_object').click(function(){
        var user_id = $('body').data('user-id');
        $.ajax({
            url: 'user/'+user_id+'/horse_race_object_click',
            type: 'post',
            data: {special: $(this).hasClass('horse_race_object_special') ? 1 : 0},
            success: function(data){
            }
        });
    });
});

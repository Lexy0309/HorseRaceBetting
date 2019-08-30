var process_bet_controls = function(){
    var link = '/bets_report/api?';
    link += 'type='+$('#betControlType').val();
    var categories = [];
    $('.betControlCategory').each(function(){
        var elem = $(this);
        if (elem.prop('checked')){
            categories.push(elem.data('title'));
        }
    });
    link += '&categories='+categories.join(',');
    return link
};

var dollarize = function(value){
    var _value = String(value);
    if (_value.startsWith('-')){
        return '-$'+_value.slice(1,_value.length);
    } else {
        return '$'+_value;
    }
};

var process_bet_graph = function(){
    var link = process_bet_controls();
    var daily_graph = $('#betGraph');
    $.ajax({
        url: link,
        success: function(result){
            daily_graph.dxChart({
                dataSource: result['data'],
                commonSeriesSettings: {
                    argumentField: "title"},
                series: result['fields'].map(function(field){return {valueField: field['special'], name: field['title']}}),
                tooltip: {
                    enabled: true,
                    customizeTooltip: function (arg) {
                        return {
                            text: 'Payback: '+arg.valueText+'%'
                        };
                    }
                },
                valueAxis: [{
                    constantLines: [{
                        value: 100,
                        color: "#fc3535",
                        dashStyle: "dash",
                        width: 2,
                        label: { visible: false }
                    }]
                }]
            })
        }
    });
};

var process_by_week_controls = function(){
    var calendar = $("#calendar-container");
    var start_date = calendar.dxCalendar('option','value');
    var weeekdays = [];
    $('.byWeekDayControl').each(function(){
        var elem = $(this);
        if (elem.prop('checked')){
            weeekdays.push(elem.data('id'));
        }
    });
    var categories = [];
    $('.byWeekControlCategory').each(function(){
        var elem = $(this);
        if (elem.prop('checked')){
            categories.push(elem.data('id'));
        }
    });
    var link = '/bets_report/by_week_special?start_date='+start_date+'&weekdays='+weeekdays.join(',')+'&categories='+categories.join(',');
    return link;
};

var process_by_week_page = function(){
    var link = process_by_week_controls();
    var week_graph = $('#weekGraph');
    $.ajax({
        url: link,
        success: function(result){
            week_graph.dxChart({
                dataSource: result['graph_data'],
                commonSeriesSettings: {
                    argumentField: "title"},
                series: [{valueField: 'amount', name: 'Amount'},{valueField: 'reward', name: 'Reward'}],
                tooltip: {
                    enabled: true,
                    customizeTooltip: function (arg) {
                        return {
                            text: dollarize(arg.valueText)
                        };
                    }
                }
            });
            var table = $('#weekContentTable');
            table.find('tbody').html('');
            var amount_sum = 0;
            var profit_sum = 0;
            var date, week, amount, reward, profit;
            result['data'].forEach(function(row){
                var tr = $('<tr></tr>');
                [date,week,amount,reward,profit] = row;
                amount_sum += parseFloat(amount);
                profit_sum += parseFloat(profit);
                tr.append($('<td>'+date.slice(0,10)+'</td>'));
                tr.append($('<td>'+week+'</td>'));
                tr.append($('<td>'+dollarize(amount)+'</td>'));
                tr.append($('<td>'+dollarize(reward)+'</td>'));
                tr.append($('<td class="'+(profit>0 ? 'correct_guessed_horse' : 'incorrect_guessed_horse')+'">'+dollarize(+profit)+'</td>'));
                tr.append($('<td>'+dollarize(amount_sum.toFixed(2))+'</td>'));
                tr.append($('<td class="'+(profit_sum>0 ? 'correct_guessed_horse' : 'incorrect_guessed_horse')+'">'+dollarize(profit_sum.toFixed(2))+'</td>'));
                table.find('tbody').append(tr);
            });
        }
    });
};


$(document).ready(function() {
    var body = $('body');
    var controller_name = body.data('controller');
    var action_name = body.data('action');
    if (controller_name=='bets_report' && action_name=='index'){
        var elem = $("#calendar-container");
        var calendar = elem.dxCalendar({
            firstDayOfWeek: 0,
            zoomLevel: 'month',
            onValueChanged: function(data) {
                var link = '/bets_report/' + data.value.getFullYear() + '-'+(data.value.getMonth()+1) + '-' + data.value.getDate();
                window.open(link,'_blank')
            }
        }).dxCalendar("instance");
        calendar.option("min", elem.data('min'));
        calendar.option("max", elem.data('max'));
        calendar.option("firstDayOfWeek", 1);
    }
    if (controller_name=='bets_report' && action_name=='graph'){
        $('#betControlType, .betControlCategory').change(function(){
            process_bet_graph();
        });
        process_bet_graph();
    }
    if (controller_name=='bets_report' && action_name=='by_week') {
        var elem = $("#calendar-container");
        var calendar = elem.dxCalendar({
            firstDayOfWeek: 0,
            zoomLevel: 'month',
            onValueChanged: function(data) {
                process_by_week_page();
            }
        }).dxCalendar("instance");
        calendar.option("min", elem.data('min'));
        calendar.option("max", elem.data('max'));
        calendar.option("value", '2017-01-01');
        calendar.option("firstDayOfWeek", 1);
        $('.byWeekDayControl, .byWeekControlCategory').change(function(){
            process_by_week_page();
        });
    }
});
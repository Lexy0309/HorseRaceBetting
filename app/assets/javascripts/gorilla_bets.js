var process_gorilla_controls = function(){
    var weeekdays = [];
    $('.byWeekDayControl').each(function(){
        var elem = $(this);
        if (elem.prop('checked')){
            weeekdays.push(elem.data('id'));
        }
    });
    var link = '/gorilla_bets/by_week_special?weekdays='+weeekdays.join(',');
    return link;
};

var process_gorilla_page = function(){
    var link = process_gorilla_controls();
    var week_graph = $('#weekGraph');
    $.ajax({
        url: link,
        success: function(result){

            week_graph.dxChart({
                palette: ['red','green'],
                dataSource: result['graph_data'],
                commonSeriesSettings: {
                    argumentField: "title",type: "bar",
                    hoverMode: "allArgumentPoints",
                    selectionMode: "allArgumentPoints",},
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
    if (controller_name=='gorilla_bets' && action_name=='index') {
        $('.byWeekDayControl').change(function(){
            process_gorilla_page();
        });
        process_gorilla_page();
    }
});
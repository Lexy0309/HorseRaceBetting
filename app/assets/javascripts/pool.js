var process_pool_controls = function(){
    var link = '/pool/api?';
    link += 'type='+$('#poolControlType').val();
    link += '&year='+$('#poolControlYear').val();
    link += '&state='+$('#poolControlState').val();
    link += '&track='+$('#poolControlTrack').val();
    var bet_types = [];
    $('.poolControlBetType').each(function(){
        var elem = $(this);
        if (elem.prop('checked')){
            bet_types.push(elem.data('title'));
        }
    });
    link += '&bet_types='+bet_types.join(',');
    return link
};

var process_pool_graph = function(){
    var link = process_pool_controls();
    var daily_graph = $('#poolGraph');
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
                            text: 'Average value: $'+arg.valueText
                        };
                    }
                }
            })
        }
    });
};

$(document).ready(function() {
    var body = $('body');
    var controller_name = body.data('controller');
    if (controller_name=='pool'){
        var poolControlTrack =  $('#poolControlTrack');
        $('#poolControlState').change(function(){
            var elem = $(this);
            var selected_state_id = elem.val();
            poolControlTrack.children('option:not(:first)').remove();
            poolControlTrack.data('store').forEach(function(x){
                if (selected_state_id==0 || selected_state_id==x[2]){
                    poolControlTrack.append($("<option></option>").attr("value",x[1]).text(x[0]));
                }
            });
        });
        $('#poolControlState, #poolControlTrack, #poolControlType, #poolControlYear, .poolControlBetType').change(function(){
            process_pool_graph();
        });
        process_pool_graph();
    }
});
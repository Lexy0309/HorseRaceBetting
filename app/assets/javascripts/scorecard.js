var process_scorecard_controls = function(){
    var link = '/scorecard/api?';
    link += 'type='+$('#scorecardControlType').val();
    link += '&year='+$('#scorecardControlYear').val();
    link += '&state='+$('#scorecardControlState').val();
    link += '&track='+$('#scorecardControlTrack').val();
    var bet_types = [];
    $('.scorecardControlBetType').each(function(){
        var elem = $(this);
        if (elem.prop('checked')){
            bet_types.push(elem.data('title'));
        }
    });
    link += '&bet_types='+bet_types.join(',');
    return link
};

var process_scorecard_graph = function(){
    var link = process_scorecard_controls();
    var daily_graph = $('#scorecardGraph');
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
                            text: 'Average perc: '+arg.valueText+'%'
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
    if (controller_name=='scorecard'){
        var scorecardControlTrack =  $('#scorecardControlTrack');
        $('#scorecardControlState').change(function(){
            var elem = $(this);
            var selected_state_id = elem.val();
            scorecardControlTrack.children('option:not(:first)').remove();
            scorecardControlTrack.data('store').forEach(function(x){
                if (selected_state_id==0 || selected_state_id==x[2]){
                    scorecardControlTrack.append($("<option></option>").attr("value",x[1]).text(x[0]));
                }
            });
        });
        $('#scorecardControlState, #scorecardControlTrack, #scorecardControlType, #scorecardControlYear, .scorecardControlBetType').change(function(){
            process_scorecard_graph();
        });
        process_scorecard_graph();
    }
});
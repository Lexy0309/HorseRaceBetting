var process_graph = function() {
    $(".infoDoughnut").each(function () {
        var elem = $(this);
        elem.dxPieChart({
            type: "doughnut",
            palette: ['green', 'lightgray'],
            dataSource: [{region: "success", val: parseInt(elem.data('success'))}, {region: "empty", val: 100-parseInt(elem.data('success'))}],
            startAngle: 90,
            legend: {visible: false},
            series: [{
                argumentField: "region"
            }],
            tooltip: {
                enabled: true,
                customizeTooltip: function (arg) {
                    return {text: 'success: '+elem.data('success')};
                }
            }
        });
    });
};

var process_horse_history_graph = function(){
    $('.infoHistoryLine').each(function(){
        var elem = $(this);
        var history = [];
        var i = 0;
        history_raw = elem.data('history');
        history_raw.split('').forEach(function(x){
            if (x!='x'){
                i += 1;
                var value_raw = parseInt(x);
                if (value_raw==0) history.push({arg:i,val:0})
                else history.push({arg:i,val:10-value_raw})
            }
        });
        elem.dxChart({
            "dataSource": history,
            "series": {},
            'commonAxisSettings': {visible: false, label: {visible: false}},
            'commonSeriesSettings':{'point':{visible: false}},
            'legend': {visible: false}
        });
    });
};

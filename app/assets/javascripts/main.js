var format_date = function(selected_date){
    var year = selected_date.getYear()+1900;
    var month = selected_date.getMonth()+1;
    month = month>=10 ? month : '0'+month;
    var date = selected_date.getDate();
    date = date>=10 ? date : '0'+date;
    var result = year+'-'+month+'-'+date;
    return result;
};

function load_tracks_special(date,state_id){
    var tracks = $('#tracks');
    $.ajax({
        url: '/forecast/ajax',
        data: {key:'tracks_new',date:date,state_id:state_id},
        success: function(data){
            tracks.html('');
            data.forEach(function(track){
                var button = $('<button class="btn btn-outline-secondary track-elem">');
                button.data('id',track.id);
                button.data('date',date);
                button.html(track.title);
                tracks.append(button);
            });
            $('.track-elem')[0].click()
        },
        dataType: 'json'
    });
}

function load_states(date){
    var states = $('#states');
    $.ajax({
        url: '/forecast/ajax',
        data: {key: 'states', date: date},
        success: function (data) {
            states.html('');
            data.forEach(function(state){
                var button = $('<button class="btn btn-outline-secondary state-elem">');
                button.data('id',state.id);
                button.data('date',date);
                button.html(state.title);
                states.append(button);
            });
            var state_elem = $('.state-elem');
            if (state_elem.length) state_elem[0].click();
        }
    });
}

function load_races(date,track_id){
    var races = $('#races');
    $.ajax({
        url: '/forecast/ajax',
        data: {key:'races_new',date:date,track_id:track_id},
        success: function(data){
            races.html('');
            data.forEach(function(race){
                var button = $('<button class="btn btn-lg btn-outline-secondary race-elem">');
                button.data('id',race.id);
                button.html(race.title);
                if (race.results.length){
                    button.append($('<br>'));
                    button.addClass('btn-with-items');
                }
                race.results.forEach(function(obj){
                    var span = $('<span class="badge">'+obj.number+'</span>');
                    if (obj.win==1){
                        span.addClass('badge-success');
                    }
                    button.append(span);
                });
                races.append(button);
            });
            $('.race-elem')[0].click()
        },
        dataType: 'json'
    });
}

function load_race(race_id,order,expandedHorses){
    $.ajax({
        url: '/forecast/ajax',
        data: {key:'race',race_id:race_id,order:order},
        success: function(data){
            if (typeof order=='undefined'){
                var order_buttons = $('.ordering');
                order_buttons.removeClass('active');
                if (order_buttons.length){
                    $(order_buttons[0]).addClass('active');
                }
            }

            $('#listTopList').tab('show');
            var info = $('#raceInfo');
            info.find('td').remove();
            for (var i = 0;i < data['info'].length; i++){
                $(info.find('tr')[i]).append($('<td>'+data['info'][i][1]+'</td>'))
            }

            var summary = $('#raceSummary');
            summary.find('td').remove();
            for (var i = 0;i < data['summary'].length; i++){
                $(summary.find('tr')[i]).append($('<td>'+data['summary'][i]+'</td>'))
            }

            var top = $('#listTop');
            var ml_top = $('#mlTop');
            top.html('');
            ml_top.html('');
            $('#listTopList').toggleClass('disabled',($.isEmptyObject(data['positions'])));
            data['positions'].forEach(function(obj){
                var button = $('<button class="btn btn-sm btn-outline-secondary">'+obj['data']['runner']+'</button>');
                var span = $('<span class="badge">'+obj['data']['rank']+'</span>');
                span.addClass((obj['data']['rank']=='1st') ? 'badge-success' :'badge-secondary');
                button.data('details',obj['data']);
                button.data('id',obj['id']);
                top.append(button.prepend(span));
                var br = $('</br>');
                button.after(br);
            });

            var results = $('#listResults');
            $('#listResultsList').toggleClass('disabled',$.isEmptyObject(data['places']) && $.isEmptyObject(data['bets']));
            results.html('');
            data['places'].forEach(function(obj){
                var button = $('<button class="btn btn-sm btn-outline-secondary">'+obj['index']+'</button>');
                var span_index = $('<span style="margin-left: 5px;" class="badge">'+obj['number']+'</span>');
                span_index.addClass((obj['index']=='1st') ? 'badge-success' :'badge-secondary');
                var span_price = $('<span style="margin-left: 5px;">');
                if (obj['index']=='1st'){
                    span_price.append('$'+obj['win']+' ($'+obj['place']+')');
                } else {
                    span_price.append('$'+obj['place']);
                }
                results.append(button.append(span_index).append(span_price));
            });
            $('#listBetList').toggleClass('disabled',$.isEmptyObject(data['bets']));
            data['bets'].forEach(function(obj) {
                var button = $('<button class="btn btn-outline-secondary">'+obj[0]+'</button>');
                var span_items = $('<span class="badge badge-secondary">'+obj[1]['items']+'</span>');
                var span_price = $('<span style="margin-left: 5px;">$'+obj[1]['value']+'</span>');
                results.append(button.prepend(span_items).append(span_price));
            });

            $('#switcher').removeClass('switched');

            var horses = $('#horses');
            var score_fields = horses.data('scoreFields');
            horses.find('tbody').html('');
            data['horses'].forEach(function(horse){
                var tr1 = $('<tr>');
                var tr2 = $('<tr>');
                var tr3 = $('<tr>');
                var tr4 = $('<tr>');
                tr1.addClass('horseRow');
                tr3.addClass('horseRowDetails');
                tr4.addClass('horseRowDetails');
                tr1.data('id',horse.horse_id);
                tr1.data('details',horse.details);
                tr1.append($('<td class="horseNumber horseRowExpander borderedTopTd" rowspan="2">'+horse.horse_number+' </td>'));
                tr1.append($('<td class="horseNumber horseRowExpander borderedTopTd" rowspan="2">'+'<img src="'+horse.image+'" class="jockeyImg">'+' </td>'));


                tr1.append($('<td class="horseNumber borderedTopTd" colspan="6"><a target="_blank" href="/horse/'+horse.horse_id+'">' +horse.horse_title+' ('+horse.barrier+')</a></td>'));
                tr1.append($('<td colspan="3" class="borderedTopTd"><strong>H.</strong> '+horse.history+'</td>'));
                tr1.append($('<td class="borderedTopTd">'+horse.score_position+'</td>'));
                tr1.append($('<td class="borderedTopTd">'+horse.total+'%</td>'));
                if (horse.scratched==0){
                    tr1.append($('<td class="runnerPrice borderedTopTd" style="width:5%">'+horse.win+'</td>'));
                    tr1.append($('<td class="runnerPrice borderedTopTd" style="width:5%">'+horse.place+'</td>'));
                } else {
                    tr1.append($('<td colspan="2" class="borderedTopTd">SCRATCHED</td>'))
                }
                tr2.append($('<td colspan="2" class="statTd borderedLeftTd" style="width:12%"><strong>J.</strong> <a target="_blank" href="/jockey/'+horse.jockey_id+'">'+horse.jockey_title+'</a> <strong>W.</strong>'+horse.weight+'</td>'));
                tr2.append($('<td colspan="2" class="statTd borderedLeftTd" style="width:12%"><strong>T.</strong> <a target="_blank" href="/trainer/'+horse.trainer_id+'">'+horse.trainer_title+'</a></td>'));
                tr2.append($('<td class="statTd borderedLeftTd" style="width:6%">'+score_fields[1]+'</td>'));
                tr2.append($('<td class="statTd" style="width:6%">'+horse['score'+2+'info1']+'</td>'));

                tr2.append($('<td class="statTd borderedLeftTd" style="width:10%"></td>'));
                tr2.append($('<td class="statTd" style="width:10%"></td>'));
                tr2.append($('<td class="statTd borderedLeftTd" style="width:10%">Distance wins</td>'));
                tr2.append($('<td class="statTd" style="width:5%">'+horse.distance_wins+'</td>'));
                tr2.append($('<td style="width:10%" class="borderedLeftTd"></td>'));

                if (horse.scratched==0){
                    tr2.append($('<td style="width:5%" class="statTd borderedLeftTd">Difference</td>'));
                    var difference = (horse['open_price']==0 ? 0 : Math.round((horse['current_price']-horse['open_price'])/horse['open_price']*100));
                    var td = $('<td style="width:5%" class="statTd">'+difference+'%</td>');
                    td.addClass(difference > 0 ? 'upperDifference' : difference < 0 ? 'lowerDifference' : '');
                    tr2.append(td);
                } else {
                    tr2.append($('<td style="width:10%" colspan="2" class="borderedLeftTd"></td>'));
                }
                tr3.append($('<td rowspan="2" colspan="2"></td>'));
                tr3.append($('<td style="width:6%" class="statTd borderedLeftTd borderedTopTd">'+score_fields[0]+'</td>'));
                tr3.append($('<td style="width:6%" class="statTd borderedLeftTd borderedTopTd">'+score_fields[4]+'</td>'));
                tr3.append($('<td style="width:6%" class="statTd borderedLeftTd borderedTopTd">'+score_fields[5]+'</td>'));
                tr3.append($('<td style="width:6%" class="statTd borderedLeftTd borderedTopTd">'+score_fields[2]+'</td>'));
                tr3.append($('<td style="width:6%" class="statTd borderedLeftTd borderedTopTd">'+score_fields[3]+'</td>'));
                tr3.append($('<td style="width:6%" class="statTd borderedLeftTd borderedTopTd">Previous inrun</td>'));
                tr3.append($('<td colspan="2" rowspan="2" class="statTd borderedLeftTd borderedTopTd infoHistoryLine" data-history="'+horse.history+'"></td>'));
                tr3.append($('<td class="statTd borderedLeftTd borderedTopTd">'+score_fields[7]+'</td>'));
                tr3.append($('<td class="statTd borderedLeftTd borderedTopTd">'+score_fields[6]+'</td>'));
                tr3.append($('<td rowspan="2" class="borderedLeftTd"></td>'));
                if (horse.scratched==0){
                    tr3.append($('<td class="statTd borderedLeftTd">Highest</td>'));
                    tr3.append($('<td class="statTd">'+horse['highest_price']+'</td>'));
                } else {
                    tr3.append($('<td colspan="2" rowspan="2" class="borderedLeftTd"></td>'));
                }
                tr4.append($('<td class="statTd borderedLeftTd"><div class="doughnutCenter">'+horse['score'+1+'info1']+'</div><div class="infoDoughnut" data-success="'+horse['score'+1+'info1']+'"></div></td>'));
                tr4.append($('<td class="statTd borderedLeftTd"><div class="doughnutCenter">'+horse['score'+5+'info1']+'</div><div class="infoDoughnut" data-success="'+horse['score'+5+'info1']+'"></div></td>'));
                tr4.append($('<td class="statTd borderedLeftTd"><div class="doughnutCenter">'+horse['score'+6+'info1']+'</div><div class="infoDoughnut" data-success="'+horse['score'+6+'info1']+'"></div></td>'));
                tr4.append($('<td class="statTd borderedLeftTd">'+horse['score'+3+'info1']+'</td>'));
                tr4.append($('<td class="statTd borderedLeftTd">'+horse['score'+4+'info1']+'</td>'));
                tr4.append($('<td class="statTd borderedLeftTd">'+horse.previous_inrun+'</td>'));
                tr4.append($('<td class="statTd borderedLeftTd">'+horse['score'+8+'info1']+'</td>'));
                tr4.append($('<td class="statTd borderedLeftTd">'+horse['score'+7+'info1']+'</td>'));
                if (horse.scratched==0){
                    tr4.append($('<td class="statTd borderedLeftTd">Lowest</td>'));
                    tr4.append($('<td class="statTd">'+horse['lowest_price']+'</td>'));
                }
                if (expandedHorses && expandedHorses.indexOf(horse.horse_id)>=0){
                    tr1.addClass('horseRowExpanded');
                    tr3.toggle();
                    tr4.toggle();
                }
                horses.find('tbody').append(tr1,tr2,tr3,tr4);
            });
            process_graph();
            process_horse_history_graph();
        }
    })
}

$(document).ready(function() {
    $('.perc-toggle').click(function(){
        $('.perc').toggle();
    });
    $('.weight-toggle').click(function(){
        $('.weight').toggle();
    });
    $('.outlier-toggle').click(function(){
        $('.outlier').toggle();
    });
    $(function () {
        $('[data-toggle="tooltip"]').tooltip()
    });
    $(document).on('click','.toggled',function(){
        var obj = $(this);
        obj.data('active',obj.data('active')%3+1);
        var index = obj.parent().find(obj.prop('nodeName')).index(obj);
        var table = obj.parent().parent().parent();
        var column_elements = table.find('tr').find('td:eq('+index+')').get();
        column_elements.forEach(function(raw){
           var elem = $(raw);
           elem.html(elem.data('toggle'+obj.data('active')));
        });
    });

    var datepicker = $('#selectDate');
    datepicker.datepicker({'autoclose':true,'daysOfWeekHighlighted':[0,6],format:'dd-mm-yyyy',todayHighlight:true,weekStart:1}).
        on('changeDate',function(){
            var selected_date = datepicker.datepicker('getDate');
            if (selected_date){
                var year = selected_date.getYear()+1900;
                var month = selected_date.getMonth()+1;
                month = month>=10 ? month : '0'+month;
                var date = selected_date.getDate();
                date = date>=10 ? date : '0'+date;
                var result = year+'-'+month+'-'+date;
                $('#today, #tomorrow').removeClass('active');
                datepicker.addClass('dateSelected');
                $('#summary').attr('href','/summary/'+result);
                load_states(result);
            }
        });


    var body = $('body');
    var controller_name = body.data('controller');
    var action_name = body.data('action');
    if (controller_name=='main' && action_name=='index'){
        var date_elems = $('#today, #tomorrow');
        date_elems.click(function(){
            var elem = $(this);
            if (elem.hasClass('active')) return;
            date_elems.removeClass('active');
            elem.addClass('active');
            datepicker.datepicker('clearDates');
            datepicker.removeClass('dateSelected');
            $('#summary').attr('href','/summary/'+elem.data('date'));
            load_states(elem.data('date'));
        });
        $(document).on('click','.state-elem',function(){
            var state = $(this);
            $('.state-elem').removeClass('active');
            state.addClass('active');
            load_tracks_special(state.data('date'),state.data('id'));
        });
        $(document).on('click','.track-elem',function(){
            var track = $(this);
            $('.track-elem').removeClass('active');
            track.addClass('active');
            load_races(track.data('date'),track.data('id'));
        });
        $(document).on('click','.race-elem',function(){
            var race = $(this);
            $('.race-elem').removeClass('active');
            race.addClass('active');
            load_race(race.data('id'));
        });

        $(document).on('click','.runnerPrice',function(){
            var runner_row = $(this).parent();
            var store = $('#betList');
            var id = runner_row.data('id');
            if (store.data('runners-keys').indexOf(id)<0){
                store.data('runners-keys').push(id);
                store.data('runners').push(runner_row.data('details'));
                var tr = $('<tr>');
                ['race','runner','rank','win','place'].forEach(function(field){
                    tr.append($('<td>'+runner_row.data('details')[field]+'</td>'));
                });
                store.find('tbody').append(tr);
            }
            runner_row.find('.runnerPrice').addClass('runnerPriceAdded');
            $('#printBetBlock').show();
        });
        $(document).on('click','.horseRowExpander',function(){
            var horse_row = $(this).parent();
            horse_row.toggleClass('horseRowExpanded');
            horse_row.next().next().toggle().next().toggle();
        });
        $('#switcher').click(function(){
            var button = $(this);
            var class_name = 'switched';
            var horseRowDetails = $('.horseRowDetails');
            var horseRows = $('.horseRow');
            if (button.hasClass(class_name)){
                horseRowDetails.hide();
                horseRows.removeClass('horseRowExpanded');
                button.removeClass(class_name);
            } else {
                horseRowDetails.show();
                horseRows.addClass('horseRowExpanded');
                button.addClass(class_name);
            }
        });
        var horses = $('#horses');
        var order_buttons = $('.ordering');
        order_buttons.click(function(){
            var button = $(this);
            if (!button.hasClass('active')){
                var order = button.data('order');
                var race_elem = $('.race-elem.active');
                if (race_elem.length){
                    order_buttons.removeClass('active');
                    button.addClass('active');
                    var race_id = $(race_elem[0]).data('id');
                    var expandedHorses = []
                    horses.find('tbody tr').each(function(){
                            var tr = $(this);
                        if (tr.hasClass('horseRowExpanded')){
                            expandedHorses.push(tr.data('id'));
                        }
                    });
                    load_race(race_id,order,expandedHorses);
                }
            }
        });


        load_states($(date_elems.get()[0]).data('date'));
        var data_source = [];
        var data_source_hash = {};
        var daily_graph = $('#dailyGraph');
        daily_graph.data('dashboard').split(';').map(function(r){return r.split(',')}).forEach(function(row){
            var elem = {};
            elem['title'] = row[0];
            elem['winrate'] = parseFloat(row[1]);
            elem['margin'] = parseFloat(row[2]);
            elem['probability'] = parseFloat(row[3]);
            data_source_hash[elem['title']] = {'winrate':parseFloat(row[4]),'margin':parseFloat(row[5]),'probability':parseFloat(row[3])}
            data_source.push(elem);
        });
        daily_graph.dxPieChart({
            palette: "ocean",
            dataSource: data_source,
            type: "doughnut",
            title: {
                text: "Top runners Winrate/Margin/Probability"
            },
            legend: {
                visible: true
            },
            innerRadius: 0.2,
            commonSeriesSettings: {
                label: {
                    visible: false
                }
            },
            tooltip: {
                enabled: true,
                customizeTooltip: function() {
                    return { text: this.argumentText + "<br>Average " + this.seriesName + ": " + data_source_hash[this.argumentText][this.seriesName]};
                }
            },
            series: [{
                name: "winrate",
                argumentField: "title",
                valueField: "winrate",
            }, {
                name: "margin",
                argumentField: "title",
                valueField: "margin"
            },{
                name: "probability",
                argumentField: "title",
                valueField: "probability"
            }]
        });

    }
    $('#printBetList').click(function(){
        var data = $('#betList').data('runners');
        if (!$.isEmptyObject(data)){
            printJS({printable: data, properties: ['race', 'runner', 'rank','win','place'], type: 'json'});
        }
    });
    $('#clearBetList').click(function(){
        $('#printBetBlock').hide();
        var bet_list = $('#betList');
        bet_list.data('runners',[]);
        bet_list.data('runners-keys',[]);
        bet_list.find('tbody').html('');
        $('.runnerPriceAdded').removeClass('runnerPriceAdded');
        $('.daily-tip-row-selected').removeClass('daily-tip-row-selected');
    });
    $('#toggleBetList').click(function(){
        $('#betList').toggle();
        $(this).toggleClass('active');
    });
    process_graph();
});
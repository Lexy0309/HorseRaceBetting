function get_date(){
    return  $("input[name='date']:checked").val()
}

function load_tracks(tracks,races,raceRow,horses,date,raceBlock,top_horses_elem,bet_block,place_block){
    tracks.find('option').remove();
    clear_races(races,raceRow);
    clear_race(raceBlock,horses,top_horses_elem,bet_block,place_block);
        $.ajax({
            url: '/forecast/ajax',
            data: {key:'tracks',date:date},
            success: function(data){
                tracks.append($('<option>',{}));
                data.forEach(function(track){
                    tracks.append($('<option>',track));
                })
            },
            dataType: 'json'
        });
}

function clear_races(races,raceRow){
    races.find('option').remove();
    raceRow.hide();
}

function highlight_column(table,column_index,reverse){
    var column_elements = table.find('tr').find('td:eq('+column_index+')');
    var values = column_elements.map(function(){return parseFloat($(this).html())}).get().filter(function(x){return !!x});
    var selected_value = reverse ? Math.min.apply(Math,values) : Math.max.apply(Math,values);
    column_elements.each(function(){
        var elem = $(this);
        var value = elem.html();
        elem.removeClass('bold');
        if (parseFloat(value)==selected_value){
            elem.addClass('bold');
        }
    });
}

function highlight_columns(){
    $('.header_highlighter').each(function(){
        var elem = $(this);
        var index = elem.parent().find(elem.prop('nodeName')).index(elem);
        var table = elem.parent().parent().parent();
        highlight_column(table,index,!!elem.data('reverse'));
    })
}

function clear_race(raceBlock,horses,top_horses_elem,bet_block,place_block){
    raceBlock.hide();
    raceBlock.find('tr').remove();
    horses.hide();
    horses.find('th').removeClass('active_score');
    horses.find('tbody tr').remove();
    top_horses_elem.find('tbody').html('');
    top_horses_elem.hide();
    bet_block.hide();
    bet_block.find('tbody').html('');
    place_block.hide();
    place_block.find('tbody').html('');
}

$(document).ready(function() {
    var body = $('body');
    var controller_name = body.data('controller');
    var action_name = body.data('action');
    if (controller_name=='forecast' && action_name=='index'){
        var tracks = $('#tracks');
        var races = $('#races');
        var horses = $('#horses');
        var raceRow = $('#raceRow');
        var raceBlock = $('#raceBlock');
        var top_horses_elem = $('#topHorses');
        var bet_block = $('#betBlock');
        var place_block = $('#placeBlock');
        raceRow.hide();
        horses.hide();
        raceBlock.hide();
        top_horses_elem.hide();
        bet_block.hide();
        place_block.hide();
        var date = get_date();
        load_tracks(tracks,races,raceRow,horses,date,raceBlock,top_horses_elem,bet_block,place_block);
        $("input[name='date']").change(function(){
            date = get_date();
            load_tracks(tracks,races,raceRow,horses,date,raceBlock,top_horses_elem,bet_block,place_block)
        });

        tracks.on('change',function(){
            clear_races(races,raceRow);
            clear_race(raceBlock,horses,top_horses_elem,bet_block,place_block);
            if (this.value){
                raceRow.show();
                $.ajax({
                    url: '/forecast/ajax',
                    data: {key:'races',date:date,track_id:this.value},
                    success: function(data){
                        races.append($('<option>',{}));
                        data.forEach(function(race){
                            races.append($('<option>',race));
                        })
                    },
                    dataType: 'json'
                });
            };
        });

        races.on('change',function(){
            clear_race(raceBlock,horses,top_horses_elem,bet_block,place_block);
            if (this.value){
                $.ajax({
                    url: '/forecast/ajax',
                    data: {key:'race',race_id:this.value},
                    success: function(data){
                        data['horses'].forEach(function(horse){
                            var tr = $('<tr>');
                            tr.append($('<td>'+horse.horse_number+'</td>'));
                            tr.append($('<td>'+horse.horse_title+'</td>'));
                            tr.append($('<td>'+horse.sex+'</td>'));
                            tr.append($('<td>'+horse.weight+'</td>'));
                            tr.append($('<td>'+horse.barrier+'</td>'));
                            tr.append($('<td>'+horse.jockey_title+'</td>'));
                            tr.append($('<td>'+horse.trainer_title+'</td>'));
                            tr.append($('<td>'+horse.age+'</td>'));
                            tr.append($('<td>'+horse.history+'</td>'));
                            for (var i = 1; i <= 10 ; i++){
                                var td = $('<td>'+horse['score'+i]+'</td>');
                                td.data('toggle1',horse['score'+i]);
                                td.data('toggle2',horse['score'+i+'info1']);
                                td.data('toggle3',horse['score'+i+'info2']);
                                tr.append(td);
                            }
                            tr.append($('<td>'+horse.total+'</td>'));
                            if (horse.scratched==1){
                                tr.append($('<td colspan=3>SCR</td>'))
                            }
                            else {
                                tr.append($('<td>'+horse.score_position+'</td>'));
                                tr.append($('<td>'+horse.win+'</td>'));
                                tr.append($('<td>'+horse.place+'</td>'));
                            }
                            horses.append(tr);
                        });
                        data['block'].forEach(function(race_row){
                            var tr = $('<tr>');
                            var th = $('<th>'+race_row[0]+'</th>');
                            var td = $('<td>'+race_row[1]+'</td>');
                            tr.append(th);
                            tr.append(td);
                            raceBlock.append(tr);
                        });
                        highlight_columns();
                        data['score_fields'].forEach(function(id){
                            horses.find('.score'+id).addClass('active_score');
                        });
                        horses.show();
                        raceBlock.show();
                        if ($.isEmptyObject(data['positions'])){
                            top_horses_elem.hide();
                        } else {
                            data['positions'].forEach(function(obj){
                                var tr = $('<tr>');
                                var td1 = $('<td>'+obj[0]+'</td>');
                                var td2 = $('<td>'+obj[1]+'</td>');
                                tr.append(td1,td2)
                                top_horses_elem.find('tbody').append(tr);
                            });
                            top_horses_elem.show();
                        }
                        if ($.isEmptyObject(data['bets'])){
                            bet_block.hide();
                        } else {
                            data['bets'].forEach(function(obj){
                                var tr = $('<tr>');
                                var td1 = $('<td>'+obj[0]+'</td>');
                                var td2 = $('<td>'+obj[1]['items']+'</td>');
                                var td3 = $('<td>$'+obj[1]['value']+'</td>');
                                tr.append(td1);
                                tr.append(td2);
                                tr.append(td3);
                                bet_block.find('tbody').append(tr);
                            });
                            bet_block.show();
                        }
                        if ($.isEmptyObject(data['places'])){
                            place_block.hide();
                        } else {
                            data['places'].forEach(function(obj){
                                var tr1 = $('<tr>');
                                var td1 = $('<td>'+obj['index']+'</td>');
                                var td2 = $('<td>'+obj['number']+'</td>');
                                var td3 = $('<td>$'+(obj['index']=='1st' ? obj['win']+'<br>$'+obj['place'] : obj['place'])+'</td>');
                                tr1.append(td1);
                                tr1.append(td2);
                                tr1.append(td3);
                                place_block.find('tbody').append(tr1);
                            });
                            place_block.show();
                        }
                    },
                    dataType: 'json'
                });
            };
        });
    }
});
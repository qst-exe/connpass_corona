-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

require 'config.display'
pcall( function() require 'config.env' end )

local widget = require 'widget'
local json = require 'json'

local header = display.newGroup()

display.newRect( header, CENTER_X, 0, _W, 50 ):setFillColor( 255/255, 57/255, 50/255 )

display.newText{
    parent = header,
    text = '勉強会一覧',
    x = CENTER_X,
    y = 0,
    font = native.systemFontBold,
    fontSize = 22,
}

local function onRowRender( event )
    local row = event.row
    local data = row.params.data

    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth

    local rowTitle = display.newText{
        parent = row,
        text = data.title,
        x = 0,
        y = rowHeight * 0.5-5,
        width = _W-100,
        height = 0,
        font = native.systemFontBold,
        fontSize = 14,
    }
    rowTitle:setFillColor( 0 )
    rowTitle.anchorX = 0
    rowTitle.x = 20

    local local_time = string.match( data.started_at, "%d+-%d+-%d+T%d+:%d+" )
    local_time = local_time:gsub( '-', '/' )
    local_time = local_time:gsub( 'T', ' ' )

    local local_time_text = display.newText{
        parent = row,
        text = local_time,
        x = 0,
        y = rowHeight-12,
        font = nil,
        fontSize = 12,
    }
    local_time_text:setFillColor( 0.3 )
    local_time_text.anchorX = 0
    local_time_text.x = 20

    display.newText{
        parent = row,
        text = '参加状況',
        x = _W-30,
        y = rowHeight * 0.5-8,
        font = nil,
        fontSize = 10,
    }:setFillColor( 0.3 )

    local limit_num = data['limit'] or '--'
    display.newText{
        parent = row,
        text = string.format( '%s/%s', data['accepted'], limit_num ),
        x = _W-30,
        y = rowHeight * 0.5+8,
        font = nil,
        fontSize = 10,
    }:setFillColor( 0.3 )

    row:addEventListener( 'tap', function()
        system.openURL( data['event_url'] )
        return true
    end )
end

local tableView = widget.newTableView(
    {
        left = 0,
        top = 25,
        height = _H,
        width = _W,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch,
        listener = scrollListener
    }
)

local function networkListener( event )

    if ( event.isError ) then
        print( "Network error: ", event.response )
        native.showAlert( '通信エラー', '通信環境を確認してリトライしてください。', { 'OK' } )
    else
        print ( "RESPONSE: " .. event.response )

        local data = json.decode( event.response )
        local event_data = data['events']
        for _, data in pairs( event_data ) do
            tableView:insertRow{
                rowHeight = 60,
                params = { data = data }
            }
        end
    end
end

assert( API_URL, 'API_URL が設定されていません。' )

network.request( API_URL, "GET", networkListener )

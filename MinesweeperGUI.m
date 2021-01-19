function MinesweeperGUI

Init
InitializeMineField

end

%Prepare the game for the very first time:
function Init
global h
global uicolor;
global numRows
global numCols
global numMines
global xOffset
global yOffset
global started
global diff
started = false;
uicolor = [0.34118 0.34118 0.34118];
h.figs = figure('name', 'Minesweeper', 'color', uicolor, 'position', [700, 400,...
    600, 400],'CloseRequestFcn',@CloseWindow);
h.checks(1) = uicontrol('Style', 'checkbox', 'position', [500, 350, 100,20], 'string',...
    'Easy', 'value', 1, 'callback', {@Checkbox});
h.checks(2) = uicontrol('Style', 'checkbox', 'position', [500, 330, 100,20], 'string',...
    'Intermediate', 'callback', {@Checkbox});
h.checks(3) = uicontrol('Style', 'checkbox', 'position', [500, 310, 100,20], 'string',...
    'Hard', 'callback', {@Checkbox});
h.timeText = uicontrol('Style', 'text', 'position', [500, 250,40,20], 'string', ...
    'Time: ', 'background', uicolor, 'fontweight', 'bold', 'Foreground', [.75 .75 .8],...
    'horizontalAlignment', 'right');
h.countText = uicontrol('Style', 'text', 'position', [500, 220,40,20], 'string', ...
    'Mines: ', 'background', uicolor, 'fontweight', 'bold', 'Foreground', [.75 .75 .8],...
    'horizontalAlignment', 'right');
h.time = uicontrol('Style', 'text', 'position', [550, 250,30,20], 'string', ...
    '-', 'background', [1 1 1], 'fontweight', 'bold', 'Foreground', [0 0 .75]);
h.count = uicontrol('Style', 'text', 'position', [550, 220,30,20], 'string', ...
    ' ', 'background', [1 1 1], 'fontweight', 'bold', 'Foreground', [.1 .1 .1]);
h.highScoreLabel = uicontrol('Style', 'text', 'position', [460, 190,80,20], 'string', ...
    'High Score: ', 'background', uicolor, 'fontweight', 'bold', 'Foreground', [.75 .75 .8],...
    'horizontalAlignment', 'right');
h.highScore = uicontrol('Style', 'text', 'position', [550, 190,30,20], 'string', ...
    '-', 'background', [1 1 1], 'fontweight', 'bold', 'Foreground', [.1 .1 .1]);
h.otherButtons(1) = uicontrol('Style', 'pushbutton', 'position', ...
    [500, 150, 95, 25],'string', 'New Game', 'callback', {@Restart,0},...
    'foreground', [.75 .1 1]);
h.otherButtons(2) = uicontrol('Style', 'pushbutton', 'position', ...
    [500, 120, 95, 25],'string', 'Restart This Game', 'callback', {@Restart,1},...
    'foreground', [.1 .6 .6]);
diff = 1;
numRows = 8;
numCols = 8;
numMines = 10;
xOffset = 100;
yOffset = 150;

h.timerObject = timer('TimerFcn',@SecondCount,'ExecutionMode','fixedRate',...
    'Period',1.0);

end

function InitializeMineField
global field
global numRows
global numCols
global h;
global squareSize;
global xOffset
global yOffset
global gameover;
global totalGood
global numMines
global goodInds
global backgroundColor
global time
global mineCount
global diff;
set(h.highScore, 'String', CheckHighScore(diff));
backgroundColor = [.78 .78 .78];
mineCount = numMines;
set(h.count, 'String', num2str(mineCount));
time = -1;
goodInds = [];
h.figs = [];
h.spots = [];
h.text = [];
h.blankSpots = [];
gameover = 0;
squareSize = 15;
totalGood = (numRows * numCols) - numMines;

%Create graphics field:
for i = 1:numRows * numCols
    h.spots(i) = uicontrol('Style', 'pushbutton', 'position', ...
        [(mod(i - 1,numCols) * squareSize) + xOffset, floor((i -1)/numCols) ...
        * (squareSize+5) + yOffset,squareSize,squareSize+5],'callback', {@ClickSpot, i},...
        'ButtonDownFcn', {@FlagSpot}, 'foreground', [1 0 0], 'background', backgroundColor);
    
end
%Create field of mines:
field = rand([numRows * numCols, 1]);

end

function CleanField(rows,cols)
global h;
global uicolor;
for i = 1 :rows * cols
    if ishandle(h.spots(i))
        delete(h.spots(i));
        
    end
    
end

for i = 1: length(h.blankSpots)
    if ishandle(h.blankSpots(i)) && h.blankSpots(i) ~= 0
        set(h.blankSpots(i), 'string', '', 'background', uicolor);
    end
end

if ishandle(h.text)
    delete(h.text);
end

try
    stop(h.timerObject);
end
set(h.time,'string', '-');

end

%Checkbox callback:
function Checkbox(my_h, event)
global h
global numRows
global numCols
global numMines
global xOffset
global yOffset
global diff
global started
easy_h = h.checks(1); %Get all the check boxes
intermediate_h = h.checks(2);
hard_h = h.checks(3);
eStr = get(easy_h,'string'); %Get string of each check box
iStr = get(intermediate_h,'string');
hStr = get(hard_h,'string');
str = get(my_h,'string');
oldR = numRows;
oldC = numCols;
switch str
    case eStr
        diff = 1;
        set(intermediate_h, 'value', 0);
        set(hard_h, 'value', 0);
        xOffset = 100;
        yOffset = 150;
        numRows = 8;
        numCols = 8;
        numMines = 10;
    case iStr
        diff = 2;
        set(easy_h, 'value', 0);
        set(hard_h, 'value', 0);
        xOffset = 40;
        yOffset = 50;
        numRows = 16;
        numCols = 16;
        numMines = 40;
    case hStr
        diff = 4;
        set(intermediate_h, 'value', 0);
        set(easy_h, 'value', 0);
        xOffset = 20;
        yOffset = 50;
        numRows = 16;
        numCols = 30;
        numMines = 99;
end
if get(my_h, 'value') == 1 %If this one is not already selected
    started = false;
    CleanField(oldR, oldC);
    InitializeMineField;
end
set(my_h, 'value', 1);
end

%Call back for clicking a spot in the mine field:
function ClickSpot(my_h, event, ind)
global started
global field
global numMines
global mineIndices
global gameover
global goodInds
global totalGood
global h
%Click only valid on non-flagged spot, and if game isn't over:
if (isempty(get(my_h,'string')) || get(my_h,'string') == ' ') && ~gameover
    %Initialize the field if it's the first time:
    if ~started
        field(ind) = 1; %First hit cannot lose
        [sorted, indices] = sort(field);
        mineIndices = indices(1:numMines);
        started = true;
        start(h.timerObject);
    end
    
    %Check for mine:
    if ~CheckSpot(ind)
        SurroundCount(ind); %Check Surrounding spots
        if ishandle(my_h)
            delete(my_h); %Delete this button if it hasn't been
        end
    else
        Lose;
    end
    
    if length(goodInds) == totalGood
        Win;
    end
end

end

%Callback for right click:
function FlagSpot(my_h, event)
global gameover
global mineCount
global h;
if strcmp(get(gcf, 'SelectionType'),'alt') && ~gameover
    if isempty(get(my_h,'string')) || get(my_h, 'string') == ' '
        set(my_h, 'string', 'F');
        mineCount = mineCount - 1;
    else
        set(my_h, 'string', ' ');
        mineCount = mineCount + 1;
    end
    set(h.count, 'String', num2str(mineCount));
end
end

%Callback for Restart
function Restart(my_h, event, choice)
global numRows
global numCols
global started
switch choice
    case 0
        started = false;
        CleanField(numRows,numCols);
        InitializeMineField;
    case 1
        CleanField(numRows,numCols);
        InitializeMineField;
end
end

%Check if an index has a mine:
function out = CheckSpot(ind)
global mineIndices;
%Check if valid input:
if ~isempty(ind)
    %Find mine:
    if any(mineIndices == ind)
        out = 1;
    else
        out = 0;
    end
else
    out = 0;
end

end

%Check surrounding spots for mines, then recursively check those spots in
%order to clear the board.
function SurroundCount (ind)
global h;
global goodInds

if ~isempty(ind) && ishandle(h.spots(ind));
    [row, col] = ind2rc(ind);
    bottomLeft = GetSurroundInd(row - 1, col - 1);
    middleLeft = GetSurroundInd(row, col - 1);
    topLeft = GetSurroundInd(row + 1, col - 1);
    bottomMiddle = GetSurroundInd(row - 1, col);
    topMiddle = GetSurroundInd(row + 1, col);
    bottomRight = GetSurroundInd(row - 1, col + 1);
    middleRight = GetSurroundInd(row, col + 1);
    topRight = GetSurroundInd(row + 1, col + 1);
    count = 0;
    count = count + CheckSpot(bottomLeft);
    count = count + CheckSpot(middleLeft);
    count = count + CheckSpot(topLeft);
    count = count + CheckSpot(bottomMiddle);
    count = count + CheckSpot(topMiddle);
    count = count + CheckSpot(bottomRight);
    count = count + CheckSpot(middleRight);
    count = count + CheckSpot(topRight);
    if count == 0 %No mines around, clear the spot and check do same for surrounding spots.
        delete(h.spots(ind));
        if ~any(goodInds == ind)
            goodInds = [goodInds ind];
        end
        DrawNewSpot(ind,'', [0 0 0]);
        SurroundCount(bottomLeft);
        SurroundCount(middleLeft);
        SurroundCount(topLeft);
        SurroundCount(bottomMiddle);
        SurroundCount(topMiddle);
        SurroundCount(bottomRight);
        SurroundCount(middleRight);
        SurroundCount(topRight);
    else
        if ~any(goodInds == ind)
            goodInds = [goodInds ind];
        end
        DrawNewSpot(ind,num2str(count), GetColor(count));
    end
end
end

%Convert from an index to row,col format
function [row, col] = ind2rc(ind)
global numCols;
row = floor((ind-1) / numCols) + 1;
col = mod(ind-1,numCols) + 1;
end

%Convert from a row,col pair to index format
function ind = rc2ind(row,col)
global numCols

ind = (row - 1) * numCols + col;
end

%Get index for a spot on grid. If it is out of bounds, return empty.
function out = GetSurroundInd(row,col)
global numRows;
global numCols;

if row < 1 || col < 1 || row > numRows || col > numCols
    out = [];
else
    out = rc2ind(row,col);
end
end

%Draw a new spot in place of a button:
function DrawNewSpot(ind, str, color)
global numCols
global squareSize
global xOffset
global yOffset
global h
global backgroundColor
h.blankSpots(ind) = uicontrol('style', 'text', 'position', ...
    [(mod(ind - 1,numCols) * squareSize) + xOffset, floor((ind -1)/numCols) ...
    * (squareSize+5) + yOffset,squareSize,squareSize+5], 'string', str, 'foreground'...
    , color, 'fontweight', 'bold', 'background', backgroundColor);
end

%Find color code for numbers that may be printed:
function out = GetColor(num)
switch num
    case 1
        out = [0 0 .9];
    case 2
        out = [0 .5 0];
    case 3
        out = [.9 0 0];
    case 4
        out = [.3 0 .5];
    case 5
        out = [.5 .02 0];
    case 6
        out = [0 .6 .6];
    case 7
        out = [0 0 0];
    case 8
        out = [.5 .5 .5];
end
end

function Win
global uicolor
global h;
global gameover
global diff

try
    stop(h.timerObject);
end
h.text = uicontrol('Style', 'text', 'position', [100, 20, 100, 30], 'string'...
    , 'You Win!', 'foreground', [0 1 0], 'background', uicolor);
gameover = 1;
Save(diff);
set(h.highScore, 'String', CheckHighScore(diff));
end

function Lose
global mineIndices;
global gameover;
global h;
global uicolor
try
    stop(h.timerObject);
end

set(h.otherButtons, 'enable', 'off');
set(h.checks, 'enable', 'off');

for i = 1:length(mineIndices)
    DrawNewSpot(mineIndices(i),'*', [0 0 0]);
    drawnow;
end

set(h.otherButtons, 'enable', 'on');
set(h.checks, 'enable', 'on');

gameover = 1;
h.text = uicontrol('Style', 'text', 'position', [100, 20, 100, 30], 'string'...
    , 'You Lose', 'foreground', [1 0 0], 'background', uicolor);
end

function SecondCount(~,~)
global h;
global time
time = time + 1;
set(h.time, 'string', num2str(time));
end

function Save(diff)
global time
file = fopen('matsweeperscore.min', 'r');
if file == -1
    file = fopen('matsweeperscore.min', 'w');
    for i = 1:3
        if mod(diff,i) == 0
            fprintf(file, [num2str(time) '\n']);
        else
            fprintf(file,' \n');
        end
    end
    fclose(file);
else
    for i = 1:3
        hs{i} = fgetl(file);
    end
    fclose(file);
    file = fopen('matsweeperscore.min', 'w');
    if all(hs{diff} ~= ' ') && all(hs{diff} ~= -1)
        if time < str2num(hs{diff})
            hs{diff} = num2str(time);
        end
    else
        hs{diff} = num2str(time);
    end
    fprintf(file,[hs{1}, '\n' hs{2}, '\n' hs{3}]);
    fclose(file);
end
end

function highScore = CheckHighScore(line)
file = fopen('matsweeperscore.min', 'r');
if file == -1
    highScore = '-';
else
    for i = 1:line
        highScore = fgetl(file);
    end
    if highScore == -1
        highScore = '-';
    elseif highScore == ' '
        highScore = '-';
    end
    fclose(file);
end

end

function CloseWindow(my_h, event)
global h;
try
    stop(h.timerObject);
end
delete(h.timerObject);
delete(gcf)
end
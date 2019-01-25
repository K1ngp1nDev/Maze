local open = io.open


function CreatePoint(x, y)
    local Point = {}
    Point.__index = Point

    local mt = {
        __call = function (Point)
            setmetatable({}, Point)
            return Point
        end,
        __tostring = function(Point)
            return "("..tostring(Point._x)..", "..tostring(Point._y)..")"
        end,
        __eq = function(Point, other)
            return Point._x == other._x and Point._y == other._y
        end
    }

    setmetatable(Point, mt)

    Point._x, Point._y = x, y
    function Point:neighbors()
        return {CreatePoint(Point._x+1, Point._y), CreatePoint(Point._x, Point._y+1), CreatePoint(Point._x-1, Point._y), CreatePoint(Point._x, Point._y-1)}
    end
    return Point
end

function CreatePath()
    local Path = {}
    Path.__index = Path

    local mt = {
        __call = function (Point)
            setmetatable({}, Point)
            return Point
        end,
        __tostring = function(Point)
            local str = ""
            for key,val in pairs(Point._points) do
                str = str..tostring(val).."->"
            end
            return str
        end,
        __add = function(Path, p)
            if type(Path._points) == 'nil' then
                Path._points = {p}
            else
                Path._points[#Path._points + 1] = p
            end
            return Path
        end
    }

    setmetatable(Path, mt)

    function Path:length()
        return #Path._points
    end

    function Path:last()
        return Path._points[#Path._points]
    end

    return Path
end

function heuristic(p1, p2)
  return math.abs(p1._x - p2._x) + math.abs(p1._y - p2._y)
end

function weight(path, p)
    return path:length() + heuristic(path:last(), p)
end

local function isWall(table, point)
    return point._x < 1 or point._y < 1 or point._x > #table or point._y > #table[point._x] or table[point._x][point._y]
end

local function filterWalls(tbl, points)
    local result = {}
    for key, val in pairs(points) do
        if not isWall(tbl, val) then
            result[#result + 1] = val
        end
    end
    return result
end

local function contains(tbl, p)
    for k, v in pairs(tbl) do
        if v == p then
            return true
        end
    end
    return false
end

function print_table(tbl, p)
    local str = p and "["..tostring(p).."]" or ""
    for k,v in pairs(tbl) do
        str = str.." "..tostring(v)
    end
    print(str)
end

function a_star_search(start, goal, map)
    local queue = dofile("priority_queue.lua")
    local path = CreatePath()
    path = path + start

    print("start", start)
    print("goal ", goal)

    queue:put(path, weight(path, goal))

    local counter = 0

    while not queue:empty() do
        local best_path = queue:pop()
        local neighbors = filterWalls(map, best_path:last():neighbors())
        local filtered_neighbors = {}
        counter = counter + 1
        for k,v in pairs(neighbors) do
            if not contains(best_path._points, v) then
                filtered_neighbors[#filtered_neighbors+1] = v
            end
        end

        for k,v in pairs(filtered_neighbors) do
            local new_path = CreatePath()
            for k,v1 in pairs(best_path._points) do
                new_path = new_path + CreatePoint(v1._x, v1._y)
            end
            new_path = new_path + CreatePoint(v._x, v._y)
            if v == goal then
                print(string.format("ways:        %d", counter))
                print(string.format("best length: %d", new_path:length().."\n"))
                return new_path
            end
            queue:put(new_path, weight(new_path, goal))
        end
    end

    local result = CreatePath()
    result = result + CreatePoint(-1, -1)
    return result
end

local function read_file(path)
    local file = open(path, "r")
      if not file then 
      return nil 
    end
    local content = file:read "*a"
    local _start, _end
    local matrix = {}
    local lst = {}

    for i = 1,content:len() do
        local char = string.sub(content, i, i)
        if char == 'I' then
            _start = CreatePoint(#matrix+1, #lst+1)
        elseif char == 'E' then
            _end = CreatePoint(#matrix+1, #lst+1)
        end
        if char == '\n' then
            matrix[#matrix + 1] = lst
            lst = {}
        else
            local is_filled = char == '0'
            lst[#lst + 1] = is_filled
        end
    end
    matrix[#matrix + 1] = lst

    print(content)
    
    file:close()
    return matrix, _start, _end
end

local function write_file(path, content)
    local file = open(path, "w")
    if not file then 
      return nil 
    end
    io.output(path)
    io.write(content)
    
    file:close()
    return content
end

local matrix, _start, _end = read_file("Maze.txt")

local result_path = a_star_search(_start, _end, matrix)

for k,v in pairs(result_path._points) do
    matrix[v._x][v._y] = 'x'
end

matrix[_start._x][_start._y] = 'I'
matrix[_end._x][_end._y] = 'E'

for i = 1, #matrix do
    for j = 1, #matrix[i] do
        if matrix[i][j] == 'x' then
            io.write('.')
        elseif matrix[i][j] == 'I' then
            io.write('I')
         elseif matrix[i][j] == 'E' then
            io.write('E')
        else
            io.write(isWall(matrix, CreatePoint(i, j)) and '0' or ' ')
        end
    end
    io.write('\n')
end

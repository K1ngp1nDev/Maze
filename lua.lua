local open = io.open


function CreatePoint(x, y)
    local Point = {}
    Point.__index = Point

    local mt = {
        __call = function (self)
            setmetatable({}, self)
            return self
        end,
        __tostring = function(self)
            return "("..tostring(self._x)..", "..tostring(self._y)..")"
        end,
        __eq = function(self, other)
            return self._x == other._x and self._y == other._y
        end
    }

    setmetatable(Point, mt)

    Point._x, Point._y = x, y
    function Point:neighbors()
        return {CreatePoint(self._x+1, self._y), CreatePoint(self._x, self._y+1), CreatePoint(self._x-1, self._y), CreatePoint(self._x, self._y-1)}
    end
    return Point
end

function CreatePath()
    local Path = {}
    Path.__index = Path

    local mt = {
        __call = function (self)
            setmetatable({}, self)
            return self
        end,
        __tostring = function(self)
            local str = ""
            for key,val in pairs(self._points) do
                str = str..tostring(val).."->"
            end
            return str
        end,
        __add = function(self, p)
            if type(self._points) == 'nil' then
                self._points = {p}
            else
                self._points[#self._points + 1] = p
            end
            return self
        end
    }

    setmetatable(Path, mt)

    function Path:length()
        return #self._points
    end

    function Path:last()
        return self._points[#self._points]
    end

    return Path
end



-- bh = PriorityQueue()

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

    print("start ", start)
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
        -- print_table(filtered_neighbors, best_path:last())

        for k,v in pairs(filtered_neighbors) do
            local new_path = CreatePath()
            for k,v1 in pairs(best_path._points) do
                new_path = new_path + CreatePoint(v1._x, v1._y)
            end
            new_path = new_path + CreatePoint(v._x, v._y)
            if v == goal then
                print("count: ", counter)
                print("length: ", new_path:length())
                return new_path
            end
            queue:put(new_path, weight(new_path, goal))
        end
    end

    local xyi = CreatePath()
    xyi = xyi + CreatePoint(-1, -1)
    return xyi
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
        char = string.sub(content, i, i)
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

    for i = 1, #matrix do
        for j = 1, #matrix[i] do
            io.write(isWall(matrix, CreatePoint(i, j)) and '0' or ' ')
        end
        io.write('\n')
    end

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

for i = 1, #matrix do
    for j = 1, #matrix[i] do
        if matrix[i][j] == 'x' then
            io.write('`')
        else
            io.write(isWall(matrix, CreatePoint(i, j)) and '#' or ' ')
        end
    end
    io.write('\n')
end
-- print(result_path)

-- write_file("A-star.txt", fileContent)
-- local start = 'I'
-- local finish = 'E'
-- print(fileContent);
-- matrix = {{}}
-- matrix.insert

-- a_star_search(graph, start, finish) --
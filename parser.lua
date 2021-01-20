HEADER, OPCODE, VALUE = 'HEADER', 'OPCODE', 'VALUE'
REGION, GROUP, CONTROL, GLOBAL, CURVE, EFFECT, MASTER, MIDI, SAMPLE =
'<region>', '<group>', '<control>', '<global>', '<curve>', '<effect>', '<master>', '<midi>', '<sample>'
pos = 1

function parser(tokens)
    local result = {
        control = {},
        regions = {}
    }
    local global_header = {}
    local group = {}
    local region = {}
    local header = nil
    local key = nil

    for _,token in pairs(tokens) do
        local token_type = token[1]
        local token_value = token[2]

        if token_type == HEADER then
            header = token_value

            for _,v in pairs(region) do
                if v then table.insert(result['regions'], region) end
                break
            end

            if header == GROUP then
                group = {}

            elseif header == REGION then
                region = {}
                for k,v in pairs(global_header) do region[k] = v end
                for k,v in pairs(group) do region[k] = v end
            end

        elseif token_type == OPCODE then
            key = token_value

        elseif token_type == VALUE then
            if header == CONTROL then result['control'][key] = token_value
            elseif header == GLOBAL then global_header[key] = token_value
            elseif header == GROUP then group[key] = token_value
            elseif header == REGION then
                if key == 'sample' then
                    local prefix = result['control']['default_path'] or ''
                    region[key] = prefix..token_value
                else
                    region[key] = token_value
                end
            else
                local header_name = string.sub(header, 2, -2)
                result[header_name] = result[header_name] or {}
                result[header_name][key] = token_value
            end

            key = nil
        end
    end

    for _,v in pairs(region) do
        if v then table.insert(result['regions'], region) end
        break
    end

    return result
end

function is_value(text, pos)
    local char = string.sub(text, pos, pos)

    return char >= '0' and char <= '9'
        or char >= 'A' and char <= 'Z'
        or char >= 'a' and char <= 'z'
        or char == '.'
        or char == ':'
        or char == '\\'
        or char == '/'
        or char == '-'
        or char == '_'
        or char == '#'
        or char == '$'
        or char == ' '
        and not is_end_of_value(text, pos + 1)
end

function is_end_of_value(text, pos)
    while is_opcode(string.sub(text, pos, pos)) do
        pos = pos + 1
        if is_equal(string.sub(text, pos, pos)) then return true end
    end

    if is_comment(text, pos) then return true end

    return false
end

function is_header(char)
    return char == '<'
        or char == '>'
        or char >= 'a' and char <= 'z'
end

function is_end_of_header(char)
    return char == '>'
end

function is_opcode(char)
    return char >= '0' and char <= '9'
        or char >= 'a' and char <= 'z'
        or char == '_'
end

function is_space(char)
    return char == ' '
        or char == '\t'
end

function is_equal(char)
    return char == '='
end

function is_comment(text, pos)
    return string.sub(text, pos, pos + 1) == '//'
end

function is_newline(char)
    return char == '\n'
        or char == '\r'
end

function next_token(text)
    if is_space(string.sub(text, pos, pos)) then
        while is_space(string.sub(text, pos, pos)) do
            pos = pos + 1

        end
    end

    if is_newline(string.sub(text, pos, pos)) then
        while is_newline(string.sub(text, pos, pos)) do
            pos = pos + 1
        end
    end

    if is_comment(text, pos) then
        while not is_newline(string.sub(text, pos, pos)) do
            pos = pos + 1
        end
    end

    if is_equal(string.sub(text, pos, pos)) then
        local token_type = VALUE
        local token_value = ''
        pos = pos + 1

        while is_value(text, pos) do
            token_value = token_value..string.sub(text, pos, pos)
            pos = pos + 1
        end

        return {token_type, token_value}

    elseif is_opcode(string.sub(text, pos, pos)) then
        local token_type = OPCODE
        local token_value = ''

        while is_opcode(string.sub(text, pos, pos)) do
            token_value = token_value..string.sub(text, pos, pos)
            pos = pos + 1
        end

        return {token_type, token_value}

    elseif is_header(string.sub(text, pos, pos)) then
        local token_type = HEADER
        local token_value = ''

        while is_header(string.sub(text, pos, pos)) and not is_end_of_header(string.sub(text, pos - 1, pos - 1)) do
            token_value = token_value..string.sub(text, pos, pos)
            pos = pos + 1
        end

        return {token_type, token_value}
    end
end

function lexer(text)
    local tokens = {}

    while pos < #text do
        local token = next_token(text)
        if token then table.insert(tokens, token) end
    end

    pos = 1

    return tokens
end

function read_file(filename)
    local text = ''
    for line in io.lines(filename) do
        text = text..line..'\n'
    end
    return text
end

function load(filename)
    local text = read_file(filename)
    local tokens = lexer(text)
    local result = parser(tokens)
    return result
end

if not ... then
    function dump(o)
        if o[1] then
            local s = '['
            for _,v in pairs(o) do
                s = s .. dump(v) .. ', '
            end
            return string.sub(s, 1, -3) .. ']'

        elseif type(o) == 'table' then
            local s = '{'
            for k,v in pairs(o) do
                s = s .. "'" .. k .."': " .. dump(v) .. ', '
            end
            return string.sub(s, 1, -3) .. '}'
        else
            return "'" .. tostring(o) .. "'"
        end
    end

    local result = load('sample.sfz')
    print(dump(result))
end

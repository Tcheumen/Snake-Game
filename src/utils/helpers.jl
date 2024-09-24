function serialize(obj)
    function format_value(value)
        if isa(value, String)
            return "\"$value\""
        elseif isa(value, Number)
            return string(value)
        elseif isa(value, Bool)
            return string(value)
        elseif value === nothing
            return "null"
        elseif isa(value, Vector)
            return "[" * join(map(format_value, value), ",") * "]"
        else
            return ""
        end
    end

    result = ""
    for (key, value) in obj
        result *= "#$key(" * format_value(value) * ")"
    end
    return result
end


function deserialize(input::String)
    function parse_value(value::String)
        if startswith(value, "\"") && endswith(value, "\"")
            return value[2:end-1]  # Remove quotes
        elseif tryparse(Int, value) !== nothing
            return parse(Int, value)
        elseif value == "true"
            return true
        elseif value == "false"
            return false
        elseif value == "null"
            return nothing
        elseif startswith(value, "[") && endswith(value, "]")
            elements = split(value[2:end-1], ",")
            return [parse_value(string(e)) for e in elements]
        else
            return value
        end
    end

    object = Dict{String, Any}()
    reading = false
    temp = ""
    key = ""
    value = ""
    i = 1
    while i <= length(input)
        if input[i] == '#'
            if reading
                object[key] = parse_value(value)
                key = ""
                value = ""
            end
            reading = true
        elseif reading
            if input[i] == '('
                key = temp
                temp = ""
            elseif input[i] == ')'
                value = temp
                temp = ""
            else
                temp *= input[i]
            end
        end
        i += 1
    end

    if key != "" && value != ""
        object[key] = parse_value(value)
    end

    return object
end




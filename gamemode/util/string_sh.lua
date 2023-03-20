local string = string
string.oldupper = string.oldupper or string.upper
string.oldlower = string.oldlower or string.lower

EngRusLetters = {
'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p',
'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l',
'z', 'x', 'c', 'v', 'b', 'n', 'm',
'й','ц','у','к','е','н','г','ш','щ','з','х','ъ',
'ф','ы','в','а','п','р','о','л','д','ж','э',
'я','ч','с','м','и','т','ь','б','ю',
}

local lowers = {['А']='а',['Б']='б',['В']='в',['Г']='г',['Д']='д',['Е']='е',['Ё']='ё',['Ж']='ж',['З']='з',['И']='и',['Й']='й',['К']='к',['Л']='л',['М']='м',['Н']='н',['О']='о',['П']='п',['Р']='р',['С']='с',['Т']='т',['У']='у',['Ф']='ф',['Х']='х',['Ц']='ц',['Ч']='ч',['Ш']='ш',['Щ']='щ',['Ъ']='ъ',['Ы']='ы',['Ь']='ь',['Э']='э',['Ю']='ю',['Я']='я'}
local uppers = {['а']='А',['б']='Б',['в']='В',['г']='Г',['д']='Д',['е']='Е',['ё']='Ё',['ж']='Ж',['з']='З',['и']='И',['й']='Й',['к']='К',['л']='Л',['м']='М',['н']='Н',['о']='О',['п']='П',['р']='Р',['с']='С',['т']='Т',['у']='У',['ф']='Ф',['х']='Х',['ц']='Ц',['ч']='Ч',['ш']='Ш',['щ']='Щ',['ъ']='Ъ',['ы']='Ы',['ь']='Ь',['э']='Э',['ю']='Ю',['я']='Я'}

function string.upper(str)
    local result = ''

    for char in string.gmatch(str, '[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*') do
        result = result .. (uppers[char] or string.oldupper(char))
    end

    return result
end

function string.lower(str)
    local result = ''

    for char in string.gmatch(str, '[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*') do
        result = result .. (lowers[char] or string.oldlower(char))
    end

    return result
end

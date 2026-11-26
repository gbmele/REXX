/* repl.rexx */

parse value "123456" with -1 str 3 
say str

parse value "the quick brown fox" with a b c .
say  a b c



/*

THE AWESOME PARSE TAB DELIMITED FIELD
tab = '09'x
line = "Greg" || tab || "ED" || tab || "Victoria" || tab || "123"

i = 0

do while line <> ""
    parse var line field (tab) line
    i = i + 1
    fld.i = field
end

fld.0 = i

say "Fields:" fld.0

do j = 1 to fld.0
    say j":" fld.j
end
*/

/*

tab = '09'x
file = 'data.tsv'

header = linein(file)

do while lines(file) > 0

    line = linein(file)

    field. = ''
    rest = line
    count = 0

    do while rest <> ''
        parse var rest value (tab) rest
        count = count + 1
        field.count = value
    end

    say field.colindex.Name,
        field.colindex.Department,
        field.colindex.Site

end

call stream file,'C','CLOSE'


*/


say countstr("the quick brown fox", 'h') "spaces in the string"



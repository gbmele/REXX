sp = " "
tab = '09'x
say "well done "
say "that seemed easy enough"

do i = 1 to 10 by 2
    say "x" sp i tab tab i*2
end


csvFile = 'assigned.csv'
lineNumber = 0
roster. = ''

dayone= '26/10/2026'

do while lines(csvFile) > 0
    csvLine = linein(csvFile)
    parse var csvLine line.1 (tab) line.2 (tab) line.3 (tab) line.4 (tab) line.5 (tab) line.6 (tab) line.7 (tab) line.8 (tab) line.9 (tab) line.10

    /*if strip(line.3) = 'Duty Date' then iterate*/
    /*another way of skipping header when you dont care what the actual header is */
    
    if lineNumber = 0 then do
        lineNumber = lineNumber + 1
        iterate
    end
    
    /*line 1 is first name last name 
      line 3 is date 
      line 5 is shift

    */
    
    person = translate(strip(line.2), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
    firstName = word(person, 1)
    lastName = space(subword(person, 2), 0)
    shortName = substr(firstName, 1, 1) || substr(lastName, 1, 6)    

    roster.shortName = line.5

    parse var line.5 before '(' line5_stuff ')' after
    line5_result = translateShift(line5_stuff)
    
    say shortname (tab) line.3 (tab) line5_result (tab) datediff(dayone, line.3)+1
    linenumber = lineNumber + 1

end

call stream csvFile, 'C', 'CLOSE'
say "lines " lineNumber




exit





translateShift: procedure
    parse arg shift
    shift = strip(shift)

    select
        when shift = 'CST 0800-1800' then return 'c'
        when shift = 'CST 1400-1800' then return 'c'
        when shift = 'CST 1400-1700' then return 'c'
        when shift = 'CST 1200-1500' then return 'c'
        when shift = 'CST 1200-1600' then return 'c'
        when shift = 'CST 1200-1800' then return 'c'
        when shift = 'CST 1600-1800' then return 'a'
        when shift = 'CST 1700-1800' then return 'a'
        when shift = 'CST 1000-1400' then return 'c'
        when shift = 'MH 1400-2400' then return 'p'
        when shift = 'MH 1000-2000' then return 'c'
        when shift = 'CST 1400-1600' then return 'p'
        when shift = 'MH 0800-1200' then return 'c'
        when shift = 'MH 1600-2400' then return 'p'
        when shift = 'MH 0800-1400' then return 'c'
        when shift = 'MH 0800-1800' then return 'a'
        when shift = 'MH 0800-1600' then return 'a'
        when shift = 'MH 0800-1600 IC' then return 'a'
        when shift = 'MH 0800-1800 IC' then return 'a'
        when shift = 'MH 0800-1600 SSU' then return 'a'
        when shift = 'MH 0800-1800 SSU' then return 'a'
        when shift = 'MH 0800-1700 SSU' then return 'a'
        when shift = 'MH 0800-1700 IC' then return 'a'
        when shift = 'MH 0800-1700' then return 'a'
        when shift = 'OnCall' then return 'p'
        when shift = '0000-0800 OC CAT2' then return 'p'
        when shift = 'U 0000-2359' then return 'o'
        when shift = 'AP stuff' then return 'apo'
        when shift = 'AA stuff' then return 'ao'
        when shift = 'PP stuff' then return 'po'
        when shift = 'UA stuff' then return 'po'
        when shift = 'UP stuff' then return 'ao'
        when shift = 'AP 0000-2359' then return 'o'
        when shift = 'AA 0800-1800' then return 'ao'
        otherwise return "NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN"
    end

fixdate: procedure
    parse arg inputDate
    inputDate = strip(inputDate)
    parse var inputDate day '/' month '/' year
    return year || right('0' || month, 2, '0') || right('0' || day, 2, '0')

dateDiff: procedure
    parse arg startDate, endDate
    startDays = date('B', fixdate(startDate), 'S')
    endDays = date('B', fixdate(endDate), 'S')
    return endDays - startDays


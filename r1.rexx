sp = " "
tab = '09'x
say "well done "
say "that seemed easy enough"

do i = 1 to 10 by 2
    say "x" sp i tab tab i*2
end

/*INIT*/
parse arg /*from commandline*/ dayone csvfile leavefile

/*csvFile = 'assigned.csv'  */
/*dayone= '26/10/2026'*/


lineNumber = 0
rostercount = 0
rosterkeys. = ''
roster. = ''

do while lines(csvFile) > 0
    csvLine = linein(csvFile)
    parse var csvLine line.1 (tab) line.2 (tab) line.3 (tab) line.4 (tab) line.5 (tab) line.6 (tab) line.7 (tab) line.8 (tab) line.9 (tab) line.10

    /*if strip(line.3) = 'Duty Date' then iterate*/
    /*another way of skipping header when you dont care what the actual header is */
    
    if lineNumber = 0 then do
        lineNumber = lineNumber + 1
        iterate
    end
    
    /*field 1 is first name last name 
      field 3 is date 
      field 5 is shift

    */
    
    person = translate(strip(line.2), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
    firstName = word(person, 1)
    lastName = space(subword(person, 2), 0)
    shortName_ = substr(firstName, 1, 1) || substr(lastName, 1, 6)    
    shortname=strip(shortname_)
    if roster.shortName = '' then do
        roster.shortName = shortname
        rosterCount = rosterCount + 1
        rosterKeys.rosterCount = strip(shortName)
    end
    
    
    parse var line.5 before '(' line5_stuff ')' after
    line5_result = translateShift(line5_stuff)
    
    dayIndex = datediff(dayone, line.3) + 1
    roster.shortName.dayIndex = line5_stuff
    
    if roster.shortName = shortName then do
        roster.shortname.dayindex=line5_result
    end


    say shortname (tab) line.3 (tab) line5_result (tab) datediff(dayone, line.3)+1
    linenumber = lineNumber + 1

end



call stream csvFile, 'C', 'CLOSE'
say "lines " lineNumber


do i = 1 to rosterCount
    doc = rosterKeys.i
    say doc '->' roster.doc
    do day = 1 to 70
            if roster.doc.day = '' then do
                    say "roster["||doc||","||day||"] = o;"
      end
      else do
                    sh= roster.doc.day 
                    say "roster["||doc||","||day||"] = "||sh||";"
      end
    end    
end



/*process leavefile*/
discard_header = linein(leavefile)
do while  lines(leavefile) > 0
    leaveLine = linein(leavefile)
    parse var leaveLine . (tab) . (tab) leave.1 (tab) . (tab) . (tab) . (tab) leave.2 (tab) leave.3 (tab) .
    name = leave.1
    name = translate(strip(name), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
    firstName = word(name, 1)
    lastName = space(subword(name, 2), 0)
    shortName = substr(firstName, 1, 1) || substr(lastName, 1, 6)
    shortName = strip(shortName)
    start_date = leave.2
    finish_date = leave.3

    leave_day1 = datediff(dayone, leave.2) + 1
    leave_day2 = datediff(dayone, leave.3) + 1
    
    say shortname " " leave_day1 " " leave_day2
    /**/  
    do dy = leave_day1 while dy <=leave_day2
        if dy >= 1 & dy <= 70 then do
            roster.shortname.dy = 'leave'
            say "roster["||shortname||","||dy||"] = leave;"
        end
    end






end

call stream leavefile, 'C', 'CLOSE'



exit



/*FUNCTIONS FUNCTIONS */

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
        when shift = 'UP 1900-2400' then return 'ao'
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


tab = '09'x
leaveFile = 'octjan_leave.txt'
dayOne = '26/10/2026'
firstNameColumn = 0
lastNameColumn = 0
startDateColumn = 0
endDateColumn = 0

if lines(leaveFile) = 0 then do
	say 'Unable to read' leaveFile
	exit 1
end

headerLine = linein(leaveFile)
remaining = headerLine
column = 0
do while remaining <>''
	column = column + 1
	parse var remaining field (tab) remaining
	fieldName = translate(strip(field))
	fieldName = translate(fieldName, '_', ' ')

	select
		when fieldName = 'FIRST_NAME' then firstNameColumn = column
		when fieldName = 'SURNAME' | fieldName = 'LAST_NAME' then lastNameColumn = column
		when fieldName = 'START' | fieldName = 'START_DATE' then startDateColumn = column
		when fieldName = 'FINISH' | fieldName = 'END_DATE' then endDateColumn = column
		otherwise nop
	end
end

if firstNameColumn = 0 | lastNameColumn = 0 | startDateColumn = 0 | endDateColumn = 0 then do
	say 'Required name and date headers were not found in' leaveFile
	exit 1
end

lastColumn = max(firstNameColumn, lastNameColumn, startDateColumn, endDateColumn)

do while lines(leaveFile) > 0
	remaining = linein(leaveFile)
	column = 0
	firstName = ''
	lastName = ''
	startDate = ''
	endDate = ''

	do column = 1 to lastColumn
		parse var remaining field (tab) remaining
		select
			when column = firstNameColumn then firstName = strip(field)
			when column = lastNameColumn then lastName = strip(field)
			when column = startDateColumn then startDate = strip(field)
			when column = endDateColumn then endDate = strip(field)
			otherwise nop
		end
	end

	shortName = translate(substr(firstName, 1, 1) || substr(lastName, 1, 6), , 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
	shortName = strip(shortName)
	firstDay = dateDiff(dayOne, startDate) + 1
	lastDay = dateDiff(dayOne, endDate) + 1

	do dayIndex = firstDay to lastDay
		if dayIndex >= 1 & dayIndex <= 70 then
			say shortName (tab) dayIndex (tab) 'leave'
	end
end

call stream leaveFile, 'C', 'CLOSE'
exit

fixDate: procedure
	parse arg inputDate
	inputDate = strip(inputDate)
	parse var inputDate day '/' month '/' year
	return year || right('0' || month, 2, '0') || right('0' || day, 2, '0')

dateDiff: procedure
	parse arg startDate, endDate
	startDays = date('B', fixDate(startDate), 'S')
	endDays = date('B', fixDate(endDate), 'S')
	return endDays - startDays

<!--- Receives information from the form and creates an Excel Spreadheet based on data stored in an SQL Server --->

<cfparam name="FORM.selectRegion" default="" >
<cfparam name="FORM.region_code" default="" >

<!--- Check to see if form parsed. If so created workbooks --->
<cfif FORM.selectRegion EQ "Generate" >

	<!--- Setup the filename and directories --->
	
    <cfset currentDirectory = GetDirectoryFromPath(GetTemplatePath()) & "\output\Electorates" >
	
    <!--- Check to see if the Directory exists and if not created one --->
    <cfif NOT DirectoryExists(currentDirectory) >
		<cfdirectory action="create" directory="#currentDirectory#" >
    </cfif>    
    
    <!--- Setup the Sheet Variables --->
    <cfset embargoMsg = "Embargoed Until " & FORM.embargo_date >
    
    <cfset hscSheets = arrayNew(1) >
    <cfset hscSheetTitle = arrayNew(1) >
    
    <cfset hscSheetTitle[1] = "Government School Students on all the All Rounders List by School, HSC " & FORM.hsc_year >
    <cfset hscSheetTitle[2] = "Government School Students on the Distinguaished Achievers List by School, HSC " & FORM.hsc_year >
    <cfset hscSheetTitle[3] = "First in Course List " & FORM.hsc_year & ", DET Students Only" >
    <cfset hscSheetTitle[4] = "Course Participants List by Course and School, HSC " & FORM.hsc_year >
    <cfset hscSheetTitle[5] = "Government School Students on the Top Achievers List by School, HSC " & FORM.hsc_year >
    
    <!--- Get electorates and loop through --->
    <cfset electorateList = session.cfcHSC.getElectorate(FORM.electorate_num) >
    
    <cfloop query="electorateList" >
    
    	<cfset thisGroup = replace(name," ","_","ALL") >
        <cfset thisGroup = replace(thisGroup,"/","_","ALL") >
        <cfset thisGroup = replace(thisGroup,"|\","_","ALL") >
        
        <!--- Setup the School Group File --->
        <cfset filePath = "\HSCMerit\output\Electorates\" & thisGroup & "_HSC.xls" >
        <cfset thisFileName = ExpandPath(filePath) >
        
        <!--- Create the workbook --->
        <cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init() />
        
        <!--- Create and name the worksheets in teh workbook --->
        <cfset hscSheets[1] = workBook.createSheet() />
        <cfset hscSheets[2] = workBook.createSheet() />
        <cfset hscSheets[3] = workBook.createSheet() />
        <cfset hscSheets[4] = workBook.createSheet() />
        <cfset hscSheets[5] = workBook.createSheet() />
        
        <cfset workBook.setSheetName(0,"All Rounders") />
        <cfset workBook.setSheetName(1,"Distinguished Achievers") />
        <cfset workBook.setSheetName(2,"First in Course") />
        <cfset workBook.setSheetName(3,"Participants") />
        <cfset workBook.setSheetName(4,"Top Achievers") />
        
        <!--- Create the bold style in the workbook --->
        <cfset cellHeaderStyle = workBook.createCellStyle() />
        <cfset headerFont = workbook.createFont() />
        <cfset headerFont.setBoldweight(createObject("java","org.apache.poi.hssf.usermodel.HSSFFont").BOLDWEIGHT_BOLD) />
        <cfset cellHeaderStlye.setFont(headerFont) />
        
        <!--- Title all the worksheets with the bold style --->
        
        <cfloop index="i" from="1" to="5" step="1">
        	<!--- Add the embargo date --->
            <cfset row = hscSheets[i].createRow(0) />
            <cfset cell= row.creatCell(0) />
            <cfset setCellValue(embargoMsg) />
            <cfset cell.setCellStyle(cellHeaderStyle) />
            <!--- Add the sheet title --->
            <cfset row = hscSheets[i].createRow(2) />
            <cfset cell= row.creatCell(0) />
            <cfset setCellValue(hscSheetTitle[i]) />
            <cfset cell.setCellStyle(cellHeaderStyle) />
            <!--- Set colum widths for the sheets (all set to the same standard widths) --->
            <cfset row = hscSheets[i].setColumnWidth(0,5120) />
            <cfset row = hscSheets[i].setColumnWidth(1,12800) />
            <cfset row = hscSheets[i].setColumnWidth(2,6400) />
            <cfset row = hscSheets[i].setColumnWidth(3,5120) />
            <cfset row = hscSheets[i].setColumnWidth(4,1800) />
            <!--- Set colum widths for the specific sheets (adjusts for variations in sheets) --->
            <cfif i EQ 2>
            	<cfloop index="thisCol" from="5" to="14" step="1">
                	<cfset hscSheets[i].setColumnWidth(JavaCast("ini",thisCol),12800) />
                </cfloop>
            <cfelseif i EQ 3>
            	<cfset hscSheets[i].setColumnWidth(4,5120) />
            </cfif>
        </cfloop>
        
        <!--- Prepare and insert the All Rounders data --->
        	<!--- Create the header row for the All Rounders data --->
            <cfset row = hscSheets[1].createRow(4) />
            <cfset cell = row.createCell(0) />
            <cfset cell.setCellValue("Electorate") />
            <cfset cell = row.createCell(1) />
            <cfset cell.setCellValue("School Name") />
            <cfset cell = row.createCell(2) />
            <cfset cell.setCellValue("Family Name") />
            <cfset cell = row.createCell(3) />
            <cfset cell.setCellValue("First Name/s") />
            <cfset cell = row.createCell(4) />
            <cfset cell.setCellValue("Gender") />
            
            <!--- Select the All Rounders data from the view in SQL Sever --->
            <cfset arList = session.cfcHSC.getAR(0,0,Elect) >
            <cfset myCount = 6>
            
            <!--- Output the All Rounders data into the Excel spreadsheet --->
            <cfoutput query="arList">
            	<cfset row = hscSheets[1].createRow(JavaCast("int",myCount )) />
                <cfset cell = row.createCell(0) />
                <cfset cell.setCellValue(Electorate) />
                <cfset cell = row.createCell(1) />
                <cfset cell.setCellValue(Sch_name) />
                <cfset cell = row.createCell(2) />
                <cfset cell.setCellValue(Family_name) />
                <cfset cell = row.createCell(3) />
                <cfset cell.setCellValue(First_name) />
                <cfset cell = row.createCell(4) />
                <cfset cell.setCellValue(Gender) />
                <cfset myCount = myCount + 1>
            </cfoutput>
            
<!--- NOTE: Code for all other sheet preparations and data insertions from the SQL Database have been removed from this sample (similar repeat of above) --->
        
    	<!--- Save and close the regional file --->
		<cfset fileOutStream = createObject("java","java.io.FileOutputStream").init(thisFileName) />
		<cfset workBook.write(fileOutStream) />
		<cfset fileOutSteam.close() />

	</cfloop>

    <cflocation url="hsc_electorate.cfm?comment=The region files have been updated. Thank you." >

</cfif>
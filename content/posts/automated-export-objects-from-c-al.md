---
title: 'Automated export objects from C/AL'
date: Mon, 07 Sep 2020 05:44:17 +0000
draft: false
tags: ['Allgemein', 'Docker', 'SQL']
---

This time I have some tips on how to use GIT integration when developing in C/AL with docker. When used to AL development one of the first things to notice when going back to C/AL is, that you do not have any version control.

To solve this problem, I added a little bit of SQL code to the \[Object\] table as SQL Trigger. This trigger exports each edited object as TXT file to specified folder. If this folder is a GIT repository, you can simply have it opened with VS Code and do your commits like you are used to in AL.

For my example I used a normal NAV 2018 container without any special setting. I placed my export folder into "C:\\ProgramData\\BcContainerHelper\\Extensions\\NAV2018\\my\\" because this folder is shared with the container by default. If you add a different folder as shared, then you can change this.

If you created your docker container, you should be able to connect to the SQL Server using the SQL Server management studio with the container name as server and the username and password like you use for NAV in this container.

![](https://stefanmaron.files.wordpress.com/2020/09/image.png)

First script you need to run is this one. It enables the XP\_CMDSHELL which is needed to run finsql.exe from SQL Server: ([MS Docs](https://docs.microsoft.com/de-de/sql/database-engine/configure-windows/xp-cmdshell-server-configuration-option?view=sql-server-ver15))

```
\-- To allow advanced options to be changed.  
EXECUTE sp\_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXECUTE sp\_configure 'xp\_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  
```

After this is enabled you can add the trigger code. Be sure to run this script on your NAV database. Normally this is CRONUS.

```
CREATE TRIGGER \[dbo\].\[ExportOnModify\]
   ON  \[dbo\].\[Object\]
   AFTER INSERT,DELETE,UPDATE
AS
BEGIN
   DECLARE
@Name varchar(30),
@Type int,
@TypeName varchar(50),
@TypeNameShort varchar(50),
@ID int,
@Code varchar(2048),
@ReturnValue varchar(2048),
@user varchar(50),
@finsql varchar(250),
@baseFolderPath varchar(250),
@repositoryName varchar(50),
@server varchar(50),
@database varchar(50),
@logfile varchar(250)
   SELECT @ID = \[ID\]
   FROM INSERTED
   SELECT @Type = \[Type\]
   FROM INSERTED
   SELECT @Name = \[Name\]
   FROM INSERTED
   SELECT @user = replace(SYSTEM\_USER,'\\','\_')
   SELECT @TypeName = 

CASE @Type 
WHEN 1 THEN 'Table'
WHEN 2 THEN 'Form'
WHEN 3 THEN 'Report'
WHEN 4 THEN 'Dataport'
WHEN 5 THEN 'Codeunit'
WHEN 6 THEN 'XMLport'
WHEN 7 THEN 'MenuSuite'
WHEN 8 THEN 'Page'
WHEN 9 THEN 'Query'
ELSE ''
END

   SELECT @TypeNameShort = 
CASE @Type 
WHEN 1 THEN 'TAB'
WHEN 2 THEN 'FOR' --??
WHEN 3 THEN 'REP'
WHEN 4 THEN 'DAT' --??
WHEN 5 THEN 'COD'
WHEN 6 THEN 'XML'
WHEN 7 THEN 'MEN'
WHEN 8 THEN 'PAG'
WHEN 9 THEN 'QUE'
ELSE ''
END

   IF @TypeName <> '' BEGIN
      SELECT @finsql = 'C:\\Program Files (x86)\\Microsoft Dynamics NAV\\110\\RoleTailored Client\\finsql.exe'
      SELECT @baseFolderPath = 'C:\\Run\\my'
      SELECT @repositoryName = 'objects'
      SELECT @server = '.'
      SELECT @database = 'CRONUS'
      SELECT @logfile = 'C:\\Run\\my\\objects\\log.txt'
      SELECT @Code = 'call "'+ @finsql +'" command=exportobjects,file="'+@baseFolderPath+'\\'+@repositoryName+'\\'+@TypeName +'\\'+@TypeNameShort + Convert(varchar(20),@ID) + '.TXT",servername='+@server+',database="'+@database+'", filter="Type=' + @TypeName + ';ID=' + Convert(varchar(20),@ID) + '", logfile="'+@logfile+'"'
      EXEC @ReturnValue = xp\_cmdshell @Code;
   END
END
GO
```

At the end of the script you can see a few settings. If you use the same environment as I do, you should be fine. If not you can adjust the script there.

Next, you need to create the folder structure:

![](https://stefanmaron.files.wordpress.com/2020/09/image-1.png)

The objects are sorted automatically into this folders. And you are ready to go!

#### Trouble shooting

If anything runs into an error, for example a folder is missing, the finsql.exe creates a log.txt:

![](https://stefanmaron.files.wordpress.com/2020/09/image-2.png)

In this file you can read what is going wrong:

![](https://stefanmaron.files.wordpress.com/2020/09/image-3.png)

I hope I did not forget anything!  
Happy coding ;)

Note: Anything is provided as is, without any warranty :)
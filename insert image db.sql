use tempdb;
go

IF OBJECT_ID('DirectoryFiles')IS NOT NULL
      DROP table DirectoryFiles;

CREATE TABLE DirectoryFiles (
      subdirectory nvarchar(max)
      ,depth int
      ,isfile bit);

INSERT DirectoryFiles  (subdirectory,depth,isfile)
EXEC master..xp_dirtree 'C:\Users\Lenovo\Pictures\test\', 1, 1;

-- select * from DirectoryFiles
go
--------------------------------------------------

IF OBJECT_ID('Image_table')IS NOT NULL
      DROP table Image_table;

CREATE Table Image_table
(
    ImageId int identity,
    ImageName nvarchar(255),
    ImageContent VARBINARY(MAX) ,
	ImageSize varchar(10)
);
go
------------------------------------------

DECLARE FileCursor CURSOR FOR
select subdirectory from DirectoryFiles where isfile=1 

declare @fileName nvarchar(max)

OPEN FileCursor
FETCH NEXT FROM FileCursor INTO @fileName

WHILE @@FETCH_STATUS = 0
BEGIN
    declare @fileFullPath nvarchar(max)
	set @fileFullPath=CONCAT('C:\Users\Lenovo\Pictures\test\',@fileName)
	
	declare @sqlText nvarchar(max)
	set @sqlText=concat('INSERT INTO Image_table (ImageName,ImageContent,ImageSize)
	 ','SELECT  ''',@fileName,'''  
	  ,BulkColumn
	  ,concat(DATALENGTH(BulkColumn)/1024,'' KB'')
	  FROM OPENROWSET  
      ( BULK ''',@fileFullPath,''',SINGLE_BLOB)  as FileContent'
      )

	  exec(@sqlText)

	FETCH NEXT FROM FileCursor INTO @fileName
END

CLOSE FileCursor
DEALLOCATE FileCursor;

go

drop table DirectoryFiles;

go

--select * from image_table

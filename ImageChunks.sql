use tempdb;
go

Create or alter view dbo.vw_ImageWithBase64 as
SELECT ImageId,ImageName,ImageSize
,concat('data:image/jpeg;base64,',(select ImageContent AS '*' FOR XML PATH(''))) [ImageBase64]
from Image_table;

go


CREATE or alter FUNCTION dbo.fn_SplitLongText (@LongText varchar(max))
RETURNS @result TABLE (
    RN  int NOT NULL,
    Textchunk VARCHAR(8000) NOT NULL
    )
AS
BEGIN
    declare @chunkSize int=8000
    declare @RN int=1
    declare @CurrentPosition int=1
    declare @LongTextLen int= len(@LongText)
    
    while @CurrentPosition<=@LongTextLen
    begin
        declare @Textchunk varchar(8000)=substring(@LongText,@CurrentPosition,@chunkSize);

        insert into @result(RN,Textchunk)
        values (@RN,@Textchunk);

        set @RN+=1
        set @CurrentPosition+=@chunkSize        
    end

    RETURN
END;

go

create or alter view dbo.vw_Imagechunks as
select ImageId,s.*
from dbo.vw_ImageWithBase64 t
cross apply dbo.fn_SplitLongText(t.ImageBase64)s;

go
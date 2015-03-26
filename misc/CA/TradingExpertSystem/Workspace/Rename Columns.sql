DECLARE @t TABLE(i INT, name NVARCHAR(100))
DECLARE @i INT = 1, @n INT
DECLARE @s NVARCHAR(100), @s2 NVARCHAR(100), @ss NVARCHAR(200)

INSERT @t
SELECT ROW_NUMBER() OVER (ORDER BY ORDINAL_POSITION), COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'workshop2A_processedData' AND COLUMN_NAME LIKE '%#%' 

SET @n = @@ROWCOUNT

WHILE @i <= @n
BEGIN
	SET @s = (SELECT TOP 1 name FROM @t WHERE i = @i)
	SET @s2 = REPLACE(@s, '#', '_')
	SET @ss = 'workshop2A_processedData.' + @s
	EXEC sp_rename @ss, @s2

	SET @i = @i + 1
END

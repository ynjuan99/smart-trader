IF NOT EXISTS ( SELECT  *
                FROM    INFORMATION_SCHEMA.COLUMNS
                WHERE   TABLE_NAME = 'tb_PivotFactorData_2010'
                        AND COLUMN_NAME = 'TotalReturn' )
    BEGIN
        ALTER TABLE dbo.tb_PivotFactorData_2010 ADD TotalReturn FLOAT
    END
GO


;
WITH    a AS (SELECT    t.Date,
                        t.SecId,
                        (SELECT AVG([4])
                         FROM   dbo.tb_PivotFactorData_2010 t2
                         WHERE  t2.SecId = t.SecId
                                AND DATEDIFF(d, t.Date, t2.Date) BETWEEN 1 AND 30
                        ) AS TotalReturn
              FROM      dbo.tb_PivotFactorData_2010 t
             )
    UPDATE  dbo.tb_PivotFactorData_2010
    SET     TotalReturn = a.TotalReturn
    FROM    dbo.tb_PivotFactorData_2010 a1
    JOIN    a
    ON      a1.Date = a.Date
            AND a1.SecId = a.SecId


SELECT YEAR(Date) AS Year, MONTH(Date) AS Month, COUNT(*) AS TotalRecord 
FROM tb_FactorScore WHERE Sector <> 'All' 
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY Year, Month

/*
Year	Month	TotalRecord
2003	12	764
2004	1	16831
2004	2	15327
2004	3	17638
2004	4	16892
2004	5	16189
2004	6	17025
2004	7	17035
2004	8	17084
2004	9	17133
2004	10	16411
2004	11	17288
2004	12	18103
2005	1	16547
2005	2	15777
2005	3	18196
2005	4	16590
2005	5	17429
2005	6	17488
2005	7	16767
2005	8	18429
2005	9	17692
2005	10	16947
2005	11	17788
2005	12	17796
2006	1	17805
2006	2	16250
2006	3	18639
2006	4	16226
2006	5	18699
2006	6	17886
2006	7	17079
2006	8	18697
2006	9	17075
2006	10	17937
2006	11	17993
2006	12	17217
2007	1	18872
2007	2	16440
2007	3	18110
2007	4	17310
2007	5	18988
2007	6	17358
2007	7	18224
2007	8	19100
2007	9	16636
2007	10	19136
2007	11	18304
2007	12	17481
2008	1	19159
2008	2	17528
2008	3	17591
2008	4	18450
2008	5	18482
2008	6	17661
2008	7	19364
2008	8	17703
2008	9	18546
2008	10	19399
2008	11	16885
2008	12	19420
2009	1	18590
2009	2	16900
2009	3	18578
2009	4	18612
2009	5	17746
2009	6	18569
2009	7	19442
2009	8	17787
2009	9	18642
2009	10	18670
2009	11	17792
2009	12	19500
2010	1	17836
2010	2	17020
2010	3	19573
2010	4	18722
2010	5	17871
2010	6	18722
2010	7	18771
2010	8	18803
2010	9	18816
2010	10	18000
2010	11	18876
2010	12	19736
2011	1	18035
2011	2	17180
2011	3	19774
2011	4	18069
2011	5	18964
2011	6	18964
2011	7	18103
2011	8	19841
2011	9	18986
2011	10	18124
2011	11	19008
2011	12	19037
2012	1	19076
2012	2	18242
2012	3	19145
2012	4	18291
2012	5	20033
2012	6	18328
2012	7	19206
2012	8	20082
2012	9	17456
2012	10	20085
2012	11	19246
2012	12	18395
2013	1	20159
2013	2	17521
2013	3	18398
2013	4	19294
2013	5	20171
2013	6	17555
2013	7	20205
2013	8	19343
2013	9	18476
2013	10	20240
2013	11	18484
2013	12	19373
2014	1	20268
2014	2	17640
2014	3	18522
2014	4	19420
2014	5	19455
2014	6	18590
2014	7	20392
2014	8	18673
2014	9	19580
2014	10	20471
2014	11	17820
2014	12	9812
*/

WITH t AS (
	SELECT YEAR(Date) AS Year, Sector, COUNT(*) AS TotalRecord 
	FROM tb_FactorScore
	WHERE Sector <> 'All' 
	GROUP BY YEAR(Date), Sector
), t1 AS (
	SELECT ROW_NUMBER() OVER(PARTITION BY YEAR ORDER BY TotalRecord DESC) AS Rank, * FROM t
)
SELECT * FROM t1 WHERE t1.Rank IN (1, 2, 3)
/*
Rank	Year	Sector	TotalRecord
1	2003	Financials                	150
2	2003	Consumer Discretionary    	112
3	2003	Information Technology    	110
1	2004	Financials                	39991
2	2004	Consumer Discretionary    	29852
3	2004	Information Technology    	29173
1	2005	Financials                	41459
2	2005	Consumer Discretionary    	31309
3	2005	Information Technology    	29786
1	2006	Financials                	41898
2	2006	Consumer Discretionary    	32197
3	2006	Information Technology    	30685
1	2007	Financials                	42051
2	2007	Consumer Discretionary    	33757
3	2007	Information Technology    	32439
1	2008	Financials                	43072
2	2008	Consumer Discretionary    	34184
3	2008	Information Technology    	33482
1	2009	Financials                	42997
2	2009	Consumer Discretionary    	34366
3	2009	Information Technology    	33847
1	2010	Financials                	43477
2	2010	Information Technology    	34688
3	2010	Consumer Discretionary    	34511
1	2011	Financials                	43940
2	2011	Consumer Discretionary    	34941
3	2011	Information Technology    	34580
1	2012	Financials                	44107
2	2012	Consumer Discretionary    	35970
3	2012	Information Technology    	34860
1	2013	Financials                	44007
2	2013	Consumer Discretionary    	36136
3	2013	Information Technology    	34986
1	2014	Financials                	42055
2	2014	Consumer Discretionary    	35008
3	2014	Information Technology    	33805
*/


/* so we choose 2013, Financials and Consumer Discretionary */

SELECT YEAR(Date) AS Year, MONTH(Date) AS Month, Sector, SIGN(PriceRetFF20D_Absolute) AS Trend, COUNT(*) AS TotalRecord 
FROM tb_FactorScore WHERE Sector IN ('Financials', 'Consumer Discretionary', 'Information Technology')
GROUP BY YEAR(Date), MONTH(Date), Sector, SIGN(PriceRetFF20D_Absolute)
ORDER BY Year, Month, Sector, SIGN(PriceRetFF20D_Absolute) DESC


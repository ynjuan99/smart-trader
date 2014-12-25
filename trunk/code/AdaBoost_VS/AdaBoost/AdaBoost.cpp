// AdabBoost.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "Ada.h"

#define WINDOWS 4

//#define LOAD_SAVED_MODEL

int _tmain(int argc, _TCHAR* argv[])
{

	char szWindowData[WINDOWS][512] = { "", "", "", "" };
	char szDataQuery[WINDOWS][512] = { "", "", "", "" };
	char szTestData[512] = "", szTestDataQuery[512] = "";
	char szOutPutFile[512] = "", szModelFile[512] = "";
	char szSectors[10][512] = { "Health Care", "Information Technology", "Consumer Discretionary", "Financials", "Telecommunication Services", "Utilities", "Industrials", "Energy", "Materials", "Consumer Staples" };

	cout << "Sector,Accuracy,Sensitivity,Specificity,Precesion" << endl;

	for (int iSec = 0; iSec < 10; iSec++)
	{
		sprintf_s(szDataQuery[0], "DATE >= '20131101' and DATE < '20131201' and Sector = '%s'", szSectors[iSec]);
		sprintf_s(szDataQuery[1], "DATE >= '20130901' and DATE < '20131201' and Sector = '%s'", szSectors[iSec]);
		sprintf_s(szDataQuery[2], "DATE >= '20130601' and DATE < '20131201' and Sector = '%s'", szSectors[iSec]);
		sprintf_s(szDataQuery[3], "DATE >= '20130101' and DATE < '20131201' and Sector = '%s'", szSectors[iSec]);

		//sprintf_s(szTestDataQuery, "DATE >= '20131201' and DATE <= '20131231' and Sector = '%s'", szSectors[iSec]);
		sprintf_s(szTestDataQuery, "DATE = '20131231' and Sector = '%s'", szSectors[iSec]);

		sprintf_s(szOutPutFile, "E:\\FYP\\AdaVS\\AdaBoost\\Output\\results_%s.csv", szSectors[iSec]);
		sprintf_s(szModelFile, "E:\\FYP\\AdaVS\\AdaBoost\\\\Model\\model_%s.csv", szSectors[iSec]);

#ifndef LOAD_SAVED_MODEL

		for (int j = 0; j < WINDOWS; j++)
		{
			// <-----Rest Variables -------------------->
			Init();
			// <-----Loading the data and cleaning ------> 
			LoadDataFromDB(szDataQuery[j]);
			CleanTrainingData();

			// <----- Initial steps ------> 
			RankAndSetQuantiles();
			InitializeWeights();

			// <----- Main Routine to find the weak classifiers ------> 
			for (int i = 0; i < ITERATIONS; i++)
			{
				FindWeakClassifier();
				AdjustWeights();
			}
			//saving weak clasifier of this window
			saveWeakClassifier(j);

		}

		saveModel(szModelFile);
#else
		loadModel(szModelFile);
#endif
		LoadTestDataFromDB(szTestDataQuery);
		RankAndSetQuantilesForTestData();

		for (int j = 0; j < WINDOWS; j++)
			ApplyStrongClassifier(j);

		CalculateAccuracy(WINDOWS, szSectors[iSec]);
		writeResuts(szOutPutFile);
	}
	system("pause");
	return 0;
}


#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <math.h>
#include <sstream>
#include <map>
#include <vector>
#include<string>

#using <System.dll>

using namespace std;
using namespace System;
using namespace System::Data;
using namespace System::Data::SqlClient;

const int ITERATIONS = 20;  // max for 20

double dDataArray_noclean[50000][200];
double dDataArray[50000][200];

double dTestDataArray[50000][200];

double LOWER_CUT = 0.2; // best for 0.6 and 0.9
double UPPER_CUT = 0.8;

double dblWindowWeights[4] = { 0.4, 0.3, 0.2, 0.1 };
map<int, vector<double> > mapWeakClassifiers;
map<int, vector<double> >::iterator it_mwc;

map<int, map<int, vector<double> >> mapWeakClassifiers_Win;
map<int, map<int, vector<double> >>::iterator it_mwc_win;
int nRows = 0;
int nFactors = 0;
int nTestRows = 0;

int iLatestWeakClassifier = 0;
double dLatestHx1 = 0;
double dLatestHx2 = 0;

void Init()
{
	nRows = 0;
	nFactors = 0;
	nTestRows = 0;

	iLatestWeakClassifier = 0;
	dLatestHx1 = 0;
	dLatestHx2 = 0;

}

bool LoadTrainingData(char *filepath)
{
	ifstream file;
	file.open(filepath, std::ifstream::in);

	string line;
	int row = 0;
	int col = 0;
	while (file.good())
	{
		getline(file, line);
		if (row != 0)  // avaiding the header
		{
			if (line.length() > 1)  // avaoding the empty lines
			{
				stringstream ss(line);
				string token;
				col = 0;
				while (std::getline(ss, token, ',')) {

					dDataArray[row][col] = atof(token.c_str());
					nFactors = col;
					col++;
				}
				nRows++;

				//cout << "row=" << row << "col=" << col << endl;
			}
		}
		row++;
	}

	file.close();

	//nRows = row - 2;
	nFactors = nFactors - 1;

	cout << "Sucessfully Loaded the data! Rows=" << nRows << "Factors=" << nFactors << endl;
	/*for(int i=0;i<55;i++)
	{
	cout << dDataArray[1][i] <<endl;
	}*/

	return true;
}

bool LoadUncleanedTrainingData(char *filepath)
{
	ifstream file;
	file.open(filepath, std::ifstream::in);

	string line;
	int row = 0;
	int col = 0;
	while (file.good())
	{
		getline(file, line);
		if (row != 0)  // avaiding the header
		{
			if (line.length() > 1)  // avaoding the empty lines
			{
				stringstream ss(line);
				string token;
				col = 0;
				while (std::getline(ss, token, ',')) {

					dDataArray_noclean[row][col] = atof(token.c_str());
					nFactors = col;
					col++;
				}
				nRows++;

				//cout << "row=" << row << "col=" << col << endl;
			}
		}
		row++;
	}

	file.close();

	//nRows = row - 2;
	nFactors = nFactors - 1;

	cout << "Sucessfully Loaded the data! Rows=" << nRows << "Factors=" << nFactors << endl;
	/*for(int i=0;i<55;i++)
	{
	cout << dDataArray[1][i] <<endl;
	}*/

	return true;
}


bool CleanTrainingData()
{


	multimap <double, int> map_Rank;
	multimap<double, int>::iterator it;

	for (int row = 1; row <= nRows; row++)
	{
		map_Rank.insert(pair<double, int>(dDataArray_noclean[row][nFactors + 1], row));
	}

	if (map_Rank.size() != nRows)
	{
		cout << " Something wrong in clean data! mapsize =" << map_Rank.size() << " nRows=" << nRows << endl;
		return false;
	}

	double dUpperCut = 0;
	double dLowerCut = 0;

	int iRow = 0;
	for (it = map_Rank.begin(); it != map_Rank.end(); ++it)
	{
		if (iRow <= nRows*LOWER_CUT)
			dLowerCut = it->first;

		if (iRow <= nRows*UPPER_CUT)
			dUpperCut = it->first;

		iRow++;
	}

	//cout << " Upper cut=" << dUpperCut << " Lower cut=" << dLowerCut << endl;


	int cleanedRows = 1;
	for (int row = 1; row <= nRows; row++)
	{
		if (dDataArray_noclean[row][nFactors + 1] < dUpperCut && dDataArray_noclean[row][nFactors + 1] > dLowerCut)
			continue;

		for (int col = 1; col <= nFactors; col++)
		{
			dDataArray[cleanedRows][col] = dDataArray_noclean[row][col];
		}
		if (dDataArray_noclean[row][nFactors + 1] > (dUpperCut - 0.0000001))
			dDataArray[cleanedRows][nFactors + 1] = 1;
		else
			dDataArray[cleanedRows][nFactors + 1] = -1;

		cleanedRows++;

	}

	nRows = cleanedRows - 1;

	//cout << " After cleaning nRows =" << nRows << endl;

	return true;
}

bool RankAndSetQuantiles()
{

	for (int col = 1; col <= nFactors; col++) // going factor by factor
	{
		multimap <double, int> map_Rank;
		multimap<double, int>::iterator it;
		for (int row = 1; row <= nRows; row++)
		{
			map_Rank.insert(pair<double, int>(dDataArray[row][col], row));
		}

		//cout << "Factor = "<< col << " Map size =" << map_Rank.size()<< endl;

		if (map_Rank.size() != nRows)
		{
			cout << "Something wrong! mapsize= " << map_Rank.size() << " rows found =" << nRows << endl;
			return false;
		}
		// now we have the ranked map

		//print map
		//for (it=map_Rank.begin(); it!=map_Rank.end(); ++it)
		//   cout << it->first << " => " << it->second << '\n';

		// we will just assign the quantile number in the sells, no need the actual data.
		// first 1/2  -1, last 1/2 +1
		int curRow = 1;
		for (it = map_Rank.begin(); it != map_Rank.end(); ++it)
		{
			//first 30%
			if (curRow <= nRows / 2)
			{
				dDataArray[it->second][col] = 1;
			}
			else
			{
				dDataArray[it->second][col] = 2;
			}

			curRow++;
		}


	}

	return true;
}

bool InitializeWeights()
{

	double initWeight = 1 / (double)nRows;
	for (int row = 1; row <= nRows; row++)
	{
		dDataArray[row][nFactors + 2] = initWeight;
	}
	return true;
}




bool printDataArray()
{
	for (int i = 1; i <= nRows; i++)
	{
		for (int j = 1; j <= nFactors + 2; j++)  // target and weight
		{
			cout << dDataArray[i][j] << ",";
		}
		cout << endl;
	}
	return true;
}

bool printNoCleanDataArray()
{
	for (int i = 1; i <= nRows; i++)
	{
		for (int j = 1; j <= nFactors + 2; j++)  // target and weight
		{
			cout << dDataArray_noclean[i][j] << ",";
		}
		cout << endl;
	}
	return true;
}

bool printTestDataArray()
{
	for (int i = 1; i <= nTestRows; i++)
	{
		for (int j = 0; j <= nFactors + 5; j++)  // target and predicted
		{
			cout << dTestDataArray[i][j] << ",";
		}
		cout << endl;
	}
	return true;
}

bool printWeakClassifiersMap(int iWindows)
{
	for (int win = 0; win < iWindows; win++)
	{
		for (it_mwc = (mapWeakClassifiers_Win[win]).begin(); it_mwc != (mapWeakClassifiers_Win[win]).end(); ++it_mwc)
		{
			vector<double> vecTemp = it_mwc->second;

			cout << it_mwc->first << "   " << it_mwc->second[0] << " , " << it_mwc->second[1] << endl;
			//for (std::vector<double>::iterator it = vecTemp.begin() ; it != vecTemp.end(); ++it)
			//    std::cout << *it << ",";
			//cout<<endl;
		}
	}
	return true;
}


bool FindWeakClassifier()
{
	// creating a array 4xfactors

	double dPosNegWeights[6][100];  // 5 rows..not taking first row/col .. W1+,W1-,W2+,W2-,H(x)

	for (int i = 0; i < 6; i++)  // ionitialize to 0
	{
		for (int j = 0; j < 100; j++)
		{
			dPosNegWeights[i][j] = 0;
		}
	}


	for (int factor = 1; factor <= nFactors; factor++)
	{
		for (int row = 1; row <= nRows; row++)
		{
			if (dDataArray[row][factor] < 1.5)   // quantile 1
			{
				if (dDataArray[row][nFactors + 1] >0)
					dPosNegWeights[1][factor] += dDataArray[row][nFactors + 2];
				else
					dPosNegWeights[2][factor] += dDataArray[row][nFactors + 2];
			}
			else  // quantile 2
			{
				if (dDataArray[row][nFactors + 1] >0)
					dPosNegWeights[3][factor] += dDataArray[row][nFactors + 2];
				else
					dPosNegWeights[4][factor] += dDataArray[row][nFactors + 2];

			}
		}
	}

	// print the pos neg array

	/*for(int i=1 ; i <= 5 ; i++)
	{
	for(int j=1 ; j <= nFactors  ; j++)
	{
	cout << dPosNegWeights[i][j] << ",";
	}
	cout<<endl;
	}*/

	// find the weak classifier per factor

	multimap <double, int> map_wc;
	multimap<double, int>::iterator it_wc;

	for (int factor = 1; factor <= nFactors; factor++)
	{

		dPosNegWeights[5][factor] = sqrt(dPosNegWeights[1][factor] * dPosNegWeights[2][factor])
			+ sqrt(dPosNegWeights[3][factor] * dPosNegWeights[4][factor]);

		map_wc.insert(pair<double, int>(dPosNegWeights[5][factor], factor));
	}

	// find the weakest clasifier

	it_wc = map_wc.begin();
	int weakestClassifier = it_wc->second;
	vector<double> vecTemp;

	// calculate hx for quantile 1 nad 2 anp append to the map

	double hx1 = 0.5 * log(
		(dPosNegWeights[1][weakestClassifier] + 1 / (double)nRows)
		/ (dPosNegWeights[2][weakestClassifier] + 1 / (double)nRows)
		);
	double hx2 = 0.5 * log(
		(dPosNegWeights[3][weakestClassifier] + 1 / (double)nRows)
		/ (dPosNegWeights[4][weakestClassifier] + 1 / (double)nRows)
		);

	vecTemp.push_back(hx1);  //
	vecTemp.push_back(hx2);

	mapWeakClassifiers.insert(pair< int, vector<double> >(weakestClassifier, vecTemp));
	iLatestWeakClassifier = weakestClassifier;
	dLatestHx1 = hx1;
	dLatestHx2 = hx2;
	//printWeakClassifiersMap();
	//cout << "Weak classifier for this iteration : factor ="<<weakestClassifier << " hx1=" << hx1 << " hx2=" << hx2 << endl;
	return true;
}

bool saveWeakClassifier(int iWindow)
{
	mapWeakClassifiers_Win.insert(pair< int, map<int, vector<double> > >(iWindow, mapWeakClassifiers));
	return true;
}


bool AdjustWeights()
{

	for (int row = 1; row <= nRows; row++)
	{
		double dy = dDataArray[row][nFactors + 1];
		double dHx = 0;

		if (dDataArray[row][iLatestWeakClassifier] < 1.5)  // Q1
		{
			dHx = dLatestHx1;
		}
		else  // Q2
		{
			dHx = dLatestHx2;
		}
		//cout << " dy="<< dy << " dHx="<< dHx << " exp value = " << exp(-1*dy*dHx)<<endl;
		dDataArray[row][nFactors + 2] *= exp(-1 * dy*dHx);

	}

	return true;
}

bool LoadTestingData(char *filepath)
{
	ifstream file;
	file.open(filepath, std::ifstream::in);

	string line;
	int row = 0;
	int col = 0;
	while (file.good())
	{
		getline(file, line);
		if (row != 0)  // avaiding the header
		{
			if (line.length() > 1)  // avoding the empty lines
			{
				stringstream ss(line);
				string token;
				col = 0;
				while (std::getline(ss, token, ',')) {

					dTestDataArray[row][col] = atof(token.c_str());
					col++;
				}
				nTestRows++;

				//cout << "row=" << row << "col=" << col << endl;
			}
		}
		row++;
	}

	file.close();

	cout << "Sucessfully Loaded the Test data! Rows=" << nTestRows << endl;

	return true;
}

bool RankAndSetQuantilesForTestData()
{
	for (int col = 1; col <= nFactors; col++) // going factor by factor
	{
		multimap <double, int> map_Rank;
		multimap<double, int>::iterator it;
		for (int row = 1; row <= nTestRows; row++)
		{
			map_Rank.insert(pair<double, int>(dTestDataArray[row][col], row));
		}

		//cout << "Factor = "<< col << " Map size =" << map_Rank.size()<< endl;

		if (map_Rank.size() != nTestRows)
		{
			cout << "Something wrong! TEST mapsize= " << map_Rank.size() << " rows found =" << nTestRows << endl;
			return false;
		}
		// now we have the ranked map

		//print map
		//for (it=map_Rank.begin(); it!=map_Rank.end(); ++it)
		//   cout << it->first << " => " << it->second << '\n';

		// we will just assign the quantile number in the sells, no need the actual data.
		// first 1/2  -1, last 1/2 +1
		int curRow = 1;
		for (it = map_Rank.begin(); it != map_Rank.end(); ++it)
		{
			//first 1/2
			if (curRow <= nTestRows / 2)
			{
				dTestDataArray[it->second][col] = 1;
			}
			else
			{
				dTestDataArray[it->second][col] = 2;
			}

			curRow++;
		}


	}

	return true;
}

bool ApplyStrongClassifier()
{

	for (int row = 1; row <= nTestRows; row++)
	{
		double dStrongClassifier = 0;
		for (it_mwc = mapWeakClassifiers.begin(); it_mwc != mapWeakClassifiers.end(); ++it_mwc)
		{
			//vector<double> vecTemp = it_mwc->second;

			if (dTestDataArray[row][it_mwc->first] < 1.5)  // Q1
			{
				dStrongClassifier += it_mwc->second[0];
			}
			else  // Q2
			{
				dStrongClassifier += it_mwc->second[1];
			}



		}
		//cout << " Strong classifier ="<<dStrongClassifier<<endl;
		if (dStrongClassifier < 0.000001)
			dTestDataArray[row][nFactors + 2] = -1;
		else
			dTestDataArray[row][nFactors + 2] = 1;

	}
	return true;
}


bool CalculateAccuracy()
{

	//printTestDataArray();
	int iCorrectPredictions = 0;
	for (int row = 1; row <= nTestRows; row++)
	{
		//if( fabs(dTestDataArray[row][nFactors+1] - dTestDataArray[row][nFactors+2] ) < 0.00001  )
		if ((dTestDataArray[row][nFactors + 1])*(dTestDataArray[row][nFactors + 2]) > 0)
			iCorrectPredictions++;
	}

	cout << " Accuracy = " << (iCorrectPredictions / (double)nTestRows) * 100 << "%" << endl;

	return true;
}

// specially added fns for window method
bool ApplyStrongClassifier(int iWindow)
{

	for (int row = 1; row <= nTestRows; row++)
	{
		double dStrongClassifier = 0;
		for (it_mwc = (mapWeakClassifiers_Win[iWindow]).begin(); it_mwc != (mapWeakClassifiers_Win[iWindow]).end(); ++it_mwc)
		{
			//vector<double> vecTemp = it_mwc->second;

			if (dTestDataArray[row][it_mwc->first] < 1.5)  // Q1
			{
				dStrongClassifier += it_mwc->second[0];
			}
			else  // Q2
			{
				dStrongClassifier += it_mwc->second[1];
			}



		}
		//cout << " Strong classifier ="<<dStrongClassifier<<endl;
		if (dStrongClassifier < 0.000001)
			dTestDataArray[row][nFactors + 2 + iWindow] = -1;
		else
			dTestDataArray[row][nFactors + 2 + iWindow] = 1;

	}
	return true;
}

bool CalculateAccuracy(int iWindows, char* szSector)
{

	//printTestDataArray();
	int iCorrectPredictions = 0;
	int iPositivePredictions = 0;
	int iCorrectPositivePredictions = 0;

	int iTruePositive = 0;
	int iTrueNegative = 0;
	int iFalsePositive = 0;
	int iFalseNegative = 0;

	for (int row = 1; row <= nTestRows; row++)
	{
		double dblWeights = 0;
		for (int win = 0; win < iWindows; win++)
		{
			dblWeights += dTestDataArray[row][nFactors + 2 + win] * dblWindowWeights[win];
		}
		//cout << dTestDataArray[row][nFactors + 1] << "," << dTestDataArray[row][nFactors + 2] << "," << dTestDataArray[row][nFactors + 3] << "," << dTestDataArray[row][nFactors + 4] << "," << dTestDataArray[row][nFactors + 4] << "," << endl;
		//		if(dblWeights * dTestDataArray[row][nFactors + 1] > 0 )
		//			iCorrectPredictions++;
		//              }
		if (dblWeights > 0)
		{
			dTestDataArray[row][nFactors + 6] = 1;
			iPositivePredictions++;
		}
		else
			dTestDataArray[row][nFactors + 6] = 0;

		if (dblWeights >= 0 && dTestDataArray[row][nFactors + 1] >= 0)
			iTruePositive++;

		if (dblWeights < 0 && dTestDataArray[row][nFactors + 1] < 0)
			iTrueNegative++;

		if (dblWeights >= 0 && dTestDataArray[row][nFactors + 1] < 0)
			iFalsePositive++;

		if (dblWeights < 0 && dTestDataArray[row][nFactors + 1] >= 0)
			iFalseNegative++;

	}



	//cout << " Accuracy = " << ((iTruePositive + iTrueNegative )/ (double)nTestRows) * 100 << "%" << endl;
	//cout << " Sensitivity = " << (iTruePositive / (double)(iTruePositive + iFalseNegative)) * 100 << "%" << endl;
	//cout << " Specificity = " << (iTruePositive / (double)(iFalsePositive + iTrueNegative)) * 100 << "%" << endl;
	//cout << " Precision = " << (iTruePositive / (double)(iTruePositive + iFalsePositive) )* 100 << "%" << endl;

	cout << szSector << ",";
	cout << ((iTruePositive + iTrueNegative) / (double)nTestRows) * 100 << ",";
	cout << (iTruePositive / (double)(iTruePositive + iFalseNegative)) * 100 << ",";
	cout << (iTruePositive / (double)(iFalsePositive + iTrueNegative)) * 100 << ",";
	cout << (iTruePositive / (double)(iTruePositive + iFalsePositive)) * 100 << endl;


	return true;
}

void writeResuts(char *outputfile)
{
	ofstream file(outputfile, std::ofstream::out);
	string line;
	int row = 0;
	int col = 0;
	for (int i = 1; i <= nTestRows; i++)
	{

		file << dTestDataArray[i][0] << "," << dTestDataArray[i][nFactors + 6] << endl;

	}

	file.close();
}

void LoadDataFromDB(string strQ)
{
	System::String^ strWhere = gcnew System::String(strQ.c_str());
	System::String^ strQuery = gcnew System::String("select SecId,EarningsFY2UpDnGrade_1M,EarningsFY1UpDnGrade_1M,EarningsRevFY1_1M,NMRevFY1_1M,\
															PriceMA10,PriceMA20,PMOM10,RSI14D,EarningsFY2UpDnGrade_3M,FERating,PriceSlope10D,PriceMA50,SalesRevFY1_1M,PMOM20,NMRevFY1_3M,EarningsFY2UpDnGrade_6M,\
																	PriceSlope20D,Price52WHigh,EarningsRevFY1_3M,PMOM50,PriceTStat200D,RSI50D,MoneyFlow14D,PriceTStat100D,PEGFY1,Volatility12M,	SharesChg12M,\
																							PriceMA100,	Volatility6M,SalesYieldFY1,EarningsYieldFY2,PriceRetFF20D from tb_FactorScore where " + strWhere);
	//strQuery = strQuery + strWhere;
	//Console::WriteLine(strQuery);

	SqlConnection^ myConnection = gcnew SqlConnection("Initial Catalog=SmartTrader;Data Source=localhost;Integrated Security=SSPI;");
	myConnection->Open();

	SqlCommand^ scmd = gcnew SqlCommand(strQuery, myConnection);
	SqlDataReader^ r = scmd->ExecuteReader();
	int row = 1;
	while (r->Read())
	{
		//DateTime date = (DateTime)r[0];
		//int sectorId = Convert::ToInt32(r[1]);
		//Console::WriteLine("Row ...");

		for (int col = 0; col < 33; col++)  // secId + 31 factors + target20day return
		{
			dDataArray_noclean[row][col] = Convert::ToDouble(r[col]);

		}

		row++;
	}
	r->Close();

	nFactors = 31;
	nRows = row - 1;

}

void LoadTestDataFromDB(string strQ)
{
	System::String^ strWhere = gcnew System::String(strQ.c_str());
	System::String^ strQuery = gcnew System::String("select SecId,EarningsFY2UpDnGrade_1M,EarningsFY1UpDnGrade_1M,EarningsRevFY1_1M,NMRevFY1_1M,\
																												PriceMA10,PriceMA20,PMOM10,RSI14D,EarningsFY2UpDnGrade_3M,FERating,PriceSlope10D,PriceMA50,SalesRevFY1_1M,PMOM20,NMRevFY1_3M,EarningsFY2UpDnGrade_6M,\
																																													PriceSlope20D,Price52WHigh,EarningsRevFY1_3M,PMOM50,PriceTStat200D,RSI50D,MoneyFlow14D,PriceTStat100D,PEGFY1,Volatility12M,	SharesChg12M,\
																																																																				PriceMA100,	Volatility6M,SalesYieldFY1,EarningsYieldFY2,PriceRetFF20D from tb_FactorScore where " + strWhere);

	SqlConnection^ myConnection = gcnew SqlConnection("Initial Catalog=SmartTrader;Data Source=localhost;Integrated Security=SSPI;");
	myConnection->Open();

	SqlCommand^ scmd = gcnew SqlCommand(strQuery, myConnection);
	SqlDataReader^ r = scmd->ExecuteReader();
	int row = 1;
	while (r->Read())
	{
		for (int col = 0; col < 33; col++)  // secId + 31 factors + target20day return
		{
			dTestDataArray[row][col] = Convert::ToDouble(r[col]);

		}

		row++;
	}
	r->Close();
	nTestRows = row - 1;
	//cout << "Sucessfully Loaded the Test data! Rows=" << nTestRows << endl;

}


void saveModel(char *modelfile)
{

	ofstream file(modelfile, std::ofstream::out);

	for (it_mwc_win = mapWeakClassifiers_Win.begin(); it_mwc_win != mapWeakClassifiers_Win.end(); it_mwc_win++)
	{
		for (it_mwc = (it_mwc_win->second).begin(); it_mwc != (it_mwc_win->second).end(); it_mwc++)
		{
			file << it_mwc_win->first << "," << it_mwc->first << "," << (it_mwc->second)[0] << "," << (it_mwc->second)[1] << endl;
		}

	}

	file.close();

}

void loadModel(char *modelfile)
{
	ifstream file;
	file.open(modelfile, std::ifstream::in);

	string line;
	int row = 0;
	int col = 0;
	//vector<double> vecTmp;
	map<int, vector<double> > mapWeakClassifiersTmp;

	while (file.good())
	{
		getline(file, line);

		if (line.length() > 1)  // avoding the empty lines
		{
			stringstream ss(line);
			string token;
			vector<double> vecTmp(2);
			col = 0;
			double dArr[4] = { 0, 0, 0, 0 };
			while (std::getline(ss, token, ',')) {
				dArr[col] = atof(token.c_str());
				col++;
			}

			//cout << dArr[2] << "  " << dArr[3] << endl;
			//vecTmp.push_back(dArr[2]);
			//vecTmp.push_back(dArr[3]);
			vecTmp[0] = dArr[2];
			vecTmp[1] = dArr[3];


			//mapWeakClassifiersTmp.insert(pair< int, vector<double> >((int)dArr[1], vecTmp));
			(mapWeakClassifiers_Win[dArr[0]]).insert(pair<int, vector<double> >((int)dArr[1], vecTmp));

			//nTestRows++;

			//cout << "row=" << row << "col=" << col << endl;
		}



		row++;
	}

	file.close();
	nFactors = 31;
	//cout << "Sucessfully Loaded the Test data! Rows=" << nTestRows << endl;


}
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <math.h>
#include <sstream>
#include <map>
#include <vector>

using namespace std;

const int ITERATIONS=98;



double dDataArray_noclean[20000][200];
double dDataArray[20000][200];

double dTestDataArray[2000][200];

double LOWER_CUT = 0.6;  // best for 0.6 and 0.9
double UPPER_CUT = 0.9;

map<int,vector<double> > mapWeakClassifiers;
map<int,vector<double> >::iterator it_mwc;

int nRows = 0;
int nFactors = 0;
int nTestRows = 0;

int iLatestWeakClassifier =0;
double dLatestHx1 =0;
double dLatestHx2 =0;

bool LoadTrainingData(char *filepath)
{
	ifstream file;
	file.open (filepath, std::ifstream::in);

	string line;
	int row = 0;
	int col = 0;
	while ( file.good() )
	{
	     getline ( file, line);
	     if(row != 0)  // avaiding the header
	     {
	    	 if(line.length() > 1 )  // avaoding the empty lines
	    	 {
			 stringstream ss(line);
			 string token;
			 col = 1;
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
	nFactors = nFactors -1;

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
	file.open (filepath, std::ifstream::in);

	string line;
	int row = 0;
	int col = 0;
	while ( file.good() )
	{
	     getline ( file, line);
	     if(row != 0)  // avaiding the header
	     {
	    	 if(line.length() > 1 )  // avaoding the empty lines
	    	 {
			 stringstream ss(line);
			 string token;
			 col = 1;
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
	nFactors = nFactors -1;

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
	multimap<double,int>::iterator it;

	for(int row = 1; row <= nRows ; row++)
	{
		map_Rank.insert(pair<double,int>(dDataArray_noclean[row][nFactors+1],row));
	}

	if(map_Rank.size() != nRows)
	{
		cout << " Something wrong in clean data! mapsize ="<<map_Rank.size()<<" nRows="<<nRows<<endl;
		return false;
	}

	double dUpperCut =0;
	double dLowerCut =0;

	int iRow=0;
	for (it=map_Rank.begin(); it!=map_Rank.end(); ++it)
	 {
		if(iRow <= nRows*LOWER_CUT)
			dLowerCut = it->first;

		if(iRow <= nRows*UPPER_CUT)
			dUpperCut = it->first;

		iRow++;
	 }

	cout << " Upper cut="<<dUpperCut<<" Lower cut="<<dLowerCut<<endl;


	int cleanedRows = 1;
	for(int row =1; row <= nRows; row++)
	{
		if( dDataArray_noclean[row][nFactors+1] < dUpperCut && dDataArray_noclean[row][nFactors+1] > dLowerCut)
			continue;

		for(int col = 1; col <= nFactors ; col++ )
		{
			dDataArray[cleanedRows][col] = dDataArray_noclean[row][col];
		}
		if(dDataArray_noclean[row][nFactors+1] > (dUpperCut - 0.0000001))
			dDataArray[cleanedRows][nFactors+1] = 1;
		else
			dDataArray[cleanedRows][nFactors+1] = -1;

		cleanedRows++;

	}

	nRows = cleanedRows-1;

	cout << " After cleaning nRows ="<< nRows << endl;

	return true;
}

bool RankAndSetQuantiles()
{

	for(int col =1 ; col <= nFactors ; col++) // going factor by factor
	{
		multimap <double, int> map_Rank;
		multimap<double,int>::iterator it;
		for(int row = 1; row <= nRows ; row++)
		{
			map_Rank.insert(pair<double,int>(dDataArray[row][col],row));
		}

		//cout << "Factor = "<< col << " Map size =" << map_Rank.size()<< endl;

		if(map_Rank.size() != nRows)
		{
			cout << "Something wrong! mapsize= "<< map_Rank.size() << " rows found =" << nRows<< endl;
			return false;
		}
		// now we have the ranked map

		//print map
		 //for (it=map_Rank.begin(); it!=map_Rank.end(); ++it)
		 //   cout << it->first << " => " << it->second << '\n';

		 // we will just assign the quantile number in the sells, no need the actual data.
		 // first 1/2  -1, last 1/2 +1
		int curRow=1;
		 for (it=map_Rank.begin(); it!=map_Rank.end(); ++it)
		 {
			 //first 30%
			 if(curRow <= nRows/2)
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

	double initWeight = 1/(double)nRows;
	for (int row=1 ;row <= nRows ; row++)
		{
			dDataArray[row][nFactors+2] = initWeight;
		}
	return true;
}




bool printDataArray()
{
	for(int i=1;i <= nRows; i++)
	{
		for (int j=1 ;j <= nFactors+2 ; j++)  // target and weight
		{
			cout << dDataArray[i][j] << ",";
		}
		cout<<endl;
	}
	return true;
}

bool printTestDataArray()
{
	for(int i=1;i <= nTestRows; i++)
	{
		for (int j=1 ;j <= nFactors+2 ; j++)  // target and predicted
		{
			cout << dTestDataArray[i][j] << ",";
		}
		cout<<endl;
	}
	return true;
}

bool printWeakClassifiersMap()
{

	for (it_mwc=mapWeakClassifiers.begin(); it_mwc!=mapWeakClassifiers.end(); ++it_mwc)
	{
		vector<double> vecTemp = it_mwc->second;

		cout<<it_mwc->first <<"   " ;
		for (std::vector<double>::iterator it = vecTemp.begin() ; it != vecTemp.end(); ++it)
		    std::cout << *it << ",";
		cout<<endl;
	}
	return true;
}


bool FindWeakClassifier()
{
	// creating a array 4xfactors

	double dPosNegWeights[6][100];  // 5 rows..not taking first row/col .. W1+,W1-,W2+,W2-,H(x)

	for(int i=0 ; i < 6 ; i++)  // ionitialize to 0
	{
		for(int j=0 ; j < 100 ; j++)
		{
			dPosNegWeights[i][j] = 0;
		}
	}


	for (int factor=1; factor <= nFactors; factor++)
	{
		for(int row=1; row <= nRows; row++)
		{
			if(dDataArray[row][factor] < 1.5)   // quantile 1
			{
				if(dDataArray[row][nFactors+1] >0)
					dPosNegWeights[1][factor] += dDataArray[row][nFactors+2];
				else
					dPosNegWeights[2][factor] += dDataArray[row][nFactors+2];
			}
			else  // quantile 2
			{
				if(dDataArray[row][nFactors+1] >0)
					dPosNegWeights[3][factor] += dDataArray[row][nFactors+2];
				else
					dPosNegWeights[4][factor] += dDataArray[row][nFactors+2];

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
	multimap<double,int>::iterator it_wc;

	for(int factor=1 ; factor <= nFactors ; factor++)
	{

		dPosNegWeights[5][factor] = sqrt(dPosNegWeights[1][factor]*dPosNegWeights[2][factor])
										+ sqrt(dPosNegWeights[3][factor]*dPosNegWeights[4][factor]) ;

		map_wc.insert(pair<double,int>(dPosNegWeights[5][factor],factor));
	}

	// find the weakest clasifier

	it_wc = map_wc.begin();
	int weakestClassifier = it_wc->second;
	vector<double> vecTemp;

	// calculate hx for quantile 1 nad 2 anp append to the map

	double hx1 = 0.5 * log(
							(dPosNegWeights[1][weakestClassifier] + 1/(double)nRows)
							/ (dPosNegWeights[2][weakestClassifier] + 1/(double)nRows)
							) ;
	double hx2 = 0.5 * log(
							(dPosNegWeights[3][weakestClassifier] + 1/(double)nRows)
							/ (dPosNegWeights[4][weakestClassifier] + 1/(double)nRows)
							);

	vecTemp.push_back (hx1);  //
	vecTemp.push_back (hx2);

	mapWeakClassifiers.insert(pair< int,vector<double> >(weakestClassifier,vecTemp));
	iLatestWeakClassifier = weakestClassifier;
	dLatestHx1 = hx1;
	dLatestHx2 = hx2;
	//printWeakClassifiersMap();
	//cout << "Weak classifier for this iteration : factor ="<<weakestClassifier << " hx1=" << hx1 << " hx2=" << hx2 << endl;
	return true;
}


bool AdjustWeights()
{

	for(int row = 1; row <= nRows; row++)
	{
		double dy = dDataArray[row][nFactors+1];
		double dHx =0;

		if(dDataArray[row][iLatestWeakClassifier] < 1.5)  // Q1
		{
			dHx = dLatestHx1;
		}
		else  // Q2
		{
			dHx = dLatestHx2;
		}
		//cout << " dy="<< dy << " dHx="<< dHx << " exp value = " << exp(-1*dy*dHx)<<endl;
		dDataArray[row][nFactors+2] *= exp(-1*dy*dHx);

	}

return true;
}

bool LoadTestingData(char *filepath)
{
	ifstream file;
	file.open (filepath, std::ifstream::in);

	string line;
	int row = 0;
	int col = 0;
	while ( file.good() )
	{
	     getline ( file, line);
	     if(row != 0)  // avaiding the header
	     {
	    	 if(line.length() > 1 )  // avoding the empty lines
	    	 {
			 stringstream ss(line);
			 string token;
			 col = 1;
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
	for(int col =1 ; col <= nFactors ; col++) // going factor by factor
		{
			multimap <double, int> map_Rank;
			multimap<double,int>::iterator it;
			for(int row = 1; row <= nTestRows ; row++)
			{
				map_Rank.insert(pair<double,int>(dTestDataArray[row][col],row));
			}

			//cout << "Factor = "<< col << " Map size =" << map_Rank.size()<< endl;

			if(map_Rank.size() != nTestRows)
			{
				cout << "Something wrong! TEST mapsize= "<< map_Rank.size() << " rows found =" << nTestRows<< endl;
				return false;
			}
			// now we have the ranked map

			//print map
			 //for (it=map_Rank.begin(); it!=map_Rank.end(); ++it)
			 //   cout << it->first << " => " << it->second << '\n';

			 // we will just assign the quantile number in the sells, no need the actual data.
			 // first 1/2  -1, last 1/2 +1
			int curRow=1;
			 for (it=map_Rank.begin(); it!=map_Rank.end(); ++it)
			 {
				 //first 30%
				 if(curRow <= nTestRows/2)
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

	for(int row = 1; row <= nTestRows ; row++)
		{
			double dStrongClassifier = 0;
		for (it_mwc=mapWeakClassifiers.begin(); it_mwc!=mapWeakClassifiers.end(); ++it_mwc)
			{
				//vector<double> vecTemp = it_mwc->second;

				if(dTestDataArray[row][it_mwc->first] < 1.5 )  // Q1
				{
					dStrongClassifier += it_mwc->second[0];
				}
				else  // Q2
				{
					dStrongClassifier += it_mwc->second[1];
				}

			}

			if (dStrongClassifier < 0.000001 )
				dTestDataArray[row][nFactors+2] = -1;
			else
				dTestDataArray[row][nFactors+2] = 1;

		}
	return true;
}


bool CalculateAccuracy()
{

	//printTestDataArray();
	int iCorrectPredictions =0;
	for(int row = 1; row <= nTestRows ; row++)
		{
			if( fabs(dTestDataArray[row][nFactors+1] - dTestDataArray[row][nFactors+2] ) < 0.00001  )
				iCorrectPredictions++;
		}

	cout << " Accuracy = " << (iCorrectPredictions/(double)nTestRows) *100 <<"%"<<endl;

	return true;
}






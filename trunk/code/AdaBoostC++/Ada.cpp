#include "Ada.h"

int main()
{

	LoadUncleanedTrainingData("/export/home/snadaraj/AdaBoost/oridata_train2.csv");
	CleanTrainingData();

	//LoadTrainingData("/export/home/snadaraj/AdaBoost/oridata_train.csv");
	RankAndSetQuantiles();
	//printDataArray();
	InitializeWeights();
	//printDataArray();


	for(int i=0 ; i < ITERATIONS;i++)
	{
		FindWeakClassifier();
		AdjustWeights();
	}

	//printDataArray();

	// testing/ using the model

	LoadTestingData("/export/home/snadaraj/AdaBoost/oridata_test.csv");
	RankAndSetQuantilesForTestData();
	ApplyStrongClassifier();
	CalculateAccuracy();

	return 1;
}

//*
//#define DEBUG
#define OS_WINDOWS
#define SEED 1425281365

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#ifdef OS_WINDOWS
#include <sys\timeb.h>
#else
#include <sys/time.h>
#endif

int sudoku[9][9], success[9][9] = { 0 }, heuristics[9][9] = { 10 }, candidates[9][9][9] = { 0 };

int solveDF(int, int);
int solveURWALK(int, int);
int solveURWALKRestart(int, int);

typedef int (*PFSOLVER)(int, int);
//PFSOLVER pfsolve = &solveDF;
//PFSOLVER pfsolve = &solveURWALK;
PFSOLVER pfsolve = &solveURWALKRestart;

int validRow(int row, int num)
{
	int column;
	for (column = 0; column < 9; column++)
		if (sudoku[row][column] == num)
			return 0;
	return 1;
}

int validColumn(int column, int num)
{
	int row;
	for (row = 0; row < 9; row++)
		if (sudoku[row][column] == num)
			return 0;
	return 1;
}

int validZone(int row, int column, int num)
{
	row = (row / 3) * 3;
	column = (column / 3) * 3;
	int r, c;
	for (r = 0; r < 3; r++)
		for (c = 0; c < 3; c++)
			if (sudoku[row + r][column + c] == num)
				return 0;
	return 1;
}

int validateTest()
{
	int i, j, k;
	for (i = 0; i < 9; i++)
	{
		for (j = 0; j < 9; j++)
		{
			if (sudoku[i][j] != 0) {
				//remaining row				
				for (k = j + 1; k < 9; k++)
				{
					if (sudoku[i][j] == sudoku[i][k])
					{
						printf("Duplicate value {%d}: [%d, %d], [%d, %d]\n", sudoku[i][j], i + 1, j + 1, i + 1, k + 1);
						return 0;
					}
				}
				//remaining column
				for (k = i + 1; k < 9; k++)
				{
					if (sudoku[i][j] == sudoku[k][j])
					{
						printf("Duplicate value {%d}: [%d, %d], [%d, %d]\n", sudoku[i][j], i + 1, j + 1, k + 1, j + 1);
						return 0;
					}
				}
				//remaining zone
				int zi = (i / 3) * 3;
				int zj = (j / 3) * 3;
				int r = i % 3, c = j % 3 + 1;
				if (c % 3 == 0)
				{
					r++;
					c = 0;
				}
				for (; r < 3; r++)
				{
					for (; c < 3; c++)
					{
						if (sudoku[i][j] == sudoku[zi + r][zj + c])
						{
							printf("Duplicate value {%d}: [%d, %d], [%d, %d]\n", sudoku[i][j], i + 1, j + 1, zi + r + 1, zj + c + 1);
							return 0;
						}
					}
					c = 0;
				}
			}
		}
	}
}

int step(int row, int column)
{
	if (column < 8)
		return pfsolve(row, column + 1);
	else
		return pfsolve(row + 1, 0);
}

void displayResult(int solved)
{
	if (solved == 1)
	{
		printf("Solved\n");
		int row, column;
		for (row = 0; row < 9; row++)
		{
			for (column = 0; column < 9; column++)
				printf("%d ", success[row][column]);
			printf("\n");
		}
	}
	else
	{
		printf("Unsolved\n");
	}
}

void solve1H()
{
	int any, row, column;
	do
	{
		any = 0;
		for (row = 0; row < 9; row++)
		{
			for (column = 0; column < 9; column++)
			{
				if (sudoku[row][column] != 0)
				{
					heuristics[row][column] = 0;
				}
				else
				{
					int n = heuristicFunc(row, column);
					if (n == 1)
					{
						sudoku[row][column] = candidates[row][column][0];
						heuristics[row][column] = 0;
						any++;
					}
					else 
					{
						heuristics[row][column] = n;
					}
				}
			}
		}
	} while (any > 0);
}

int solveDF(int row, int column)
{
	if (row > 8)
	{
		memcpy(success, sudoku, sizeof(success));
		return 1;
	}

	if (sudoku[row][column] != 0)
	{
		return step(row, column);
	}
	else
	{
		int i;
		for (i = 1; i <= 9; i++)
		{
			if ((validRow(row, i) == 1) && (validColumn(column, i) == 1) && (validZone(row, column, i) == 1))
			{
				sudoku[row][column] = i;
				if (step(row, column) == 1)
					return 1;
			}
		}
		sudoku[row][column] = 0;
		return 0;
	}
}

int solveURWALK(int row, int column)
{
	if (row > 8)
	{
		memcpy(success, sudoku, sizeof(success));
		return 1;
	}

	if (sudoku[row][column] != 0)
	{
		return step(row, column);
	}
	else
	{
		int i;
		int offset = rand() % 9;
		for (i = 0; i < 9; i++)
		{
			int r = (i + offset) % 9 + 1;
			if ((validRow(row, r) == 1) && (validColumn(column, r) == 1) && (validZone(row, column, r) == 1))
			{
				sudoku[row][column] = r;
				solve1H();
				return step(row, column);
			}
		}

		return 0;
	}
}

int solveURWALKRestart(int row, int column)
{
	if (row > 8)
	{
		memcpy(success, sudoku, sizeof(success));
		return 1;
	}

	if (sudoku[row][column] != 0)
	{
		return step(row, column);
	}
	else
	{
		int i;
		int offset = rand() % 9;
		int restart[9][9];
		memcpy(restart, sudoku, sizeof(restart));
		for (i = 0; i < 9; i++)
		{
			if (i > 0)
				memcpy(sudoku, restart, sizeof(sudoku));
			int r = (i + offset) % 9 + 1;
			if ((validRow(row, r) == 1) && (validColumn(column, r) == 1) && (validZone(row, column, r) == 1))
			{
				sudoku[row][column] = r;
				solve1H();
				if (step(row, column) == 1)
					return 1;
			}
		}
		
		return 0;
	}
}

int isSolved()
{
	int row, column;
	for (row = 0; row < 9; row++)
	{
		for (column = 0; column < 9; column++)
		{
			if (heuristics[row][column] > 0)
				return 0;
		}
	}

	return 1;
}

int getMostHeuristic(int *locRow, int *locColumn)
{
	int most = 10;
	int row, column;
	int current, move;
	for (row = 0; row < 9; row++)
	{
		for (column = 0; column < 9; column++)
		{
			current = heuristics[row][column];
			if (current > 0)
			{
				move = 0;
				if (most > current)
					move = 1;
				else if (most == current)
				{
					if (rand() % 2 == 1)
						move = 1;
				}

				if (move == 1)
				{
					most = current;
					*locRow = row;
					*locColumn = column;
				}
			}
		}
	}	

	return most;
}

int solveGreedy()
{
	if (isSolved() == 1)
	{
		memcpy(success, sudoku, sizeof(success));
		return 1;
	}
	else
	{
		solve1H();
	}
			
	int hRow, hColumn;
	int i;
	int restart[9][9];

	int most = getMostHeuristic(&hRow, &hColumn);	
	while (most > 0 && most < 10)
	{		
		memcpy(restart, sudoku, sizeof(restart));
		for (i = 0; i < most; i++)
		{
			if (i > 0)
				memcpy(sudoku, restart, sizeof(sudoku));
			sudoku[hRow][hColumn] = candidates[hRow][hColumn][i];
			if (solveGreedy() == 1)
				return 1;
		}
	}
	
	return 0;
}

int heuristicFunc(int row, int column)
{	
	int i, n = 0;
	for (i = 1; i <= 9; i++)
	{
		if ((validRow(row, i) == 1) && (validColumn(column, i) == 1) && (validZone(row, column, i) == 1))
		{
			candidates[row][column][n++] = i;
		}		
	}
	
	return n;
}

int tests[6][9][9] =
{
	{
		{ 5, 3, 0, 0, 7, 0, 0, 0, 0 },
		{ 6, 0, 0, 1, 9, 5, 0, 0, 0 },
		{ 0, 9, 8, 0, 0, 0, 0, 0, 0 },
		{ 8, 0, 0, 0, 6, 0, 0, 0, 3 },
		{ 4, 0, 0, 8, 0, 3, 0, 0, 1 },
		{ 7, 0, 0, 0, 2, 0, 0, 0, 6 },
		{ 0, 6, 0, 0, 0, 0, 2, 8, 0 },
		{ 0, 0, 0, 4, 1, 9, 0, 0, 5 },
		{ 0, 0, 0, 0, 8, 0, 0, 7, 9 },
	},
	{
		{ 0, 0, 0, 8, 9, 6, 0, 0, 0 },
		{ 0, 7, 5, 0, 0, 0, 1, 0, 0 },
		{ 3, 0, 0, 0, 0, 0, 4, 0, 0 },
		{ 6, 0, 0, 1, 0, 0, 0, 0, 0 },
		{ 0, 2, 7, 0, 0, 0, 3, 1, 0 },
		{ 0, 0, 0, 0, 0, 5, 0, 0, 4 },
		{ 0, 0, 6, 0, 0, 0, 0, 0, 8 },
		{ 0, 0, 4, 0, 0, 0, 9, 7, 0 },
		{ 0, 0, 0, 2, 6, 3, 0, 0, 0 },
	},
	{
		{ 7, 9, 0, 0, 0, 0, 3, 0, 0 },
		{ 0, 0, 0, 0, 0, 6, 9, 0, 0 },
		{ 8, 0, 0, 0, 3, 0, 0, 7, 6 },
		{ 0, 0, 0, 0, 0, 5, 0, 0, 2 },
		{ 0, 0, 5, 4, 1, 8, 7, 0, 0 },
		{ 4, 0, 0, 7, 0, 0, 0, 0, 0 },
		{ 6, 1, 0, 0, 9, 0, 0, 0, 8 },
		{ 0, 0, 2, 3, 0, 0, 0, 0, 0 },
		{ 0, 0, 9, 0, 0, 0, 0, 5, 4 },
	},
	{
		{ 0, 0, 2, 8, 0, 7, 9, 0, 0 },
		{ 0, 4, 0, 0, 0, 0, 0, 1, 0 },
		{ 8, 0, 0, 0, 1, 0, 0, 0, 7 },
		{ 7, 0, 0, 1, 0, 5, 0, 0, 9 },
		{ 0, 0, 9, 0, 0, 0, 6, 0, 0 },
		{ 2, 0, 0, 3, 0, 6, 0, 0, 8 },
		{ 1, 0, 0, 0, 8, 0, 0, 0, 6 },
		{ 0, 6, 0, 0, 0, 0, 0, 4, 0 },
		{ 0, 0, 4, 2, 0, 9, 1, 0, 0 },
	},
	{
		{ 0, 3, 5, 1, 0, 6, 0, 0, 9 },
		{ 0, 6, 9, 0, 0, 3, 7, 8, 0 },
		{ 0, 0, 1, 0, 2, 9, 3, 5, 0 },
		{ 0, 9, 0, 7, 5, 0, 0, 3, 4 },
		{ 5, 2, 8, 0, 9, 0, 0, 6, 0 },
		{ 7, 0, 0, 0, 1, 8, 0, 9, 2 },
		{ 3, 0, 0, 2, 0, 7, 9, 0, 5 },
		{ 9, 5, 2, 4, 0, 0, 6, 0, 0 },
		{ 6, 0, 0, 9, 3, 0, 2, 0, 8 },
	},
	{
		{ 0, 0, 8, 3, 4, 2, 9, 0, 0 },
		{ 0, 0, 9, 0, 0, 0, 7, 0, 0 },
		{ 4, 0, 0, 0, 0, 0, 0, 0, 3 },
		{ 0, 0, 6, 4, 7, 3, 2, 0, 0 },
		{ 0, 3, 0, 0, 0, 0, 0, 1, 0 },
		{ 0, 0, 2, 8, 5, 1, 6, 0, 0 },
		{ 7, 0, 0, 0, 0, 0, 0, 0, 8 },
		{ 0, 0, 4, 0, 0, 0, 1, 0, 0 },
		{ 0, 0, 3, 6, 9, 7, 5, 0, 0 },
	}
};

double getMillisecons()
{
#ifdef OS_WINDOWS
	struct timeb now;	
	ftime(&now);
	return 1000.0 * now.time + now.millitm;
#else
	timeval* t;
	gettimeofday(&t, NULL);
	return 1000.0 * t.tv_sec + t.tv_usec / 1000.0;
#endif
}

int main(const char** args)
{
	srand(SEED);

	int i;
	for (i = 0; i < 6; i++)
	{
		memcpy(sudoku, tests[i], sizeof(sudoku));
		if (validateTest() == 0)
		{
			printf("Invalid initialization as above.\n");
			return;
		}

		solve1H();

		double start = getMillisecons();
		//urwalk
		//int solved = pfsolve(0, 0);
		//gready
		int solved = solveGreedy();
		double end = getMillisecons();
		displayResult(solved);
		printf("#%d: duration(s) - %lf\n\n", i + 1, end - start);

		memset(heuristics, 0, sizeof(heuristics));
		memset(candidates, 0, sizeof(candidates));
	}
}
//*/


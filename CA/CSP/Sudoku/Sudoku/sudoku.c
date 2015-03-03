//#define DEBUG
#define OS_WINDOWS
#define SEED 1425281365

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#ifdef OS_WINDOWS
#include <sys\timeb.h>
#else
#include <sys/time.h>
#endif

//data
static int sudoku[9][9], success[9][9] = { 0 }, heuristics[9][9] = { 10 }, candidates[9][9][9] = { 0 };

//solver facade
int solveDF();
int solveURWalk();
int solveURWalkRestart();
int solveGreedy();

//helper
static int validateTest();
static int validRow(int row, int num);
static int validColumn(int column, int num);
static int validZone(int row, int column, int num);
static void displayResult(int solved);
static double getMillisecons();
static void debugRun(int mode);

//solver backbone
static int solveDFInternal(int, int);
static int solveURWalkInternal(int, int);
static int solveURWalkRestartInternal(int, int);
static void solveHeuristic();
static int isSolved();
static int getMostHeuristic(int *locRow, int *locColumn);
static int heuristicFunc(int row, int column);

//main
int main(int argc, char *argv[])
{
	srand(SEED);

#ifdef DEBUG
	//readInput("E:\Self\\xKE\\Semester 5\\CSP\\Assigment1\\Sample\\sudoku-eg1.txt");
	//debugRun(0);
	//debugRun(1);
	//debugRun(2);
	debugRun(3);
	return;
#endif

	if (argc < 2)
	{
		printf("Usage: \n\tsudoku <sudoku-input-file.txt>\n");
		return 0;
	}
	if (readInput(argv[1]) != 1)
	{
		return 0;
	}
	if (validateTest() == 0)
	{
		printf("Invalid test case.\n");
		return 0;
	}

	//double start = getMillisecons();
	solveHeuristic();
	int solved = solveDF();
	//double end = getMillisecons();
	displayResult(solved, argv[1]);
	//printf("#%d: duration(s) - %lf\n\n", i + 1, end - start);	
}

int readInput(char* path)
{
	char line[100];
	FILE *file;
	file = fopen(path, "r");
	if (file == NULL)
	{
		printf("Error opening file\n");
		return 0;
	}

	int i, row = 0, column;
	while (row < 9 && fgets(line, 100, file) != NULL)
	{
		if (line[0] == '#')
			continue;

		i = 0;
		column = 0;
		while (column < 9 && line[i] != '\0')
		{
			if (line[i] == '_')
			{
				sudoku[row][column] = 0;
				column++;
			}
			else if (isdigit(line[i]))
			{
				sudoku[row][column] = line[i] - '0';
				column++;
			}	

			i++;
		}
		row++;
	}
		
	fclose(file);
	return 1;	
}

void debugRun(int mode)
{
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

	int i;
	char strMode[2] = { 0 };
	for (i = 0; i < 6; i++)
	{
		memcpy(sudoku, tests[i], sizeof(sudoku));
		if (validateTest() == 0)
		{
			printf("Invalid initialization as above.\n");
			continue;
		}
		
		int solved;
		double start = getMillisecons();
		solveHeuristic();
		switch (mode)
		{
		case 1:			
			solved = solveURWalk();
			break;
		case 2:
			solved = solveURWalkRestart();
			break;
		case 3:
			solved = solveGreedy();
			break;
		default:
			solved = solveDF();
			break;
		}
		double end = getMillisecons();

		strMode[0] = mode + '0';
		displayResult(solved, strMode);
		printf("#%d: duration(s) - %lf\n\n", i + 1, end - start);

		memset(heuristics, 0, sizeof(heuristics));
		memset(candidates, 0, sizeof(candidates));
	}
}


/////////////////////////////////////////////////
///Implementations - BEGIN
int solveDF()
{
	return solveDFInternal(0, 0);
}
int solveURWalk()
{
	return solveURWalkInternal(0, 0);
}
int solveURWalkRestart()
{
	return solveURWalkRestartInternal(0, 0);
}

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

void displayResult(int solved, char* file)
{
	if (solved == 1)
	{
		printf("# %s: satisfiable solution\n", file);
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
		printf("# %s: unsolved\n", file);
	}
}

void solveHeuristic()
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

int solveDFInternal(int row, int column)
{
	if (column > 8)
	{
		row++;
		column = 0;
	}

	if (row > 8)
	{
		memcpy(success, sudoku, sizeof(success));
		return 1;
	}

	if (sudoku[row][column] != 0)
	{
		return solveDFInternal(row, column + 1);
	}
	else
	{
		int i;
		for (i = 1; i <= 9; i++)
		{
			if ((validRow(row, i) == 1) && (validColumn(column, i) == 1) && (validZone(row, column, i) == 1))
			{
				sudoku[row][column] = i;
				if (solveDFInternal(row, column + 1) == 1)
					return 1;
			}
		}
		sudoku[row][column] = 0;
		return 0;
	}
}

int solveURWalkInternal(int row, int column)
{
	if (column > 8)
	{
		row++;
		column = 0;
	}

	if (row > 8)
	{
		memcpy(success, sudoku, sizeof(success));
		return 1;
	}

	if (sudoku[row][column] != 0)
	{
		return solveURWalkInternal(row, column + 1);
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
				solveHeuristic();
				return solveURWalkInternal(row, column + 1);
			}
		}

		return 0;
	}
}

int solveURWalkRestartInternal(int row, int column)
{
	if (column > 8)
	{
		row++;
		column = 0;
	}
	
	if (row > 8)
	{
		memcpy(success, sudoku, sizeof(success));
		return 1;
	}

	if (sudoku[row][column] != 0)
	{
		return solveURWalkRestartInternal(row, column + 1);
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
				solveHeuristic();
				if (solveURWalkRestartInternal(row, column + 1) == 1)
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
		solveHeuristic();
	}

	int hRow, hColumn;
	int i;
	int restart[9][9];

	int most = getMostHeuristic(&hRow, &hColumn);
	while (most > 1 && most < 10)
	{
		memcpy(restart, sudoku, sizeof(restart));
		int r, offset = rand() % most;
		for (i = 0; i < most; i++)
		{
			if (i > 0)
				memcpy(sudoku, restart, sizeof(sudoku));

			r = (i + offset) % most;
			sudoku[hRow][hColumn] = candidates[hRow][hColumn][r];
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
///Implementations - END
